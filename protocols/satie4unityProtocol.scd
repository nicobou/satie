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

/*
for debugguing

~s4u = ~satie4unityProtocol.value(~osc, ~scbr);
~s4u.debugFlag = true;
~s4u.debugFlag = false;
*/


(
~satie4unityProtocol = { | oscContext, satieContext, satieProcessContext,  oscID = \satie4unityOSC |
	var osc = oscContext;
	var satie = satieContext;
	var procMan = satieProcessContext;

	var e = Environment.make({
		~allSourceNodes = Dictionary();        //  ~allSourceNodes.postln;
		~allGroupNodes = Dictionary();        //  ~allGroups.postln;
		//		~projectDirectory = nil;

		~debugFlag=false;

		~satieAuxBusCount = satie.aux.size;

		// make sure this effcts group is defined since all  uri types "effect://name" are assigned to it
		if ( satie.satieGroups[\effect] == nil,
			{~effectProx = satie.makeSatieGroup(\effect, \addToTail);}
		);

		~coreCallback = { arg msg;
			var command;
			command = msg[1];
			// postf("~coreCallback: command: %, msg: %, \n", command, msg);

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
							e.createSource(sourceName, uriName, groupName);
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
							e.createGroup(groupName);
						}
					)
				},
				'createProcess',
				{
					postf("~coreCallback: createProcess:  command: %, messLen: %   msg: %, \n", command, msg.size, msg);

					if ( (msg.size < 3 ) ,
						{"~coreCallback: OSCrx createProcess message missing values".warn;
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
							e.createProcess(sourceName, uriName, groupName);
					});
				},
				'deleteNode',
				{
					if ( (msg.size < 3 ) ,
						{"~coreCallback: OSCrx deleteNode message missing values".warn;},
						// else
						{
							var nodeName = msg[2];
							// "~coreCallback: OSCrx deleteNode CALLED ".warn;

							if (e.allGroupNodes.includesKey(nodeName.asSymbol),
								{   e.removeGroup(nodeName);  },
								// else
								{
									e.deleteSource(nodeName);   });
						}
					)
				},
				'clear',
				{
					e.clearScene();

				};
			);
			//"coreCallback called".postln;
		};

		/*		// accepts arbitrary key value pairs and applies them to the named source node
		~setMessageHandler = { 	| args |
		var nodeName  = args[1];
		var props = args.copyRange(2, args.size - 1);
		var thisSynth;

		if ( e.allSourceNodes.includesKey(nodeName.asSymbol) == false,
		{
		error("satie4UnityProtocol.sourceSetHandler:  source node: "++nodeName++"  is undefined \n");
		}, // else node exists,  process event
		{
		if (  (  ( (props.size&1)==1) || (props.size == 0) ),
		{
		error("satie4UnityProtocol.sourceSetHandler: BAD ARGS: "++props);
		}, // else args good
		{
		thisSynth = e.allSourceNodes[nodeName.asSymbol].at(\synth);
		if ( thisSynth == nil,
		{
		error("satie4UnityProtocol.sourceSetHandler:  source node: "++nodeName++"  BUG FOUND: undefined SYNTH  \n");

		},   // else good to go
		{
		e.nodeSet( props, thisSynth);
		});
		});
		});
		};*/

		// accepts arbitrary key value pairs and applies them to the named group node
		~setMessageHandler = { 	| args |
			var type = args[0].asString.split[2].asSymbol;
			var nodeName  = args[1];
			var props = args.copyRange(2, args.size - 1);
			var targetNode;

			//postf("satie4UnityProtocol.setMessHandler:  source node: %,  mess: %\n", nodeName, args);

			// verify data
			if (  (  ( (props.size&1)==1) || (props.size == 0) ),
				{
					error("satie4UnityProtocol.setMessHandler: BAD ARGS: "++props);
				}, // else args good
				{
					switch(type,
						'source',
						{
							if ( e.allSourceNodes.includesKey(nodeName.asSymbol) == true,
								{
									targetNode = e.allSourceNodes[nodeName.asSymbol].at(\synth);
									if ( targetNode == nil,
										{
											error("satie4UnityProtocol.setMessHandler:  source node: "++nodeName++"  BUG FOUND: undefined SYNTH  \n");
										},   // else good to go
										{
											e.nodeSet( props, targetNode);
									});
								},
								{
									error("satie4UnityProtocol.setMessHandler:  source node: "++nodeName++"  is undefined \n");
							}); // else node exists,  process event
						},
						'group',
						{
							if ( ~satie4unity.allGroupNodes.includesKey (\sheefa) == true,
								{
									targetNode = e.allGroupNodes[nodeName.asSymbol].at(\group).group;
									e.nodeSet( props, targetNode);
								},
								{   // else no group
									error("satie4UnityProtocol.setMessHandler:  group node: "++nodeName++"  is undefined \n");
							});
						},
						'process',
						{
							if ( e.allSourceNodes.includesKey(nodeName.asSymbol) == true,
								{
									var thisGroupName = e.allSourceNodes[nodeName.asSymbol].at(\groupNameSym);  // process nodes have unique groups
									var thisGroup = e.allGroupNodes[thisGroupName].at(\group).group;
									var myProcess = e.allSourceNodes[nodeName.asSymbol].at(\process);

									if ( myProcess == nil,
										{
											error("satie4UnityProtocol.setMessHandler:  process node: "++nodeName++"  BUG FOUND: undefined process  \n");

										},
										{  // good to go
											e.processSet( props, myProcess, thisGroup);
									});

								},
								{  // else error
									error("satie4UnityProtocol.setMessHandler:  process node: "++nodeName++"  is undefined \n");
							});
					});
			});
		};

		// accepts arbitrary key value pairs and applies them to the named target node (source or group)
		~nodeSet = { | self, propsVec, targetNode  |

			// var group = self.allGroupNodes[groupName.asSymbol].at(\group).group;

			propsVec.pairsDo({ | prop, val |
				var defaultFlag=true;
				switch(prop,
					'hpHz',
					{
						var halfSrate = 0.5 * s.sampleRate;

						targetNode.set(\hpHz ,  clip(val, 1, halfSrate ));
						//postf("** instance: set  % to %\n", prop, val);
						defaultFlag=false;
					},
					'spread',
					{
						// invert and scale the spread value (usually an exp) to work with SATIE's VBAP-based spatializer (or others)
						var spread = 100 *  ( 1 - (clip(val,0,1)));  //
						targetNode.set(\spread, spread);
						//postf("** instance: set  % to %\n", prop, val);
						defaultFlag=false;
					},
					'in',
					{
						targetNode.set(prop, satie.aux[val.asInt]);
						defaultFlag = false;
				});
				// else just set the prop val pair
				if (defaultFlag,
					{
						//postf("** instance: set  % to %\n", prop, val);
						targetNode.set(prop, val);
				});
			});
		};

		// accepts arbitrary key value pairs and applies them to the named target node (source or group)
		~processSet = { | self, propsVec, process, group  |
			var value;
			var functionName = nil;

			propsVec.pairsDo({ | prop, val |
				var defaultFlag=true;
				switch(prop,
					'hpHz',
					{
						var halfSrate = 0.5 * s.sampleRate;
						value = clip(val, 1, halfSrate );
						defaultFlag=false;
					},
					'spread',
					{
						// invert and scale the spread value (usually an exp) to work with SATIE's VBAP-based spatializer (or others)
						value = 100 *  ( 1 - (clip(val,0,1)));  //
						defaultFlag=false;
					},
					'in',
					{
						value = satie.aux[val.asInt];  // set the aux bus for the synthdef
						defaultFlag = false;
				});
				// else just set the prop val pair
				if (defaultFlag,
					{
						value = val;
				});

				// Now handle the keyword value pair
				// Check to see if there is a custom handler defined in the process's environment

				if ( process[prop.asSymbol].class == Function,   // let's see if a function named prop.asSymbol is defined.
					{
						functionName = process[prop.asSymbol];   // yes, get the function
					},
					{
						// else  nope:  no function with that name exists.  Check to see if there's a set message handler
						if ( process[\set].class == Function,
							{ functionName = process[\set]; });    // yes, use the process's set  function
				});

				// if the process has no defined function with the name prop,   set the  prop value  pair in the group's synth
				if ( functionName == nil,
					{
						//postf("~processSet:  setting keyword value pair for node's synth group  %\n", process.nodeGroupName);
						group.set(prop.asSymbol, value);
					},
					// else call a custom handler with args: prop value
					{
						//postf("~processSet:  calling process[%]  (or process[\set] )  with  keyword:%   value:% pair for node  %\n", prop, prop, value, process.nodeName);

						functionName.value(process, prop.asSymbol, value);
				});
			});
		};

		// accepts arbitrary key value pairs and applies them to the named process node
		~processProperty = { | args  |
			var type = args[0].asString.split[2].asSymbol;
			var nodeName  = args[1];
			var propsVec = args.copyRange(2, args.size - 1);

			//postf("satie4UnityProtocol.processProperty:  RX    \n", args);

			// verify data
			if (  (  ( (propsVec.size&1)==1) || (propsVec.size == 0) ),
				{
					error("satie4UnityProtocol.processProperty: BAD ARGS: "++propsVec);
				}, // else args good
				{  // verify node
					if ( e.allSourceNodes.includesKey(nodeName.asSymbol) == true,
						{
							var thisGroupName = e.allSourceNodes[nodeName.asSymbol].at(\groupNameSym);  // process nodes have unique groups
							var thisGroup = e.allGroupNodes[thisGroupName].at(\group).group;
							var myProcess = e.allSourceNodes[nodeName.asSymbol].at(\process);

							if ( myProcess == nil,     // verify process
								{
									error("satie4UnityProtocol.processProperty:  process node: "++nodeName++"  BUG FOUND: undefined process  \n");

								},
								{  // good to go:  write key val pairs to process environment instance

									var function= nil;

									// postf("satie4UnityProtocol.processProperty:  process node: "++nodeName++" process: % \n", myProcess.class);


									if (myProcess[\property].class == Function,
										{
											function = myProcess[\property];
									});

									propsVec.pairsDo({ | prop, val |

										if (function != nil,
										{
											function.value(myProcess, prop, val);
										}, // else set the process's environment variable directly
										{
											myProcess[prop.asSymbol] = val;
									});
									});
							});
						},
						{  // else error
							error("satie4UnityProtocol.setMessHandler:  process node: "++nodeName++"  is undefined \n");
					});
			});
		};


		// osc rx   ARGS:  sourceName azimuthRADIANS elevationRADIANS gainDB delayMS  lpHZ  distanceMETERS
		~sourceUpdateHandler = { 	| args |
			var nodeName  = args[1];
			var aziDeg, eleDeg, gainDB, delayMs, lpHz, distance;
			var thisSynth;


			if ( e.allSourceNodes.includesKey(nodeName.asSymbol) == false,
				{
					error("satie4UnityProtocol.sourceUpdateHandler:  source node: "++nodeName++"  is undefined \n");
				},
				// else all ok
				{
					thisSynth = e.allSourceNodes[nodeName.asSymbol].at(\synth);

					if ( thisSynth == nil, {error("satie4UnityProtocol.sourceUpdateHandler:  source node: "++nodeName++"  BUG FOUND: undefined SYNTH  \n");});

					if ( (args.size != 8 ) ,
						{"satie4UnityProtocol.sourceUpdateHandler:  message missing values".warn;},
						// else
						{
							// get values from vector, and write to connectionState
							aziDeg = args[2].raddeg;
							eleDeg= args[3].raddeg;
							gainDB = args[4];
							delayMs = args[5];
							lpHz = args[6];
							distance = args[7];  // not used by basic spatializers

							thisSynth.set(\aziDeg, aziDeg, \eleDeg, eleDeg, \gainDB, gainDB, \delayMs, delayMs, \lpHz, lpHz);
							//postf("sourceUpdateHandler:  update: gain  % \n", gainDB);

							if (e.debugFlag,
								{
									// postf("~sourceUpdateHandler:  nodeName: %  size: % args: %\n", nodeName, args.size, args);
									postf("satie4UnityProtocol.sourceUpdateHandler:  aziDeg %  eleDeg %  gainDB %  delayMs %  lpHz %  distanceMeters % \n", aziDeg, eleDeg, gainDB, delayMs, lpHz, distance);
							});


					});
			});
		};

		// osc rx   ARGS:  sourceName hpHz
		~sourceHpHzHandler = { 	| args |
			var nodeName  = args[1];
			var hpHz;
			var thisSynth;
			var halfSrate = 0.5 * s.sampleRate;

			error("sourceHpHzHandler:  nodeName: %  size: % args: %\n", nodeName, args.size, args);
			/*			if ( e.allSourceNodes.includesKey(nodeName.asSymbol) == false,
			{
			error("satie4UnityProtocol.sourceHpHzHandler:  source node: "++nodeName++"  is undefined \n");
			},
			// else all ok
			{
			thisSynth = e.allSourceNodes[nodeName.asSymbol].at(\synth);

			if ( thisSynth == nil, {error("satie4UnityProtocol.sourceHpHzHandler:  source node: "++nodeName++"  BUG FOUND: undefined SYNTH  \n");});

			if ( (args.size != 3 ) ,
			{"satie4UnityProtocol.sourceHpHzHandler: bad arg count for hpHz message".warn;},
			// else
			{
			// get value from vector, and write to connectionState
			hpHz = args[2];   // get highpass cutoff value
			thisSynth.set(\hpHz ,  clip(hpHz, 1, halfSrate ));
			});
			});*/
		};

		// osc rx   ARGS:  sourceName spread
		~sourceSpreadHandler = { 	| args |
			var nodeName  = args[1];
			var spread;
			var thisSynth;

			// postf("sourceHpHzHandler:  nodeName: %  size: % args: %\n", nodeName, args.size, args);
			/*			if ( e.allSourceNodes.includesKey(nodeName.asSymbol) == false,
			{
			error("satie4UnityProtocol.sourceHpHzHandler:  source node: %  is undefined \n", nodeName);
			},
			// else all ok
			{
			thisSynth = e.allSourceNodes[nodeName.asSymbol].at(\synth);
			if ( thisSynth == nil, {error("satie4UnityProtocol.sourceHpHzHandler:  source node: "++nodeName++"  BUG FOUND: undefined SYNTH  \n");});

			if ( (args.size != 3 ) ,
			{"satie4UnityProtocol.sourceSpreadHandler: bad arg count for hpHz message".warn;},

			// else
			{
			// invert the spread value (usually an exp) to work with SATIE's VBAP-based spatializer (or others)
			spread = 100 *  ( 1 - (clip(args[2],0,1)));  // get values from vector, and write to connectionState
			thisSynth.set(\spread, spread);
			//postf("~connectionCallback:  SPREAD:  connectionName: %  spread: % \n", connectionName, spread);
			});
			});*/
		};


		// osc rx   ARGS:  processName azimuthRADIANS elevationRADIANS gainDB delayMS  lpHZ  distanceMETERS
		~processUpdateHandler = { 	| args |
			var nodeName  = args[1];
			var aziDeg, eleDeg, gainDB, delayMs, lpHz, hpHz, spread, distance;
			var thisGroupName, thisGroup,  myProcess;

			// postf("~sourceUpdateHandler:  nodeName: %  size: % args: %\n", nodeName, args.size, args);
			if ( e.allSourceNodes.includesKey(nodeName.asSymbol) == false,
				{
					error("satie4UnityProtocol.processUpdateHandler:  process node: "++nodeName++"  is undefined \n");
				},
				// else all ok
				{
					// We know this is a sourceProcessingNode since this callback was chosen for this node
					// so by default, we will update the source's group

					thisGroupName = e.allSourceNodes[nodeName.asSymbol].at(\groupNameSym);  // process nodes have unique groups
					thisGroup = e.allGroupNodes[thisGroupName].at(\group).group;
					myProcess = e.allSourceNodes[nodeName.asSymbol].at(\process);
					// thisSynth = e.allSourceNodes[nodeName.asSymbol].at(\synth);

					if ( myProcess == nil, {error("satie4UnityProtocol.processUpdateHandler:  process node: "++nodeName++"  BUG FOUND: undefined process  \n");});

					if ( (args.size != 8 ) ,
						{"satie4UnityProtocol.processUpdateHandler:  message missing values".warn;},
						// else
						{
							// get values from vector, and write to connectionState
							aziDeg = args[2].raddeg;
							eleDeg= args[3].raddeg;
							gainDB = args[4];
							delayMs = args[5];
							lpHz = args[6];
							distance = args[7];  // not used by basic spatializers

							if (myProcess[\update] == nil,
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
					});
			});
		};

		// osc rx   ARGS:  sourceName hpHz
		~processHpHzHandler = { 	| args |
			var nodeName  = args[1];
			var hpHz;
			var thisGroupName, thisGroup,  myProcess;
			var halfSrate = 0.5 * s.sampleRate;

			error("processHpHzHandler:  nodeName: %  size: % args: %\n", nodeName, args.size, args);
			/*			if ( e.allSourceNodes.includesKey(nodeName.asSymbol) == false,
			{
			error("satie4UnityProtocol.processHpHzHandler:  process node: "++nodeName++"  is undefined \n");
			},
			// else all ok
			{
			thisGroupName = e.allSourceNodes[nodeName.asSymbol].at(\groupNameSym);  // process nodes have unique groups
			thisGroup = e.allGroupNodes[thisGroupName].at(\group).group;
			myProcess = e.allSourceNodes[nodeName.asSymbol].at(\process);

			if ( myProcess == nil, {error("satie4UnityProtocol.processHpHzHandler:  process node: "++nodeName++"  BUG FOUND: undefined process  \n");});


			if ( (args.size != 3 ) ,
			{"satie4UnityProtocol.processHpHzHandler: bad arg count for hpHz message".warn;},
			// else
			{
			// get value from vector, and write to connectionState
			hpHz = args[2];   // get highpass cutoff value

			if (myProcess[\updateHpHz] == nil,
			{
			//postf("processHpHzHandler:  setting update for nodes group %\n", connectionName);
			// distance not used by standard spatializers
			thisGroup.set(\hpHz ,  clip(hpHz, 1, halfSrate ));
			},
			// else use custom handler
			{
			// postf("processHpHzHandler:  calling custom update handler for %\n", connectionName);
			// distance used by custom process functions
			myProcess[\updateHpHz].value(myProcess,  clip(hpHz, 1, halfSrate ));
			});
			});
			});*/
		};

		// osc rx   ARGS:  sourceName spread
		~processSpreadHandler = { 	| args |
			var nodeName  = args[1];
			var spread;
			var thisGroupName, thisGroup,  myProcess;

			error("sourceHpHzHandler:  nodeName: %  size: % args: %\n", nodeName, args.size, args);
			/*			if ( e.allSourceNodes.includesKey(nodeName.asSymbol) == false,
			{
			error("satie4UnityProtocol.processSpreadHandler:  process node: "++nodeName++"  is undefined \n");
			},
			// else all ok
			{
			thisGroupName = e.allSourceNodes[nodeName.asSymbol].at(\groupNameSym);  // process nodes have unique groups
			thisGroup = e.allGroupNodes[thisGroupName].at(\group).group;
			myProcess = e.allSourceNodes[nodeName.asSymbol].at(\process);

			if ( myProcess == nil, {error("satie4UnityProtocol.processSpreadHandler:  process node: "++nodeName++"  BUG FOUND: undefined process  \n");});

			if ( (args.size != 3 ) ,
			{"satie4UnityProtocol.processSpreadHandler: bad arg count for hpHz message".warn;},

			// else
			{
			// invert the spread value (usually an exp) to work with SATIE's VBAP-based spatializer (or others)
			spread = 100 *  ( 1 - (clip(args[2],0,1)));  // get values from vector, and write to connectionState


			if (myProcess[\spread] == nil,
			{
			//postf("~connectionProcessCallback:  setting spread for node's group  %\n", connectionName);
			thisGroup.set(\spread, spread);
			},
			// else use a custom handler
			{
			//postf("~connectionProcessCallback:  calling custom spread handler for %\n", connectionName);
			myProcess[\spread].value(myProcess, spread);

			});
			});
			});*/
		};

		// e.g  /satie/source/prop nodeName  key val
		~sourceNodeCallback = {
			| args |
			var name, type, values, eventName, state;

			name = args[1];
			type = args[0].asString.split[3].asSymbol;

			'~sourceNodeCallback'.postln;

			if ( e.allSourceNodes.includesKey(name.asSymbol) == false,
				{
					warn("satie4UnityProtocol.sourceNodeCallback:  source node: "++name++" is undefined \n");
				},
				// else node is defined, process.
				{

					if ( e.debugFlag,
						{
							postf("~sourceNodeCallback:  arg1:  %  type : %    arg2: %   arg3: %  \n", name, type, args[2], args[3]);
					});

					switch(type,
						'prop',
						{
							error("~sourceNodeCallback:  PROP MESSAGE CALLED BY:  %\n", name);
							/*						if ( (args.size > 2) ,
							{
							e.setProperty(name, args[2], args[3]);
							error("~sourceNodeCallback:  nodeName: %  setProp: %  key: % value: %\n", name, args[2], args[3]);
							},
							{
							"sourceNodeCallback_prop:  osc message: missing values".warn;

							}); // else*/
						},
						'uri',
						{
							error("~sourceNodeCallback:  IGNORING URI MESSAGE TO:  nodeName: %  mesageType: %  %\n", name, type);
							//e.setUri(name, args[2]);
						},
						'event',
						{
							//postf("~sourceNodeCallback:  nodeName: %  mesageType: %  size: % args: %\n", name, type, args.size, args);
							if ( (args.size < 3 ) ,
								{"sourceNodeCallback_setEvent: osc message: missing values".warn; },
								{  // else
									values = args;
									eventName = args[2];
									values.removeAt(0);   // trim off oscAddr nodeName eventName
									values.removeAt(0);
									values.removeAt(0);
									e.setEvent(name, eventName, values);
								}
							)
						},
						'state',
						{
							if ( (args.size > 2) ,
								{
									state = args[2];
									e.setState(name, state);
								},
								{"~setState: OSCrx message with no values".warn; })  // else
						},
						{postf("~sourceNodeCallback:  UNMATCHED:  nodeName: %  mesageType: %  size: % args: %\n", name, type, args.size, args)};
					);
			});
		};

		// ~processCallback = { "processCallback called".warn; };
		// e.g  /satie/source/prop nodeName  key val
		// source node has unique group, updates are to source's group (to cloned synths etc)
		~processCallback = { | args |
			var name, type, values, eventName, state, myProcess, myProcessSym;
			name = args[1];
			type = args[0].asString.split[3].asSymbol;

			if ( e.allSourceNodes.includesKey(name.asSymbol) == false,
				{
					error("satie4UnityProtocol.processCallback:  process node: "++name++" is undefined \n");
			});

			myProcess = e.allSourceNodes[name.asSymbol].at(\process);

			if ( myProcess== nil,
				{
					error("satie4UnityProtocol.processCallback:  process node: "++name++" missing proces \n");
			});

			switch(type,
				'prop',
				{
					error("~processCallback:  PROP MESSAGE CALLED BY:  %\n", name);
					/*					if (myProcess[\prop] == nil,
					{
					var groupName = e.allSourceNodes[name.asSymbol].at(\groupNameSym);

					//postf("~processCallback: send PROP to group:  nodeName: %  group: %   \n", name,groupName);

					e.setGroupProperty(groupName, args[2], args[3]);
					},
					// else use custom handler
					{
					//postf("~~processCallback:  calling custom prop handler for %\n", name);
					myProcess[\prop].value(myProcess,  args[2], args[3]);
					});*/
				},
				'event',
				{
					//postf("~processCallback:  nodeName: %  mesageType: %  size: % args: %\n", name, type, args.size, args);
					if ( (args.size < 3 ) ,
						{"~processCallback event: OSCrx message with no values".warn;},
						{  // else
							values = args;
							eventName = args[2];
							values.removeAt(0);  // remove first three elements in array:  oscAddress nodeName eventName
							values.removeAt(0);
							values.removeAt(0);


							// NOTE:  event names for processes are either:
							//  \setParam (to the state of a process param)
							// or
							// allOtherNames (to call a function with an arg vec)
							if (( eventName == \setParam)&& (values.size == 2),
								{
									//postf("processCallback event_setParam: %  % \n", values[0].asSymbol, values[1]);
									myProcess[values[0].asSymbol] = values[1] ;

								},
								// else  it is a function call
								{
									//postf("~processCallback: event_function call:  nodeName: %  event: %  size: % args: %\n", name, eventName.asSymbol, values.size, values);
									myProcess[eventName.asSymbol].value(myProcess, values);   // call the process corresponding method passing argVec
							});
					});
				},
				{postf("~processCallback:  UNMATCHED:  nodeName: %  mesageType: %  size: % args: %\n", name, type, args.size, args)};
			);
		};


		//~groupCallback = { "groupCallback called".warn;};

		// e.g  /satie/source/prop nodeName  key val
		~groupNodeCallback = {
			| args |
			var name, type, values, eventName, state;

			name = args[1];
			type = args[0].asString.split[3].asSymbol;

			if ( e.debugFlag,
				{
					postf("~groupCallback:  arg1nodeName: %  type : %    argCount: %   args: %  \n", name, type, args.size,  args);
			});

			switch(type,
				'prop',
				{
					error("~groupNodeCallback:  PROP MESSAGE CALLED BY:  %\n", name);
					/*					if ( (args.size < 4 ) ,
					{"~groupCallback.prop: message missing values".warn;},
					// else
					{
					error("~groupCallback:  nodeName: %  setProp: %  key: % value: %\n", name, args[2], args[3]);
					e.setGroupProperty(name, args[2], args[3]);
					});*/

				},
				'uri',
				{
					//not implemented
					// ~setUri.value(name, args[1])
				},
				'event',
				{
					//postf("~groupCallback:  nodeName: %  mesageType: %  size: % args: %\n", name, type, args.size, args);
					if ( (args.size < 3 ) ,
						{"groupCallback.event: osc message: missing values".warn; },
						{  // else
							values = args;
							eventName = args[2];
							values.removeAt(0);   // trim off oscAddr nodeName eventName
							values.removeAt(0);
							values.removeAt(0);
							e.setGroupEvent(name, eventName, values);
					});
				},
				'state',
				{
					// not implemented
				},
				'add',
				{
					if ( (args.size < 3 ) ,
						{"groupCallback.add:  osc message: missing values".warn; },
						{
							postf("~groupCallback.add:  nodeName: %  add member: %  \n", name, args[2]);

							e.addMember(name, args[2]);
					});
				},
				'drop',
				{
					if ( (args.size < 3 ) ,
						{"groupCallback.drop:  osc message: missing values".warn; },
						{
							postf("~groupCallback.drop:  nodeName: %  add member: %  \n", name, args[2]);

							e.dropMember(name, args[2]);
					});
				},
				{
					postf("~groupCallback:  UNMATCHED:  nodeName: %  mesageType: %  size: % args: %\n", name, type, args.size, args);
			});
		};


		~createSource = {| self, sourceName, uriPath , groupName = \default |
			//"createSource called".inform;
			if (self.allSourceNodes.includesKey(sourceName),
				{
					postf("~createSource:   % exists, no action \n", sourceName);
				},
				// else create new node
				{
					var type;
					type = self.getUriType(uriPath);

					postf("~createSource:   NAME: %   type :%  \n", sourceName, type);

					if (  (type=="plugin")  ||  (type=="effect"),
						{
							self.createSourceNode(sourceName.asSymbol, uriPath,groupName );
						},
						// else
						{
							postf("~createSource: node  %  URI: %,  wrong type,  no action \n", sourceName, type);
					});

				}
			);
		};

		~createProcess = {| self, sourceName, uriPath , groupName = \default |
			"~createProcess called".inform;
			if (self.allSourceNodes.includesKey(sourceName),
				{
					postf("~createSource:   % exists, no action \n", sourceName);
				},
				// else create new node
				{
					var type;
					type = self.getUriType(uriPath);

					if ( type == "process",  {
						self.createSourceProcess(sourceName.asSymbol, uriPath,groupName );
					},
					// else
					{
						postf("~createProcess: node  %  URI: %,  wrong type,  no action \n", sourceName, type);
					});
				}
			);
		};

		// ~createSourceProcess = { "createSourceProcess called".warn;};
		// called for uri type process://
		//error check uriName done before call this, uriPath will be a process name
		// ignore groupName since a unique one will be generated for this node and its clones
		//  uri path may include arguments
		// eg. uriPath:  "process://sheefa arg1 1.1 arg2 2.2 arg3"

		~createSourceProcess = { | self, sourceName, uriPath , groupNameDummy = \default |
			var temp, type, charIndex, processName, myProcess, cloneGroup, cloneGroupName;
			var processClone = nil;
			var argsString = "";
			var stringArray;
			var rawArgVec = nil;
			var argList = List[];

			if ( e.debugFlag,
				{
					("~createSourceProcess:  URI"++uriPath).postln;
			});

			// sheefa = uriPath;

			stringArray = uriPath.asString.split($ );
			charIndex = stringArray[0].asString.find("://");
			processName = stringArray[0].asString.subStr(charIndex+3);
			argsString = uriPath.asString.subStr(stringArray[0].size+1);
			rawArgVec= argsString.asString.split($ );

			// make list of items in argString
			rawArgVec.do( { arg item;
				if ( item != "",
					{
						argList.add(item);
				});
			});

			if (self.allSourceNodes[sourceName.asSymbol]  != nil,
				{
					error("~createSourceProcess source Process node: %,   ALREAYD EXISTS, aborting \n", sourceName);
				},
				// else ALL GOOD,  instantiate
				{
					processClone = procMan.cloneProcess(processName.asSymbol);
					if (processClone == nil,
						{
							error("~createSourceProcess: undefined process name:"++processName++"   ,  node not created \n");
						},						// else node good to go
						{
							postf("~createSourceProcess nodeName: %,   process name: %  URI: % \n", sourceName, processName, uriPath);
							//postf("~createSourceProcess: %:  uri: %  group: %\n", sourceName, uriPath, groupName);

							self.allSourceNodes[sourceName.asSymbol] = Dictionary();   // create node  -- create node-specific dict.
							self.allSourceNodes[sourceName.asSymbol].put(\plugin, \nil);

							// generate groupName unique to source node
							cloneGroupName = sourceName ++ "_group";
							cloneGroup = self.createGroup(cloneGroupName.asSymbol);   // create group for this node and its clones


							cloneGroup = self.allGroupNodes[cloneGroupName.asSymbol].at(\group); // must be called after createGroup() above

							self.allSourceNodes[sourceName.asSymbol].put(\process, processClone);
							self.allSourceNodes[sourceName.asSymbol].put(\groupNameSym, cloneGroupName.asSymbol);

							myProcess = self.allSourceNodes[sourceName.asSymbol].at(\process);

							// send URI's argsString to setup without any error checking

							myProcess[\setup].value(myProcess, sourceName.asSymbol, cloneGroupName.asSymbol, argList );   // set the state of the process
							self.setSynth(sourceName.asSymbol, "");  // sets dummy plugin as placeholder

							// osc.sourceOSC(sourceName.asSymbol, e.['processCallback']);   // DO NOT create OSC callback
							postf("~createSourceProcess: CREATED NODE: %,  with  process:  % \n", sourceName, processName);
					});
			});
		};


		~createSourceNode = { | self, sourceName, uriString , groupName = \default, argsList|
			var synthName;
			var type;

			// MAKE SURE URI STRING IS VALID -- if not, will post warning and be set to plugin://dummyPlugin
			uriString = self.checkUri(sourceName, uriString);

			type = self.getUriType(uriString);

			if (groupName == "", { groupName = \default; });   // make sure group name is ok

			// check to see if group  exists (even if the corresponding groupNode has not yet been instntiated),  if  not, create it
			if ( satie.satieGroups[groupName.asSymbol] == nil,
				{
					postf("~createSource_groupcheck:   source:%    group:  % undefined,  CREATING GROUP NOW \n", sourceName, groupName);
					self.createGroup(groupName.asSymbol);
				}
			);

			postf("~createSourceNode: %:  uri: %  group: %\n", sourceName, uriString, groupName);
			self.allSourceNodes[sourceName.asSymbol] = Dictionary();   // create node  -- create node-specific dict.
			self.allSourceNodes[sourceName.asSymbol].put(\plugin, \nil);
			self.allSourceNodes[sourceName.asSymbol].put(\uriStr, uriString);

			// now set node's group
			self.allSourceNodes[sourceName.asSymbol].put(\groupNameSym, groupName.asSymbol);

			// call  setSynth to complete instance creation
			// note:  setSynth acts on URI

			if ( ( (type != "plugin") &&  (type != "effect") ),
				{
					error("~createSourceNode: BUG FOUND IN CODE:   URL SHOULD BE OK" );
					self.setSynth(sourceName.asSymbol, \dummyPlugin);
				},
				// else  // path format ok, proceed
				{
					synthName = self.getUriName(uriString);
					self.setSynth(sourceName.asSymbol, synthName);
			});
		};

		//~createGroup = { "createGroup called".warn;};
		// returns group
		~createGroup = { |self,  groupName |

			if (self.allGroupNodes.includesKey(groupName),
				{
					postf("createGroup:  GroupNode % exists, no action \n", groupName);
					self.allGroupNodes[groupName.asSymbol].at(\group);  // return group
				},
				// else create new group node
				{
					var group;

					if (satie.satieGroups[groupName.asSymbol] != nil, // group already exists in SATIE, no need to create it
						{
							group = satie.satieGroups[groupName.asSymbol];
						},
						// else  group does not exist in SATIE,  create it
						{
							group = satie.makeSatieGroup(groupName.asSymbol);
							if ( groupName.asSymbol == \default,
								{
									postf("~createGroup:  BUG FOUND-- SHOULD NOT HAVE TO INSTANITATE DEFAULT GROUP !!!!");
							});
					});

					postf("~createGroupNode:   % \n", groupName);
					self.allGroupNodes[groupName.asSymbol] = Dictionary();   // create node  -- create node-specific dict.
					self.allGroupNodes[groupName.asSymbol].put(\group , group);  // save group
					self.allGroupNodes[groupName.asSymbol].put(\groupSym , groupName.asSymbol);  // save group name symbol
					self.allGroupNodes[groupName.asSymbol].put(\members, List() );  // create dict for members
					self.allGroupNodes[groupName.asSymbol].put(\plugin, \nil);

					//  set group
					self.allGroupNodes[groupName.asSymbol].put(\group, group );

					//osc.sourceOSC(groupName.asSymbol, e.['groupCallback']);   // NO NEED TO create OSC callback

					group;  // returns groups
				}
			);
		};

		~setSynth = { 	| self, nodeName, pluginName |
			var validPluginName = pluginName;
			var sourceNode = self.allSourceNodes[nodeName.asSymbol];
			var groupName = sourceNode.at(\groupNameSym);
			var type;
			var inBus;

			var uriPath = sourceNode.at(\uriStr);

			type = self.getUriType( uriPath );


			//postf("~setSynth: node: %   uriStr: %  type: % \n",  nodeName, uriPath,   type);

			//postf("~setSynth: node: %    NEW: %  CURRENT: % \n", nodeName, pluginName.asSymbol, self.allSourceNodes[nodeName.asSymbol].at(\plugin).asSymbol);


			// NEED A REAL SYNTH DEF CHECK HERE- set the \dummyPlugin if it fails
			if ( validPluginName.asString == "", { validPluginName = \dummyPlugin; });


			if (validPluginName.asSymbol != self.allSourceNodes[nodeName.asSymbol].at(\plugin).asSymbol,
				{
					var synth;

					// check to see if a synth has already been allocacted, if so, kill it
					if  ( self.allSourceNodes[nodeName.asSymbol].at(\synth) != nil,
						{
							'~setSynth: REPLACE EXISTING SYNTH'.postln;
							satie.cleanInstance(nodeName.asSymbol,groupName.asSymbol );
					});

					sourceNode.put(\plugin, validPluginName.asSymbol);


					if ( ( (type == "effect") || (groupName == \effect) ),
						{
							inBus = self.getFxInBus(uriPath);
							postf("~setSynth: assigning inBus: % to effects node % \n", satie.aux[inBus] , nodeName);
							synth = satie.makeInstance(nodeName.asSymbol, validPluginName.asSymbol, \effect, [\in, satie.aux[inBus] ]);
						},
						// else
						{
							synth = satie.makeInstance(nodeName.asSymbol, validPluginName.asSymbol, groupName.asSymbol);
					});


					sourceNode.put(\synth, synth);
				},
				{
					//postf("~setSynth: ignoring set plugin % for node % : plugin already set \n", pluginName, nodeName);
				}
			);
			//"setSynth called".inform;

		};


		/*		~setProperty = { | self, nodeName, property, value |
		var thisSynth = self.allSourceNodes[nodeName.asSymbol].at(\synth);
		//"setProperty called".inform;
		//postf("~setProperty: seting % of % to %\n", property, nodeName, value);

		thisSynth.set(property.asSymbol, value);
		};*/

		/*		~setGroupProperty = { | self, groupName, property, value |
		var group = self.allGroupNodes[groupName.asSymbol].at(\group).group;

		//postf("~setGroupProperty: seting % of % to %\n", property, groupName, value);

		group.set(property.asSymbol, value);
		};*/


		~setState = { | self, nodeName,  value |
			var thisSynth = self.allSourceNodes[nodeName.asSymbol].at(\synth);
			var state;

			if ( value == 0 , { state = false}, {state = true});

			thisSynth.run(state);


			if (self.debugFlag, {postf("~setState: seting state of % to %\n", nodeName, state)});
		};

		// events RX:   /spatosc/core/source/nodename/event eventName v1...vN
		~setGroupEvent = { | self, groupName, eventName,  args |
			var valueCount = args.size;
			var group = self.allGroupNodes[groupName.asSymbol].at(\group).group;

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

		~setEvent = { | self, nodeName, eventName,  args |
			var valueCount = args.size;
			var thisSynth = self.allSourceNodes[nodeName.asSymbol].at(\synth);

			// DEBUG
			//var db = ~allSourceNodes.at( nodeName.asSymbol).at(\outDB);
			//"setEvent called".inform;


			if ( (valueCount > 1) ,    // pass vector
				{
					// DEBUG
					//postln("~setEvent: " ++ nodeName.asSymbol ++ "    args: " ++ args  );
					//if( args[2] < 0.07, {postln("~setEvent: " ++ nodeName.asSymbol ++ "   INCIDENCE  " ++ args[2]  )});

					thisSynth.set(eventName.asSymbol, args);
				},
				// else
				{
					if ( (valueCount == 1) ,    // pass value
						{
							// DEBUG
							// postln("~setEvent: " ++ nodeName.asSymbol ++ "        BANG\n");

							thisSynth.set(eventName.asSymbol, args[0]);
						},
						// else  no args.. just pass 1
						{
							"no args to setEvent".warn;
							thisSynth.set(eventName.asSymbol, 1);
						}
					);
			});
		};

		//~addMember = { "addMember called".warn;};
		~addMember = { | self,  groupName, nodeName |
			var memberList = self.allGroupNodes[groupName].at(\members);
			var group = self.allGroupNodes[groupName].at(\group).group;
			//


			// check to see if member is already in group

			// if not add it
			// satie.changeGroup(groupName, nodeName);   // assign source node to group's proxySpace
			//  self.allSourceNodes[nodeName.asSymbol].put(\group, groupProxy);
			memberList.add(nodeName.asSymbol);


			postf("~addMember: group % adding member %\n", groupName, nodeName);
			// ~groupCopyState(groupName, nodeName);
		};


		//~dropMember = { "dropMember called".warn;};

		~dropMember = { |self  groupName, memberName |
			var memberList = self.allGroupNodes[groupName].at(\members);
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

		~clearScene = {  | self |
			var nodelist = self.allSourceNodes.keys;
			"clearScene called".warn;
			//'CLEARING SCENE'.postln;

			// first flush all nodes
			self.allSourceNodes.keysDo { |key |
				//key.postln;
				self.clearSourceNode(key);
			};

			self.allSourceNodes.clear();
			self.allSourceNodes.size;

			// do not clear all groups except default group

			/*		satie.satieGroups.keysDo{ |key |
			var nodeSym = key;

			if (key != \default,
			{
			satie.killSatieGroup(key);
			});
			};*/

		};
		~deleteSource = { | self, nodeName |
			//"deletaSource called".inform;
			if ( self.allSourceNodes.includesKey(nodeName.asSymbol) ,
				{
					// if its a sourceProcessNode do this first


					self.clearSourceNode(nodeName.asSymbol);
					//'REMOVE NODE'.postln;
					self.allSourceNodes.removeAt(nodeName.asSymbol);     // remove node from global dictionary
			});
		};
		~removeGroup = { | self, groupName |
			"removeGroup called".inform;
			if ( self.allGroupNodes.includesKey(groupName.asSymbol) ,
				{
					//  No OP  ~clearGroupNode.value(groupName.asSymbol);
					postf("~removeGroup:  group node: % \n",  groupName);
					self.allGroupNodes.removeAt(groupName.asSymbol);     // remove node from global dictionary
			});
		};
		~clearGroupeNode = { | self, nameSym |
			var node = self.allGroupNodes[nameSym];
			//var connectionName = node.at(\connectionName);
			var nodeKeys = node.keys;
			var thisGroup = self.allGroupNodes[nameSym].at(\group);
			var memberList = self.allGroupNodes[nameSym].at(\members);
			"clearGroupNode called".inform;


			//~cleaninstance(nameSym, thisGroup);

			postf("~clearGroupeNode:  group node: % \n",  nameSym);

			// disconnect callbacks

			osc.removeGroupOSC(nameSym);
			//  clear node's local dictionary
			// maybe this is unnecessary

			memberList.clear();

			nodeKeys.do { | key |
				postf("removing node keys:  node: %   key %  \n",  nameSym, key);
				node.removeAt(key);
			};
		};

		~clearSourceNode = {  | self, nameSym |
			var node = self.allSourceNodes[nameSym];
			//var connectionName = node.at(\connectionName);
			var nodeKeys = node.keys;
			var thisGroupName = self.allSourceNodes[nameSym].at(\groupNameSym);
			//"clearSourceNode called".inform;

			//self.allSourceNodes[nameSym].postln;

			// is this a process node?
			if ( self.allSourceNodes[nameSym].at(\process) != nil,
				{
					var groupSym =  self.allSourceNodes[nameSym].at(\groupNameSym);

					var myProcess = self.allSourceNodes[nameSym].at(\process);



					// now kill off the clones in that group
					//myProcess.at(\nodeGroupProxy).free;

					myProcess.cleanup();   // frees any state the process may have created, i.e. synths

					//  IF THE SYNTH IS NOT CLEANED FROM THE NODE TREE, DO THE SAME AS THE REGULAR SOURCE CASE BELOW
					satie.cleanInstance(nameSym,thisGroupName );

					// now delete group
					self.removeGroup(groupSym); //
					satie.killSatieGroup(groupSym);   // kill the group, since it was unique to this source
				},
				// else  its just a regular source
				{
					var synth = satie.satieGroupInstances[thisGroupName][nameSym];
					satie.cleanInstance(nameSym,thisGroupName );
					synth.free;    // to make sure it gets cleaned from the node tree
					if (self.debugFlag, {postf("clearSourceNode: delete  node  % in group %\n", nameSym, thisGroupName);});

			});

			//postf("~clearing:  node: % and connection: %\n",  nameSym, connectionName);

			// disconnect callbacks
			/*		if (node.includesKey(\connectionName),
			{
			osc.removeConnectionOSC( node.at(\connectionName).asSymbol );
			});*/

			osc.removeSourceOSC(nameSym);
			//  clear node's local dictionary
			// maybe this is unnecessary
			nodeKeys.do { | key |
				//postf("removing node keys:  node: %   key %  \n",  nameSym, key);
				node.removeAt(key);
			};
		};

		~getUriName = { |  self, uriPath |
			var stringArray = uriPath.asString.split($ );
			var charIndex = uriPath.asString.find("://");
			var temp = uriPath.asString.subStr(charIndex);
			var uriName = temp.asString.replace("://", "");

			uriName.asString.split($ )[0].asString;
		};

		~getUriType = { | self, uriPath |
			var charIndex, uriName, type, temp;

			type = "";

			// type://name (i.e. plugin://DustDust, file://<path>

			// check URI name to make sure its valid

			if (uriPath.asString.contains("://") == false,
				{
					if (uriPath.size > 0, {warn("~getUriType:  uri type format error: % ", uriPath);});
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

		~getUriArgs = { |self, uriPath  |
			var temp,charIndex, processName;
			var argsString = "";
			var stringArray;
			var rawArgVec = nil;
			var argList = List[];

			//("~getUriArgs:  URI: "++uriPath).postln;

			// sheefa = uriPath;

			stringArray = uriPath.asString.split($ );

			if (stringArray.size < 2,
				{
					[];
				},
				{

					charIndex = stringArray[0].asString.find("://");
					processName = stringArray[0].asString.subStr(charIndex+3);

					argsString = uriPath.asString.subStr(stringArray[0].size+1);

					//argsString.postln;

					rawArgVec= argsString.asString.split($ );
					// make list of items in argString
					rawArgVec.do( { arg item;
						if ( item != "",
							{
								argList.add(item);
						});
					})
			});
		};

		// no error checking, must not be called on empty node, or non-effects-type node
		// uriPath  eg:   effect://reverb satieAuxBus 3
		~getFxInBus = { | self, uriPath |
			var synth;
			var auxBus = 0;  //default bus
			var satieBus;


			var argList = self.getUriArgs(uriPath);

			//("~getFxInBus:  URI: "++uriPath).postln;


			// if there are two args, and the first arg is the keyword "inBus"then try to set the effect's \in param to the second arg
			if (argList.size > 1,
				{
					if (argList[0].asString == "inBus",
						{
							auxBus = argList[1].asInt.clip(0, self.satieAuxBusCount-1);
					});
			});

			auxBus;  // returns auxBus for effects node

			//	satieBus = satie.aux[auxBus];
			//synth = self.allSourceNodes[nodeName.asSymbol].get(\synth);
			//synth.set(\in, auxBus);
			//synth.set(\in, satieBus );
			//postf("~setFxInBus: setting Aux Bus in %   % for effects node % \n", auxBus, uriPath, nodeName);
		};


		// if URI is ok, returns uriString, else   "plugin://dummyPlugin"
		~checkUri = { | self, nodeName, uriString |
			var type = self.getUriType(uriString);

			//uriString.postln;
			if ( (type != "plugin") && (type != "effect"),
				{
					error("~checkUri:  node: %  bad URI: % , using default: plugin://dummyPlugin \n", nodeName, uriString);

					"plugin://dummyPlugin"
				},
				{
					uriString;
			});
		};

		// DEBUGGING FUNCTIONS
		/*		~dumpConnections = { 	| self |
		var undefined = 0;

		self.allNodes.keysDo { |key |
		var nodeSym = key;
		postf("node: %  :   ", key);
		postf("\t : node:   %  connectionName:    % \n",  key, self.allNodes[nodeSym].at(\connectionName));

		};
		};*/

		~dumpNodes = { 	| self |
			//var connections = 0;
			self.allSourceNodes.keysDo { |key |
				var nodeSym = key;
				postf("node: %  \n", key);
				self.allSourceNodes[nodeSym].keysDo { | key |
					postf("\t : %  =  % \n",  key, self.allSourceNodes[nodeSym].at(key));
				};
			};
		};

		~dumpGroups = { 	| self |

			postf("~dumpGroups: %  groups defined via OSCrx: \n", self.allGroupNodes.size);
			self.allGroupNodes.keysDo { |key |
				var nodeSym = key;
				var memberList = self.allGroupNodes[nodeSym].at(\members);

				postf("Group node: %  members: \n", nodeSym);
				memberList.do { | key |
					postf("\t : %  \n",  key);
				};

				postf("node: %  \n", key);
				self.allGroupNodes[nodeSym].keysDo { | key |
					postf("\t : %  =  % \n",  key, self.allGroupNodes[nodeSym].at(key));
				};
			};
		};

		// DEPRICATED
		~globalSetState = { "globalSetState has been depricated".warn;};
		~globalSet = { "globalSet  has been depricated".warn;};
		~isFXuri = {"isFXuri has been depricated".warn;};


		// ~updateBlobHandler
		// receives OSC messages that look like:   /satie/source/upblob srcName blob_data1 .... blob_dataN
		// blob data format:
		// 12 unsigned bytes as follows
		// aziDeg =   byte1  * 360 * 1/255   , offset to range: -179 to 180
		// elevDeg = byte2  * 360 * 1/255   , offset to range: -179 to 180
		// gainDB: (   0.00001 *  ( byte3 << 24 + byte4 << 16  + byte5 << 8  + byte6 ) ).ampdb
		// delayMS:   0.1 *  ( byte7 << 8  + byte8  )     // input values < 6553 milliseconds are clipped to 6553
		// lpHz:    byte9 << 8  + byte10       // input values < 65535 hz are clipped to 65535
		// distanceMeters:   0.01 *  ( byte11 << 8  + byte12  )     // input values < 655 meters are clipped to 655

		~blobUpdateHandler = {
			arg msg;

			if (msg.class != Array,
				{
					error("satie4UnityProtocol.blobUpdateHandler;  BUG FOUND: received message: %  not an ARRAY \n", msg);
					~sickMsg=msg;
				},
				{
					if (msg.size != 3,
						{
							"satie4UnityProtocol.blobUpdateHandler;  bad message format: expects  address nodeName blobArray".error;
							postf("\t blobUpdateHandler: bad message: %\n", msg);

						},
						// else
						{
							var aziDeg, eleDeg, gainDB, delayMs, lpHz, distanceMeters;
							var oscAddr = msg[0].asString;

							var degScaler = 1.411764705882 ; // 360/255
							var thisSynth = nil;

							var nodeType = oscAddr.split($/)[2];


							//postf("~satie4Unity.blobUpdateHandler:  nodeName %,  noteType % \n", nodeName, nodeType);
							if (msg.size == 0,
								{
									~sickMsg=msg;

									postf("~satie4Unity.blobUpdateHandler: mess: %    length %\n", msg, msg.size);
									~sickMsg.dump.class

							});


							if (  (msg[1].class != Symbol ) || (msg[2].class != Int8Array ) ||  ( msg[2].size != 12),
								{
									error("satie4UnityProtocol.blobUpdateHandler:  message bad data format, expecting array  of  12 bytes :");
									error("\t satie4UnityProtocol.blobUpdateHandler:  message % \n", msg);

								},
								// else data good, extract
								{
									var nodeName = msg[1];
									var dataArray = msg[2];

									aziDeg = degScaler *  e.sined2unsignedByte( dataArray[0] );
									if (aziDeg >179, { aziDeg = aziDeg - 360;});

									eleDeg = degScaler * e.sined2unsignedByte( dataArray[1] );
									if (eleDeg > 179, { eleDeg = eleDeg - 360;});

									gainDB =  (e.sined2unsignedByte(  dataArray[2] ) << 24);
									gainDB =  gainDB + (e.sined2unsignedByte(  dataArray[3]) << 16);
									gainDB =  gainDB +   (e.sined2unsignedByte(  dataArray[4]) << 8);
									gainDB =  gainDB +  e.sined2unsignedByte(  dataArray[5] );
									gainDB = gainDB * 0.00001;
									gainDB = gainDB.ampdb;

									delayMs  = (e.sined2unsignedByte(  dataArray[6]) << 8);
									delayMs =  delayMs +  e.sined2unsignedByte(  dataArray[7] );
									delayMs = delayMs * 0.1;

									lpHz  = (e.sined2unsignedByte(  dataArray[8]) << 8);
									lpHz =  lpHz +  e.sined2unsignedByte(  dataArray[9] );

									distanceMeters  = (e.sined2unsignedByte(  dataArray[10]) << 8);
									distanceMeters =  distanceMeters +  e.sined2unsignedByte(  dataArray[11] );
									distanceMeters = distanceMeters * 0.01;

									if (e.debugFlag,
										{
											postf("satie4UnityProtocol.blobUpdateHandler;     aziDeg %  eleDeg %  gainDB %  delayMs %  lpHz %  distanceMeters %        \n", aziDeg, eleDeg, gainDB, delayMs, lpHz, distanceMeters);
									});

									switch(nodeType.asSymbol,
										'source',
										{
											if ( e.allSourceNodes.includesKey(nodeName.asSymbol) == false,
												{
													error("satie4UnityProtocol.blobUpdateHandler:  source node: "++nodeName++"  is undefined \n");
												},
												// else all ok
												{
													thisSynth = e.allSourceNodes[nodeName.asSymbol].at(\synth);

													if ( thisSynth == nil,
														{
															error("satie4UnityProtocol.blobUpdateHandler:  source node: "++nodeName++"  BUG FOUND: undefined SYNTH  \n");
														},
														//else
														{
															// distance not used by source nodes
															thisSynth.set(\aziDeg, aziDeg, \eleDeg, eleDeg, \gainDB, gainDB, \delayMs, delayMs, \lpHz, lpHz);
													});
											});
										},
										'group',
										{
										},
										'process',
										{
											// We know this is a sourceProcessingNode since this callback was chosen for this node
											// so by default, we will update the source's group
											var thisGroupName;
											var thisGroup;
											var myProcess;

											thisGroupName = e.allSourceNodes[nodeName.asSymbol].at(\groupNameSym);  // process nodes have unique groups
											thisGroup = e.allGroupNodes[thisGroupName].at(\group).group;
											myProcess = e.allSourceNodes[nodeName.asSymbol].at(\process);
											// thisSynth = e.allSourceNodes[nodeName.asSymbol].at(\synth);

											if ( myProcess == nil,
												{
													error("satie4UnityProtocol.blobUpdateHandler:  process node: "++nodeName++"  BUG FOUND: undefined process  \n");
												},
												// else all good

												{
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
															myProcess[\updateConnection].value(myProcess, aziDeg, eleDeg, gainDB, delayMs, lpHz, distanceMeters);
													});
											});

									});
							});
					});
			});
		};

		~sined2unsignedByte= { | self, val |
			var outVal = val;
			if (val < 0, { outVal = 256 + val});
			outVal;
		};

	}); // Environment.make
	"satie4unityprotol loaded".inform;
	e.know = true;
	// postf("passed osc env: %\n", osc);

	// connect renderer oscMessage RX to handlers
	osc.deleteOSC(\satieScene);  // disconnect any previous handlers
	osc.newOSC(\satieScene, e['coreCallback'], "/satie/scene");   // connect handler

	// general
	osc.deleteOSC(\updateBlobHandlerSrc);  // disconnect any previous handlers
	osc.newOSC(\updateBlobHandlerSrc, e['blobUpdateHandler'],  "/satie/source/ublob");   // connect handler

	osc.deleteOSC(\updateBlobHandlerProcess);  // disconnect any previous handlers
	osc.newOSC(\updateBlobHandlerProcess, e['blobUpdateHandler'],  "/satie/process/ublob");   // connect handler


	osc.deleteOSC(\satieSrcSet);  // disconnect any previous handlers
	osc.newOSC(\satieSrcSet, e['setMessageHandler'], "/satie/source/set");   // connect handler

	osc.deleteOSC(\satieGroupSet);  // disconnect any previous handlers
	osc.newOSC(\satieGroupSet, e['setMessageHandler'], "/satie/group/set");   // connect handler

	osc.deleteOSC(\satieProcSet);  // disconnect any previous handlers
	osc.newOSC(\satieProcSet, e['setMessageHandler'], "/satie/process/set");   // connect handler


	// sources
	osc.deleteOSC(\satieSrcProp);  // disconnect any previous handlers
	osc.newOSC(\satieSrcProp, e['sourceNodeCallback'], "/satie/source/prop");   // connect handler

	osc.deleteOSC(\satieSrcState);  // disconnect any previous handlers
	osc.newOSC(\satieSrcState, e['sourceNodeCallback'], "/satie/source/state");   // connect handler

	osc.deleteOSC(\satieSrcEvent);  // disconnect any previous handlers
	osc.newOSC(\satieSrcEvent, e['sourceNodeCallback'], "/satie/source/event");   // connect handler

	osc.deleteOSC(\satieSrcUpdate);  // disconnect any previous handlers
	osc.newOSC(\satieSrcUpdate, e['sourceUpdateHandler'], "/satie/source/update");   // connect handler

	osc.deleteOSC(\satieSrcHpHz);  // disconnect any previous handlers
	osc.newOSC(\satieSrcHpHz, e['sourceHpHzHandler'], "/satie/source/hpHz");   // connect handler

	osc.deleteOSC(\satieSrcSpread);  // disconnect any previous handlers
	osc.newOSC(\satieSrcSpread, e['sourceSpreadHandler'], "/satie/source/spread");   // connect handler




	// groups
	osc.deleteOSC(\satieGroupProp);  // disconnect any previous handlers
	osc.newOSC(\satieGroupProp, e['groupNodeCallback'], "/satie/group/prop");   // connect handler

	osc.deleteOSC(\satieGroupEvent);  // disconnect any previous handlers
	osc.newOSC(\satieGroupEvent, e['groupNodeCallback'], "/satie/group/event");   // connect handler

	osc.deleteOSC(\satieGroupAdd);  // disconnect any previous handlers
	osc.newOSC(\satieGroupAdd, e['groupNodeCallback'], "/satie/group/add");   // connect handler

	osc.deleteOSC(\satieGroupDrop);  // disconnect any previous handlers
	osc.newOSC(\satieGroupDrop, e['groupNodeCallback'], "/satie/group/drop");   // connect handler


	// processes
	osc.deleteOSC(\satieProcessProp);  // disconnect any previous handlers
	osc.newOSC(\satieProcessProp, e['processCallback'], "/satie/process/prop");   // connect handler

	osc.deleteOSC(\satieProcessState);  // disconnect any previous handlers
	osc.newOSC(\satieProcessState, e['processCallback'], "/satie/process/state");   // connect handler

	osc.deleteOSC(\satieProcessEvent);  // disconnect any previous handlers
	osc.newOSC(\satieProcessEvent, e['processCallback'], "/satie/process/event");   // connect handler

	osc.deleteOSC(\satieProcessUpdate);  // disconnect any previous handlers
	osc.newOSC(\satieProcessUpdate, e['processUpdateHandler'], "/satie/process/update");   // connect handler

	osc.deleteOSC(\satieProcessSpread);  // disconnect any previous handlers
	osc.newOSC(\satieProcessSpread, e['processSpreadHandler'], "/satie/process/spread");   // connect handler

	osc.deleteOSC(\satieProcessHpHz);  // disconnect any previous handlers
	osc.newOSC(\satieProcessHpHz, e['processHpHzHandler'], "/satie/process/hpHz");   // connect handler

	osc.deleteOSC(\satieProcessProperty);  // disconnect any previous handlers
	osc.newOSC(\satieProcessProperty, e['processProperty'], "/satie/process/property");   // connect handler

	e;
};


/*
for debugguing

~s4u = ~satie4unityProtocol.value(~osc, ~scbr);
~s4u.debugFlag = true;
~s4u.debugFlag = false;
*/

)