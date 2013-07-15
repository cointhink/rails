var http = require('http');
var r = require('rethinkdb');
var fs = require('fs');
var path = require('path');

r.connect({host:'localhost', port:28015, db:'cointhink'},
  function(err, conn) {
  conn.addListener('error', function(e) {
    console.log("rethinkdb error: "+e)
  })

  conn.addListener('close', function() {
    console.log("rethinkdb closed")
  })

  console.log("rethink connected. http listening on 3002")
  http.createServer(do_request).listen(3002);

  function do_request(req, res){
    var parts = req.url.split('/');
    var username = parts[1]
    var scriptname = parts[2]
    var key = parts[3]

    console.log(req.method+" "+req.url)

    var body = ""

    req.on("readable",function(){
      var data = req.read()
      body += data.toString()
    })

    req.on("close",function(){
      console.log('http client closed early')
    })

    req.on("end",function(){
      console.log(body)
      if((username == 'npm' || username == 'dist') && key == null) {
        console.log('fetching npm '+scriptname)
        res.statusCode = 200;
        respond(fs.readFileSync('npm/'+path.basename(scriptname)));
      } else {
        var fullname = username+'/'+scriptname
        r.table('scripts').get(fullname).run(conn, doc_loaded)
      }

      function doc_loaded (err, doc){
        if(err){
          console.log(err)
          res.statusCode = 403;
          respond(JSON.stringify({error: "not found"}));
        } else {
          if(doc.key == key) {
            // Authorized
            if(req.method == 'GET') {
              console.log('serving script '+fullname)
              respond(doc.body);
            }
            if(req.method == 'POST') {
              do_post()
            }
          } else {
            respond(403, JSON.stringify({error: "bad key"}));
          }
        }

        function do_post(){
          var sig_doc = {}
          sig_doc.name = username+'/'+scriptname
          sig_doc.time = (new Date()).toISOString()
          sig_doc.type = parts[4]
          sig_doc.msg = body
          r.table('signals').insert(sig_doc).run(conn, function(err, doc){
            if(err){
              respond({error: err});
            } else {
              respond(JSON.stringify(doc));
            }
          })
        }

      }

      function respond(status, doc) {
        if(arguments.length == 1) {
          doc = status
        } else {
          res.statusCode = status
        }
        res.end(doc)
      }
    })
  }
})

