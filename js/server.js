var bouncy = require('bouncy');

var server = bouncy(function (req, res, bounce) {
  var port;
  if (req.url.substr(0,5) == '/api/') {
      port = 8000
  } else {
      port = 3000
  }
  bounce(port);
  console.log(port+": "+req.method+" "+req.url)
});
console.log("listening on 3001")
server.listen(3001);

