//// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
/*
NOTES:
this implementation is based on a one-listener model. In the future, we may wish to exapnd this to integrate more than one.  In such a case, proivision will have to be made so that multiple listener synth-defs can be defined.
OSC RX message specification is based on the SPATOSC specification  (see:   http://code.sat.qc.ca/redmine/projects/spatosc/wiki/spec  )
*/

/*
s.makeGui;
s.meter

s.dump
 s.reboot;
~allSourceNodes.size;
*/

(
// set these flags depending on your environment

~superNovaFlag = true;

//~listeningFormat = \domeVBAP;       // for sato
//~listeningFormat = \labodomeVBAP;      // for labodome
~listeningFormat = \stereoListener;      // for labodome

//~outAudioDev = "Soundflower (64ch)";   //  for multi-channel testing without hardware on OSX
//~outAudioDev = "MADIface USB (23635751)";     // for labodome or SATO


if ( ~superNovaFlag != nil,
	{
		Server.supernova;
});

o = Server.local.options;   // default set up options
o.memSize = 2**19;        // probably should just leave this the same for everyting



// o.device = "MADIface USB (23635751)";     // set for dome or labodome

if ( ~listeningFormat == \domeVBAP,
	{
		o.numOutputBusChannels = 32;
		~outAudioDev = "MADIface USB (23635751)";
		// o.dump;
});

if ( ~listeningFormat == \labodomeVBAP,
	{
		o.numOutputBusChannels = 32;
		~outAudioDev = "MADIface USB (23635751)";
		// o.dump;
});



if ( ~outAudioDev != nil ,
	{
		o.device = ~outAudioDev;
});


s.waitForBoot{


	// finding source directory
	~rootSrcPath = thisProcess.nowExecutingPath.dirname ++ "/..";
	(~rootSrcPath ++ "/src/*.scd").pathMatch.do({arg item; item.loadPaths});

	~num_aux_bus = 5;
	// creating a sc-basic-renderer
	~scbr = ~scbrMaker.value(numAudioAux: ~num_aux_bus);
	// printing internal aux array with bus indexes
	~scbr.aux;
	// loading source plugins
	~scbr.pluginLoader.loadAudioPlugins(~rootSrcPath ++ "/audiosources/*.scd");
	// see the loaded plugins in the console
	~scbr.pluginLoader.audioPlugins;
	// loading spatializer plugins
	~scbr.pluginLoader.loadSpatPlugins(~rootSrcPath ++ "/spatializers/*.scd");
	~scbr.pluginLoader.spatPlugins;

	~scbr.makeSynthDef(\dummyPlugin, \emptySource, [\emptySpat], [0]);    // dummy synthdef, used for new nodes

	if ( ~listeningFormat == nil,
		{
			// NEEDS IMPROVEMENT
			// all plugins (synthDefs) have to be evaluated in "pre-runtime" herea
			//
			'NO LISTENING FORMAT SELECTED : generating synthdefs'.postln;

			~scbr.makeSynthDef(\pink, \PinkSin, [\stereoPanner, \monoSpat], [0, 2]);
			~scbr.makeSynthDef(\dust, \DustDust, [\stereoPanner, \monoSpat], [0, 2]);
			~scbr.makeSynthDef(\default, \default, [\stereoListener], [0]);
			~scbr.makeSynthDef(\zkarpluck0, \zkarpluck0, [\stereoListener], [0]);
			~scbr.makeSynthDef(\zkarpluck1, \zkarpluck1, [\stereoListener], [0]);
			~scbr.makeSynthDef(\zbell1, \zbell1, [\stereoListener], [0]);
			~scbr.makeSynthDef(\test, \testtone, [\stereoListener], [0]);
		},
		// else evalualte for dome listeners
		{
			postf("generating synthdefs for %\n", ~listeningFormat);
			~scbr.makeSynthDef(\pink, \PinkSin, [~listeningFormat], [0]);
			~scbr.makeSynthDef(\dust, \DustDust, [~listeningFormat], [0]);
			~scbr.makeSynthDef(\default, \default, [~listeningFormat], [0]);
			~scbr.makeSynthDef(\zkarpluck0, \zkarpluck0, [~listeningFormat], [0]);
			//~scbr.makeSynthDef(\zkarpluck1, \zkarpluck1, [~listeningFormat], [0]);
			~scbr.makeSynthDef(\test, \testtone,  [~listeningFormat], [0]);
			~scbr.makeSynthDef(\zbell1, \zbell1, [~listeningFormat], [0]);
			~scbr.makeSynthDef(\zkarpluck1, \zkarpluck1, [~listeningFormat], [0], [~scbr.aux[0]]);
			~scbr.makeSynthDef(\busreverb, \freeverb, [~listeningFormat], [0]);

		}
	);

	// be sure the synthDefs are compiled on the server
	s.sync;

	OSCdef(\createSoundSource).clear.free;  // just in case newOSC will be re-evaluated.
	~scbr.oscInterface.newOSC(\createSoundSource, ~coreCallback, "/spatosc/core");


	// ******************** usage with JITlib & ProxySpace *********************


		if ( ~prox == nil,
		{

		// creating a global ProxySpace
			~prox = ProxySpace(s);
			~prox.fadeTime = 2;

			// creating a global SOURCE ParGroup for supernova
			~group = ParGroup.new; // ~group.freeAll;

			// the proxyspace is going to be embedded in the global pargroup
			~prox.group = ~group;
	});


	if ( ~proxEffect == nil,
		{
			// creating a global ProxySpace for effects
			~proxEffect = ProxySpace(s);
			~proxEffect.fadeTime = 2;

			// creating a global EFFECT ParGroup for supernova,  located at tail of chain
			~groupEffect = ParGroup.new(addAction: \addToTail);

			// the proxyspace is going to be embedded in the global pargroup
			~proxEffect.group = ~groupEffect;
	});


	//instance factory
	~makeinstance = { | name = \out, p, src = \string |
		// ensuring not extra bus is allocated:
		// (must be the first reference of "name" in the proxyspace
		p[name].ar(0);
		p[name].source = src;
		nil;
	};
	~cleaninstance = { | name = \out, p |
		p[name].release();
		// fadeTime must be higher than SATIE internal fadeTime:
		p.[name].clear(0.03);
		nil;
	};
	~pauseinstance = { | name = \out, p |
		p[name].release();
		nil;
	};

	// dictionarys for source nodes
	~allSourceNodes = Dictionary();        //  ~allSourceNodes.postln;
	~allGroupNodes = Dictionary();        //  ~allGroups.postln;


	~coreCallback = {
		arg msg;
		var command;
		command = msg[1];
		//postf("~coreCallback: command: %, msg: %, \n", command, msg);

		switch (command,
			'createSource',
			{
				if ( (msg.size < 3 ) ,
					{"~coreCallback: OSCrx createSource message missing values".warn;
						postf("CREATESOURCE MESS LEN: %", msg.size);

					},
					// else
					{
						var sourceName = msg[2];
						var uriName;

						if (msg.size == 3,
							{
								uriName = "";
							},
							// else
							{
								uriName = msg[3];
						});

						~createSource.value(sourceName, uriName);
					}
				)
			},
			'createGroup',
			{
				if ( (msg.size < 3 ) ,
					{"~coreCallback: OSCrx createSource message missing values".warn;
						postf("CREATESOURCE MESS LEN: %", msg.size);

					},
					// else
					{
						var sourceName = msg[2];
						~createGroup.value(sourceName);
					}
				)
			},
			'deleteNode',
			{
				if ( (msg.size < 3 ) ,
					{"~coreCallback: OSCrx deleteNode message missing values".warn;},
					// else
					{
						var nodeName = msg[2];

						if (~allGroupNodes.includesKey(nodeName.asSymbol),
							{   ~deleteGroup.value(nodeName);  },
							// else
							{  ~deleteSource.value(nodeName);   });
					}
				)
			},
			'clear', {~clearScene.value();},
			'connect',
			{
				if ( (msg.size < 4 ) ,
					{"~coreCallback: OSCrx connect message missing values".warn;},
					// else
					{
						var sourceName, listenerName;
						sourceName = msg[2];
						listenerName = msg[3];
						~createConnection.value(sourceName, listenerName);
					}
				)
			};
		);
	};


	// /spatosc/core/connection/source->listener/update azi elev gainDB delayMS  lpHZ
	// /spatosc/core/connection/source->listener/spread  exp   // exponent for incidence effect
	~connectionCallback = { | args |
		var nodeName, listenerName, connectionName, type, temp, charIndex;
		var aziDeg, eleDeg, gainDB, delayMs, lpHz, spread;
		var thisProxy;

		//args.postln;
		connectionName = args[0].asString.split[4].asSymbol;   // this is terrible.  ThespatOSC message format could be improved here
		type = args[0].asString.split[5].asSymbol;
		charIndex = connectionName.asString.find("->");

		nodeName = connectionName.asString.subStr(0, charIndex-1);
		//postf("~connectionCallback:  connectionName: %  type: %  size: % args: %\n", connectionName, type, args.size, args);

		thisProxy = ~allSourceNodes[nodeName.asSymbol].at(\proxy);

		switch(type,
			'update',
			{
				if ( (args.size != 6 ) ,
					{"connectionCallback: OSCrx update message missing values".warn;},
					// else
					{
						// get values from vector, and write to connectionState
						aziDeg = args[1].raddeg;
						eleDeg= args[2].raddeg;
						gainDB = args[3];
						delayMs = args[4];
						lpHz = args[5];

						thisProxy[nodeName.asSymbol].set(\aziDeg, aziDeg, \eleDeg, eleDeg, \gainDB, gainDB, \delayMs, delayMs, \lpHz, lpHz);

					}
				)
			},
			'spread',
			{
				if ( (args.size > 0 ) ,
					{
						//postf("~connectionCallback:  connectionName: %  type: %  size: % args: %\n", connectionName, type, args.size, args);
						spread = args[1];  // get values from vector, and write to connectionState
						thisProxy[nodeName.asSymbol].set(\spread, spread);
					},
					// else
					{"~connectionCallback: OSCrx spread message with no values".warn; })
			};
		);
	};


	// e.g  /spatosc/core/source/nodename/prop  key val
	~sourceCallback = {
		| args |
		var name, type, values, eventName, state;
		name = args[0].asString.split[4].asSymbol;
		type = args[0].asString.split[5].asSymbol;

		//'~sourceCallback'.postln;

		switch(type,
			'prop', {~setProperty.value(name, args[1], args[2])},
			'uri', {~setUri.value(name, args[1])},
			'event',
			{
				postf("~sourceCallback:  nodeName: %  mesageType: %  size: % args: %\n", name, type, args.size, args);
				if ( (args.size < 2 ) ,
					{"~setEvent: OSCrx message with no values".warn;},
					{  // else
						values = args;
						eventName = args[1];
						values.removeAt(0);
						values.removeAt(0);
						~setEvent.value(name, eventName, values);
					}
				)
			},
			'state',
			{
				if ( (args.size > 1) ,
					{
						state = args[1];
						~setState.value(name, state);
					},
					{"~setState: OSCrx message with no values".warn; })  // else
			},
			{postf("~sourceCallback:  UNMATCHED:  nodeName: %  mesageType: %  size: % args: %\n", name, type, args.size, args)};
		);
	};

		// e.g  /spatosc/core/group/nodename/prop  key val
	~groupCallback = {
		| args |
		var name, type, values, eventName, state;
		name = args[0].asString.split[4].asSymbol;
		type = args[0].asString.split[5].asSymbol;

		'~groupCallback'.postln;

		switch(type,
			'prop',
			{
				//~setProperty.value(name, args[1], args[2])
				postf("~groupCallback:  nodeName: %  setProp: %  key: % value: %\n", name, args[1], args[2]);
			},
			'uri',
			{
				postf("~groupCallback:  nodeName: %  setUri: %  \n", name, args[1]);
				// ~setUri.value(name, args[1])


			},
			'event',
			{
				postf("~groupCallback:  nodeName: %  set event: %  size: % args: %\n", name, type, args.size, args);
				if ( (args.size < 2 ) ,
					{"~setEvent: OSCrx message with no values".warn;},
					{  // else
						values = args;
						eventName = args[1];
						values.removeAt(0);
						values.removeAt(0);
						//~setEvent.value(name, eventName, values);
					}
				)
			},
			'state',
			{
				if ( (args.size > 1) ,
					{
						state = args[1];
						//eventName = args[1];
						//~setState.value(name, state);
						postf("~groupCallback:  node: %  set state: % \n", name, state);
					},
					{"~groupCallback: OSCrx message with no values".warn; })  // else
			},
			'add',
			{
				postf("~groupCallback:  nodeName: %  add member: %  \n", name, args[1]);
				~addMember.value(name, args[1])


			},
			'drop',
			{
				postf("~groupCallback:  nodeName: %  drop member: %  \n", name, args[1]);
				~dropMember.value(name, args[1])


			},{postf("~groupCallback:  UNMATCHED:  nodeName: %  mesageType: %  size: % args: %\n", name, type, args.size, args)};
		);
	};

	// define some functions to handle actions

		~reverbName="resonance-SC:spatOSCsource_1";  //  HACK to set up rvb node


	~createSource = { | sourceName uriName |
		if (~allSourceNodes.includesKey(sourceName),
			{
				postf("~createSource:   % exists, no action \n", sourceName);
			},
			// else create new node
			{
				postf("~createSource:   %  with uri: %\n", sourceName, uriName);
				~allSourceNodes[sourceName.asSymbol] = Dictionary();   // create node  -- create node-specific dict.
				~allSourceNodes[sourceName.asSymbol].put(\plugin, \nil);


				// assign proxy space
				if (~reverbName.asSymbol == sourceName.asSymbol,   // set EFFECTS proxy
					{
						postf("~createSource: setting  EFFECTS GROUP proxy  node %\n", sourceName);
						~allSourceNodes[sourceName.asSymbol].put(\proxy, ~proxEffect );
						~proxEffect[sourceName.asSymbol].set(\in, ~scbr.aux[0]);  //  HACK to set up rvb node

					},
					// else set normal proxy
					{
						~allSourceNodes[sourceName.asSymbol].put(\proxy, ~prox );

					}
				);

				// now set a plugin to complete instance creation
				if (uriName == "",
					{
						~setPlugin.value(sourceName.asSymbol,\dummyPlugin);
					},
					// else
					{
						~setUri.value(sourceName.asSymbol,uriName.asSymbol);
					}
				);
				~scbr.oscInterface.sourceOSC(sourceName.asSymbol, ~sourceCallback);   // create OSC callback for this source
			}
		);
	};


	~createGroup = { | groupName |
		if (~allSourceNodes.includesKey(groupName),
			{
				postf("~createGroup:   % exists, no action \n", groupName);
			},
			// else create new node
			{
				postf("~createGroupNode:   % \n", groupName);
				~allGroupNodes[groupName.asSymbol] = Dictionary();   // create node  -- create node-specific dict.
				~allGroupNodes[groupName.asSymbol].put(\members, List() );  // create dict for members
				//~allGroupNodes[groupName.asSymbol].put(\plugin, \nil);

				//  set normal proxy

				~allGroupNodes[groupName.asSymbol].put(\proxy, ~prox );

				~scbr.oscInterface.groupOSC(groupName.asSymbol, ~groupCallback);   // create OSC callback for this source
		});
	};

	~createConnection = { |sourceName listenerName |
		var connectionName = sourceName ++ "->" ++ listenerName;

		if (  ~allSourceNodes.includesKey(sourceName.asSymbol) == false ,
			// source not defined  ???
			{
				postf("warning: ~createConnection: SOURCE % not defined \n", sourceName);
		});

		if ( ~allSourceNodes[sourceName.asSymbol].includesKey(\connectionName),
			{
				'~createConnection:  connection already exists, no action taken'.postln;
			},
			// else create new one,  and a corresponding OSC callback
			{
				~allSourceNodes[sourceName.asSymbol].put(\connectionName, connectionName.asSymbol);

				~scbr.oscInterface.connectionOSC(~allSourceNodes[sourceName.asSymbol].at(\connectionName),~connectionCallback );

				// postf("~createConnection: creating callback for  %  ", ~allSourceNodes[sourceName.asSymbol].at(\connectionName));
		});
	};


	// update a node's plugin (synthdef)


	~setPlugin = { | nodeName pluginName |
		var validPluginName = pluginName;

		//postf("~setPlugin: node: %    NEW: %  CURRENT: % \n", nodeName, pluginName.asSymbol, ~allSourceNodes[nodeName.asSymbol].at(\plugin).asSymbol);


		// NEED A REAL SYNTH DEF CHECK HERE- set the \dummyPlugin if it fails
		if ( validPluginName.asString == "", { validPluginName = \dummyPlugin; });


		if (validPluginName.asSymbol != ~allSourceNodes[nodeName.asSymbol].at(\plugin).asSymbol,
			{

				~allSourceNodes[nodeName.asSymbol].put(\plugin, validPluginName.asSymbol);

				~makeinstance.value(nodeName.asSymbol, ~allSourceNodes[nodeName.asSymbol].at(\proxy) , validPluginName.asSymbol);
			},
			{
				//postf("~setPlugin: ignoring set plugin % for node % : plugin already set \n", pluginName, nodeName);
			}
		);

	};


	// value is a uri path:   file://~/Desktop/sheefa8.aif, plugin://testnoise~ , adc://1
	~setUri = { | nodeName, uriPath |
		var charIndex, uriName, type, temp;

		// type://name (i.e. plugin://DustDust, file://<path>

		// check URI name to make sure its valid

		if (uriPath.asString.contains("plugin://") == false,
			{
				postf("~setUri: WARNING: node: %  bad URI format : %,  setting to \dummyPlugin", nodeName, uriPath);
				~setPlugin.value(nodeName.asSymbol, \dummyPlugin);
			},

			// else  // path ok, proceed
			{
				charIndex = uriPath.asString.find("://");

				temp = uriPath.asString.subStr(charIndex);
				type = uriPath.asString.subStr(0, charIndex-1);
				uriName = temp.asString.replace("://", "");

				//postf("~setUri nodeName: %, type: %  plugName: %\n", name, type, uriPath);
				// still needs to be expanded for soundfiles, adc, web etc..
				switch( type,
					"plugin", {
						~setPlugin.value(nodeName.asSymbol, uriName)

					},
					// "file", {~setPlugin.value(name, uriPath)}  not implemented yet
				);
		});
	};


	// always a keyWord Value pair
	~setProperty = { | nodeName property value |
		var thisProxy = ~allSourceNodes[nodeName.asSymbol].at(\proxy);

		//postf("~setProperty: seting % of % to %\n", property, nodeName, value);

		thisProxy[nodeName.asSymbol].set(property.asSymbol, value);
	};


	// enable/disable node
	~setState = { | nodeName,  state |
		var thisProxy = ~allSourceNodes[nodeName.asSymbol].at(\proxy);
		if ( (state > 0),
			{
				~makeinstance.value(nodeName.asSymbol, thisProxy, ~allSourceNodes[nodeName.asSymbol].at(\plugin).asSymbol);
			},
			//else turn state off
			{
				~pauseinstance.value(nodeName.asSymbol, thisProxy );
			}
		);
		//postf("~setState: seting state of % to %\n", nodeName, state);
	};

	// events RX:   /spatosc/core/source/nodename/event eventName v1...vN
	~setEvent = { | nodeName, eventName,  args |
		var valueCount = args.size-1;
		var thisProxy = ~allSourceNodes[nodeName.asSymbol].at(\proxy);

		//postln("~setEvent: node:" ++nodeName ++" event name:"++eventName++"  arg(s): "++ args );

		if ( (valueCount >= 1) ,    // pass vector
			{

				thisProxy[nodeName.asSymbol].set(eventName.asSymbol, args);

				//thisProxy[\out].set(eventName, args);
			},
			// else
			{
				if ( (valueCount == 1) ,    // pass value
					{
						thisProxy[\out].set(eventName, args[0]);
					},
					// else  no args.. just pass 1
					{
						thisProxy[nodeName.asSymbol].set(eventName.asSymbol, 1);
					}
				);
		});
	};

	~addMember = { |  groupName, memberName |
		var memberList = ~allGroupNodes[groupName].at(\members);
		memberList.add(memberName.asSymbol);
		//postf("~addMember: group % adding member %\n", groupName, memberName);
		// ~groupCopyState(groupName, memberName);
	};


	~dropMember = { | groupName, memberName |
		var memberList = ~allGroupNodes[groupName].at(\members);
		var memberNameSym = memberName.asSymbol;
		var index = -1 ;

		memberList.do({ arg item, i;
			if ( item == memberNameSym,
				{ index = i });

		});
		if (index > -1,
			{
				memberList.removeAt(index);
				memberList.postln;
				postf("~~dropMember: group % dropping member %\n", groupName, memberName);
		},
			// else
			{
				postf("~dropMember: group % member % not found \n", groupName, memberName);
		});
	};





	~clearScene = {
		var nodelist = ~allSourceNodes.keys;
		'CLEARING SCENE'.postln;

		// first flush all nodes
		~allSourceNodes.keysDo { |key |
			key.postln;


			~clearSourceNode.value(key);
		};
		// now remove all nodes in the global dictionary
		/*		nodelist.do { | key |
		postf("removing:  node: %  from dictionary\n",  key);
		~allSourceNodes.removeAt(key);
		};*/
		//~allSourceNodes.removeEvery();

		~allSourceNodes.clear();
		~allSourceNodes.size;
	};

	~deleteSource = { | nodeName |
		if ( ~allSourceNodes.includesKey(nodeName.asSymbol) ,
			{
				~clearSourceNode.value(nodeName.asSymbol);
				//	'REMOVE NODE'.postln;
				~allSourceNodes.removeAt(nodeName.asSymbol);     // remove node from global dictionary
		});
	};

		~deleteGroup = { | nodeName |
		if ( ~allGroupNodes.includesKey(nodeName.asSymbol) ,
			{
				~clearGroupNode.value(nodeName.asSymbol);
				postf("~deleteGroup:  group node: % \n",  nodeName);
				~allGroupNodes.removeAt(nodeName.asSymbol);     // remove node from global dictionary
		});
	};

	~clearGroupeNode= { | nameSym |
		var node = ~allGroupNodes[nameSym];
		//var connectionName = node.at(\connectionName);
		var nodeKeys = node.keys;
		var thisProxy = ~allGroupNodes[nameSym].at(\proxy);
		var memberList = ~allGroupNodes[nameSym].at(\members);


		//~cleaninstance.value(nameSym, thisProxy);

		//postf("~clearGroupeNode:  group node: % \n",  nameSym);

		// disconnect callbacks

		~scbr.oscInterface.removeGroupOSC(nameSym);
		//  clear node's local dictionary
		// maybe this is unnecessary

		memberList.clear();

		nodeKeys.do { | key |
			postf("removing node keys:  node: %   key %  \n",  nameSym, key);
			node.removeAt(key);
		};
	};


		~clearSourceNode= { | nameSym |
		var node = ~allSourceNodes[nameSym];
		var connectionName = node.at(\connectionName);
		var nodeKeys = node.keys;
		var thisProxy = ~allSourceNodes[nameSym].at(\proxy);

		~cleaninstance.value(nameSym, thisProxy);

		//postf("~clearing:  node: % and connection: %\n",  nodeName, connectionName);

		// disconnect callbacks
		if (node.includesKey(\connectionName),
			{
				~scbr.oscInterface.removeConnectionOSC( node.at(\connectionName).asSymbol );
		});

		~scbr.oscInterface.removeSourceOSC(nameSym);
		//  clear node's local dictionary
		// maybe this is unnecessary
		nodeKeys.do { | key |
			//postf("removing node keys:  node: %   key %  \n",  nameSym, key);
			node.removeAt(key);
		};
	};

	~globalSetState = { | state |
		'Setting Global state'.postln;
		~allSourceNodes.keysDo { |key |
			//key.postln;
			~setState.value(key, state);
		};
	};

	~globalSet = { | param, value |
		~group.set(param.asSymbol, value);
	};

		~dumpNodes = {
		~allSourceNodes.keysDo { |key |
			var nodeSym = key;
			postf("node: %  \n", key);
			~allSourceNodes[nodeSym].keysDo { | key |
				postf("\t : %  =  % \n",  key, ~allSourceNodes[nodeSym].at(key));
			};
		};
	};

	~dumpGroup = {
		~allGroupNodes.keysDo { |key |
			var nodeSym = key;
			var memberList = ~allGroupNodes[nodeSym].at(\members);

			postf("Group node: %  members: \n", nodeSym);
			memberList.do { | key |
				postf("\t : %  \n",  key);
			};

			postf("node: %  \n", key);
			~allGroupNodes[nodeSym].keysDo { | key |
				postf("\t : %  =  % \n",  key, ~allGroupNodes[nodeSym].at(key));
			};
		};
	};


	s.sync;


	// ~dumpGroup.value();

		// HACK:   create reverb EFFECTS node and set input to  relative aux 0
/*
	 ~reverbName="resonance-SC:spatOSCsource_1";
	 ~createSource.value(~reverbName.asSymbol);
	 ~createConnection.value(~reverbName.asSymbol, "listener:spatOSClistener_0");
	 ~prox[~reverbName.asSymbol].set(\in, ~scbr.aux[0]);

	 ~makeinstance.value(~reverbName.asSymbol, ~prox, \busreverb);

		 ~makeinstance.value(\sheefaRev, ~prox, \busreverb);

	postf("makeing % instance \n", ~reverbName);
	*/

	//
	// ~allSourceNodes[~reverbName.asSymbol].at(\plugin);

	//~setUri.value(~reverbName.asSymbol, "plugin://busreverb");
	//~prox[~reverbName].set(\gainDB, 0);
	//~prox[~reverbName].set(\outputDB, 0);



	/*  TEMP

	~allSourceNodes.size;
	~globalSetState.value(0);
	~globalSetState.value(1);

	~nodeName="sourceC:spatOSCsource_0".asSymbol;
	~nodeName="ball_0:spatOSCsource_1".asSymbol;



	~nodeName=\mySound;
	~listenerName=\ear;
	~connectionName= ~nodeName ++ "->" ++ ~listenerName;


	~createSource.value(~nodeName);

	~createConnection.value(~nodeName, "ear");

	~setUri.value(~nodeName, "plugin://default");

	~setUri.value(~nodeName, "plugin://zkarpluck1");


	~allSourceNodes[~nodeName].release;



	~deleteSource.value(\testNode8);

	~dumpNodes.value();

	~allSourceNodes.size;

	~clearScene.value();


	// generate N instances

	1.do({ arg item;
	var nodename=("testNode"++item).asSymbol;
	var connectionName = "testNode"++item++"->ear";

	~createSource.value(nodename);
	//~createConnection.value(nodename, "ear");
	~setUri.value(nodename, "plugin://default");
	//~connectionCallback.value( ["/spatosc/core/connection/"++ connectionName ++"/spread", 10]);
	});


	~createSource.value(\testNode0);

	~setUri.value(\testNode0, "plugin://default");


	~globalSet.value(\fb, 100);

	~globalSet.value(\pos, 0);
	~globalSet.value(\pos, 0.5);
	~globalSet.value(\pos, 1);

	~globalSet.value(\gainDB, -30);
	~globalSet.value(\spread, 10);


	*/
};
)

