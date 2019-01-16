SatieOSC {

	var satie;
	var <rootURI;
	var <>oscServerPort;
	var <>oscClientPort;
	var <>oscClientIP;

	// client
	var <dynamicResponder;
	var returnAddress;

	// used for audio renderer control
	var volume;     // will point to server volume / mute control
	var outputDB = 0;    // current state of the supercollider server output
	var outputTrimDB = 0;

	// custom update message. These keys will be mached with sent values.
	var update_message_keys;
	var <>update_custom_keys;

	var <oscDefs;

	// TODO satieContext must be an array in order to duplicate message forwarding to sc server
	*new { | satieContext, rootPath = "/satie", serverPort = 18032, clientPort = 18060 |
		^super.newCopyArgs(satieContext, rootPath, serverPort, clientPort).initOSC;
	}

	initOSC {
		" - satie: %\n - rootURI: %\n - port: %".format(satie, rootURI, oscServerPort).postln;
		" + %".format(satie.config.server).postln;
		oscDefs = IdentityDictionary.new;
		dynamicResponder = true;
		oscClientIP = "localhost";
		returnAddress = NetAddr(this.oscClientIP, this.oscClientPort);
		volume = satie.config.server.volume;
		volume.setVolumeRange(-99, 18);
		update_message_keys = [\aziDeg, \eleDeg, \gainDB];
		update_custom_keys = List.new();

		// set up default groups
		if ( satie.groups[\default] == nil,
			{
				postln("satieOSC.INIT:  \default group not defined on the server, creating \default group on head");
				this.createGroup(\default);
			});

		// set up defaultFx group
		if ( satie.groups[\defaultFx] == nil,
			{
				postln("satieOSC.INIT:  \defaultFx group not defined on the server, creating \defaultFx group on tail");
				this.createGroup(\defaultFx,\addToTail);
			});


		// scene level handler
		this.newOSC(\satieSceneCreateSource, this.createSourceHandler, "/satie/scene/createSource");
		this.newOSC(\satieSceneCreateEffect, this.createEffectHandler, "/satie/scene/createEffect");
		this.newOSC(\satieSceneCreateProcess, this.createProcessHandler, "/satie/scene/createProcess");
		this.newOSC(\satieSceneCreateSourceGroup, this.createSourceGroupHandler, "/satie/scene/createSourceGroup");
		this.newOSC(\satieSceneCreateEffectGroup, this.createEffectGroupHandler, "/satie/scene/createEffectGroup");
		this.newOSC(\satieSceneCreateProcessGroup, this.createProcessGroupHandler, "/satie/scene/createProcessGroup");

		this.newOSC(\satieSceneDeleteNode, this.deleteNodeHandler, "/satie/scene/deleteNode");
		this.newOSC(\satieDebugFlag, this.debugFlagHandler, "/satie/scene/debug");
		this.newOSC(\satieClearScene, this.clearSceneHandler, "/satie/scene/clear");

		// node level handlers
		this.newOSC(\satieSrcState, this.stateSourceHandler, "/satie/source/state");
		this.newOSC(\satieGroupState, this.stateGroupHandler, "/satie/group/state");
		this.newOSC(\satieProcState, this.stateProcHandler, "/satie/process/state");
		this.newOSC(\satieSrcSet, this.setSrcHandler, "/satie/source/set");
		this.newOSC(\satieGroupSet, this.setGroupHandler, "/satie/group/set");
		this.newOSC(\satieProcSet, this.setProcHandler, "/satie/process/set");
		this.newOSC(\satieSrcUpdate, this.updateSrcHandler, "/satie/source/update");
		this.newOSC(\satieGroupUpdate, this.updateGroupHandler, "/satie/group/update");
		this.newOSC(\satieProcUpdate, this.updateProcHandler, "/satie/process/update");
		this.newOSC(\satieSrcSetVec, this.setVecSourceHandler, "/satie/source/setvec");
		this.newOSC(\satieGroupSetVec, this.setVecGroupHandler, "/satie/group/setvec");
		this.newOSC(\satieProcSetVec, this.setVecProcHandler, "/satie/process/setvec");

		// process only handlers
		this.newOSC(\satieProcProp, this.propertyProcHandler, "/satie/process/property");
		this.newOSC(\satieProcEval, this.evalFnProcHandler, "/satie/process/eval");




		// client
		this.newOSC(\audioplugins, this.getAudioPlugins, "/satie/plugins");
		this.newOSC(\pluginArgs, this.getPluginArguments, "/satie/pluginargs");
		this.newOSC(\pluginDetails, this.getPluginDetails, "/satie/plugindetails");
		this.newOSC(\responderAddress, this.returnAddress, "/satie/responder");

		this.newOSC(\satieLoadFile, this.loadFile, "/satie/load");

		this.newOSC(\satieRendererSetOrientationDeg, this.setOrientationDegHandler, "/satie/renderer/setOrientationDeg");
		this.newOSC(\satieRendererSetOutputDB, this.setOutputDBHandler, "/satie/renderer/setOutputDB");
		this.newOSC(\satieRendererSetOutputTrimDB, this.setOutputTrimDBHandler, "/satie/renderer/setOutputTrimDB");
		this.newOSC(\satieRendererSetOutputMute, this.setOutputMuteHandler, "/satie/renderer/setOutputMute");
		this.newOSC(\satieRendererSetOutputDim, this.setOutputDimHandler, "/satie/renderer/setOutputDim");
		this.newOSC(\satieRendererFreeSynths, this.freeSynthsHandler, "/satie/renderer/freeSynths");

		// This is for the exclusive use of SendTrig, which (invariably) sends a trigger message to '/tr' path.
		// We use OSCdef directly because currently newOSC custom method does not give us full control over
		// OSCdef instance.
		oscDefs.put(
			\satieTrigger,
			OSCdef(\satieTrigger, this.triggerHandler, "/tr", satie.config.server.addr);
		);
		// and another receiver for SendReply attached to the envelope follower
		oscDefs.put(
			\satieEnvelope,
			OSCdef(\satieEnvelope, this.envelopeHandler, "/analysis", satie.config.server.addr);
		);
	}

	/*      create a new OSC definition*/
	newOSC { | id, cb, path = \default |
		var key = id.asSymbol;
		oscDefs.put(
			key,
			OSCdef(key, cb, path, recvPort: oscServerPort)
		);
	}

	deleteOSC { |id|
		var key = id.asSymbol;
		OSCdef(key).free;
		oscDefs.removeAt(key);
	}

	deleteAll {
		oscDefs.keysDo({ |key| OSCdef(key).free });
		oscDefs.clear;
	}

	removeGroup { | groupName |
		if ( satie.groups.includesKey(groupName.asSymbol) ,
			{
				if (satie.config.debug, {postf("•satieOSC.removeGroup:  group node: % \n",  groupName);});
				satie.groups.removeAt(groupName.asSymbol);     // remove node from global dictionary
		});
	}

	deleteSource { | nodeName |
		satie.groupInstances.keys.do({|gr, idx|
			if ( satie.groupInstances[gr].includesKey(nodeName.asSymbol) ,
				{
					this.clearSourceNode(nodeName.asSymbol, gr.asSymbol);
				});
		});
	}

	clearSourceNode {  | nameSym, group = \default |
		var node = nameSym.asSymbol;
		// is this a process node?
		if ( satie.processInstances.includesKey(node),
			{
				satie.cleanProcessInstance(node);
			},
			// else  its just a regular source
			{
				if (satie.groupInstances[group].includesKey(node),
					{
						satie.cleanInstance(node, group.asSymbol);
					},
					{
						"%: node: % does not exist".format(this.class.getBackTrace, node).warn;
					}
				);
				if (satie.config.debug,
					{postf("•satieOSC.clearSourceNode: delete  node  % in group %\n", nameSym, group);});
		});
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

	createSourceNode { | sourceName, synthName , groupName=\default |
		var type, synth;

		if (satie.config.debug, {"→    %: sourceName: %,  synthName: %,  groupName: %".format(this.class.getBackTrace, sourceName,synthName,groupName).postln});

		synth = satie.makeSourceInstance(sourceName.asSymbol, synthName, groupName);

		postf(">>satieOSC.createSourceNode:  creating %:  uri: %  group: %\n", sourceName, synthName, groupName);

	}

	createEffectNode { | sourceName, synthName , groupName=\defaultFx, auxBus|
		var synth;
		if (satie.config.debug, {"→    %: sourceName: %,  synthName: %,  groupName: %,  auxBus %".format(this.class.getBackTrace, sourceName,synthName,groupName, auxBus).postln});

		synth = satie.makeFxInstance(sourceName, synthName, groupName, [\in, satie.aux[auxBus] ]);
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

		if (satie.groups.includesKey(groupName),
			{
				postf("satieOSC.createGroup:  GroupNode % exists, no action \n", groupName);
				satie.groups[groupName.asSymbol];  // return group
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
					});

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
					var filepath = msg[1].asString.standardizePath;   // can handle '~'\
					satie.executeExternalFile(filepath);
			});
		}
	}
}
