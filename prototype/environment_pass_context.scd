(
~satieOSCMaker = { | rootPath = "/satie", port = 18032 |
	var rootURI = rootPath;
	var oscPort = port;
	var e = Environment.make({

		// main OSC method
		~newOSC = {|self, id, cb , path = \default|
			var idsym = id.asSymbol;
			postf("callback passed : %\n", cb);
			OSCdef(idsym, cb, path, recvPort: oscPort);
		};
	});
	e.know = true;
	"satieOSC interface loaded".inform;
	e;
};
)

(
~oscProtocol = { | oscContext |
	var osc = oscContext;
	// var satie = satieContext;
	var e = Environment.make({

		~createSoundSource = { | self, name |
			postf("self: %, name: %\n", self, name);
		};

		~coreCallback = { | msg |
			var url, dest, obj, command, name, synth;
			postf("message: %\n", msg);
			e.createSoundSource(msg[2]);
		};

	}); // Environment.make

	e.know = true;
	postf("passed osc env: %\n", osc);
	osc.newOSC(\satieOSC, e['coreCallback'], "/satie");
	e;
};
)

~osc = ~satieOSCMaker.value();
~protocol = ~oscProtocol.value(~osc);
/*
and then from command line:
oscsend localhost 18032 /satie ss create synth
*/

