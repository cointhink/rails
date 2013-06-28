var bouncy = require('bouncy');
var r = require('rethinkdb');
var fs = require('fs');
var path = require('path');
var iso8601 = require('iso8601');

var server = bouncy(function (req, res, bounce) {
  var parts = req.url.split('/');
  var username = parts[1]
  var scriptname = parts[2]
  var key = parts[3]

  console.log(req.method+" "+req.url)
 if((username == 'npm' || username == 'dist') && key == null) {
    console.log('fetching npm '+scriptname)
    res.statusCode = 200;
    res.end(fs.readFileSync('npm/'+path.basename(scriptname)));
  } else {
    var fullname = username+'/'+scriptname
    console.log((new Date())+' loading '+fullname)
    r.connect({host:'localhost', port:28015, db:'cointhink'},
      function(err, conn) {
        r.table('scripts').get(fullname).run(conn, function(err, doc){
          if(doc) {
            if(doc.key == key) {
              res.statusCode = 200;
              // Authorized
              if(req.method == 'GET') {
                console.log('serving script '+fullname)
                res.end(doc.body);
              }
              if(req.method == 'POST') {
                req.on("data",function(data){
                  var sig_doc = {}
                  sig_doc.name = username+'/'+scriptname
                  sig_doc.time = (new Date()).toISOString()
                  sig_doc.type = parts[4]
                  sig_doc.msg = data.toString('utf8')
                  console.log('rethink insert '+JSON.stringify(sig_doc))
                  r.table('signals').insert(sig_doc).run(conn, function(err, doc){
                    if(err){
                      res.end({error: err});
                    } else {
                      res.end(JSON.stringify(doc));
                    }
                  })
                })
              }
            } else {
              res.statusCode = 403;
              res.end(JSON.stringify({error: "bad key"}));

            }
          } else {
            res.statusCode = 403;
            res.end(JSON.stringify({error: "not found"}));
          }
        })
      }
    )
  }
});
console.log("listening on 3002")
server.listen(3002);

