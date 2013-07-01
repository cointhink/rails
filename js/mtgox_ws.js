var zmq = require('zmq'),
    sock = zmq.socket('push');
var websocket = require('websocket');

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
          var data = JSON.stringify(packet["ticker"])
          sock.send(data)
        }
    });
})

setInterval(function(){
  riemann_send(message_count)
  if(old_message_count != message_count){
    console.log((new Date())+' messages per second '+message_count)
  }
  old_message_count = message_count
  message_count = 0
}, 1000)

function riemann_send(count) {
  if(use_riemann){
    riemann.send(riemann.Event({
      service: 'mtgox',
      metric: count
    }))
  }
}

ws.connect('ws://websocket.mtgox.com:80/?Channel=ticker.BTCUSD', null,  "http://websocket.mtgox.com");


