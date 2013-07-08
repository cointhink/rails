var zmq = require('zmq'),
    sock = zmq.socket('push');
var websocket = require('websocket'),
    redis = require('redis').createClient()

var WebSocketClient = require('websocket').client;
var ws = new WebSocketClient();

sock.bindSync('tcp://172.16.42.1:3001');
console.log('zeromq push bound to port 3001');

var riemann = require('riemann').createClient({ host: 'localhost', port: 5555 })
var use_riemann = false
riemann.tcp.socket.on('error', function(e){ console.warn("Riemann TCP error: "+e.message)})
riemann.tcp.socket.on('connect', function(){ use_riemann = true; console.log("riemann connected")})

ws.on('connectFailed', function(error) {
    console.log('Connect Error: ' + error.toString());
});

var old_message_count, message_count = 0;
var old_message_date = new Date();

ws.on('connect', function(connection) {
    console.log('mtgox websocket connected');
    connection.on('error', function(error) {
        console.log("Connection Error: " + error.toString());
    });
    connection.on('close', function() {
        console.log('echo-protocol Connection Closed');
    });
    connection.on('message', function(message) {
        if (message.type === 'utf8') {
          packet = JSON.parse(message.utf8Data)
          console.log(packet.ticker.last)
          message_count += 1
          var ticker = packet["ticker"]
          zmq_send(ticker)
          redis_ticker(ticker)
        }
    });
})

setInterval(function(){
  riemann_send(message_count)
  if(old_message_count == message_count){
    var stable_time = ((new Date()) - old_message_date)/1000
    if(stable_time > 120) {
      console.log('mps rate has been at '+message_count+' for '+stable_time+' seconds!')
      process.exit(1)
    }
  } else {
    console.log((new Date())+' messages per second '+message_count)
    old_message_count = message_count
    old_message_date = new Date()
  }
  message_count = 0
}, 1000)

function zmq_send(packet){
  var data = JSON.stringify(packet)
  sock.send(data)
}

function redis_ticker(ticker){
  var hash_name = 'mtgox-ticker-'+ticker.item+ticker.last.currency
  console.log('set '+hash_name+' ')
  redis.hset(hash_name, 'value', ticker.last.value)
  redis.hset(hash_name, 'now', (new Date(ticker.now/1000)).toISOString())
}

function riemann_send(count) {
  if(use_riemann){
    riemann.send(riemann.Event({
      service: 'mtgox',
      metric: count
    }))
  }
}

ws.connect('ws://websocket.mtgox.com:80/?Channel=ticker.BTCUSD', null,  "http://websocket.mtgox.com");


