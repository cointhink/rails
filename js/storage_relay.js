var zmq = require('zmq'),
    sock = zmq.socket('rep');
var r = require('rethinkdb');

sock.bindSync('tcp://172.16.42.1:3003');
console.log('storage relay on 3003')

sock.on('message', function(data){
  try {
    var message = JSON.parse(data)
    console.log(message)
    var payload = message.payload
    var fullname = message.username+"/"+message.scriptname

    r.connect({host:'localhost', port:28015, db:'cointhink'},
      function(err, conn) {
        r.table('scripts').get(fullname).run(conn, function(err, doc){
          if(err){
            console.log(err)
            respond({"status":"dberr"})
          } else {
            if(doc){
              if(doc.key == message.key){
                var storage = doc.storage
                if(payload.action == 'get'){
                  sock.send(JSON.stringify({"status":"ok", "payload":storage[payload.key]}))
                }
                if(payload.action == 'set'){
                  console.log('set '+payload.key+' '+payload.value)
                  storage[payload.key] = payload.value
                  r.table('scripts').get(fullname).update({storage:storage}).run(conn, function(status){
                    respond({"status":"ok", "payload":status})
                  })
                }
              } else {
                console.log("bad key!")
                respond({"status":"badkey"})
              }
            } else {
              console.log("empty doc!")
              respond({"status":"nodoc"})
            }
          }
        })
      }
    )
  } catch (ex) {
    console.log(ex+' ignoring "'+data+'"')
    respond({"status":"garbled"})
  }
})

function respond(payload){
  sock.send(JSON.stringify(payload))
}