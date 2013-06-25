var zmq = require('zmq'),
    sock = zmq.socket('rep');
var r = require('rethinkdb');

sock.bindSync('tcp://172.16.42.1:3003');
console.log('storage relay on 3003')

sock.on('message', function(data){
  try {
    var message = JSON.parse(data)
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
                  var value = storage[payload.key]
                  console.log(fullname+' get '+payload.key+' '+value)
                  sock.send(JSON.stringify({"status":"ok", "payload":value}))
                }
                if(payload.action == 'set'){
                  console.log(fullname+' set '+payload.key+' '+payload.value)
                  storage[payload.key] = payload.value
                  r.table('scripts').get(fullname).update({storage:storage}).run(conn, function(status){
                    respond({"status":"ok", "payload":status})
                  })
                }
              } else {
                console.log(fullname+" bad key!")
                respond({"status":"badkey"})
              }
            } else {
              console.log(fullname+" empty doc!")
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