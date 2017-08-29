+ SatieOSC {
	setResponderAddress {| addr |
		if(satie.satieConfiguration.debug, {"% addy: %".format(this.class.getBackTrace, addr).postln;});
		this.oscClientPort = addr;
		responder = addr;
		if(satie.satieConfiguration.debug,
			{"% addy after: %, responder: %".format(this.class.getBackTrace, this.oscClientPort, responder).postln;}
		);
	}

	getAudioPlugins {
		^{ | args, time, addr, recvPort |
			var json;
			if(satie.satieConfiguration.debug, {"% arguments: %".format(this.class.getBackTrace, args).postln;});
			this.setResponderAddress(addr);
			json = satie.inspector.getInstancesJSON();
			if(satie.satieConfiguration.debug, {"% json: %".format(this.class.getBackTrace, json).postln;});
			responder.sendMsg("/plugins", json);
		}
	}

	getPluginArguments {
		^{| args, time, addr, recvPort |
			var pluginName, json;
			pluginName = args[1];
			if(satie.satieConfiguration.debug, {"% arguments: %".format(this.class.getBackTrace, args).postln;});
			this.setResponderAddress(addr);
			json = satie.inspector.getInstanceInfoJSON(pluginName);
			responder.sendMsg("/arguments", json);
		}
	}
}