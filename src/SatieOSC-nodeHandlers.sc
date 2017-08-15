+ SatieOSC {

	updateSrcHandler {
		^{ | args |
			var nodeName = args[1];
			var aziDeg, eleDeg, gainDB, delayMs, lpHz, distance;
			var thisSynth;
			"    *****".postln;
			
			if (args.size != 8,
				{"→    %: message missing values".format(args).warn},
				{
					thisSynth = this.getSourceNode(nodeName, \synth);
					this.updateNode(thisSynth, args);
				}
			)
		}
	}

	updateGroupHandler {
		^{ | args |
			var nodeName = args[1];
			var aziDeg, eleDeg, gainDB, delayMs, lpHz, distance;
			var thisGroup;

			if (args.size != 8,
				{"→    %: message missing values".format(args).warn},
				{
					thisGroup = this.getGroupNode(nodeName, \group);
					this.updateNode(thisGroup, args);
				}
			);
		}
	}

	updateProcHandler {
		^{ | args |
			var nodeName = args[1];
			var thisGroupName, thisGroup, myProcess;

			if (args.size != 8,
				{"→    %: message missing values".format(args).warn},
				{
					thisGroupName = allGroupNodes[nodeName.asSymbol].at(\groupNameSym);
					thisGroup = this.getGroupNode(thisGroupName, \group);
					myProcess = allSourceNodes[nodeName.asSymbol].at(\process);
					if (myProcess == nil, {
						"%: process node %: BUG FOUND: undefined process"
						.format(this.class.getBackTrace, nodeName).error}
					);
					if (myProcess[\setUpdate] == nil,
						{
							this.updateNode(thisGroup, args);
						},
						{
							var aziDeg, eleDeg, gainDB, delayMs, lpHz, distance;
							aziDeg = args[2] + satie.satieConfiguration.orientationOffsetDeg[0];
							eleDeg= args[3] + satie.satieConfiguration.orientationOffsetDeg[1];
							gainDB = args[4];
							delayMs = args[5];
							lpHz = args[6];
							distance = args[7];  // not used by basic spatializers
							myProcess[\setUpdate].value(myProcess, aziDeg, eleDeg, gainDB, delayMs, lpHz, distance);
						}
					
					);
				}
			);
		};
	}


	// for sources and groups
	updateNode { | node, args |
		var aziDeg, eleDeg, gainDB, delayMs, lpHz, distance;
		// get values from vector
		aziDeg = args[2] + satie.satieConfiguration.orientationOffsetDeg[0];
		eleDeg= args[3] + satie.satieConfiguration.orientationOffsetDeg[1];
		gainDB = args[4];
		delayMs = args[5];
		lpHz = args[6];
		distance = args[7];  // not used by basic spatializers
		node.set(
			\aziDeg, aziDeg,
			\eleDeg, eleDeg,
			\gainDB, gainDB,
			\delayMs, delayMs,
			\lpHz, lpHz
		);
	}

	setProcHandler {
		^{ | args |
			var nodeName = args[1];
			var props = args.copyRange(2, args.size -1);

			if (satie.satieConfiguration.debug, {"→    %: message: %".format(this.class.getBackTrace, args).postln});
			if (allSourceNodes.includesKey(nodeName.asSymbol),
				{
					var thisGroupName = allSourceNodes[nodeName.asSymbol].at(\groupNameSym);  // process nodes have unique groups
					var thisGroup = this.getGroupNode(thisGroupName, \group);
					var myProcess = this.getSourceNode(nodeName, \process);
					if (myProcess == nil,
						{
							"→    %: process node; % - BUG? undefined process".format(
								this.class.getBackTrace, nodeName);
						},
						{
							this.processSet (myProcess, props);
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
			if (allGroupNodes.includesKey(nodeName.asSymbol),
				{
					targetNode = this.getGroupNode(nodeName, \group);
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
					targetNode = this.getSourceNode(nodeName, \synth);
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
		if (satie.satieConfiguration.debug,
			{"→ %:\n    → targetNode: %\n     →properties: % ".
				format(this.class.getBackTrace, targetNode, props).postln
			}
		);

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

	processSet { | process, props |
		var value;
		var keyHandler = nil;
		var setHandler = nil;

		if (satie.satieConfiguration.debug, {
			"%: %".format(this.class.getBackTrace, props);
		});

		props.pairsDo({|prop, val|
			switch(prop,
				'hpHz',
				{
					var halfSrate = 0.5 * satie.server.sampleRate;
					value = clip(val, 1, halfSrate );
				},
				'spread',
				{
					// invert and scale the spread value (usually an exp) to work with SATIE's VBAP-based spatializer (or others)
					var spread = 100 *  ( 1 - (clip(val,0,1)));  //
					value = spread;
				},
				'in',
				{
					value = satie.aux[val.asInt];
				},
				{
					"%: running default set, args: \n     prop: %\n     value: % ".format(
						this.class.getBackTrace, prop, val
					).postln;
					value = val;
				}
			);

			if (process[\set].class == Function,
				{
					process[\set].value(prop, val);
				},
				{
					"%: % does not implement a setter".format(this.class.getBackTrace, process).postln;
				}
			)

		})
	}

	setVecHandler {
		^{ | args |
			var type = args[0].asString.split[2].asSymbol;


			if (satie.satieConfiguration.debug, { postf("•satieOSCProtocol.setvecMessHandler:  mess: %\n", args); });

			// verify data
			if (  ( args.size < 3)  ,
				{
					error("satieOSCProtocol.setVecHandler: bad message length: expects oscAddress key data1 or more \n"++args);
				}, // else args good
				{
					var nodeName  = args[1];
					var key = args[2];
					var vector = args.copyRange(3, args.size - 1);
					var targetNode = nil;

					switch(type,
						'source',
						{
							targetNode = this.getSourceNode(nodeName, \synth);
							targetNode.set(key, vector);
						},
						'group',
						{
							targetNode = this.getGroupNode(nodeName, \group);
							targetNode.set(key, vector);
						},
						'process',
						{
							if ( allSourceNodes.includesKey(nodeName.asSymbol) == true,
								{
									var thisGroupName = allSourceNodes[nodeName.asSymbol].at(\groupNameSym);  // process nodes have unique groups
									var thisGroup = this.getGroupNode(thisGroupName, \group);
									var myProcess = allSourceNodes[nodeName.asSymbol].at(\process);
									var matched = false;

									if ( myProcess == nil,
										{
											error("satieOSCProtocol.setVecHandler:  process node: "++nodeName++"  BUG FOUND: undefined process  \n");

										},
										{  // good to go
											if ( myProcess[key.asSymbol].class == Function,  // does a specific handler exist for this key ?
												{
													matched = true;
													myProcess[key.asSymbol].value(myProcess, vector);   // use process's specially defined message handler for this key
												},
												{
													// else  nope:  no handler with that name exists.  Check  if a handler named \setVec is defined.
													if ( myProcess[\setVec].class == Function,
														{
															matched = true;
															myProcess[\setVec].value(myProcess, key, vector);   // use process's \setVec message handler
														});
												});
											//
											if (matched == false,
												{
													// or just update the process's group
													thisGroup.set(key,vector);
												});
										});
								},
								{  // else error
									error("satieOSCProtocol.setVecHandler:  process node: "++nodeName++"  is undefined \n");
								});
						});
				});
		}
	}
}