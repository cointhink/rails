var zmq = require('zmq'),
    sock = zmq.socket('push');
var websocket = require('websocket');

var WebSocketClient = require('websocket').client;
var ws = new WebSocketClient();

sock.bindSync('tcp://172.16.42.1:3001');
console.log('event_relay zmq push bound to port 3001');

ws.on('connectFailed', function(error) {
    console.log('Connect Error: ' + error.toString());
});

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
          console.log(message.utf8Data)
          sock.send(message.utf8Data)
        }
    });
})

ws.connect('ws://websocket.mtgox.com:80/?Channel=ticker.BTCUSD', null,  "http://websocket.mtgox.com");


