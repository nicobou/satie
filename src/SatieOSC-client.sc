+ SatieOSC {
	setResponderAddress {| addr|
		if(satie.config.debug, {"% addy: %".format(this.class.getBackTrace, addr).postln;});
		this.oscClientPort = addr.port;
		this.oscClientIP = addr.ip;
		returnAddress = NetAddr(this.oscClientIP, this.oscClientPort);
		if(satie.config.debug,
			{"% addy after: %, returnAddress: %".format(this.class.getBackTrace, this.oscClientPort, returnAddress).postln;}
		);
		dynamicResponder = false;
	}

	returnAddress {
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
			if(satie.config.debug, {"% arguments: %".format(this.class.getBackTrace, args).postln;});
			if (dynamicResponder,
				{
					this.setResponderAddress(addr);
				}
			);
			json = satie.inspector.getCompiledPluginsJSON();
			if(satie.config.debug, {"% json: %".format(this.class.getBackTrace, json).postln;});
			returnAddress.sendMsg("/plugins", json);
		}
	}

	getPluginArguments {
		^{| args, time, addr, recvPort |
			var pluginName, json;
			pluginName = args[1];
			if(satie.config.debug, {"% arguments: %".format(this.class.getBackTrace, args).postln;});
			if (dynamicResponder,
				{
					this.setResponderAddress(addr);
				}
			);
			json = satie.inspector.getSynthDefInfoJSON(pluginName);
			returnAddress.sendMsg("/arguments", json);
		}
	}

	getPluginDetails {
		^{| args, time, addr, recvPort |
			var pluginName, json;
			pluginName = args[1];
			if(satie.config.debug, {"% arguments: %".format(this.class.getBackTrace, args).postln;});
			if (dynamicResponder,
				{
					this.setResponderAddress(addr);
				}
			);
			json = satie.inspector.getSynthDefParametersJSON(pluginName);
			returnAddress.sendMsg("/arguments", json);
		}
	}

	triggerHandler {
		^{ |args, time, addr, recvPort|
			SatieQueryTree.get(
				server: satie.config.server,
				action: { |snapshot|
					snapshot.nodeIds.do({ |id|
						var instanceName;
						if(id == args[1]) {
							satie.namesIds.keysValuesDo({ |key, value|
								if (value == id) {
									instanceName = key;
								}
							});
							returnAddress.sendMsg("/trigger", instanceName, args[3]);
						}
					});
				}
			);
		}
	}

	envelopeHandler {
		^{ |args, time, addr, recvPort|
			SatieQueryTree.get(
				server: satie.config.server,
				action: { |snapshot|
					snapshot.nodeIds.do({ |id|
						var instanceName, restArgs;
						if(id == args[1]) {
							satie.namesIds.keysValuesDo({ |key, value|
								if (value == id) {
									instanceName = key;
								}
							});
							// because SendReply allows for a list of values to be sent...
							restArgs = args.copyRange(3, args.size() -1);
							returnAddress.sendMsg("/analysis", instanceName, *restArgs);
						}
					});
				}
			);
		}
	}
}
