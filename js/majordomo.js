var zmq = require('zmq');

function Majordomo(options)
{
	this.requests = zmq.socket('router');
	this.requests.identity = 'majordomo:incoming:' + process.pid;
	this.responders = zmq.socket('dealer');
	this.responders.identity = 'majordomo:outgoing:' + process.pid;
	if (options)
		this.configure(options);
}

Majordomo.prototype.configure = function(options)
{
	var self = this;
	this.config = options;

	this.requests.on('message', function()
	{
		var argl = arguments.length,
			envelopes = Array.prototype.slice.call(arguments, 0, argl - 1),
			payload = arguments[argl - 1];

		console.log('incoming request: ' + payload.toString('utf8'));
		self.responders.send([envelopes, payload]);
	});

	this.requests.bind(options['router'], function(err)
	{
		if (err) console.log(err);
		console.log("router on "+options['router']);
	});

	this.responders.on('message', function()
	{
		var argl = arguments.length,
			envelopes = Array.prototype.slice.call(arguments, 0, argl - 1),
			payload = arguments[argl - 1];

		console.log('incoming response: ' + payload.toString('utf8'));
		self.requests.send([envelopes, payload]);
	});

	this.responders.bind(options['dealer'], function(err)
	{
		if (err) console.log(err);
		console.log("dealer on "+options['dealer']);
	});
}

var majordomo = new Majordomo();
majordomo.configure({
	router: 'tcp://172.16.42.1:3003',
	dealer: 'tcp://127.0.0.1:3004'
});
