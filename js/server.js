var bouncy = require('bouncy');

var server = bouncy(function (req, res, bounce) {
  console.log(req.method+" "+req.url)
  if (req.url.substr(0,5) == '/api/') {
      bounce(8000);
  } else {
      bounce(3000);
  }
});
console.log("listening on 3001")
server.listen(3001);

