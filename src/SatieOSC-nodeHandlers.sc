+ SatieOSC {

	test {
		"boo".postln;
	}

	updateSrcHandler {
		^{ | args |
			var nodeName = args[1];
			var aziDeg, eleDeg, gainDB, delayMs, lpHz, distance;
			var thisSynth;

			if (allSourceNodes.includesKey(nodeName.asSymbol) == false,
				{
					"%: node % not found, could be abug.".format(this.class.getBackTrace, nodeName).error;
				},
				{
					thisSynth = this.getSourceNode(nodeName, \synth);
					"this Synth is: %".format(thisSynth).postln;

					if (args.size != 8,
						{"→    %: message missing values".warn},
						{
							// get values from vector, and write to connectionState
							aziDeg = args[2] + satie.satieConfiguration.orientationOffsetDeg[0];
							eleDeg= args[3] + satie.satieConfiguration.orientationOffsetDeg[1];
							gainDB = args[4];
							delayMs = args[5];
							lpHz = args[6];
							distance = args[7];  // not used by basic spatializers

							thisSynth.set(
								\aziDeg, aziDeg,
								\eleDeg, eleDeg,
								\gainDB, gainDB,
								\delayMs, delayMs,
								\lpHz, lpHz
							);
						}
					);
				}
			)
		}
	}

	setProcHandler {
		^{ | args |
			var nodeName = args[1];
			var props = args.copyRange(2, args.size -1);

			if (satie.satieConfiguration.debug, {"→    %: message: %".format(this.class.getBackTrace, args).postln});
			if (allSourceNodes.includesKey(nodeName.asSymbol),
				{
					var thisGroupName = allSourceNodes[nodeName.asSymbol].at(\groupNameSym);  // process nodes have unique groups
					var thisGroup = allGroupNodes[thisGroupName].at(\group).group;
					var myProcess = allSourceNodes[nodeName.asSymbol].at(\process);
					if (myProcess == nil,
						{
							"→    %: process node; % - BUG? undefined process".format(
								this.class.getBackTrace, nodeName);
						},
						{
							this.processSet (myProcess, props, thisGroup);
						}
					)
				}
			);
		}
	}

	setGroupHandler {
		^{ | args |
			var nodeName = args[1];
			var props = args.copyRange(2, args.size -1);
			var targetNode;

			if (satie.satieConfiguration.debug, {"→    %: message: %".format(this.class.getBackTrace, args).postln});
			if (allSourceNodes.includesKey(nodeName.asSymbol),
				{
					targetNode = allSourceNodes[nodeName.asSymbol].at(\group);
					this.nodeSet(targetNode, props);
				},
				{
					"→   %: group node % does not exist".format(this.class.getBackTrace, nodeName).error;
				}
			);
		}
	}

	setSrcHandler {
		^{| args |
			var nodeName = args[1];
			var props = args.copyRange(2, args.size -1);
			var targetNode;

			if (satie.satieConfiguration.debug, {"→ %: message: %".format(this.class.getBackTrace, args).postln});
			if (allSourceNodes.includesKey(nodeName.asSymbol),
				{
					targetNode = allSourceNodes[nodeName.asSymbol].at(\synth);
					if (targetNode == nil,
						{
							error("%: source node: % - bug: undefined synth".format(this.class.getBackTrace, targetNode));
						},
						{
							this.nodeSet(targetNode, props);
						}
					);
				},
				{
					error("%: source node: % is undefined".format(this.class.getBackTrace, nodeName));
				}
			);
		}
	}

	nodeSet { | targetNode, props |
		if (satie.satieConfiguration.debug, {"→ %:\n    → targetNode: %\n     →properties: % ".format(this.class.getBackTrace, targetNode, props).postln});

		props.pairsDo({|prop, val|
			switch(prop,
				'hpHz',
				{
					var halfSrate = 0.5 * satie.server.sampleRate;

					targetNode.set(\hpHz ,  clip(val, 1, halfSrate ));
				},
				'spread',
				{
					// invert and scale the spread value (usually an exp) to work with SATIE's VBAP-based spatializer (or others)
					var spread = 100 *  ( 1 - (clip(val,0,1)));  //
					targetNode.set(\spread, spread);
				},
				'in',
				{
					targetNode.set(prop, satie.aux[val.asInt]);
				},
				{
					"%: running default set, args: \n     prop: %\n     value: % ".format(
						this.class.getBackTrace, prop, val
					).postln;
					targetNode.set(prop, val);
				}
			)
		})
	}
	// setMessageHandler { 	| args |
	// 		var type = args[0].asString.split[2].asSymbol;
	// 		var nodeName  = args[1];
	// 		var props = args.copyRange(2, args.size - 1);
	// 		var targetNode;

	// 		if (e.debugFlag, { postf("•satieOSCProtocol.setMessHandler:  mess: %\n", args); });

	// 		// verify data
	// 		if (  (  ( (props.size&1)==1) || (props.size == 0) ),
	// 			{
	// 				error("satieOSCProtocol.setMessHandler: BAD ARGS: "++props);
	// 			}, // else args good
	// 			{
	// 				switch(type,
	// 					'source',
	// 					{
	// 						if ( e.allSourceNodes.includesKey(nodeName.asSymbol) == true,
	// 							{
	// 								targetNode = e.allSourceNodes[nodeName.asSymbol].at(\synth);
	// 								if ( targetNode == nil,
	// 									{
	// 										error("satieOSCProtocol.setMessHandler:  source node: "++nodeName++"  BUG FOUND: undefined SYNTH  \n");
	// 									},   // else good to go
	// 									{
	// 										e.nodeSet( props, targetNode);
	// 								});
	// 							},
	// 							{
	// 								error("satieOSCProtocol.setMessHandler:  source node: "++nodeName++"  is undefined \n");
	// 						}); // else node exists,  process event
	// 					},
	// 					'group',
	// 					{
	// 						if ( e.allGroupNodes.includesKey (nodeName.asSymbol) == true,
	// 							{
	// 								targetNode = e.allGroupNodes[nodeName.asSymbol].at(\group).group;
	// 								e.nodeSet( props, targetNode);
	// 							},
	// 							{   // else no group
	// 								error("satieOSCProtocol.setMessHandler:  group node: "++nodeName++"  is undefined \n");
	// 						});
	// 					},
	// 					'process',
	// 					{
	// 						if ( e.allSourceNodes.includesKey(nodeName.asSymbol) == true,
	// 							{
	// 								var thisGroupName = e.allSourceNodes[nodeName.asSymbol].at(\groupNameSym);  // process nodes have unique groups
	// 								var thisGroup = e.allGroupNodes[thisGroupName].at(\group).group;
	// 								var myProcess = e.allSourceNodes[nodeName.asSymbol].at(\process);

	// 								if ( myProcess == nil,
	// 									{
	// 										error("satieOSCProtocol.setMessHandler:  process node: "++nodeName++"  BUG FOUND: undefined process  \n");

	// 									},
	// 									{  // good to go
	// 										e.processSet( props, myProcess, thisGroup);
	// 								});

	// 							},
	// 							{  // else error
	// 								error("satieOSCProtocol.setMessHandler:  process node: "++nodeName++"  is undefined \n");
	// 						});
	// 				});
	// 		});
	// 	};
}