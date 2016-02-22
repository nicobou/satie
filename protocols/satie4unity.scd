// Satie4Unity, audio rendering support for Unity
// Copyright (C) 2016  Zack Settel
// This program is free software: you can redistribute it and/or modify
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
Satie4Unity's message specification is inspired from the SPATOSC specification  (see:   http://code.sat.qc.ca/redmine/projects/spatosc/wiki/spec  )
*/


// Note:  the SATIE kernel in SATIE/src be evaluated before loading this file
//  meaning that the global:   '~scbr' must be defined already

(
s.waitForBoot{

		// initialize the OSC interpreter here
	~oscInterface = ~cOSCMaker.value();

	// global variable, potentially used by project processes
	~projectDirectory =  thisProcess.nowExecutingPath.dirname;    // can be overwritten by OSC messages to audioRenderer

	~volume = s.volume;     // create hook to global audio engine volume / mute control
	~volume.setVolumeRange(-99, 18);


	~scbr.makeSynthDef(\dummyPlugin, \emptySource, [\emptySpat], [0]);    // dummy synthdef, used for new nodes
	// be sure the synthDef is compiled on the server
	s.sync;

	// get default group
	//~defaultProx = ~scbr.satieGroups[\default];  // Satie Groups are actually ProxySpace



	// create special effects group located at tail

	if ( ~scbr.satieGroups[\effect] == nil,
		{~effectProx = ~scbr.makeSatieGroup(\effect, \addToTail);}
	);


	// dictionarys for source nodes
	~allSourceNodes = Dictionary();        //  ~allSourceNodes.postln;
	~allGroupNodes = Dictionary();        //  ~allGroups.postln;

	if (~allProcesses == nil, {
		~allProcesses = ();         // environment namespace for project functions
	});

	~fxSynthdefRegister;


	//~createGroup.value(\default);

	~command = "ls " ++ thisProcess.nowExecutingPath.dirname ++ "/../../effects";
	~fxSynthdefRegister = ~command.unixCmdGetStdOut;  // concatanated string containing all filenames in the "effects" directory



	// called by project files to "register" project/node specific functions
	// not used--- now, allProcesses is appened locally in each project file
	// ~registerProcess = { | fnSym, fn |
	// 	postf("~registerProcess: %\n",fnSym);
	//
	// 	~allProcesses.put(fnSym.asSymbol, fn);
	// };



	~outputDB = 0;    // current state of the supercollider's output
	~outputTrimDB = 0;

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
				'setProjectDir',
					{
							if ( (msg.size != 3 ) ,
							{"~basicRendererCallback: setProjectDir bad arg count: expecting 'setProjectDir projectDirPath' ".warn;},
							// else
							{
								~projectDirectory = msg[2];

								~projectDirectory.postln;

							}
						)
					},
					'setOutputTrimDB',
					{
							if ( (msg.size < 3 ) ,
							{"~basicRendererCallback: setOutputTrimDB missing value".warn;},
							// else
							{
								~outputTrimDB = msg[2];
								~volume.volume = ~outputTrimDB + ~outputDB;
							}
						)
					},
					'setOutputDB',
					{
							if ( (msg.size < 3 ) ,
							{"~basicRendererCallback: setOutputDB missing value".warn;},
							// else
							{
								~outputDB = msg[2];
								~volume.volume = ~outputTrimDB + ~outputDB;
							}
						)
					},
					'setOutputDIM',
					{
							if ( (msg.size < 3 ) ,
							{"~basicRendererCallback: setOutputMute missing value".warn;
								// postf("CREATESOURCE MESS LEN: %", msg.size);

							},
							// else
							{
								if (msg [2] > 0,
									 {  ~volume.volume = -30;  },
									// else
									{  ~volume.volume =  ~outputDB + ~outputTrimDB;   });
							}
						)
					},
					'setOutputMute',
					{
						//postf("~basicRendererCallback setMute: %\n", msg[2]);
						if ( (msg.size < 3 ) ,
							{"~basicRendererCallback: setOutputDIM missing value".warn;  },
							// else
							{
								if (msg [2] > 0,
									{~volume.mute;},
									// else
									{~volume.unmute;} );  // full muting implmentation
							}
						);
					}
				)
		});
	};


	~coreCallback = {
		arg msg;
		var command;
		command = msg[1];
		//postf("~coreCallback: command: %, msg: %, \n", command, msg);

		switch (command,
			'createSource',  // required args:  name uri    <optional>  group
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
							{   ~removeGroup.value(nodeName);  },
							// else
							{
									~deleteSource.value(nodeName);   });
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





	// /spatosc/core/connection/source->listener/update azi elev gainDB delayMS  lpHZ distance
	// /spatosc/core/connection/source->listener/spread  exp   // exponent for incidence effect
	// /spatosc/core/connection/source->listener/hpHz fq   // high pass cutoff for underwater etc.

	~connectionCallback = { | args |
		var nodeName, listenerName, connectionName, type, temp, charIndex;
		var aziDeg, eleDeg, gainDB, delayMs, lpHz, hpHz, spread, distance;
		var thisSynth;
		var index;
		var halfSrate = 0.5 * s.sampleRate;

		//args.postln;
		connectionName = args[0].asString.split[4].asSymbol;   // this is terrible.  The spatOSC message format should be improved here
		type = args[0].asString.split[5].asSymbol;
		charIndex = connectionName.asString.find("->");

		nodeName = connectionName.asString.subStr(0, charIndex-1);
		//postf("~connectionCallback:  connectionName: %  type: %  size: % args: %\n", connectionName, type, args.size, args);

		thisSynth = ~allSourceNodes[nodeName.asSymbol].at(\synth);

		switch(type,
			'update',
			{
				if ( (args.size != 7 ) ,
					{"connectionCallback: OSCrx update message missing values".warn;},
					// else
					{
						// get values from vector, and write to connectionState
						aziDeg = args[1].raddeg;
						eleDeg= args[2].raddeg;
						gainDB = args[3];
						delayMs = args[4];
						lpHz = args[5];
						distance = args[6];  // not used by basic spatializers

						//DEBUG
						//~allSourceNodes[nodeName.asSymbol].put(\outDB, gainDB);



				/*		z = (z+1).mod(20);
						if ( (z == 0), {postf("\n")});
						postf("  %  " ++ gainDB.trunc );*/


						thisSynth.set(\aziDeg, aziDeg, \eleDeg, eleDeg, \gainDB, gainDB, \delayMs, delayMs, \lpHz, lpHz);
						//postf("~connectionCallback:  update: lpHz  % \n", lpHz);

					}
				)
			},
			'hpHz',   //  degree  (0 == noEffect,  1 == full effect)
			{
				if ( (args.size != 2 ) ,
					{"connectionCallback: OSCrx hpHz message wrong number of values".warn;},
					// else
					{
						// get value from vector, and write to connectionState
						hpHz = args[1];   // get highpass cutoff value
						thisSynth.set(\hpHz ,  clip(hpHz, 1, halfSrate ));

								postf("~connectionCallback:  hpHz connectionName: %  type: %  size: % args: %\n", connectionName, type, args.size, args);

					}
				)
			},
			'spread',
			{
				if ( (args.size > 0 ) ,
					{


						// invert the spread value (usually an exp) to work with SATIE's VBAP-based spatializer (or others)
						spread = 100 *  ( 1 - (clip(args[1],0,1)));  // get values from vector, and write to connectionState

						thisSynth.set(\spread, spread);

						//postf("~connectionCallback:  SPREAD:  connectionName: %  spread: % \n", connectionName, spread);

					},
					// else
					{"~connectionCallback: OSCrx spread message with no values".warn; })
			};
		);
	};


	// /spatosc/core/connection/source->listener/update azi elev gainDB delayMS  lpHZ distance
	// /spatosc/core/connection/source->listener/spread  exp   // exponent for incidence effect
	// /spatosc/core/connection/source->listener/hpHz fq   // high pass cutoff for underwater etc.
	~connectionProcessCallback = { | args |
		var nodeName, listenerName, connectionName, type, temp, charIndex;
		var aziDeg, eleDeg, gainDB, delayMs, lpHz, spread, distance;
		var thisGroup, thisGroupName;
		var myProcess;


		//postf(" ~connectionProcessCallback \n");

		//args.postln;
		connectionName = args[0].asString.split[4].asSymbol;   // this is terrible.  The spatOSC message format should be improved here
		type = args[0].asString.split[5].asSymbol;
		charIndex = connectionName.asString.find("->");

		nodeName = connectionName.asString.subStr(0, charIndex-1);


		// We know this is a sourceProcessingNode since this callback was chosen for this node
		// so by default, we will update the source's group

		thisGroupName = ~allSourceNodes[nodeName.asSymbol].at(\groupNameSym);  // process nodes have unique groups
		thisGroup = ~allGroupNodes[thisGroupName].at(\group).group;

		myProcess = ~allSourceNodes[nodeName.asSymbol].at(\process);


		//postf("~connectionProcessCallback:  connectionName: %  type: %  size: % args: %\n", connectionName, type, args.size, args);

		switch(type,
			'update',
			{
				if ( (args.size != 7 ) ,
					{"connectionProcessCallback: OSCrx update message missing values".warn;},
					// else
					{
						// get values from vector, and write to connectionState
						aziDeg = args[1].raddeg;
						eleDeg= args[2].raddeg;
						gainDB = args[3];
						delayMs = args[4];
						lpHz = args[5];
						distance = args[6];

						if (myProcess[\updateConnection] == nil,
							{

								//postf("~connectionProcessCallback:  setting update for nodes group %\n", connectionName);
								// distance not used by standard spatializers
								thisGroup.set(\aziDeg, aziDeg, \eleDeg, eleDeg, \gainDB, gainDB, \delayMs, delayMs, \lpHz, lpHz);
							},
							// else use custom handler
							{
								// postf("~connectionProcessCallback:  calling custom update handler for %\n", connectionName);
								// distance used by custom process functions
								myProcess[\updateConnection].value(myProcess, aziDeg, eleDeg, gainDB, delayMs, lpHz, distance);
						});

					}
				)
			},
			// 'hpHz',   //  degree  (0 == noEffect,  1 == full effect)  Not implemented yet
			'spread',
			{
				if ( (args.size > 0 ) ,
					{
						//postf("~connectionProcessCallback:  connectionName: %  type: %  size: % args: %\n", connectionName, type, args.size, args);
						spread = args[1];  // get values from vector, and write to connectionState

						if (myProcess[\spread] == nil,
							{
								postf("~connectionProcessCallback:  setting spread for node's group  %\n", connectionName);
								thisGroup.set(\spread, spread);
							},
							// else use a custom handler
							{
								postf("~connectionProcessCallback:  calling custom spread handler for %\n", connectionName);
								myProcess[\spread].value(myProcess, spread);

						});
					},
					// else
					{"~connectionProcessCallback: OSCrx spread message with no values".warn; })
			};
		);
	};

	// e.g  /spatosc/core/source/nodename/prop  key val
	~sourceNodeCallback = {
		| args |
		var name, type, values, eventName, state;
		name = args[0].asString.split[4].asSymbol;
		type = args[0].asString.split[5].asSymbol;

		//'~sourceNodeCallback'.postln;

		switch(type,
			'prop', {~setProperty.value(name, args[1], args[2]);
					//postf("~sourceNodeCallback:  nodeName: %  setProp: %  key: % value: %\n", name, args[1], args[2]);

			},
			'uri', {~setUri.value(name, args[1])},
			'event',
			{
				//postf("~sourceNodeCallback:  nodeName: %  mesageType: %  size: % args: %\n", name, type, args.size, args);
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
			{postf("~sourceNodeCallback:  UNMATCHED:  nodeName: %  mesageType: %  size: % args: %\n", name, type, args.size, args)};
		);
	};

		// e.g  /spatosc/core/source/nodename/prop  key val
	// source node has unique group, updates are to source's group (to cloned synths etc)
	~sourceProcessCallback = {
		| args |
		var name, type, values, eventName, state, myProcess, myProcessSym;

		name = args[0].asString.split[4].asSymbol;
		type = args[0].asString.split[5].asSymbol;

		//myProcessSym = ~allSourceNodes[name.asSymbol].at(\process);
		//myProcess = ~allProcesses[myProcessSym];
		 myProcess = ~allSourceNodes[name.asSymbol].at(\process);

		//'~sourceProcessCallback'.postln;

		switch(type,
			'prop',
			{
				if (myProcess[\prop] == nil,
					{
						var groupName = ~allSourceNodes[name.asSymbol].at(\groupNameSym);
						~setGroupProperty.value(groupName, args[1], args[2]);
					},
					// else use custom handler
					{
						//postf("~~sourceProcessCallback:  calling custom prop handler for %\n", name);
						myProcess[\prop].value(myProcess,  args[1], args[2]);
				});


			},

			'uri',  // not used:  process synths are defined in the process class, or set by events
			{
				// ~setUri.value(name, args[1])

			},
			'state',    // not used
			{
			},
			'event',
			{
				//postf("~sourceProcessCallback:  nodeName: %  mesageType: %  size: % args: %\n", name, type, args.size, args);
				if ( (args.size < 2 ) ,
					{"~sourceProcessCallback event: OSCrx message with no values".warn;},
					{  // else
						values = args;
						eventName = args[1];
						values.removeAt(0);
						values.removeAt(0);


						// NOTE:  event names for processes are either:
						//  \setParam (to the state of a process param)
						// or
						// allOtherNames (to call a function with an arg vec)
						if (( eventName == \setParam)&& (values.size == 2),
							{
								// postf("sourceProcessCallback event_setParam: %  % \n", values[0].asSymbol, values[1]);
								myProcess[values[0].asSymbol] = values[1] ;

							},
							// else  it is a function call
							{
								//postf("~sourceProcessCallback: event_function call:  nodeName: %  event: %  size: % args: %\n", name, eventName.asSymbol, values.size, values);
								myProcess[eventName.asSymbol].value(myProcess, values);   // call the process corresponding method passing argVec
						});
				});
			},
			{postf("~sourceProcessCallback:  UNMATCHED:  nodeName: %  mesageType: %  size: % args: %\n", name, type, args.size, args)};
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

				var type;
				type = ~uriType.value(uriName);


				switch( type,
					"plugin", {
						~createSourceNode.value(sourceName.asSymbol, uriName,groupName )

					},
					"process", {
						~createSourceProcess.value(sourceName.asSymbol, uriName,groupName )

					},
					// "file", {~setSynth.value(name, uriPath)}  not implemented yet
				);



			}
		);
	};


	// called for uri type process://
	//error check uriName done before call this, uriPath will be a process name
	// ignore groupName since a unique one will be generated for this node and its clones
	//  uri path may include arguments
	// eg. uriPath:  "process://sheefa arg1 1.1 arg2 2.2 arg3"

	~createSourceProcess = { | sourceName, uriPath , groupNameDummy = \default |
		var temp, type, charIndex, processName, processClone, myProcess, cloneGroup, cloneGroupName;
		var argsString = "";
		var stringArray;


		("sheefa.createSourceProcess:  URI"++uriPath).postln;

		stringArray = uriPath.asString.split($ );
		charIndex = stringArray[0].asString.find("://");
		processName = stringArray[0].asString.subStr(charIndex+3);
		argsString = uriPath.asString.subStr(stringArray[0].size+1);


		if (~allProcesses[processName.asSymbol] == nil,
			{
				postf("~createSourceProcess: undefined process name:"++processName++"   ,  node not created \n");
			},
			// else ALL GOOD,  instantiate
			{
				if (~allSourceNodes[sourceName.asSymbol]  != nil,
					{
						error("~createSourceProcess source Process node: %,   ALREAYD EXISTS \n", sourceName);
					},
					// else node good to go
					{
						//postf("~createSourceProcess nodeName: %,   PROCESS_NAME: %\n", sourceName, processName);
						//postf("~createSourceProcess: %:  uri: %  group: %\n", sourceName, uriPath, groupName);

						~allSourceNodes[sourceName.asSymbol] = Dictionary();   // create node  -- create node-specific dict.
						~allSourceNodes[sourceName.asSymbol].put(\plugin, \nil);

						// generate groupName unique to source node
						cloneGroupName = sourceName ++ "_group";
						cloneGroup = ~createGroup.value(cloneGroupName.asSymbol);   // create group for this node and its clones

						//cloneGroup.postln;

						// clone a new copy of the process
						temp = ~allProcesses.at(processName.asSymbol);
						processClone = temp.copy;
						//processClone[\nodeName]=sourceName.asSymbol;

						cloneGroup = ~allGroupNodes[cloneGroupName.asSymbol].at(\group); // must be called after createGroup() above

						~allSourceNodes[sourceName.asSymbol].put(\process, processClone);
						~allSourceNodes[sourceName.asSymbol].put(\groupNameSym, cloneGroupName.asSymbol);

						myProcess = ~allSourceNodes[sourceName.asSymbol].at(\process);

						// send URI's argsString to setup without any error checking

							myProcess[\setup].value(myProcess, sourceName.asSymbol, cloneGroupName.asSymbol, argsString );   // set the state of the process
						~setSynth.value(sourceName.asSymbol, "");  // sets dummy plugin as placeholder

						~oscInterface.sourceOSC(sourceName.asSymbol, ~sourceProcessCallback);   // create OSC callback

				});
		});
	};



	~createSourceNode = { | sourceName, uriName , groupName = \default |
		var synthName;

		if (groupName == "", { groupName = \default; });   // make sure group name is ok

		// check to see if group  exists (even if the corresponding groupNode has not yet been instntiated),  if  not, create it
		if ( ~scbr.satieGroups[groupName.asSymbol] == nil,
			{
				postf("~createSource_groupcheck:   source:%    group:  % undefined,  CREATING GROUP NOW \n", sourceName, groupName);
				~createGroup.value(groupName.asSymbol);
			}
		);

		postf("~createSourceNode: %:  uri: %  group: %\n", sourceName, uriName, groupName);
		~allSourceNodes[sourceName.asSymbol] = Dictionary();   // create node  -- create node-specific dict.
		~allSourceNodes[sourceName.asSymbol].put(\plugin, \nil);

		// handle any aux send issues here
		if ( groupName == \effect,
			{
				postf("~createSource:  CREATING EFFECTS SOURCE for:%\n", sourceName.asSymbol);

				if (~fxInputBus == nil,    // this should be defined previously in the project's .scd
					{
						postf("~createSource:  ~fxInputBus not defined");
						~fxInputBus = 0;
				});

				// this is an effects node, so save its aux bus assign
				~allSourceNodes[sourceName.asSymbol].put(\auxBus, ~scbr.aux[~fxInputBus]);  //  HACK to set up effects send node
		});

		// now set node's group
		~allSourceNodes[sourceName.asSymbol].put(\groupNameSym, groupName.asSymbol);

		// call ~setUri to complete instance creation
		//~setUri.value(sourceName.asSymbol,uriName.asSymbol);

		// now set up synth
		if (uriName.asString.contains("plugin://") == false,
			{
				warn("~createSource: WARNING: node: %  bad URI format : %,  setting to \dummyPlugin", sourceName, uriName);
				~setSynth.value(sourceName.asSymbol, \dummyPlugin);
			},
			// else  // path ok, proceed
			{
				var charIndex = uriName.asString.find("://");
				var temp = uriName.asString.subStr(charIndex);
				var type = uriName.asString.subStr(0, charIndex-1);
				synthName = temp.asString.replace("://", "");

				//postf("~setUri nodeName: %, type: %  plugName: %\n", uriName, type, uriPath);
				// still needs to be expanded for soundfiles, adc, web etc..
				switch( type,
					"plugin", {
						~setSynth.value(sourceName.asSymbol, synthName)

					},
					// "file", {~setSynth.value(name, uriPath)}  not implemented yet
				);
		});
		~oscInterface.sourceOSC(sourceName.asSymbol, ~sourceNodeCallback);   // create OSC callback
	};


	// returns group
	~createGroup = { | groupName |

		if (~allGroupNodes.includesKey(groupName),
			{
				postf("createGroup:  GroupNode % exists, no action \n", groupName);
				~allGroupNodes[groupName.asSymbol].at(\group);  // return group
			},
			// else create new group node
			{
				var group;


				if (~scbr.satieGroups[groupName.asSymbol] != nil, // group already exists in SATIE, no need to create it
					{
						group = ~scbr.satieGroups[groupName.asSymbol];
					},
					// else  group does not exist in SATIE,  create it
					{
						group = ~scbr.makeSatieGroup(groupName.asSymbol);
						if ( groupName.asSymbol == \default,
							{
								postf("~createGroup:  BUG FOUND-- SHOULD NOT HAVE TO INSTANITATE DEFAULT GROUP !!!!");
						});
				});

				postf("~createGroupNode:   % \n", groupName);
				~allGroupNodes[groupName.asSymbol] = Dictionary();   // create node  -- create node-specific dict.
				~allGroupNodes[groupName.asSymbol].put(\group , group);  // save group
				~allGroupNodes[groupName.asSymbol].put(\groupSym , groupName.asSymbol);  // save group name symbol
				~allGroupNodes[groupName.asSymbol].put(\members, List() );  // create dict for members
				~allGroupNodes[groupName.asSymbol].put(\plugin, \nil);


				//  set group

				~allGroupNodes[groupName.asSymbol].put(\group, group );


				~oscInterface.groupOSC(groupName.asSymbol, ~groupCallback);   // create OSC callback for this source
				group;  // returns groups
			}
		);
	};

	~createConnection = { |sourceName listenerName |
		var connectionName = sourceName ++ "->" ++ listenerName;
		var myProcess = ~allSourceNodes[sourceName.asSymbol].at(\process);

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

				// is this a processNode ?
				if ( myProcess != nil,
					{
						postf("~createConnection: creating Custom update callback for  %  ", sourceName.asSymbol);
						~oscInterface.connectionOSC(~allSourceNodes[sourceName.asSymbol].at(\connectionName), ~connectionProcessCallback);
					},
					//else  regular source node, set up standard connection callback
					{
						~oscInterface.connectionOSC(~allSourceNodes[sourceName.asSymbol].at(\connectionName),~connectionCallback);
				});

				// postf("~createConnection: creating callback for  %  ", ~allSourceNodes[sourceName.asSymbol].at(\connectionName));
		});
	};


	// create a node's  (synthdef)
	~setSynth = { | nodeName pluginName |
		var validPluginName = pluginName;
		var groupName = ~allSourceNodes[nodeName.asSymbol].at(\groupNameSym);

		//postf("~setSynth: node: %    NEW: %  CURRENT: % \n", nodeName, pluginName.asSymbol, ~allSourceNodes[nodeName.asSymbol].at(\plugin).asSymbol);


		// NEED A REAL SYNTH DEF CHECK HERE- set the \dummyPlugin if it fails
		if ( validPluginName.asString == "", { validPluginName = \dummyPlugin; });


		if (validPluginName.asSymbol != ~allSourceNodes[nodeName.asSymbol].at(\plugin).asSymbol,
			{
				var synth;
				~allSourceNodes[nodeName.asSymbol].put(\plugin, validPluginName.asSymbol);

				if ( groupName.asSymbol == \default,
					{
						synth = ~scbr.makeInstance(nodeName.asSymbol, validPluginName.asSymbol);  // just being careful, but the call below should work for this too
					},
					{
						synth = ~scbr.makeInstance(nodeName.asSymbol, validPluginName.asSymbol, groupName.asSymbol);

				});

				// now if its a node that has an aux send assign, it must be an effects node, so set its synth param with the aux bus number
				if ( ~allSourceNodes[nodeName.asSymbol].at(\auxBus) != nil,
					{
						synth.set(\in, ~allSourceNodes[nodeName.asSymbol].at(\auxBus) );
				});

				~allSourceNodes[nodeName.asSymbol].put(\synth, synth);
			},
			{
				//postf("~setSynth: ignoring set plugin % for node % : plugin already set \n", pluginName, nodeName);
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
				~setSynth.value(nodeName.asSymbol, \dummyPlugin);
			},

			// else  // path ok, proceed
			{
				charIndex = uriPath.asString.find("://");

				temp = uriPath.asString.subStr(charIndex);
				type = uriPath.asString.subStr(0, charIndex-1);
				uriName = temp.asString.replace("://", "");

				//postf("~setUri nodeName: %, type: %  plugName: %\n", uriName, type, uriPath);
				// still needs to be expanded for soundfiles, adc, web etc..
				switch( type,
					"plugin", {
						~setSynth.value(nodeName.asSymbol, uriName)

					},
					// "file", {~setSynth.value(name, uriPath)}  not implemented yet
				);
		});
	};


	// always a keyWord Value pair
	~setProperty = { | nodeName property value |
		var thisSynth = ~allSourceNodes[nodeName.asSymbol].at(\synth);

		//postf("~setProperty: seting % of % to %\n", property, nodeName, value);

		thisSynth.set(property.asSymbol, value);
	};

	// always a keyWord Value pair
	~setGroupProperty = { | groupName property value |
		var group = ~allGroupNodes[groupName.asSymbol].at(\group).group;

		// postf("~setGroupProperty: seting % of % to %\n", property, groupName, value);

		group.set(property.asSymbol, value);
	};

	// enable/disable node
	~setState = { | nodeName,  state |
		var thisSynth = ~allSourceNodes[nodeName.asSymbol].at(\synth);
		/*		if ( (state > 0),
		{
		~scbr.makeInstance(nodeName.asSymbol, ~allSourceNodes[nodeName.asSymbol].at(\plugin).asSymbol, thisGroupSym);
		},
		//else turn state off
		{
		~scbr.pauseInstance.value(nodeName.asSymbol, thisGroupSym );
		}
		);*/
		//postf("~setState: seting state of % to %\n", nodeName, state);
	};


	// events RX:   /spatosc/core/source/nodename/event eventName v1...vN
	~setGroupEvent = { | groupName, eventName,  args |
		var valueCount = args.size;
		var group = ~allGroupNodes[groupName.asSymbol].at(\group).group;

		postln("~setGroupEvent: node:" ++groupName ++" event name:"++eventName++"  arg(s): "++ args );

		if ( (valueCount > 1) ,    // pass vector
			{
				group.set(eventName.asSymbol, args);
			},
			// else
			{
				if ( (valueCount == 1) ,    // pass value
					{
						group.set(eventName.asSymbol, args[0]);
					},
					// else  no args.. just pass 1
					{
						group.set(eventName.asSymbol, 1);
					}
				);
		});
	};


	// events RX:   /spatosc/core/source/nodename/event eventName v1...vN
	~setEvent = { | nodeName, eventName,  args |
		var valueCount = args.size;
		var thisSynth = ~allSourceNodes[nodeName.asSymbol].at(\synth);

		// DEBUG
		//var db = ~allSourceNodes.at( nodeName.asSymbol).at(\outDB);



		if ( (valueCount > 1) ,    // pass vector
			{
				// DEBUG
				//postln("~setEvent: " ++ nodeName.asSymbol ++ "    args: " ++ args[0]  ++ "     " ++ (args[1]*1000).trunc++ "    " ++ (args[2]*100).trunc  );
				//if( args[2] < 0.07, {postln("~setEvent: " ++ nodeName.asSymbol ++ "   INCIDENCE  " ++ args[2]  )});

				thisSynth.set(eventName.asSymbol, args);
			},
			// else
			{
				if ( (valueCount == 1) ,    // pass value
					{
					// DEBUG
					//postln("~setEvent: " ++ nodeName.asSymbol ++ "        BANG   db: "++db.trunc++ "\n");

						thisSynth.set(eventName.asSymbol, args[0]);
					},
					// else  no args.. just pass 1
					{
						thisSynth.set(eventName.asSymbol, 1);
					}
				);
		});
	};

	~addMember = { |  groupName, nodeName |
		var memberList = ~allGroupNodes[groupName].at(\members);
		var group = ~allGroupNodes[groupName].at(\group).group;
		//


		// check to see if member is already in group

		// if not add it
		// ~scbr.changeGroup(groupName, nodeName);   // assign source node to group's proxySpace
		//  ~allSourceNodes[nodeName.asSymbol].put(\group, groupProxy);
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

		~allSourceNodes.clear();
		~allSourceNodes.size;

	// do not clear all groups except default group

/*		~scbr.satieGroups.keysDo{ |key |
			var nodeSym = key;

			if (key != \default,
				{
					~scbr.killSatieGroup(key);
			});
		};*/

	};

	~deleteSource = { | nodeName |
		if ( ~allSourceNodes.includesKey(nodeName.asSymbol) ,
			{
				// if its a sourceProcessNode do this first


				~clearSourceNode.value(nodeName.asSymbol);
				//	'REMOVE NODE'.postln;
				~allSourceNodes.removeAt(nodeName.asSymbol);     // remove node from global dictionary
		});
	};

		~removeGroup = { | groupName |
		if ( ~allGroupNodes.includesKey(groupName.asSymbol) ,
			{
				//  No OP  ~clearGroupNode.value(groupName.asSymbol);
				postf("~removeGroup:  group node: % \n",  groupName);
				~allGroupNodes.removeAt(groupName.asSymbol);     // remove node from global dictionary
		});
	};

	~clearGroupeNode= { | nameSym |
		var node = ~allGroupNodes[nameSym];
		//var connectionName = node.at(\connectionName);
		var nodeKeys = node.keys;
		var thisGroup = ~allGroupNodes[nameSym].at(\group);
		var memberList = ~allGroupNodes[nameSym].at(\members);


		//~cleaninstance(nameSym, thisGroup);

		postf("~clearGroupeNode:  group node: % \n",  nameSym);

		// disconnect callbacks

		~oscInterface.removeGroupOSC(nameSym);
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
		var thisGroupName = ~allSourceNodes[nameSym].at(\groupNameSym);


		// is this a process node?
		if ( ~allSourceNodes[nameSym].at(\process) != nil,
			{
				var groupSym =  ~allSourceNodes[nameSym].at(\groupNameSym);

				var myProcess = ~allSourceNodes[nameSym].at(\process);

				//postf("clearSourceNode.deleteGroup()  %\n", groupSym);

				// now kill off the clones in that group
				//myProcess.at(\nodeGroupProxy).free;

				myProcess.cleanup();   // frees any state the process may have created, i.e. synths

				~scbr.cleanInstance(nameSym,thisGroupName );

				// now delete group
				~removeGroup.value(groupSym); //
				~scbr.killSatieGroup(groupSym);   // kill the group, since it was unique to this source
		},
		// else  its just a regular source
		{
				~scbr.cleanInstance(nameSym,thisGroupName );

		});

		//postf("~clearing:  node: % and connection: %\n",  nameSym, connectionName);

		// disconnect callbacks
		if (node.includesKey(\connectionName),
			{
				~oscInterface.removeConnectionOSC( node.at(\connectionName).asSymbol );
		});

		~oscInterface.removeSourceOSC(nameSym);
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
			// ~setSynth.value(nodeName.asSymbol, \dummyPlugin);
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


	~uriType = { | uriPath |
		var charIndex, uriName, type, temp;

		type = nil;

		// type://name (i.e. plugin://DustDust, file://<path>

		// check URI name to make sure its valid

		if (uriPath.asString.contains("://") == false,
			{
				error("~getUriSym:  uri type format error: % ", uriPath);

			},

			// else  // path ok, proceed
			{
				charIndex = uriPath.asString.find("://");

				temp = uriPath.asString.subStr(charIndex);
				type = uriPath.asString.subStr(0, charIndex-1);
				uriName = temp.asString.replace("://", "");
		});
		type;
	};


	// LAST:

	//OSCdef(\createSoundSource).clear.free;  // just in case newOSC will be re-evaluated.
	~oscInterface.removeBasicRendererOSC(\createSoundSource);

	~oscInterface.newOSC(\createSoundSource, ~coreCallback, "/spatosc/core");

	~oscInterface.removeBasicRendererOSC(\brOSC);
	~oscInterface.basicRendererOSC(\brOSC,~basicRendererCallback);


	'satie4unity loaded'.postln;

	s.sync;

	// roomsize=50, revtime=3, damping=0.5, inputbw=0.5, spread=15, drylevel=1, earlylevel=0.7, taillevel=0.5, maxroomsize=300


/*	  	// tune up reverb

	~rvbname="resonance_SC:spatOSCsource_0".asSymbol;
	~setEvent.value(~rvbname,  \outputDB, [-10]);
	~setEvent.value(~rvbname,  \roomsize, [160]);
	~setEvent.value(~rvbname,  \revtime, [3]);
	~setEvent.value(~rvbname,  \damping, [0.1]);
	~setEvent.value(~rvbname,  \inputbw, [0.6]);
	~setEvent.value(~rvbname,  \spread, [15]);
	~setEvent.value(~rvbname,  \drylevel, [-99]);
	~setEvent.value(~rvbname,  \earlylevel, [3]);
	~setEvent.value(~rvbname,  \taillevel, [3]);

*/


		// e.g  /spatosc/core/source/nodename/prop  key val
	//~sourceNodeCallback.value("/spatosc/core/source/resonance_SC:spatOSCsource_1/prop", "outputDB", -20.0);



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

	~scbr.makeInstance(~reverbName.asSymbol,\busgverb, \effect);






	postf("makeing % instance \n", ~reverbName);
	*/

	//
	// ~allSourceNodes[~reverbName.asSymbol].at(\plugin);

	//~setUri.value(~reverbName.asSymbol, "plugin://busreverb");
	//~prox[~reverbName].set(\gainDB, 0);
	//~prox[~reverbName].set(\outputDB, 0);


	//~setEvent.value("resonance_SC:spatOSCsource_1".asSymbol,  \revtime, 0.5);


	/*  TEMP

	~allSourceNodes.size;
	~globalSetState.value(0);
	~globalSetState.value(1);

	~nodeName="sourceC:spatOSCsource_0".asSymbol;
	~nodeName="ball_0:spatOSCsource_1".asSymbol;



	// --------------------------------------SPREAD TEST
	// sourceB->listener
	~nodeName=\sourceB;
	~listenerName=\listener;
	~connectionName= ~nodeName ++ "->" ++ ~listenerName;
~connectionCallback.value( ["/spatosc/core/connection/"++ ~connectionName ++"/spread", 100]);

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

