+ SatieOSC {
	setResponderAddress {| addr|
		if(satie.satieConfiguration.debug, {"% addy: %".format(this.class.getBackTrace, addr).postln;});
		this.oscClientPort = addr.port;
		this.oscClientIP = addr.ip;
		returnAddress = NetAddr(this.oscClientIP, this.oscClientPort);
		if(satie.satieConfiguration.debug,
			{"% addy after: %, returnAddress: %".format(this.class.getBackTrace, this.oscClientPort, returnAddress).postln;}
		);
		dynamicResponder = false;
	}

	returnAddress{
		^{ | args, time, addr, recvPort |
			var ip, port;
			if (args.size == 3,
				{
					ip = args[1];
					port = args[2];
					this.setResponderAddress(NetAddr(ip.asString, port));
				},
				{"% not enough arguments, should be 2, %".format(this.class.getBackTrace, args).postln;}
			)
		}
	}

	getAudioPlugins {
		^{ | args, time, addr, recvPort |
			var json;
			if(satie.satieConfiguration.debug, {"% arguments: %".format(this.class.getBackTrace, args).postln;});
			if (dynamicResponder,
				{
					this.setResponderAddress(addr);
				}
			);
			json = satie.inspector.getInstancesJSON();
			if(satie.satieConfiguration.debug, {"% json: %".format(this.class.getBackTrace, json).postln;});
			returnAddress.sendMsg("/satie/dump/plugins/audioSources", json);
		}
	}

	getPluginArguments {
		^{| args, time, addr, recvPort |
			var pluginName, json;
			pluginName = args[1];
			if(satie.satieConfiguration.debug, {"% arguments: %".format(this.class.getBackTrace, args).postln;});
			if (dynamicResponder,
				{
					this.setResponderAddress(addr);
				}
			);
			json = satie.inspector.getInstanceInfoJSON(pluginName);
			returnAddress.sendMsg("/satie/dump/plugins/audioSourceArgs", json);
		}
	}
}