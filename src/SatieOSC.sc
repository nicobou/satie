SatieOSC {
	var satie;
	var <rootURI;
	var <>oscPort;

	// private
	var allSourceNodes;
	var allGroupNodes;

	*new { | satieContext, rootPath = "/satie", port = 18032|
		^super.newCopyArgs(satieContext, rootPath, port).initOSC;
	}

	initOSC {
		" - satie: %\n - rootURI: %\n - port: %".format(satie, rootURI, oscPort).postln;
		" + %".format(satie.satieConfiguration.server).postln;
		allSourceNodes = Dictionary();
		allGroupNodes = Dictionary();
		this.newOSC(\satieScene, this.coreHandler, "/satie/scene");
		Log(this.class).formatter = {
			|item, log|
			"%.%: %".format(log.name, log.level, item.string);
		}
	}

	/*      create a new OSC definition*/
	newOSC { | id, cb, path = \default |
		"newOSC called".postln;
		OSCdef(id.asSymbol, cb, path, recvPort: oscPort);
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
					Log(\coreHandler).error("createSource message missing values");
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
						},
						'clear',
						{
							this.clearScene();
						};
					)
			});
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
				" -- got type %".format(type).postln;
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
		Log(\getUriType).warning("got %".format(uriPath));

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

	createSourceNode { | sourceName, uriString , groupName = \default, argsList|
		var synthName;
		var type;
		~uriString = uriString;

		// MAKE SURE URI STRING IS VALID -- if not, will post warning
		uriString = this.checkUri(sourceName, uriString);

		type = this.getUriType(uriString);

		if (groupName == "", { groupName = \default; });   // play it safe: make sure group name is defined


		//
		if ( (type == \effect) &&  (groupName == \default), { groupName = \defaultFx;});


		// check to see if group  exists,  if  not, create it
		if (  allGroupNodes[groupName] == nil,
			{
				postf("~satieOSC.createSourceNode:   source:%    group:  % undefined,  creating  group  \n", sourceName, groupName);
				if (type == \effect,
					{
						thiscreateGroup(groupName.asSymbol, \addToTail);
					},
					{
						this.createGroup(groupName.asSymbol);
				});
		});

		// check to make sure group type is kosher for effects
		if (  allGroupNodes[groupName.asSymbol] != nil,
			{
				if (type == \effect,
					{
						if (  allGroupNodes[groupName.asSymbol].at(\position) != \tail,
							{
								error("satieOSC.createSourceNode: node "++sourceName++"'s group: "++groupName++" is not an effects group. Setting group to defaultFx group");
								groupName = \defaultFx;
						});
				});
				// else  fix it if its a plugin with an effects group
				if (type == \plugin,
					{
						if (  allGroupNodes[groupName.asSymbol].at(\position) == \tail,
							{
								error("satieOSC.createSourceNode: node "++sourceName++"'s group: "++groupName++" is an effects group. Setting group to default group");
								groupName = \default;
						});
				});
		});

		allSourceNodes[sourceName.asSymbol] = Dictionary();   // create node  -- create node-specific dict.
		allSourceNodes[sourceName.asSymbol].put(\plugin, \nil);
		allSourceNodes[sourceName.asSymbol].put(\uriStr, uriString);

		// now set node's group
		allSourceNodes[sourceName.asSymbol].put(\groupNameSym, groupName.asSymbol);

		if ( ( (type != \plugin) &&  (type != \effect) ),
			{
				error("satieOSC.createSourceNode: BUG FOUND IN CODE:   BAD URI  " );
			},
			// else  // path format ok, proceed
			{
				synthName = this.getUriName(uriString);
				postln("synthname: "++synthName);

				this.setSynth(sourceName.asSymbol, synthName);
		});

		postf(">>satieOSC.createSourceNode:  creating %:  uri: %  group: %\n", sourceName, uriString, groupName);

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
			clearSourceNode(key);
		};

		allSourceNodes.clear();
		allSourceNodes.size;
	}

	// handles /satie/nodetype/state  nodeName flag
	setState { | args |
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
								targetNode = allSourceNodes[nodeName.asSymbol].at(\synth);
								if ( targetNode == nil,
									{
										error("satieOSCProtocol.setStateHandler:  source node: "++nodeName++"  BUG FOUND: undefined SYNTH  \n");
									}, // else good to go
									{
										targetNode.run(state);
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
								var myProcess = allSourceNodes[nodeName.asSymbol].at(\process);

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
											});
									});
							},
							{  // else error
								error("satieOSCProtocol.setStateHandler:  process node: "++nodeName++"  is undefined \n");
							});
					});
			});
	}
}
