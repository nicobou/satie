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

		// set up default groups
		if ( satie.groups[\default] == nil,
			{
				warn("satieOSC.INIT:  \default group not defined on the server, creating \default group on head");
				this.createGroup(\default);
			},
			// else all good, create an entry for \default group
			{
				allGroupNodes[\default] = Dictionary();   // create group node  -- create node-specific dict.
				allGroupNodes[\default].put(\group , satie.groups[\default] );  // set group
				allGroupNodes[\default].put(\groupSym , \default);  // save group name symbol
				allGroupNodes[\default].put(\plugin, \nil);
				allGroupNodes[\default].put(\position, \head);  //  indicates group DSP chain evaluation order  (head or tail)
				postf(">>satieOSC.INIT:  setting up   % group at head of server groups %\n", \default);
		});

		// set up defaultFx group
		if ( satie.groups[\defaultFx] == nil,
			{
				warn("satieOSC.INIT:  \defaultFx group not defined on the server, creating \defaultFx group on tail");
				this.createGroup(\defaultFx,\addToTail);
			},
			// else all good, create an entry for \defaultFx group
			{
				allGroupNodes[\defaultFx] = Dictionary();   // create group node  -- create node-specific dict.
				allGroupNodes[\defaultFx].put(\group , satie.groups[\defaultFx] );  // set group
				allGroupNodes[\defaultFx].put(\groupSym , \defaultFx);  // save group name symbol
				allGroupNodes[\defaultFx].put(\plugin, \nil);
				allGroupNodes[\defaultFx].put(\position, \effect);  //  indicates group DSP chain evaluation order  (head or tail)
				postf(">>satieOSC.INIT:  setting up   % group at after the default group\n", \defaultFx);
		});


		// scene level handler
		this.newOSC(\satieSceneCreateSource, this.createSourceHandler, "/satie/scene/createSource");
		this.newOSC(\satieSceneCreateEffect, this.createEffectHandler, "/satie/scene/createEffect");
		this.newOSC(\satieSceneCreateGroup, this.createGroupHandler, "/satie/scene/createGroup");
		this.newOSC(\satieSceneCreateProcess, this.createProcessHandler, "/satie/scene/createProcess");
		this.newOSC(\satieSceneDeleteNode, this.deleteNodeHandler, "/satie/scene/deleteNode");
		this.newOSC(\satieDebugFlag, this.debugFlagHandler, "/satie/scene/debugFlag");
		this.newOSC(\satieClearScene, this.clearSceneHandler, "/satie/scene/clear");

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
		if (  allGroupNodes[groupName].at(\position) == \effect,
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

		if (groupName == \default,
			{
				warn("satieOSC.createEffectNode: changing  "++sourceName++"'s group: "++groupName++" to: defaultFx group");
				groupName = \defaultFx;
		});

		// check to see if group  exists,  if  not, create it on the tail
		if (  allGroupNodes[groupName] == nil,
			{
				postf("~satieOSC.createEffectNode:   source:%    group:  % undefined,  creating  group on tail of DSP chain  \n", sourceName, groupName);
				this.createGroup(groupName, \effect);
			},
			// else make sure named group is on the tail, if not, set to defaultFx group
			{
				if (  allGroupNodes[groupName].at(\position) != \effect,
					{
						error("satieOSC.createEffectNode: node "++sourceName++"'s group: "++groupName++" is not an effects group. Setting group to defaultFx group");
						groupName = \defaultFx;
				});
		});

		allSourceNodes[sourceName.asSymbol] = Dictionary();   // create node  -- create node-specific dict.
		allSourceNodes[sourceName.asSymbol].put(\groupNameSym, groupName);
		allSourceNodes[sourceName.asSymbol].put(\plugin, synthName);
		synth = satie.makeInstance(sourceName, synthName, groupName, [\in, satie.aux[auxBus] ]);
		allSourceNodes[sourceName.asSymbol].put(\synth, synth);
		postf("satieOSC.createEffectNode: creating effects node % of group %, with  synth:  % on bus %, \n", sourceName, groupName, synthName, auxBus);
	}


	createGroup { | groupName, position=\addToHead|

		var groupPos = \head;
		var addAction = \addToHead;

		if (position == \addToTail,
			{
				groupPos = \effect;
				addAction = \addToTail;
		});

		if (position == \effect,
		{
				groupPos = \effect;
				addAction = \addToEffects;
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
						group = satie.makeSatieGroup(groupName.asSymbol, addAction);
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

	getUriName { | uriPath |
		var uriName, uriSynth;
		~uriPAth = uriPath;
		uriName = uriPath.asString.split($ );
		uriSynth = uriName[0].asString.split($/)[2];

		^uriSynth.asString;
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