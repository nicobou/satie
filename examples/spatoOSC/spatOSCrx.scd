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

//~allSourceNodes.size;


(

s.waitForBoot{

	~volume = s.volume;     // create hook to global audio engine volume / mute control
	~volume.setVolumeRange(-99, 18);


	~scbr.makeSynthDef(\dummyPlugin, \emptySource, [\emptySpat], [0]);    // dummy synthdef, used for new nodes
	// be sure the synthDef is compiled on the server
	s.sync;

	// get default group
	~defaultProx = ~scbr.satieGroups[\default];  // Satie Groups are actually ProxySpace



	// create special effects group located at tail

	if ( ~scbr.satieGroups[\effect] == nil,
		{~effectProx = ~scbr.makeSatieGroup(\effect, \addToTail);}
	);

	// list internal instances from default group (internal instances are NodeProxy instances):
	// ~defaultProx.existingProxies;

	// dictionarys for source nodes
	~allSourceNodes = Dictionary();        //  ~allSourceNodes.postln;
	~allGroupNodes = Dictionary();        //  ~allGroups.postln;
	~fxSynthdefRegister;

	OSCdef(\createSoundSource).clear.free;  // just in case newOSC will be re-evaluated.
	~scbr.oscInterface.newOSC(\createSoundSource, ~coreCallback, "/spatosc/core");

	~scbr.oscInterface.removeBasicRendererOSC(\brOSC);
	~scbr.oscInterface.basicRendererOSC(\brOSC,~basicRendererCallback);

	//~createGroup.value(\default);

	~command = "ls " ++ thisProcess.nowExecutingPath.dirname ++ "/../../effects";
	~fxSynthdefRegister = ~command.unixCmdGetStdOut;  // concatanated string containing all filenames in the "effects" directory





	~basicRendererCallback = {
		arg msg;
		var command = msg[1];
		//postf("~basicRendererCallback: command: %, msg: %, \n", command, msg);

		if (msg.size < 2,
			{"~basicRendererCallback: empty message".warn;
				postf("~basicRendererCallback MESS LEN: %", msg.size);

			},
			// else
			{

				switch (command,
					'setOutputDB',
					{
						//postf("~basicRendererCallback setVolume: %\n", msg[2]);
						if ( (msg.size < 3 ) ,
							{"~basicRendererCallback: setVolume missing value".warn;
								// postf("CREATESOURCE MESS LEN: %", msg.size);

							},
							// else
							{
								~volume.volume = msg[2];
							}
						)
					},
					'setDIM',   // this is really setMute; a proper setMute message and setDIM responder should be implemented.
					{
						//postf("~basicRendererCallback setMute: %\n", msg[2]);
						if ( (msg.size < 3 ) ,
							{"~basicRendererCallback: setMute missing value".warn;
								// postf("CREATESOURCE MESS LEN: %", msg.size);

							},
							// else
							{
								if (msg [2] > 0,
									{~volume.mute;},
									// else
									{~volume.unmute;});
							}
						)
					}
				);
		});
	};


	~coreCallback = {
		arg msg;
		var command;
		command = msg[1];
		//postf("~coreCallback: command: %, msg: %, \n", command, msg);

		switch (command,
			'createSource',  // note:  EFFECTS SOURCES MUST HAVE URI ARG PROVIDED
			{
				//postf("~coreCallback: command: %, messLen: %   msg: %, \n", command, msg.size, msg);

				if ( (msg.size < 3 ) ,
					{"~coreCallback: OSCrx createSource message missing values".warn;
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
						~createSource.value(sourceName, uriName, groupName);
				});
			},
			'createGroup',
			{
				if ( (msg.size < 3 ) ,
					{"~coreCallback: OSCrx createGroup message missing values".warn;
						postf("createGroup MESS LEN: %", msg.size);

					},
					// else
					{
						var groupName = msg[2];
						~createGroup.value(groupName);
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

						thisProxy.set(\aziDeg, aziDeg, \eleDeg, eleDeg, \gainDB, gainDB, \delayMs, delayMs, \lpHz, lpHz);

					}
				)
			},
			'spread',
			{
				if ( (args.size > 0 ) ,
					{
						//postf("~connectionCallback:  connectionName: %  type: %  size: % args: %\n", connectionName, type, args.size, args);
						spread = args[1];  // get values from vector, and write to connectionState
						thisProxy.set(\spread, spread);
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
				//postf("~sourceCallback:  nodeName: %  mesageType: %  size: % args: %\n", name, type, args.size, args);
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

		//'~groupCallback'.postln;

		switch(type,
			'prop',
			{
				//~setProperty.value(name, args[1], args[2])

				//postf("~groupCallback:  nodeName: %  setProp: %  key: % value: %\n", name, args[1], args[2]);
				~setGroupProperty.value(name, args[1], args[2]);

			},
			'uri',
			{
				//postf("~groupCallback:  nodeName: %  setUri: %  \n", name, args[1]);
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
						~setGroupEvent.value(name, eventName, values);
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



	~createSource = { | sourceName, uriName , groupName = \default |

		if (~allSourceNodes.includesKey(sourceName),
			{
				postf("~createSource:   % exists, no action \n", sourceName);
			},
			// else create new node
			{
				if (groupName == "", { groupName = \default; });   // make sure group name is ok


				if (~isFXuri.value(uriName), { groupName = \effect };);  // if URI is a fx plugin,  force group to effects group


				// check to see if group's proxy exists (even if the corresponding groupNode has not yet been instntiated),  if  not, create it
				if ( ~scbr.satieGroups[groupName.asSymbol] == nil,
					{
						postf("~createSource_groupcheck:   source:%    group:  % undefined,  CREATING GROUP NOW \n", sourceName, groupName);
						~createGroup.value(groupName.asSymbol);
					}
				);

				postf("createSource: %:  uri: %  group: %\n", sourceName, uriName, groupName);
				~allSourceNodes[sourceName.asSymbol] = Dictionary();   // create node  -- create node-specific dict.
				~allSourceNodes[sourceName.asSymbol].put(\plugin, \nil);


				// assign proxy name
				if ( groupName == \effect,
					{

						if (~fxInputBus == nil,
							{
								postf("~createSource:  ~fxInputBus not defined");
								~fxInputBus = 0; };);   // this should be defined previously in the project's .scd

						~allSourceNodes[sourceName.asSymbol].put(\proxySymb, \effect);
						~effectProx[sourceName.asSymbol].set(\in, ~scbr.aux[0]);  //  HACK to set up rvb node
					},
					// else set normal proxy
					{
						~allSourceNodes[sourceName.asSymbol].put(\proxySymb, groupName.asSymbol);

						//var proxy = ~scbr.satieGroups[groupName.asSymbol];	  //
						//~allSourceNodes[sourceName.asSymbol].put(\proxy, proxy);
				};);

				// call ~setUri to complete instance creation
				~setUri.value(sourceName.asSymbol,uriName.asSymbol);

				~scbr.oscInterface.sourceOSC(sourceName.asSymbol, ~sourceCallback);   // create OSC callback
			}
		);
	};


	~createGroup = { | groupName |

		if (~allGroupNodes.includesKey(groupName),
			{
				postf("createGroup:  GroupNode % exists, no action \n", groupName);
			},
			// else create new group node
			{
				var groupProxy;


				if (~scbr.satieGroups[groupName.asSymbol] != nil, // group already exists in SATIE, no need to create it
					{
						groupProxy = ~scbr.satieGroups[groupName.asSymbol];
					},
					// else  group does not exist in SATIE,  create it
					{
						groupProxy = ~scbr.makeSatieGroup(groupName.asSymbol);
						if ( groupName.asSymbol == \default,
							{
								postf("~createGroup:  BUG FOUND-- SHOULD NOT HAVE TO INSTANITATE DEFAULT GROUP !!!!");
						});
				});

				postf("~createGroupNode:   % \n", groupName);
				~allGroupNodes[groupName.asSymbol] = Dictionary();   // create node  -- create node-specific dict.
				~allGroupNodes[groupName.asSymbol].put(\proxy , groupProxy);  // save proxy space
				~allGroupNodes[groupName.asSymbol].put(\proxySym , groupName.asSymbol);  // save proxy symbol
				~allGroupNodes[groupName.asSymbol].put(\members, List() );  // create dict for members
				~allGroupNodes[groupName.asSymbol].put(\plugin, \nil);


				//  set group proxy

				~allGroupNodes[groupName.asSymbol].put(\proxy, groupProxy );


				~scbr.oscInterface.groupOSC(groupName.asSymbol, ~groupCallback);   // create OSC callback for this source
			}
		);
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


	// create or a node's plugin (synthdef)
	~setPlugin = { | nodeName pluginName |
		var validPluginName = pluginName;
		var proxyName = ~allSourceNodes[nodeName.asSymbol].at(\proxySymb);

		//postf("~setPlugin: node: %    NEW: %  CURRENT: % \n", nodeName, pluginName.asSymbol, ~allSourceNodes[nodeName.asSymbol].at(\plugin).asSymbol);


		// NEED A REAL SYNTH DEF CHECK HERE- set the \dummyPlugin if it fails
		if ( validPluginName.asString == "", { validPluginName = \dummyPlugin; });


		if (validPluginName.asSymbol != ~allSourceNodes[nodeName.asSymbol].at(\plugin).asSymbol,
			{
				var proxy;
				~allSourceNodes[nodeName.asSymbol].put(\plugin, validPluginName.asSymbol);

				if ( proxyName.asSymbol == \default,
					{
						proxy = ~scbr.makeInstance(nodeName.asSymbol, validPluginName.asSymbol);  // just being careful, but the call below should work for this too
					},
					{
						proxy = ~scbr.makeInstance(nodeName.asSymbol, validPluginName.asSymbol, proxyName.asSymbol);

				});
				~allSourceNodes[nodeName.asSymbol].put(\proxy, proxy);
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

		thisProxy.set(property.asSymbol, value);
	};

	// always a keyWord Value pair
	~setGroupProperty = { | groupName property value |
		var groupProxy = ~allGroupNodes[groupName.asSymbol].at(\proxy);

		//postf("~setGroupProperty: seting % of % to %\n", property, groupName, value);

		groupProxy.group.set(property.asSymbol, value);
	};

	// enable/disable node
	~setState = { | nodeName,  state |
		var thisProxySym = ~allSourceNodes[nodeName.asSymbol].at(\proxySymb);
		/*		if ( (state > 0),
		{
		~scbr.makeInstance(nodeName.asSymbol, ~allSourceNodes[nodeName.asSymbol].at(\plugin).asSymbol, thisProxySym);
		},
		//else turn state off
		{
		~scbr.pauseInstance.value(nodeName.asSymbol, thisProxySym );
		}
		);*/
		//postf("~setState: seting state of % to %\n", nodeName, state);
	};


	// events RX:   /spatosc/core/source/nodename/event eventName v1...vN
	~setGroupEvent = { | groupName, eventName,  args |
		var valueCount = args.size;
		var groupProxy = ~allGroupNodes[groupName.asSymbol].at(\proxy);

		postln("~setGroupEvent: node:" ++groupName ++" event name:"++eventName++"  arg(s): "++ args );

		if ( (valueCount > 1) ,    // pass vector
			{
				groupProxy.group.set(eventName.asSymbol, args);
			},
			// else
			{
				if ( (valueCount == 1) ,    // pass value
					{
						groupProxy.group.set(eventName.asSymbol, args[0]);
					},
					// else  no args.. just pass 1
					{
						groupProxy.group.set(eventName.asSymbol, 1);
					}
				);
		});
	};


	// events RX:   /spatosc/core/source/nodename/event eventName v1...vN
	~setEvent = { | nodeName, eventName,  args |
		var valueCount = args.size;
		var thisProxy = ~allSourceNodes[nodeName.asSymbol].at(\proxy);

		//postln("~setEvent: node:" ++nodeName ++" event name:"++eventName++"  arg(s): "++ args );

		if ( (valueCount > 1) ,    // pass vector
			{
				thisProxy.set(eventName.asSymbol, args);
			},
			// else
			{
				if ( (valueCount == 1) ,    // pass value
					{
						thisProxy.set(eventName.asSymbol, args[0]);
					},
					// else  no args.. just pass 1
					{
						thisProxy.set(eventName.asSymbol, 1);
					}
				);
		});
	};

	~addMember = { |  groupName, nodeName |
		var memberList = ~allGroupNodes[groupName].at(\members);
		var groupProxy = ~allGroupNodes[groupName].at(\proxy);
		//


		// check to see if member is already in group

		// if not add it
		// ~scbr.changeGroup(groupName, nodeName);   // assign source node to group's proxySpace
		//  ~allSourceNodes[nodeName.asSymbol].put(\proxy, groupProxy);
		memberList.add(nodeName.asSymbol);


		//postf("~addMember: group % adding member %\n", groupName, nodeName);
		// ~groupCopyState(groupName, nodeName);
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
		//'CLEARING SCENE'.postln;

		// first flush all nodes
		~allSourceNodes.keysDo { |key |
			//key.postln;


			~clearSourceNode.value(key);
		};
		// now remove all nodes in the global dictionary
		/*		nodelist.do { | key |
		postf("removing:  node: %  from dictionary\n",  key);
		~allSourceNodes.removeAt(key);
		};*/
		//~allSourceNodes.removeEvery();

		// NEED TO CLEAR ALL GROUPS TOO

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


		//~cleaninstance(nameSym, thisProxy);

		postf("~clearGroupeNode:  group node: % \n",  nameSym);

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
		var thisProxyName = ~allSourceNodes[nameSym].at(\proxySymb);

		~scbr.cleanInstance(nameSym,thisProxyName );

		//postf("~clearing:  node: % and connection: %\n",  nameSym, connectionName);

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
		~scbr.satieGroups[\default].group.set(param.asSymbol, value);
	};


	~dumpConnections = {
		var undefined = 0;

		~allNodes.keysDo { |key |
			var nodeSym = key;
			postf("node: %  :   ", key);
			postf("\t : node:   %  connectionName:    % \n",  key, ~allNodes[nodeSym].at(\connectionName));

		};
	};


	~dumpNodes = {
		var connections = 0;
		~allSourceNodes.keysDo { |key |
			var nodeSym = key;
			postf("node: %  \n", key);
			~allSourceNodes[nodeSym].keysDo { | key |
				postf("\t : %  =  % \n",  key, ~allSourceNodes[nodeSym].at(key));
			};
		};
	};

	~dumpGroups = {

		postf("~dumpGroups: %  groups defined via OSCrx: \n", ~allGroupNodes.size);
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


~isFXuri = { | uriPath |
	var charIndex, uriName, type, temp;

	// type://name (i.e. plugin://DustDust, file://<path>

	// check URI name to make sure its valid

	if (uriPath.asString.contains("plugin://") == false,
		{
			postf("~getUriSym:  non-plugin type URI: % ", uriPath);
			// ~setPlugin.value(nodeName.asSymbol, \dummyPlugin);
			false;
		},

		// else  // path ok, proceed
		{
			charIndex = uriPath.asString.find("://");

			temp = uriPath.asString.subStr(charIndex);
			type = uriPath.asString.subStr(0, charIndex-1);
			uriName = temp.asString.replace("://", "");

				if ( ~fxSynthdefRegister.contains(uriName),
					{ true },
					{false};);
	});
};


	'spatOSCrx loaded'.postln;

	s.sync;


	// ~dumpGroup.value();

	// HACK:   create reverb EFFECTS node and set input to  relative aux 0
	/*


	~dumpNodes.value();

	~dumpGroups.value();

	~dumpConnections.value();



	~reverbName="resonance-SC:spatOSCsource_1";
	~createSource.value(~reverbName.asSymbol);
	~createConnection.value(~reverbName.asSymbol, "listener:spatOSClistener_0");
	~prox[~reverbName.asSymbol].set(\in, ~scbr.aux[0]);

	~scbr.makeInstance(~reverbName.asSymbol,\busreverb, \effect);



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

