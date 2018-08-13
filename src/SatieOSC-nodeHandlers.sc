+ SatieOSC {

	// expects /oscaddress nodeName pluginName groupName<optional>
	createSourceHandler {
		^{ | args |

			if (satie.satieConfiguration.debug, {"→    %: message: %".format(this.class.getBackTrace, args).postln});

			if ( (args.size < 2 ) ,
				{
					"→    %: message: bad arg count: expects  at least 2 values:  nodeName, pluginName, and optionally:  groupName".format(this.class.getBackTrace).error
				},
				// else
				{
					var sourceName = args[1].asSymbol;
					var synthName  = args[2].asSymbol;
					var groupName = \default;

					if (args.size == 4,
						{
							groupName = args[3].asSymbol;
					});
					this.createSourceNode(sourceName, synthName, groupName );
				}

			);
		}
	}

	// expects /oscaddress nodeNameSym synthName  <opt>groupNameSym <opt>auxBus
	// where UriString == either:  synthName , or synthName N, where N is the number of the Satie AuxBus input to the effect
	createEffectHandler {
		^{ | args |

			if (satie.satieConfiguration.debug, {"→    %: message: %".format(this.class.getBackTrace, args).postln});

			if ( (args.size < 3 ) ,
				{
					"→    %: message: bad arg count: expects  at least 2 values:  nodeName, pluginUri, and optionally:  groupName".format(this.class.getBackTrace).error
				},
				// else
				{
					var sourceName = args[1].asSymbol;
					var synthName  = args[2].asSymbol;
					var groupName = \defaultFx;
					var auxBus = 0;
					~effectsMess=args;
					if (args.size == 5,
						{
							if (args[4].class == Symbol, {groupName = args[4].asSymbol;
							},
							//else
							{
								if (  (args[4].class == Integer) || (args[3].class == Float), {auxBus = args[4].asInt;
								});

							});
					});

					if (args.size > 3,
						{
							if (args[3].class == Symbol, {groupName = args[3].asSymbol;
							},
							//else
							{
								if  (  (args[3].class == Integer) || (args[3].class == Float), {auxBus = args[3].asInt;
								});

							});
					});
					this.createEffectNode(sourceName, synthName, groupName, auxBus );
				}
			);
		}
	}

	// expects /oscaddress nodeName URI groupName<opt: but ignored>
	createProcessHandler {
		^{ | args |

			if (satie.satieConfiguration.debug, {"→    %: message: %".format(this.class.getBackTrace, args).postln});

			if ( (args.size < 2 ) ,
				{
					"→    %: message: bad arg count: expects  at least 2 values:  nodeName, pluginName, and optionally: groupName".format(this.class.getBackTrace).error
				},
				// else
				{
					var id = args[1].asSymbol;
					var uriPath  = args[2].asString;
					// var groupName = \default;

					/*					if (args.size == 4,
					{
					groupName = args[3].asSymbol;
					});*/
					this.createProcessNode(id, uriPath );
				}
			);
		}
	}


	// expects /oscaddress groupName
	createSourceGroupHandler {
		^{ | args |

			if (satie.satieConfiguration.debug, {"→    %: message: %".format(this.class.getBackTrace, args).postln});

			if ( (args.size < 2 ) ,
				{
					"→    %: message: missing  nodeName argument".format(this.class.getBackTrace).error
				},
				// else
				{
					var groupName = args[1].asSymbol;
					this.createGroup(groupName, \addToHead);
			});
		}
	}

	// expects /oscaddress groupName
	createEffectGroupHandler {
		^{ | args |

			if (satie.satieConfiguration.debug, {"→    %: message: %".format(this.class.getBackTrace, args).postln});

			if ( (args.size < 2 ) ,
				{
					"→    %: message: missing  nodeName argument".format(this.class.getBackTrace).error
				},
				// else
				{
					var groupName = args[1].asSymbol;

					this.createGroup(groupName, \effect);
			});
		}
	}

	// expects /oscaddress groupName
	createProcessGroupHandler {
		^{ | args |

			if (satie.satieConfiguration.debug, {"→    %: message: %".format(this.class.getBackTrace, args).postln});

			if ( (args.size < 2 ) ,
				{
					"→    %: message: missing  nodeName argument".format(this.class.getBackTrace).error
				},
				// else
				{
					var groupName = args[1].asSymbol;

					this.createGroup(groupName, \addToHead);
			});
		}
	}


	deleteNodeHandler {
		^{ | args |
			if (satie.satieConfiguration.debug, {"→    %: message: %".format(this.class.getBackTrace, args).postln});

			if ( (args.size != 2 ) ,
				{	"→    %: message missing nodeName %".format(this.class.getBackTrace, args).error},
				// else
				{
					var nodeName = args[1].asSymbol;

					// first check if node is a process as it is a special case
					if (satie.processInstances.includesKey(nodeName),
						{
							satie.cleanProcessInstance(nodeName);
						},
						{
							if (satie.groupInstances.includesKey(nodeName.asSymbol),
								{   this.removeGroup(nodeName);  },
								// else
								{
									this.deleteSource(nodeName);   });

						});
				}
			);
		}
	}

	clearSceneHandler {
		^{ | args |

			if (satie.satieConfiguration.debug, {"→    %: message: %".format(this.class.getBackTrace, args).postln});

			satie.cleanUp();
		}
	}

	debugFlagHandler {
		^{ | args |
			if ((args.size !=2 ),
				{"% message missing flag".format(this.class.getBackTrace).warn},
				{
					"→    %:  message: %".format(this.class.getBackTrace, args).postln;
					satie.satieConfiguration.debug = args[1].asInt.asBoolean;
				}
			)
		}
	}

	updateSrcHandler {
		^{ | args |
			var nodeName = args[1];
			var aziDeg, eleDeg, gainDB, delayMs, lpHz, distance;
			var thisSynth;
			if (args.size != 8,
				{"→    %: message missing values".format(args).warn},
				{
					if (satie.satieConfiguration.debug,
						{"→    %: message: %".format(this.class.getBackTrace, args).postln});
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
			var nodeName = args[1].asSymbol;
			var thisGroupName, thisGroup, myProcess;

			if (args.size != 8,
				{"→    %: message missing values".format(args).warn},
				{
					if (satie.satieConfiguration.debug,
						{
							"%: args: %".format(this.class.getBackTrace, args).postln;
						}
					);
					thisGroupName = (nodeName++"_group").asSymbol;
					thisGroup = satie.groups[thisGroupName.asSymbol];
					myProcess = satie.processInstances[nodeName];
					if (myProcess == nil, {
						"%: process node %: BUG FOUND: undefined process"
						.format(this.class.getBackTrace, nodeName).error}
					);
					if (myProcess[\setUpdate] == nil,
						{
							if (satie.satieConfiguration.debug,
								{
									"%: no setUpdate on % so we update group % with args %".
									format(this.class.getBackTrace, myProcess, thisGroup, args).postln;
								}
							);
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
		if (satie.satieConfiguration.debug, {"→    %: message: %".format(this.class.getBackTrace, args).postln});
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
			\lpHz, lpHz,
			\distance, distance;
		);
	}

	setProcHandler {
		^{ | args |
			var nodeName = args[1].asSymbol;
			var props = args.copyRange(2, args.size -1);

			if (satie.satieConfiguration.debug, {"→    %: message: %".format(this.class.getBackTrace, args).postln});
			if (satie.processInstances.includesKey(nodeName.asSymbol),
				{
					var grName = (nodeName++"_group").asSymbol;
					var thisGroup = satie.groups[grName];
					var myProcess = satie.processInstances(nodeName);
					if (myProcess == nil,
						{
							"→    %: process node; % - BUG? undefined process".format(
								this.class.getBackTrace, nodeName);
						},
						{
							var myEnv = myProcess.at(nodeName);
							this.processSet (myEnv, thisGroup, props);
						}
					)
				},
				{  // else error
					error("SatieOSC.setProcHandler:  process node: "++nodeName++"  is undefined \n");
			});

		}
	}

	setGroupHandler {
		^{ | args |
			var nodeName = args[1];
			var props = args.copyRange(2, args.size -1);
			var targetNode;

			if (satie.satieConfiguration.debug, {"→    %: message: %".format(this.class.getBackTrace, args).postln});
			if (satie.groups.includesKey(nodeName.asSymbol),
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
			targetNode = this.getSourceNode(nodeName);
			// this.nodeSet(targetNode, props);
			if (targetNode == nil,
				{
					error("%: source node: % - bug: undefined synth".format(this.class.getBackTrace, targetNode));
				},
				{
					this.nodeSet(targetNode, props);
				}
			);
		}
	}

	nodeSet {| targetNode, props |

		if (satie.satieConfiguration.debug, {"→ %:\n    → targetNode: %\n     →properties: % ".format(this.class.getBackTrace, targetNode, props).postln});

		props.pairsDo({|prop, val|
			switch(prop,
				'hpHz',
				{
					var halfSrate = 0.5 * satie.satieConfiguration.server.sampleRate;

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
					targetNode.set(prop, val);
				}
			)
		})
	}

	processSet { | process, group, props |
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
					var halfSrate = 0.5 * satie.satieConfiguration.server.sampleRate;
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
/*					"%: running default set, args: \n     prop: %\n     value: % ".format(
						this.class.getBackTrace, prop, val
					).postln;*/
					value = val;
				}
			);

			if (process[\set].class == Function,
				{
					process[\set].value(process, prop, val);
				},
				{
					group.set(prop.asSymbol, val);
					//"%: % does not implement a setter".format(this.class.getBackTrace, process).postln;
			});
		});
	}



	// accepts arbitrary key value pair,  and sets value to corresponding process environment key
	propertyProcHandler
	{
		^{ | args |
			var type = args[0].asString.split[2].asSymbol;
			var nodeName  = args[1].asSymbol;
			var propsVec = args.copyRange(2, args.size - 1);

			if (satie.satieConfiguration.debug,
				{
					postf("SatieOSC.processProperty: % \n", args);
				});

			// verify data
			if (  (  ( (propsVec.size&1)==1) || (propsVec.size == 0) ),
				{
					error("SatieOSC.processProperty: BAD ARGS: "++propsVec);
				}, // else args good
				{  // verify node
					if ( satie.processInstances.includesKey(nodeName) == true,
						{
							// var thisGroupName = allSourceNodes[nodeName.asSymbol].at(\groupNameSym);  // process nodes have unique groups
							// var thisGroup = this.getGroupNode(thisGroupName, \group);
							var myProcess = satie.processInstances[nodeName];

							if ( myProcess == nil,     // verify process
								{
									error("SatieOSC.processProperty:  process node: "++nodeName++"  BUG FOUND: undefined process  \n");

								},
								{  // good to go:  write key val pairs to process environment instance

									var handler= nil;

									// postf("SatieOSC.processProperty:  process node: "++nodeName++" process: % \n", myProcess.class);


									if (myProcess[\property].class == Function,
										{
											handler = myProcess[\property];
										}
									);

									propsVec.pairsDo({ | prop, val |

										if (handler != nil,
											{
												handler.value(myProcess, prop, val);
											}, // else set the process's environment variable directly
											{
												myProcess[prop.asSymbol] = val;
											});
									});
								});
						},
						{  // else error
							error("SatieOSC.setMessHandler:  process node: "++nodeName++"  is undefined \n");
						});
				});
		}
	}

	evalFnProcHandler {
		^{ | args |

			if (satie.satieConfiguration.debug, { postf("SatieOSC.evalProcFnHandler:  mess: %\n", args); });

			// verify data
			if (  ( args.size < 3)  ,
				{
					error("SatieOSC.evalProcFnHandler: bad message length: expects oscAddress key data1 or more \n"++args);
				}, // else args good
				{
					var nodeName  = args[1].asSymbol;
					var key = args[2];
					var vector = args.copyRange(3, args.size - 1); // nil is OK.
					var targetNode = nil;

					var myProcess = satie.processInstances.at(nodeName);

					if ( myProcess == nil,
						{
							"%: process node: % does not exist".format(this.class.getBackTrace, myProcess).error;
						},
						{  // good to go
							if ( myProcess[key.asSymbol].class == Function,  // does a specific handler exist for this key ?
								{
									myProcess[key.asSymbol].value(myProcess, vector);   // use process's specially defined message handler for this key
								},
								{
									// else  nope:  no handler with that name exists.  Check  if a handler named \setVec is defined.
									warn("SatieOSC.evalProcFnHandler:  process node: "++nodeName++"  undefined method: "++key.asSymbol++"  , can not service message \n");
								});
						});
				});
		}
	}

	setVecProcHandler {
		^{ | args |

			if (satie.satieConfiguration.debug, { postf("SatieOSC.setVecProcHandler:  mess: %\n", args); });

			if (  ( args.size < 3)  ,   			// verify data
				{
					error("SatieOSC.setVecHandler: bad message length: expects oscAddress key data1 or more \n"++args);
				}, // else args good
				{
					var nodeName  = args[1].asSymbol;
					var key = args[2];
					var vector = args.copyRange(3, args.size - 1); // nil is OK.
					var targetNode = nil;

					if ( satie.processInstances.includesKey(nodeName) == true,
						{
							var thisGroup = satie.groups.at((nodeName++"_group").asSymbol);
							var myProcess = satie.processInstances.at(nodeName);
							var matched = false;

							if ( myProcess == nil,
								{
									error("SatieOSC.setVecHandler:  process node: "++nodeName++"  BUG FOUND: undefined process  \n");

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
							error("SatieOSC.setVecHandler:  process node: "++nodeName++"  is undefined \n");
					});
			});
		}
	}

	setVecSourceHandler {
		^{ | args |

			if (satie.satieConfiguration.debug, { postf("satieOSC.setVecSourceHandler:  mess: %\n", args); });

			if (  ( args.size < 3)  ,   // verify data
				{
					error("SatieOSC.setVecHandler: bad message length: expects oscAddress key data1 or more \n"++args);
				}, // else args good
				{
					var nodeName  = args[1];
					var key = args[2];
					var vector = args.copyRange(3, args.size - 1);
					var targetNode;

					targetNode = this.getSourceNode(nodeName);
					targetNode.set(key, vector);
			});
		}
	}

	setVecGroupHandler {
		^{ | args |

			if (satie.satieConfiguration.debug, { postf("SatieOSC.setVecGroupHandler:  mess: %\n", args); });

			if (  ( args.size < 3)  ,   // verify data
				{
					error("SatieOSC.setVecHandler: bad message length: expects oscAddress key data1 or more \n"++args);
				}, // else args good
				{
					var nodeName  = args[1];
					var key = args[2];
					var vector = args.copyRange(3, args.size - 1);
					var targetNode;

					targetNode = this.getGroupNode(nodeName, \group);
					targetNode.set(key, vector);
			});
		}
	}

	// handles /satie/source/state  nodeName flag
	stateSourceHandler {
		^{ | args |

			if ( satie.satieConfiguration.debug,
				{
					postf("SatieOSC.stateSourceHandler: % \n", args);
			});

			// verify message
			if (  ( args.size != 3)  ,
				{
					error("SatieOSC.stateSourceHandler: bad messafe length: expects oscAddress nodeName val % \n", args);
				}, // else args good
				{
					var nodeName  = args[1];
					var value = args[2];
					var targetNode = nil;
					var state;

					if ( value == 0 , { state = false}, {state = true});

					targetNode = this.getSourceNode(nodeName);
					if ( targetNode == nil,
						{
							error("SatieOSC.stateSourceHandler:  source node: "++nodeName++"  BUG FOUND: undefined SYNTH  \n");
						}, // else good to go
						{
							targetNode.run(state);
							targetNode.register(); // register with NodeWatcher, for state checking
						});
				});
		}
	}

	// handles /satie/group/state  nodeName flag
	stateGroupHandler {
		^{ | args |

			if ( satie.satieConfiguration.debug,
				{
					postf("SatieOSC.stateGroupHandler: % \n", args);
			});

			// verify message
			if (  ( args.size != 3)  ,
				{
					error("SatieOSC.stateGroupHandler: bad messafe length: expects oscAddress nodeName val % \n", args);
				}, // else args good
				{
					var nodeName  = args[1];
					var value = args[2];
					var targetNode = nil;
					var state;

					if ( value == 0 , { state = false}, {state = true});

					if (  satie.groups.includesKey (nodeName.asSymbol) == true,
						{
							targetNode = satie.groups[nodeName.asSymbol];
							targetNode.run(state);
							targetNode.register(); // register with NodeWatcher, for state checking

						},
						{   // else no group
							error("SatieOSC.stateGroupHandler:  group node: "++nodeName++"  is undefined \n");
					});
			});
		}
	}

	// handles /satie/process/state  nodeName flag
	stateProcHandler {
		^{ | args |

			if ( satie.satieConfiguration.debug,
				{
					postf("SatieOSC.stateProcHandler: % \n", args);
				});

			// verify message
			if (  ( args.size != 3)  ,
				{
					error("SatieOSC.stateProcHandler: bad message length: expects oscAddress nodeName val % \n", args);
				}, // else args good
				{
					var processName  = args[1].asSymbol;
					var value = args[2];
					var thisGroup;
					var myProcess = satie.processInstances[processName];
					var state;

					if ( value == 0 , { state = false}, {state = true});

					thisGroup = (processName++"_group").asSymbol;

					if (myProcess == nil,
						{
							"%: undefined process: %".format(this.class, processName).warm;
						},
						{
							if (myProcess[\state].class == Function,
								{
									myProcess[\state].value(myProcess, state);
								},
								{
									if ( thisGroup != nil,
										{
											satie.groups[thisGroup.asSymbol].run(state);
										},
										{ "%: process % missing state method and no group is defined".format(this.class, processName).error;}
									);
								}
							);
						});
				});
		};
	}

}  // end of context
