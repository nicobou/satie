SatieOSC {
	var satie;
	var <rootURI;
	var <>oscServerPort;
	var <>oscClientPort;

	// private
	var allSourceNodes;
	var allGroupNodes;
	var responder;


	// used for audio renderer control
	var volume;     // will point to server volume / mute control
	var outputDB = 0;    // current state of the supercollider server output
	var outputTrimDB = 0;

	// TODO satieContext must be an array in order to duplicate message forwarding to sc server
	*new { | satieContext, rootPath = "/satie", serverPort = 18032, clientPort = 18060 |
		^super.newCopyArgs(satieContext, rootPath, serverPort, clientPort).initOSC;
	}

	initOSC {
		" - satie: %\n - rootURI: %\n - port: %".format(satie, rootURI, oscServerPort).postln;
		" + %".format(satie.satieConfiguration.server).postln;
		allSourceNodes = Dictionary();
		allGroupNodes = Dictionary();
		responder = NetAddr("localhost", this.oscClientPort);
		volume = satie.satieConfiguration.server.volume;
		volume.setVolumeRange(-99, 18);

		// set up default group
		if ( satie.groups[\default] == nil,
			{
				warn("satieOSC.INIT:  \default group not defined in Satie, instantiating, \default group");
				this.createGroup(\default);
			},
			// else all good, create an entry for \default group
			{
				allGroupNodes[\default] = Dictionary();   // create group node  -- create node-specific dict.
				allGroupNodes[\default].put(\group , satie.groups[\default] );  // set group
				allGroupNodes[\default].put(\groupSym , \default);  // save group name symbol
				allGroupNodes[\default].put(\plugin, \nil);
				allGroupNodes[\default].put(\position, \head);  //  indicates group DSP chain evaluation order  (head or tail)
				postf(">>satieOSC.INIT:  setting up   % group at DSP %\n", \default, \head);
		});

				// set up defaultFx group
		if ( satie.groups[\defaultFx] == nil,
			{
				warn("satieOSC.INIT:  \defaultFx group not defined in Satie, instantiating, \defaultFx group");
				this.createGroup(\defaultFx,\addToTail);
			},
			// else all good, create an entry for \default group
			{
				allGroupNodes[\defaultFx] = Dictionary();   // create group node  -- create node-specific dict.
				allGroupNodes[\defaultFx].put(\group , satie.groups[\defaultFx] );  // set group
				allGroupNodes[\defaultFx].put(\groupSym , \defaultFx);  // save group name symbol
				allGroupNodes[\defaultFx].put(\plugin, \nil);
				allGroupNodes[\defaultFx].put(\position, \tail);  //  indicates group DSP chain evaluation order  (head or tail)
				postf(">>satieOSC.INIT:  setting up   % group at DSP %\n", \defaultFx, \tail);
		});


		// scene level handler
		this.newOSC(\satieScene, this.coreHandler, "/satie/scene");
		this.newOSC(\satieSceneCreateSource, this.createSourceHandler, "/satie/scene/createSource");
		this.newOSC(\satieSceneCreateEffect, this.createEffectHandler, "/satie/scene/createEffect");

		// set command handlers
		this.newOSC(\satieSrcState, this.setState, "/satie/source/state");
		this.newOSC(\satieGroupState, this.setState, "/satie/group/state");
		this.newOSC(\satieSrcSet, this.setSrcHandler, "/satie/source/set");
		this.newOSC(\satieGroupSet, this.setGroupHandler, "/satie/group/set");
		this.newOSC(\satieProcSet, this.setProcHandler, "/satie/process/set");
		this.newOSC(\satieSrcUpdate, this.updateSrcHandler, "/satie/source/update");
		this.newOSC(\satieGroupUpdate, this.updateGroupHandler, "/satie/group/update");
		this.newOSC(\satieProcUpdate, this.updateProcHandler, "/satie/process/update");
		this.newOSC(\satieSrcSetVec, this.setVecHandler, "/satie/source/setvec");
		this.newOSC(\satieGroupSetVec, this.setVecHandler, "/satie/group/setvec");
		this.newOSC(\satieProcSetVec, this.setVecHandler, "/satie/process/setvec");

		this.newOSC(\audioplugins, this.getAudioPlugins, "/satie/audioplugins");
		this.newOSC(\pluginArgs, this.getPluginArguments, "/satie/pluginargs");

		this.newOSC(\satieLoadFile, this.loadFile, "/satie/load");

		this.newOSC(\satieRendererSetOrientationDeg, this.setOrientationDegHandler, "/satie/renderer/setOrientationDeg");
		this.newOSC(\satieRendererSetOutputDB, this.setOutputDBHandler, "/satie/renderer/setOutputDB");
		this.newOSC(\satieRendererSetOutputTrimDB, this.setOutputTrimDBHandler, "/satie/renderer/setOutputTrimDB");
		this.newOSC(\satieRendererSetOutputMute, this.setOutputMuteHandler, "/satie/renderer/setOutputMute");
		this.newOSC(\satieRendererSetOutputDim, this.setOutputDimHandler, "/satie/renderer/setOutputDim");
		this.newOSC(\satieRendererFreeSynths, this.freeSynthsHandler, "/satie/renderer/freeSynths");
	}

	/*      create a new OSC definition*/
	newOSC { | id, cb, path = \default |
		OSCdef(id.asSymbol, cb, path, recvPort: oscServerPort);
	}

	deleteOSC {|id|
		OSCdef(id.asSymbol).free;
	}

	/////////////////////////////////////////////////////////
	// Handle /satie/scene level messages:
	//
	// /satie/scene createSource  nodeName  URI<plugin://synthdefName groupName<opt>   // default groupName = 'default'
	// /satie/scene createSource  nodeName  URI<effect://synthdefName  optionalArgs: inbus N >   groupName<opt>   // defaults:  groupName = 'defaultFx',  inbus = 0
	// /satie/scene createGroup nodeName   optionalURI<effect://>   // uri determines the DSP position of group (head or tail)   -defaults to head
	// /satie/scene createProcess nodeName URI<uriPath process://processName optargs >   // unique group is automatically generated for each created process node
	// /satie/scene deleteNode nodeName
	// /satie/scene clear
	// /satie/scene/set keyword value   // to set scene parameters like 'debugFlag 1'
	/////////////////////////////////////////////////////////
	coreHandler {
		^{|msg|
			var command = msg[1];
			if (msg.size < 3,
				{
					switch (command,
						'clear',
						{
							this.clearScene();
						};
					);
				},
				{
					switch (command,
						'createSource',
						{if (satie.satieConfiguration.debug,
							{postf("•satieOSC.coreCallback: command: %, messLen: %   msg: %, \n", command, msg.size, msg);});

						if ( (msg.size < 3 ) ,
							{"satieOSC.coreCallback:  createSource message missing values".warn;
								postf("createSource MESS LEN: %", msg.size);

							},
							// else
							{
								var sourceName = msg[2];
								var uriName = "";
								var groupName = "";

								if (msg.size > 3,
									{
										uriName = msg[3];
								});

								if (msg.size > 4,
									{
										groupName = msg[4];
								});
								this.createSource(sourceName, uriName, groupName);
						});},
						'createGroup',
						{
							if ( (msg.size < 3 ) ,
								{"satieOSC.coreCallback:  createGroup message missing values".warn;
									postf("createGroup MESS LEN: %", msg.size);

								},
								// else
								{
									var groupName = msg[2];
									var position = \addToHead;
									var type;

									if (msg.size == 4,
										{
											type = this.getUriType(msg[3].asString);
											if (type == \effect, { position = \addToTail;});
									});

									this.createGroup(groupName, position);
								}
						)},
						'createProcess',
						{
							if (satie.satieConfiguration.debug,
								{postf("•satieOSC.coreCallback: createProcess:  command: %, messLen: %   msg: %, \n", command, msg.size, msg);});
							if ( (msg.size < 3 ) ,
								{"satieOSC.coreCallback:  createProcess message missing values".warn;
									postf("createProcess MESS LEN: %", msg.size);

								},
								// else
								{
									var sourceName = msg[2];
									var uriName = "";
									var groupName = "";

									if (msg.size > 3,
										{
											uriName = msg[3];
									});

									if (msg.size > 4,
										{
											groupName = msg[4];
									});
									this.createProcess(sourceName, uriName, groupName);
							});
						},
						'deleteNode',
						{
							if ( (msg.size < 3 ) ,
								{"satieOSC.coreCallback:  deleteNode message missing values".warn;},
								// else
								{
									var nodeName = msg[2];
									// "~coreCallback: OSCrx deleteNode CALLED ".warn;

									if (allGroupNodes.includesKey(nodeName.asSymbol),
										{   this.removeGroup(nodeName);  },
										// else
										{
											this.deleteSource(nodeName);   });
								}
							)
						},
						'debugFlag',
						{
							this.setDebug(msg)
						};
					)
			});
		}
	}

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

	// expects /oscaddress nodeNameSym UriString  <opt>groupNameSym
	// where UriString == either:  synthName , or synthName 'inBus' N
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
					var uriString  = args[2].asString;
					var groupName = \defaultFx;
					var stringArray, auxBus = 0;
					var synthName;

					if (args.size == 4,
						{
							groupName = args[3].asSymbol;
					});

					stringArray = uriString.asString.split($ );

					if (stringArray.size == 0,
						{
							"→    %: message: Empty URI String, can not create %".format(this.class.getBackTrace, sourceName.asString).error
						},
						// else OK to parse uriString
						{
							synthName = stringArray[0].asSymbol;  // get synthName

							// check for auxBus assignment
							if (stringArray.size == 3,
								{
									if (stringArray[1] == "inBus", { auxBus = stringArray[2] .asInt;

									});
							});

							this.createEffectNode(sourceName, synthName, groupName, auxBus );

					})
				}
			);
		}
	}


	setDebug { | msg |
		msg.postln;
		if ((msg.size < 3),
			{"% wrong number of arguments".format(this.class.getBackTrace).warn},
			{
				satie.satieConfiguration.debug = msg[2].asInt.asBoolean;
			}
		)
	}

	removeGroup { | groupName |
		if ( allGroupNodes.includesKey(groupName.asSymbol) ,
			{
				if (satie.satieConfiguration.debug, {postf("•satieOSC.removeGroup:  group node: % \n",  groupName);});
				allGroupNodes.removeAt(groupName.asSymbol);     // remove node from global dictionary
		});
	}

	deleteSource { | nodeName |
		if ( allSourceNodes.includesKey(nodeName.asSymbol) ,
			{
				this.clearSourceNode(nodeName.asSymbol);
				allSourceNodes.removeAt(nodeName.asSymbol);     // remove node from global dictionary
		});
	}

	clearSourceNode {  | nameSym |
		var node = allSourceNodes[nameSym];
		var nodeKeys = node.keys;
		var thisGroupName = allSourceNodes[nameSym].at(\groupNameSym);

		// is this a process node?
		if ( allSourceNodes[nameSym].at(\process) != nil,
			{
				var groupSym =  allSourceNodes[nameSym].at(\groupNameSym);

				var myProcess = allSourceNodes[nameSym].at(\process);
				"found a process %".format(allSourceNodes[nameSym].at(\process)).postln;

				myProcess.cleanup();   // frees any state the process may have created, i.e. synths

				//  IF THE SYNTH IS NOT CLEANED FROM THE NODE TREE, DO THE SAME AS THE REGULAR SOURCE CASE BELOW
				satie.cleanInstance(nameSym,thisGroupName );

				// now delete group
				this.removeGroup(groupSym); //
				satie.killSatieGroup(groupSym);   // kill the group, since it was unique to this source
			},
			// else  its just a regular source
			{
				var synth = satie.groupInstances[thisGroupName][nameSym];
				satie.cleanInstance(nameSym,thisGroupName );
				if (satie.satieConfiguration.debug,
					{postf("•satieOSC.clearSourceNode: delete  node  % in group %\n", nameSym, thisGroupName);});
		});

		//  clear node's local dictionary
		// probably this is unnecessary
		nodeKeys.do { | key |
			//postf("removing node keys:  node: %   key %  \n",  nameSym, key);
			node.removeAt(key);
		};
	}

	createSource {| sourceName, uriPath , groupName = \default |
		//"createSource called".inform;
		if (allSourceNodes.includesKey(sourceName),
			{
				postf("satieOSC.createSource:   % exists, no action \n", sourceName);
			},
			// else create new node
			{
				var type;
				type = this.getUriType(uriPath);

				if (  (type == \plugin)  ||  (type== \effect),
					{
						this.createSourceNode(sourceName.asSymbol, uriPath,groupName );
					},
					// else
					{
						postf("satieOSC.createSource: node  %  URI: %,  wrong type,  no action \n", sourceName, type);
				});

			}
		);
	}

	getUriType { | uriPath |
		var charIndex, uriName, type;

		type = "";

		// type://name (i.e. plugin://DustDust, file://<path>

		// check URI name to make sure its valid

		if (uriPath.asString.contains("://") == false,
			{
				if (uriPath.size > 0, {warn("~getUriType:  uri type format error: "++uriPath++" \n");});
			},

			// else  // path ok, proceed
			{
				charIndex = uriPath.asString.find("://");
				type = uriPath.asString.split($:)[0];
				~type = type;
				// uriName = temp.asString.replace("://", "");
		});
		^type.asSymbol;
	}

	createSourceNode { | sourceName, synthName , groupName |
		var type, synth;

		if (satie.satieConfiguration.debug, {"→    %: sourceName: %,  synthName: %,  groupName: %".format(this.class.getBackTrace, sourceName,synthName,groupName).postln});

		// check to see if group  exists,  if  not, create it
		if (  allGroupNodes[groupName] == nil,
			{
				postf("~satieOSC.createSourceNode:   source:%    group:  % undefined,  creating  group  \n", sourceName, groupName);
				this.createGroup(groupName);
		});


		// make sure group is not located at the tail (used by efffects)
		if (  allGroupNodes[groupName].at(\position) == \tail,
			{
				error("satieOSC.createSourceNode: node "++sourceName++"'s group: "++groupName++" is an effects group. Setting group to default group");
				groupName = \default;
		});


		allSourceNodes[sourceName.asSymbol] = Dictionary();   // create node  -- create node-specific dict.
		// allSourceNodes[sourceName.asSymbol].put(\uriStr, uriString);

		synth = satie.makeInstance(sourceName.asSymbol, synthName, groupName);
		synth.register(); // register with NodeWatcher for testing

		allSourceNodes[sourceName.asSymbol].put(\groupNameSym, groupName);
		allSourceNodes[sourceName.asSymbol].put(\plugin, synthName);
		allSourceNodes[sourceName.asSymbol].put(\synth, synth);

		postf(">>satieOSC.createSourceNode:  creating %:  uri: %  group: %\n", sourceName, synthName, groupName);

	}

	createEffectNode { | sourceName, synthName , groupName, auxBus|
		var synth;
		if (satie.satieConfiguration.debug, {"→    %: sourceName: %,  synthName: %,  groupName: %,  auxBus %".format(this.class.getBackTrace, sourceName,synthName,groupName, auxBus).postln});


		// check to see if group  exists,  if  not, create it on the tail
		if (  allGroupNodes[groupName] == nil,
			{
				postf("~satieOSC.createEffectNode:   source:%    group:  % undefined,  creating  group on tail of DSP chain  \n", sourceName, groupName);
				this.createGroup(groupName, \addToTail);
			},
			// else make sure named group is on the tail, if not, set to defaultFx group
			{
				if (  allGroupNodes[groupName].at(\position) != \tail,
					{
						error("satieOSC.createEffectNode: node "++sourceName++"'s group: "++groupName++" is not an effects group. Setting group to defaultFx group");
						groupName = \defaultFx;
				});
		});



		allSourceNodes[sourceName.asSymbol] = Dictionary();   // create node  -- create node-specific dict.
		allSourceNodes[sourceName.asSymbol].put(\groupNameSym, groupName);
		allSourceNodes[sourceName.asSymbol].put(\plugin, synthName);

		postf("satieOSC.createEffectNode: creating effects node % of group %, with  synth:  % on bus %, \n", sourceName, groupName, synthName, auxBus);
		synth = satie.makeInstance(sourceName, synthName, groupName, [\in, satie.aux[auxBus] ]);

		allSourceNodes[sourceName.asSymbol].put(\synth, synth);
	}


	checkUri { | nodeName, uriString |
		var type = this.getUriType(uriString);

		//uriString.postln;
		if ( (type != \plugin) && (type != \effect),
			{
				error("~checkUri:  node: %  bad URI: % , using default: \n", nodeName, uriString);
				^nil;
			},
			{
				^uriString;
		});
	}

	createGroup { | groupName, position=\addToHead|

		var groupPos = \head;

		if (position != \addToHead,
			{
				groupPos = \tail;
				position = \addToTail;
		});

		if (allGroupNodes.includesKey(groupName),
			{
				postf("satieOSC.createGroup:  GroupNode % exists, no action \n", groupName);
				allGroupNodes[groupName.asSymbol].at(\group);  // return group
			},
			// else create new group node
			{
				var group;

				if (satie.groups[groupName.asSymbol] != nil, // group already exists in SATIE, no need to create it
					{
						group = satie.groups[groupName.asSymbol];
					},
					// else  group does not exist in SATIE,  create it
					{
						group = satie.makeSatieGroup(groupName.asSymbol, position);
						if ( groupName.asSymbol == \default,
							{
								postf("satieOSC.createGroup:  BUG FOUND-- SHOULD NOT HAVE TO INSTANITATE DEFAULT GROUP !!!!");
						});
				});

				allGroupNodes[groupName.asSymbol] = Dictionary();   // create node  -- create node-specific dict.
				allGroupNodes[groupName.asSymbol].put(\group , group);  // save group
				allGroupNodes[groupName.asSymbol].put(\groupSym , groupName.asSymbol);  // save group name symbol
				allGroupNodes[groupName.asSymbol].put(\plugin, \nil);
				allGroupNodes[groupName.asSymbol].put(\position, groupPos);  //  indicates group DSP chain evaluation order  (head or tail)

				//  set group
				allGroupNodes[groupName.asSymbol].put(\group, group );

				postf(">>satieOSC.createGroup:  creating   %   groupType: %\n", groupName, groupPos);

				^group;  // returns groups
			}
		);
	}

	setSynth {|nodeName, pluginName |
		var validPluginName = pluginName;
		var sourceNode = allSourceNodes[nodeName.asSymbol];
		var groupName = sourceNode.at(\groupNameSym);
		var type;
		var inBus;

		var uriPath = sourceNode.at(\uriStr);

		type = this.getUriType( uriPath );


		if (satie.satieConfiguration.debug,
			{postf("•satieOSC.setSynth: node: %   uriStr: %  group: %  type: % \n",  nodeName, uriPath,  groupName,  type);});

		if (validPluginName.asSymbol != allSourceNodes[nodeName.asSymbol].at(\plugin).asSymbol,
			{
				// replace existing with new plugin
				var synth;

				// check to see if a synth has already been allocacted, if so, kill it
				if  ( allSourceNodes[nodeName.asSymbol].at(\synth) != nil,
					{
						'satieOSC.setSynth: REPLACE EXISTING SYNTH'.postln;
						satie.cleanInstance(nodeName.asSymbol,groupName.asSymbol );
				});

				sourceNode.put(\plugin, validPluginName.asSymbol);

				if ( ( type == \effect) ,
					{
						inBus = this.getFxInBus(uriPath);
						postf("satieOSC.setSynth: assigning inBus: % to effects node % -- %\n", satie.aux[inBus] , nodeName, validPluginName.asSymbol);
						synth = satie.makeInstance(nodeName.asSymbol, validPluginName.asSymbol, groupName.asSymbol, [\in, satie.aux[inBus] ]);
					},
					// else
					{
						synth = satie.makeInstance(nodeName.asSymbol, validPluginName.asSymbol, groupName.asSymbol);
				});
				synth.register(); // register with NodeWatcher for testing
				sourceNode.put(\synth, synth);
			},
			{
				// else plugin already set, take no action
			}
		);
	}

	getUriName { | uriPath |
		var uriName, uriSynth;
		~uriPAth = uriPath;
		uriName = uriPath.asString.split($ );
		uriSynth = uriName[0].asString.split($/)[2];

		^uriSynth.asString;
	}

	clearScene {
		var nodelist = allSourceNodes.keys;
		"clearScene called".warn;

		// first flush all nodes
		allSourceNodes.keysDo { |key |
			this.clearSourceNode(key);
		};

		allSourceNodes.clear();
		allSourceNodes.size;
	}

	// receives OSC messages that look like:   /satie/load filename
	loadFile {
		^{ | msg |
			"SatieOSC : satieFileLoader called".postln;
			if ( (msg.size < 2 ) ,
				{"SatieOSC : satieFileLoader:  message missing filepath".warn;},
				// else
				{
					var filepath = msg[1].asString.standardizePath;   // can handle '~'

					if ( File.exists(filepath) == false,
						{
							error("SatieOSC: satieFileLoader:   "++filepath++" not found, aborting");
						},
						// else  file exists, process
						{

							if (filepath.splitext.last != "scd",
								{
									error("SatieOSC : satieFileLoader: "++filepath++" must be a file of type  '.scd'  ");
								},
								// else file type is good. Try to load
								{
									satie.satieConfiguration.server.waitForBoot {

										filepath.load;
										satie.satieConfiguration.server.sync;
									}; // waitForBoot
							});
					});
			});
		}
	}

	// handles /satie/nodetype/state  nodeName flag
	setState {
		^{ | args |
			var type = args[0].asString.split[2].asSymbol;

			if ( satie.satieConfiguration.debug,
				{
					postf("•satieOSC.setStateHandler: % \n", args);
			});

			// verify message
			if (  ( args.size != 3)  ,
				{
					error("satieOSCProtocol.setStateHandler: bad messafe length: expects oscAddress nodeName val % \n", args);
				}, // else args good
				{
					var nodeName  = args[1];
					var value = args[2];
					var targetNode = nil;
					var state;

					if ( value == 0 , { state = false}, {state = true});

					switch(type,
						'source',
						{
							if ( allSourceNodes.includesKey(nodeName.asSymbol) == true,
								{
									targetNode = this.getSourceNode(nodeName, \synth);
									if ( targetNode == nil,
										{
											error("satieOSCProtocol.setStateHandler:  source node: "++nodeName++"  BUG FOUND: undefined SYNTH  \n");
										}, // else good to go
										{
											targetNode.run(state);
											targetNode.register(); // register with NodeWatcher, for state checking
									});
								},
								{
									error("satieOSCProtocol.setStateHandler:  source node: "++nodeName++"  is undefined \n");
							}); // else node exists,  process event
						},
						'group',
						{
							if (  allGroupNodes.includesKey (nodeName.asSymbol) == true,
								{
									targetNode = allGroupNodes[nodeName.asSymbol].at(\group).group;
									targetNode.run(state);
									targetNode.register(); // register with NodeWatcher, for state checking

								},
								{   // else no group
									error("satieOSCProtocol.setStateHandler:  group node: "++nodeName++"  is undefined \n");
							});
						},
						'process',
						{
							if ( allSourceNodes.includesKey(nodeName.asSymbol) == true,
								{
									var thisGroupName = allSourceNodes[nodeName.asSymbol].at(\groupNameSym);  // process nodes have unique groups
									var thisGroup = allGroupNodes[thisGroupName].at(\group).group;
									var myProcess = this.getSourceNode(nodeName, \process);

									if ( myProcess == nil,
										{
											error("satieOSCProtocol.setStateHandler:  process node: "++nodeName++"  BUG FOUND: undefined process  \n");
										},
										{  // good to go
											if ( myProcess[\state].class == Function,     // does the process implement the \state handler
												{
													myProcess[\state].value(myProcess, state);   // yes, call it
												},
												{
													thisGroup.run(state);   // or just update the process's group
													// thisGroup.register(); // TODO: is this relevant for processes?
											});
									});
								},
								{  // else error
									error("satieOSCProtocol.setStateHandler:  process node: "++nodeName++"  is undefined \n");
							});
					});
			});
		};
	}
}