var zmq = require('zmq'),
    sock = zmq.socket('rep');
var r = require('rethinkdb');

sock.bindSync('tcp://172.16.42.1:3003');
console.log('storage relay on 3003')

  sock.on('message', function(data){
    var message = JSON.parse(data)
    console.log(message)
    var payload = message.payload
    var fullname = message.username+"/"+message.scriptname

    r.connect({host:'localhost', port:28015, db:'cointhink'},
      function(err, conn) {
        r.table('scripts').get(fullname).run(conn, function(err, doc){
          if(doc && doc.key == message.key){
            sock.send(JSON.stringify({"status":"ok"}))
          }
        })
      }
    )

  })
