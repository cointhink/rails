var bouncy = require('bouncy');
var r = require('rethinkdb');

var server = bouncy(function (req, res, bounce) {
  var parts = req.url.split('/');
  var username = parts[1]
  var scriptname = parts[2]
  var key = parts[3]

  console.log(req.method+" "+req.url)
  console.log('fetching '+username+'/'+scriptname)
  r.connect({host:'localhost', port:28015, db:'cointhink'},
    function(err, conn) {
      r.table('scripts').get(username+'/'+scriptname).run(conn, function(err, doc){
        if(doc) {
          if(doc.key == key) {
            res.statusCode = 200;
            res.end(doc.body);
          } else {
            res.statusCode = 403;
            res.end(JSON.stringify({error: "bad key"}));

          }
        } else {
          res.statusCode = 403;
          res.end(JSON.stringify({error: "not found"}));
        }
      })
    })
});
console.log("listening on 3002")
server.listen(3002);

