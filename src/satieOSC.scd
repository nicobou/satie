// satieOSC, audio rendering support for Unity
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
satieOSC's message specification is inspired from the SPATOSC specification  (see:   http://code.sat.qc.ca/redmine/projects/spatosc/wiki/spec  )
*/

/*
for debugguing

~satieOSC = ~satieOSCProtocol.value(~osc, ~satie);
~satieOSC.debugFlag = true;
~satieOSC.debugFlag = false;
*/


(
~satieOSCProtocol = { | oscContext, satieContext,  oscID = \satieOSCOSC |
	var osc = oscContext;
	var satie = satieContext;

	var e = Environment.make({
		~allSourceNodes = Dictionary();        //  ~allSourceNodes.postln;
		~allGroupNodes = Dictionary();        //  ~allGroups.postln;
		//		~projectDirectory = nil;

		~debugFlag=false;
		~satieAuxBusCount = satie.aux.size;


		~coreCallback = { arg msg;
			var command;
			command = msg[1];

			switch (command,
				'createSource',  // required args:  name uri    <optional>  group
				{
					if (e.debugFlag, {postf("•satieOSC.coreCallback: command: %, messLen: %   msg: %, \n", command, msg.size, msg);});

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
							e.createSource(sourceName, uriName, groupName);
					});
				},
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
									type = e.getUriType(msg[3].asString);
									if (type == \effect, { position = \addToTail;});
							});

							e.createGroup(groupName, position);
						}
					)
				},
				'createProcess',
				{
					if (e.debugFlag, {postf("•satieOSC.coreCallback: createProcess:  command: %, messLen: %   msg: %, \n", command, msg.size, msg);});


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
							e.createProcess(sourceName, uriName, groupName);
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

							if (e.allGroupNodes.includesKey(nodeName.asSymbol),
								{   e.removeGroup(nodeName);  },
								// else
								{
									e.deleteSource(nodeName);   });
						}
					)
				},
				'debugFlag',
				{
					if ( (msg.size < 3 ) ,
						{"satieOSC.coreCallback:  debugFlag message missing value".warn;},
						// else
						{
							e.debugFlag= msg[2].asInt.asBoolean;
							postf("•satieOSC.debug state = % \n", e.debugFlag);
					});
				},
				'clear',
				{
					e.clearScene();

				};
			);
			//"coreCallback called".postln;
		};

		// accepts arbitrary key value pairs and applies them to the named group node
		~setMessageHandler = { 	| args |
			var type = args[0].asString.split[2].asSymbol;
			var nodeName  = args[1];
			var props = args.copyRange(2, args.size - 1);
			var targetNode;

			if (e.debugFlag, { postf("•satieOSCProtocol.setMessHandler:  mess: %\n", args); });

			// verify data
			if (  (  ( (props.size&1)==1) || (props.size == 0) ),
				{
					error("satieOSCProtocol.setMessHandler: BAD ARGS: "++props);
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
											error("satieOSCProtocol.setMessHandler:  source node: "++nodeName++"  BUG FOUND: undefined SYNTH  \n");
										},   // else good to go
										{
											e.nodeSet( props, targetNode);
									});
								},
								{
									error("satieOSCProtocol.setMessHandler:  source node: "++nodeName++"  is undefined \n");
							}); // else node exists,  process event
						},
						'group',
						{
							if ( e.allGroupNodes.includesKey (nodeName.asSymbol) == true,
								{
									targetNode = e.allGroupNodes[nodeName.asSymbol].at(\group).group;
									e.nodeSet( props, targetNode);
								},
								{   // else no group
									error("satieOSCProtocol.setMessHandler:  group node: "++nodeName++"  is undefined \n");
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
											error("satieOSCProtocol.setMessHandler:  process node: "++nodeName++"  BUG FOUND: undefined process  \n");

										},
										{  // good to go
											e.processSet( props, myProcess, thisGroup);
									});

								},
								{  // else error
									error("satieOSCProtocol.setMessHandler:  process node: "++nodeName++"  is undefined \n");
							});
					});
			});
		};

		// accepts arbitrary key vector messages
		~setVecHandler = { 	| args |
			var type = args[0].asString.split[2].asSymbol;


			if (e.debugFlag, { postf("•satieOSCProtocol.setvecMessHandler:  mess: %\n", args); });

			// verify data
			if (  ( args.size < 3)  ,
				{
					error("satieOSCProtocol.setVecHandler: bad messafe length: expects oscAddress key data1 or more \n"++args);
				}, // else args good
				{
					var nodeName  = args[1];
					var key = args[2];
					var vector = args.copyRange(3, args.size - 1);
					var targetNode = nil;

					switch(type,
						'source',
						{
							if ( e.allSourceNodes.includesKey(nodeName.asSymbol) == true,
								{
									targetNode = e.allSourceNodes[nodeName.asSymbol].at(\synth);
									if ( targetNode == nil,
										{
											error("satieOSCProtocol.setVecHandler:  source node: "++nodeName++"  BUG FOUND: undefined SYNTH  \n");
										}, // else good to go
										{
											targetNode.set(key, vector);
									});
								},
								{
									error("satieOSCProtocol.setVecHandler:  source node: "++nodeName++"  is undefined \n");
							}); // else node exists,  process event
						},
						'group',
						{
							if (  e.allGroupNodes.includesKey (nodeName.asSymbol) == true,
								{
									targetNode = e.allGroupNodes[nodeName.asSymbol].at(\group).group;
									targetNode.set(key, vector);
								},
								{   // else no group
									error("satieOSCProtocol.setVecHandler:  group node: "++nodeName++"  is undefined \n");
							});
						},
						'process',
						{
							if ( e.allSourceNodes.includesKey(nodeName.asSymbol) == true,
								{
									var thisGroupName = e.allSourceNodes[nodeName.asSymbol].at(\groupNameSym);  // process nodes have unique groups
									var thisGroup = e.allGroupNodes[thisGroupName].at(\group).group;
									var myProcess = e.allSourceNodes[nodeName.asSymbol].at(\process);
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
		};

		// accepts arbitrary key value pairs and applies them to the named target node (source or group)
		~nodeSet = { | self, propsVec, targetNode  |

			if ( e.debugFlag, { postf("•satieOSC.nodeSet: % \n", propsVec); });

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
			var keyHandler = nil;
			var setHandler = nil;

			if ( e.debugFlag,
				{
					postf("•satieOSC.processSet: % \n", propsVec);
			});

			propsVec.pairsDo({ | key, val |
				var defaultFlag=true;
				switch(key,
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
				// else just set the key val pair
				if (defaultFlag,
					{
						value = val;
				});

				// Now handle the keyword value pair
				// Check to see if there is a custom handler defined in the process's environment
				if ( process[key.asSymbol].class == Function,   // check  if a handler named key.asSymbol is defined.
					{
						keyHandler = process[key.asSymbol];   // yes, get the function
					},
					{
						// else  nope:  no handler with that name exists.  Check  if a handler named key.asSymbol is defined.
						if ( process[\set].class == Function,
							{ setHandler = process[\set]; });    // yes, use the process's 'set'  handler
				});

				// if the process has no defined handler for the key or for 'set',   set the  key value  pair in the group's synth
				if (  (setHandler == nil) && (keyHandler == nil),
					{
						//postf("~processSet:  setting keyword value pair for node's synth group  %\n", process.nodeGroupName);
						group.set(key.asSymbol, value);
					},
					// else call the custom handler
					{
						//postf("~processSet:  calling process[%]  (or process[\set] )  with  keyword:%   value:% pair for node  %\n", key, key, value, process.nodeName);

						if ( setHandler != nil, { setHandler.value(process, key.asSymbol, value);});    // call 'set' handler with args: key value
						if ( keyHandler != nil, { keyHandler.value(process, value);});  // call  key handler with arg:   value
				});
			});
		};

		// accepts arbitrary key value pair,  and sets value to corresponding process environment key
		~processProperty = { | args  |
			var type = args[0].asString.split[2].asSymbol;
			var nodeName  = args[1];
			var propsVec = args.copyRange(2, args.size - 1);

			if ( e.debugFlag,
				{
					postf("•satieOSC.processProperty: % \n", args);
			});

			// verify data
			if (  (  ( (propsVec.size&1)==1) || (propsVec.size == 0) ),
				{
					error("satieOSCProtocol.processProperty: BAD ARGS: "++propsVec);
				}, // else args good
				{  // verify node
					if ( e.allSourceNodes.includesKey(nodeName.asSymbol) == true,
						{
							var thisGroupName = e.allSourceNodes[nodeName.asSymbol].at(\groupNameSym);  // process nodes have unique groups
							var thisGroup = e.allGroupNodes[thisGroupName].at(\group).group;
							var myProcess = e.allSourceNodes[nodeName.asSymbol].at(\process);

							if ( myProcess == nil,     // verify process
								{
									error("satieOSCProtocol.processProperty:  process node: "++nodeName++"  BUG FOUND: undefined process  \n");

								},
								{  // good to go:  write key val pairs to process environment instance

									var handler= nil;

									// postf("satieOSCProtocol.processProperty:  process node: "++nodeName++" process: % \n", myProcess.class);


									if (myProcess[\property].class == Function,
										{
											handler = myProcess[\property];
									});

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
							error("satieOSCProtocol.setMessHandler:  process node: "++nodeName++"  is undefined \n");
					});
			});
		};


		// osc rx   ARGS:  sourceName azimuthDegrees elevationDegrees gainDB delayMS  lpHZ  distanceMETERS
		~sourceUpdateHandler = { 	| args |
			var nodeName  = args[1];
			var aziDeg, eleDeg, gainDB, delayMs, lpHz, distance;
			var thisSynth;


			if ( e.allSourceNodes.includesKey(nodeName.asSymbol) == false,
				{
					error("satieOSCProtocol.sourceUpdateHandler:  source node: "++nodeName++"  is undefined \n");
				},
				// else all ok
				{
					thisSynth = e.allSourceNodes[nodeName.asSymbol].at(\synth);

					if ( thisSynth == nil, {error("satieOSCProtocol.sourceUpdateHandler:  source node: "++nodeName++"  BUG FOUND: undefined SYNTH  \n");});

					if ( (args.size != 8 ) ,
						{"satieOSCProtocol.sourceUpdateHandler:  message missing values".warn;},
						// else
						{
							// get values from vector, and write to connectionState
							aziDeg = args[2];
							eleDeg= args[3];
							gainDB = args[4];
							delayMs = args[5];
							lpHz = args[6];
							distance = args[7];  // not used by basic spatializers

							if ( satie.nearFieldRadius > 0,    // if the near field has a value greater than zero, handle this case
								{  gainDB = gainDB + e.nfClipGainDBoffset(distance)});


							thisSynth.set(\aziDeg, aziDeg, \eleDeg, eleDeg, \gainDB, gainDB, \delayMs, delayMs, \lpHz, lpHz);
							//postf("sourceUpdateHandler:  update: gain  % \n", gainDB);

							if (e.debugFlag,
								{
									// postf("~sourceUpdateHandler:  nodeName: %  size: % args: %\n", nodeName, args.size, args);
									postf("•satieOSCProtocol.sourceUpdateHandler:  aziDeg %  eleDeg %  gainDB %  delayMs %  lpHz %  distanceMeters % \n", aziDeg, eleDeg, gainDB, delayMs, lpHz, distance);
							});


					});
			});
		};


		// osc rx   ARGS:  sourceName azimuthDegrees elevationDegrees gainDB delayMS  lpHZ  distanceMETERS
		~processUpdateHandler = { 	| args |
			var nodeName  = args[1];
			var aziDeg, eleDeg, gainDB, delayMs, lpHz, hpHz, spread, distance;
			var thisGroupName, thisGroup,  myProcess;

			// postf("~sourceUpdateHandler:  nodeName: %  size: % args: %\n", nodeName, args.size, args);
			if ( e.allSourceNodes.includesKey(nodeName.asSymbol) == false,
				{
					error("satieOSCProtocol.processUpdateHandler:  process node: "++nodeName++"  is undefined \n");
				},
				// else all ok
				{
					// We know this is a sourceProcessingNode since this callback was chosen for this node
					// so by default, we will update the source's group

					thisGroupName = e.allSourceNodes[nodeName.asSymbol].at(\groupNameSym);  // process nodes have unique groups
					thisGroup = e.allGroupNodes[thisGroupName].at(\group).group;
					myProcess = e.allSourceNodes[nodeName.asSymbol].at(\process);
					// thisSynth = e.allSourceNodes[nodeName.asSymbol].at(\synth);

					if ( myProcess == nil, {error("satieOSCProtocol.processUpdateHandler:  process node: "++nodeName++"  BUG FOUND: undefined process  \n");});

					if ( (args.size != 8 ) ,
						{"satieOSCProtocol.processUpdateHandler:  message missing values".warn;},
						// else
						{
							// get values from vector, and write to connectionState
							aziDeg = args[2];
							eleDeg= args[3];
							gainDB = args[4];
							delayMs = args[5];
							lpHz = args[6];
							distance = args[7];  // not used by basic spatializers

						    if ( satie.nearFieldRadius > 0,    // if the near field has a value greater than zero, handle this case
								{  gainDB = gainDB + e.nfClipGainDBoffset(distance)});


							if (myProcess[\setUpdate] == nil,
								{
									//postf("~connectionProcessCallback:  setting update for nodes group %\n", connectionName);
									// distance not used by standard spatializers
									thisGroup.set(\aziDeg, aziDeg, \eleDeg, eleDeg, \gainDB, gainDB, \delayMs, delayMs, \lpHz, lpHz);
								},
								// else use custom handler
								{
									// postf("~connectionProcessCallback:  calling custom update handler for %\n", connectionName);
									// distance used by custom process functions
									myProcess[\setUpdate].value(myProcess, aziDeg, eleDeg, gainDB, delayMs, lpHz, distance);
							});
					});
			});
		};

		// ~blobUpdateHandler    --- experimental.. OSC blob reception appears to be unstable on OSX
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
					error("satieOSCProtocol.blobUpdateHandler;  BUG FOUND: received message: %  not an ARRAY \n", msg);
					~sickMsg=msg;
				},
				{
					if (msg.size != 3,
						{
							"satieOSCProtocol.blobUpdateHandler;  bad message format: expects  address nodeName blobArray".error;
							postf("\t blobUpdateHandler: bad message: %\n", msg);

						},
						// else
						{
							var aziDeg, eleDeg, gainDB, delayMs, lpHz, distanceMeters;
							var oscAddr = msg[0].asString;

							var degScaler = 1.411764705882 ; // 360/255
							var thisSynth = nil;

							var nodeType = oscAddr.split($/)[2];

							//postf("~satieOSC.blobUpdateHandler:  nodeName %,  noteType % \n", nodeName, nodeType);
							if (msg.size == 0,
								{
									~sickMsg=msg;

									postf("~satieOSC.blobUpdateHandler: mess: %    length %\n", msg, msg.size);
									~sickMsg.dump.class
							});


							if (  (msg[1].class != Symbol ) || (msg[2].class != Int8Array ) ||  ( msg[2].size != 12),
								{
									error("satieOSCProtocol.blobUpdateHandler:  message bad data format, expecting array  of  12 bytes :");
									error("\t satieOSCProtocol.blobUpdateHandler:  message % \n", msg);

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
											postf("•satieOSCProtocol.blobUpdateHandler;     aziDeg %  eleDeg %  gainDB %  delayMs %  lpHz %  distanceMeters %        \n", aziDeg, eleDeg, gainDB, delayMs, lpHz, distanceMeters);
									});

									switch(nodeType.asSymbol,
										'source',
										{
											if ( e.allSourceNodes.includesKey(nodeName.asSymbol) == false,
												{
													error("satieOSCProtocol.blobUpdateHandler:  source node: "++nodeName++"  is undefined \n");
												},
												// else all ok
												{
													thisSynth = e.allSourceNodes[nodeName.asSymbol].at(\synth);

													if ( thisSynth == nil,
														{
															error("satieOSCProtocol.blobUpdateHandler:  source node: "++nodeName++"  BUG FOUND: undefined SYNTH  \n");
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
													error("satieOSCProtocol.blobUpdateHandler:  process node: "++nodeName++"  BUG FOUND: undefined process  \n");
												},
												// else all good

												{
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
															myProcess[\update].value(myProcess, aziDeg, eleDeg, gainDB, delayMs, lpHz, distanceMeters);
													});
											});

									});
							});
					});
			});
		};

		// handles /satie/nodetype/state  nodeName flag
		~setStateHandler = { 	| args |
			var type = args[0].asString.split[2].asSymbol;

			if ( e.debugFlag,
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
							if ( e.allSourceNodes.includesKey(nodeName.asSymbol) == true,
								{
									targetNode = e.allSourceNodes[nodeName.asSymbol].at(\synth);
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
							if (  e.allGroupNodes.includesKey (nodeName.asSymbol) == true,
								{
									targetNode = e.allGroupNodes[nodeName.asSymbol].at(\group).group;
									targetNode.run(state);
								},
								{   // else no group
									error("satieOSCProtocol.setStateHandler:  group node: "++nodeName++"  is undefined \n");
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
		};


		~createProcess = {| self, sourceName, uriPath , groupName = \default |
			if (self.allSourceNodes.includesKey(sourceName),
				{
					postf("satieOSC.createSource:   % exists, no action \n", sourceName);
				},
				// else create new node
				{
					var type;
					type = self.getUriType(uriPath);

					if ( type == \process,  {
						self.createProcessNode(sourceName.asSymbol, uriPath,groupName );
					},
					// else
					{
						postf("satieOSC.createProcess: node  %  URI: %,  wrong type,  no action \n", sourceName, type);
					});
				}
			);
		};

		// ~createProcessNode = { "createProcessNode called".warn;};
		// called for uri type process://
		//error check uriName done before call this, uriPath will be a process name
		// ignore groupName since a unique one will be generated for this node and its clones
		//  uri path may include arguments
		// eg. uriPath:  "process://sheefa arg1 1.1 arg2 2.2 arg3"

		~createProcessNode = { | self, sourceName, uriPath , groupNameDummy = \default |
			var temp, type, charIndex, processName, myProcess, cloneGroup, cloneGroupName;
			var processClone = nil;
			var rawArgVec = nil;
			var argList = List[];

			if ( e.debugFlag,  { postf("•satieOSC.createProcessNode:   %   URI  % \n", sourceName, uriPath);});

			processName= uriPath.asString.split($ )[0].split($/)[2];
			rawArgVec = uriPath.asString.split($ );
			rawArgVec.removeAt(0);  // drop first item in list

			// make list of items in argString
			rawArgVec.do( { arg item;
				if ( item != "",
					{
						argList.add(item);
				});
			});


			if (self.allSourceNodes[sourceName.asSymbol]  != nil,
				{
					error("satieOSC.createProcessNode source Process node: %,   ALREAYD EXISTS, aborting \n", sourceName);
				},
				// else ALL GOOD,  instantiate
				{
					processClone = satie.cloneProcess(processName.asSymbol);
					if (processClone == nil,
						{
							error("satieOSC.createProcessNode: undefined process name:"++processName++"   ,  node not created \n");
						},						// else node good to go
						{
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

							postf(">>satieOSC.createProcessNode: creating: %,  with  process:  %   and arglist: % \n", sourceName, processName, argList);

					});
			});
		};


		~createSource = {| self, sourceName, uriPath , groupName = \default |
			//"createSource called".inform;
			if (self.allSourceNodes.includesKey(sourceName),
				{
					postf("satieOSC.createSource:   % exists, no action \n", sourceName);
				},
				// else create new node
				{
					var type;
					type = self.getUriType(uriPath);

					if (  (type == \plugin)  ||  (type== \effect),
						{
							self.createSourceNode(sourceName.asSymbol, uriPath,groupName );
						},
						// else
						{
							postf("satieOSC.createSource: node  %  URI: %,  wrong type,  no action \n", sourceName, type);
					});

				}
			);
		};

		~createSourceNode = { | self, sourceName, uriString , groupName = \default, argsList|
			var synthName;
			var type;
			~uriString = uriString;

			// MAKE SURE URI STRING IS VALID -- if not, will post warning and be set to plugin://dummyPlugin
			uriString = self.checkUri(sourceName, uriString);

			type = self.getUriType(uriString);

			if (groupName == "", { groupName = \default; });   // play it safe: make sure group name is defined


			//
			if ( (type == \effect) &&  (groupName == \default), { groupName = \defaultFx;});


			// check to see if group  exists,  if  not, create it
			if (  e.allGroupNodes[groupName] == nil,
				{
					postf("~satieOSC.createSourceNode:   source:%    group:  % undefined,  creating  group  \n", sourceName, groupName);
					if (type == \effect,
						{
							self.createGroup(groupName.asSymbol, \addToTail);
						},
						{
							self.createGroup(groupName.asSymbol);
					});
			});

			// check to make sure group type is kosher for effects
			if (  self.allGroupNodes[groupName.asSymbol] != nil,
				{
					if (type == \effect,
						{
							if (  self.allGroupNodes[groupName.asSymbol].at(\position) != \tail,
								{
									error("satieOSC.createSourceNode: node "++sourceName++"'s group: "++groupName++" is not an effects group. Setting group to defaultFx group");
									groupName = \defaultFx;
							});
					});
					// else  fix it if its a plugin with an effects group
					if (type == \plugin,
						{
							if (  self.allGroupNodes[groupName.asSymbol].at(\position) == \tail,
								{
									error("satieOSC.createSourceNode: node "++sourceName++"'s group: "++groupName++" is an effects group. Setting group to default group");
									groupName = \default;
							});
					});
			});

			self.allSourceNodes[sourceName.asSymbol] = Dictionary();   // create node  -- create node-specific dict.
			self.allSourceNodes[sourceName.asSymbol].put(\plugin, \nil);
			self.allSourceNodes[sourceName.asSymbol].put(\uriStr, uriString);

			// now set node's group
			self.allSourceNodes[sourceName.asSymbol].put(\groupNameSym, groupName.asSymbol);

			// call  setSynth to complete instance creation
			// note:  setSynth acts on URI

			if ( ( (type != \plugin) &&  (type != \effect) ),
				{
					error("satieOSC.createSourceNode: BUG FOUND IN CODE:   BAD URI  " );
					self.setSynth(sourceName.asSymbol, \dummyPlugin);
				},
				// else  // path format ok, proceed
				{
					synthName = self.getUriName(uriString);
					postln("synthname: "++synthName);

					self.setSynth(sourceName.asSymbol, synthName);
			});

			postf(">>satieOSC.createSourceNode:  creating %:  uri: %  group: %\n", sourceName, uriString, groupName);

		};

		// returns group
		~createGroup = { |self,  groupName, position=\addToHead|

			var groupPos = \head;

			if (position != \addToHead,
				{
					groupPos = \tail;
					position = \addToTail;
			});

			if (self.allGroupNodes.includesKey(groupName),
				{
					postf("satieOSC.createGroup:  GroupNode % exists, no action \n", groupName);
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
							group = satie.makeSatieGroup(groupName.asSymbol, position);
							if ( groupName.asSymbol == \default,
								{
									postf("satieOSC.createGroup:  BUG FOUND-- SHOULD NOT HAVE TO INSTANITATE DEFAULT GROUP !!!!");
							});
					});

					self.allGroupNodes[groupName.asSymbol] = Dictionary();   // create node  -- create node-specific dict.
					self.allGroupNodes[groupName.asSymbol].put(\group , group);  // save group
					self.allGroupNodes[groupName.asSymbol].put(\groupSym , groupName.asSymbol);  // save group name symbol
					//self.allGroupNodes[groupName.asSymbol].put(\members, List() );  // create dict for members
					self.allGroupNodes[groupName.asSymbol].put(\plugin, \nil);
					self.allGroupNodes[groupName.asSymbol].put(\position, groupPos);  //  indicates group DSP chain evaluation order  (head or tail)

					//  set group
					self.allGroupNodes[groupName.asSymbol].put(\group, group );

					//osc.sourceOSC(groupName.asSymbol, e.['groupCallback']);   // NO NEED TO create OSC callback

					postf(">>satieOSC.createGroup:  creating   %   groupType: %\n", groupName, groupPos);

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


			if (e.debugFlag, {postf("•satieOSC.setSynth: node: %   uriStr: %  group: %  type: % \n",  nodeName, uriPath,  groupName,  type);});

			//postf("~setSynth: node: %    NEW: %  CURRENT: % \n", nodeName, pluginName.asSymbol, self.allSourceNodes[nodeName.asSymbol].at(\plugin).asSymbol);


			// NEED A REAL SYNTH DEF CHECK HERE- set the \dummyPlugin if it fails
			if ( validPluginName.asString == "", { validPluginName = \dummyPlugin; });


			if (validPluginName.asSymbol != self.allSourceNodes[nodeName.asSymbol].at(\plugin).asSymbol,
				{
					// replace existing with new plugin
					var synth;

					// check to see if a synth has already been allocacted, if so, kill it
					if  ( self.allSourceNodes[nodeName.asSymbol].at(\synth) != nil,
						{
							'satieOSC.setSynth: REPLACE EXISTING SYNTH'.postln;
							satie.cleanInstance(nodeName.asSymbol,groupName.asSymbol );
					});

					sourceNode.put(\plugin, validPluginName.asSymbol);


					if ( ( type == \effect) ,
						{
							inBus = self.getFxInBus(uriPath);
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
		};

		~deleteSource = { | self, nodeName |
			if ( self.allSourceNodes.includesKey(nodeName.asSymbol) ,
				{
					self.clearSourceNode(nodeName.asSymbol);
					self.allSourceNodes.removeAt(nodeName.asSymbol);     // remove node from global dictionary
			});
		};

		~removeGroup = { | self, groupName |
			if ( self.allGroupNodes.includesKey(groupName.asSymbol) ,
				{
					//  No OP  ~clearGroupNode.value(groupName.asSymbol);
					if (self.debugFlag, {postf("•satieOSC.removeGroup:  group node: % \n",  groupName);});
					self.allGroupNodes.removeAt(groupName.asSymbol);     // remove node from global dictionary
			});
		};

		~clearSourceNode = {  | self, nameSym |
			var node = self.allSourceNodes[nameSym];
			//var connectionName = node.at(\connectionName);
			var nodeKeys = node.keys;
			var thisGroupName = self.allSourceNodes[nameSym].at(\groupNameSym);

			// is this a process node?
			if ( self.allSourceNodes[nameSym].at(\process) != nil,
				{
					var groupSym =  self.allSourceNodes[nameSym].at(\groupNameSym);

					var myProcess = self.allSourceNodes[nameSym].at(\process);

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
					//synth.free;    // to make sure it gets cleaned from the node tree
					if (self.debugFlag, {postf("•satieOSC.clearSourceNode: delete  node  % in group %\n", nameSym, thisGroupName);});

			});

			//  clear node's local dictionary
			// probably this is unnecessary
			nodeKeys.do { | key |
				//postf("removing node keys:  node: %   key %  \n",  nameSym, key);
				node.removeAt(key);
			};
		};


		// Utility functions    ****************************************

		~getUriName = { |  self, uriPath |
			/*			var stringArray = uriPath.asString.split($ );
			var charIndex = uriPath.asString.find("://");
			var temp = uriPath.asString.subStr(charIndex);
			var uriName = temp.asString.replace("://", "");*/
			var uriName, uriSynth;
			~uriPAth = uriPath;
			uriName = uriPath.asString.split($ );
			uriSynth = uriName[0].asString.split($/)[2];

			uriSynth.asString;
			// uriName.asString.split($ )[0].asString;
		};

		~getUriType = { | self, uriPath |
			var charIndex, uriName, type, temp;

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

					// temp = uriPath.asString.subStr(charIndex);
					type = uriPath.asString.split($:)[0];
					//type.postln;
					~type = type;
					// uriName = temp.asString.replace("://", "");
			});
			type.asSymbol;
		};

		~getUriArgs = { |self, uriPath  |
			var temp,charIndex, processName;
			var argsString = "";
			var stringArray;
			var rawArgVec = nil;
			var argList = List[];
			var argsArray;

			//("~getUriArgs:  URI: "++uriPath).postln;

			// sheefa = uriPath;

			stringArray = uriPath.asString.split($ );

			if (stringArray.size < 2,
				{
					[];
				},
				{
					// charIndex = stringArray[0].asString.find("://");
					// processName = stringArray[0].asString.subStr(charIndex+3);

					// argsString = uriPath.asString.subStr(stringArray[0].size+1);
					// argsString = uriPath.asString.subStr(stringArray[0].size+1);
					argsArray = uriPath.asString.split($ );

					//argsString.postln;

					argsArray.removeAt(0);
					// make list of items in argString
					argsArray.do( { arg item;
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
			argList.postln;

			// if there are two args, and the first arg is the keyword "inBus"then try to set the effect's \in param to the second arg
			if (argList.size > 1,
				{
					if (argList[0].asString == "inBus",
						{
							auxBus = argList[1].asInt.clip(0, self.satieAuxBusCount-1);
					});
			});
			auxBus;  // returns auxBus for effects node
		};

		// if URI is ok, returns uriString, else   "plugin://dummyPlugin"
		~checkUri = { | self, nodeName, uriString |
			var type = self.getUriType(uriString);

			//uriString.postln;
			if ( (type != \plugin) && (type != \effect),
				{
					error("~checkUri:  node: %  bad URI: % , using default: plugin://dummyPlugin \n", nodeName, uriString);

					"plugin://dummyPlugin"
				},
				{
					uriString;
			});
		};

		// debugging
		~debug_dumpNodes = { 	| self |
			//var connections = 0;
			self.allSourceNodes.keysDo { |key |
				var nodeSym = key;
				postf("node: %  \n", key);
				self.allSourceNodes[nodeSym].keysDo { | key |
					postf("\t : %  =  % \n",  key, self.allSourceNodes[nodeSym].at(key));
				};
			};
		};

		~sined2unsignedByte= { | self, val |
			var outVal = val;
			if (val < 0, { outVal = 256 + val});
			outVal;
		};


		// returns the corresponding db attenuation offset
		~nfClipGainDBoffset= { | self, distance |
			var dbOffset;
			var nfScaler = distance.clip(0.01, satie.nearFieldRadius) / satie.nearFieldRadius;
			var exp = satie.nearFieldExp;


			if (satie.nearFieldInvert == false,
				{
					nfScaler = 1 - nfScaler;
			});

			nfScaler = nfScaler**exp;
			dbOffset = nfScaler.ampdb;
			if (e.debugFlag, {postf("•satieOSC.nfClipGainDBoffset: distance: %  nearFieldRadius: %    nearFieldExp: %     nearFieldInvert  %   DB attenuation offset: % \n",  distance, satie.nearFieldRadius, satie.nearFieldExp, satie.nearFieldInvert, dbOffset)});
			dbOffset;
		};




	});   // Environment.make


	"satieOSCprotol loaded".inform;
	e.know = true;

	e.createGroup(\default);   // creates satieOSC group entry, instantiates group in satie if not already defined
	e.createGroup(\defaultFx, \addToTail); // creates satieOSC group entry, instantiates group in satie if not already defined



	//  OSC HANDELERS  TO BE RELOCATED TO SATIEOSCMAKER

	// scene
	osc.deleteOSC(\satieScene);  // disconnect any previous handlers
	osc.newOSC(\satieScene, e['coreCallback'], "/satie/scene");   // connect handler


	// all nodes
	osc.deleteOSC(\satieSrcSet);  // disconnect any previous handlers
	osc.newOSC(\satieSrcSet, e['setMessageHandler'], "/satie/source/set");   // connect handler

	osc.deleteOSC(\satieGroupSet);  // disconnect any previous handlers
	osc.newOSC(\satieGroupSet, e['setMessageHandler'], "/satie/group/set");   // connect handler

	osc.deleteOSC(\satieProcSet);  // disconnect any previous handlers
	osc.newOSC(\satieProcSet, e['setMessageHandler'], "/satie/process/set");   // connect handler


	osc.deleteOSC(\satieSrcSetVec);  // disconnect any previous handlers
	osc.newOSC(\satieSrcSetVec, e['setVecHandler'], "/satie/source/setvec");   // connect handler

	osc.deleteOSC(\satieGroupSetVec);  // disconnect any previous handlers
	osc.newOSC(\satieGroupSetVec, e['setVecHandler'], "/satie/group/setvec");   // connect handler

	osc.deleteOSC(\satieProcSetVec);  // disconnect any previous handlers
	osc.newOSC(\satieProcSetVec, e['setVecHandler'], "/satie/process/setvec");   // connect handler

	osc.deleteOSC(\satieSrcState);  // disconnect any previous handlers
	osc.newOSC(\satieSrcState, e['setStateHandler'], "/satie/source/state");   // connect handler

	osc.deleteOSC(\satieGroupState);  // disconnect any previous handlers
	osc.newOSC(\satieGroupState, e['setStateHandler'], "/satie/group/state");   // connect handler

	osc.deleteOSC(\satieProcessState);  // disconnect any previous handlers
	osc.newOSC(\satieProcessState, e['setStateHandler'], "/satie/process/state");   // connect handler

	// sources and processes
	osc.deleteOSC(\satieSrcUpdate);  // disconnect any previous handlers
	osc.newOSC(\satieSrcUpdate, e['sourceUpdateHandler'], "/satie/source/update");   // connect handler

	osc.deleteOSC(\satieProcessUpdate);  // disconnect any previous handlers
	osc.newOSC(\satieProcessUpdate, e['processUpdateHandler'], "/satie/process/update");   // connect handler

	osc.deleteOSC(\updateBlobHandlerSrc);  // disconnect any previous handlers
	osc.newOSC(\updateBlobHandlerSrc, e['blobUpdateHandler'],  "/satie/source/ublob");   // connect handler

	osc.deleteOSC(\updateBlobHandlerProcess);  // disconnect any previous handlers
	osc.newOSC(\updateBlobHandlerProcess, e['blobUpdateHandler'],  "/satie/process/ublob");   // connect handler



	// processes
	osc.deleteOSC(\satieProcessProperty);  // disconnect any previous handlers
	osc.newOSC(\satieProcessProperty, e['processProperty'], "/satie/process/property");   // connect handler





	// DEPRECIATED
	/*
	// sources
	osc.deleteOSC(\satieSrcProp);  // disconnect any previous handlers
	osc.newOSC(\satieSrcProp, e['sourceNodeCallback'], "/satie/source/prop");   // connect handler


	osc.deleteOSC(\satieSrcEvent);  // disconnect any previous handlers
	osc.newOSC(\satieSrcEvent, e['sourceNodeCallback'], "/satie/source/event");   // connect handler

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

	osc.deleteOSC(\satieProcessEvent);  // disconnect any previous handlers
	osc.newOSC(\satieProcessEvent, e['processCallback'], "/satie/process/event");   // connect handler

	osc.deleteOSC(\satieProcessSpread);  // disconnect any previous handlers
	osc.newOSC(\satieProcessSpread, e['processSpreadHandler'], "/satie/process/spread");   // connect handler

	osc.deleteOSC(\satieProcessHpHz);  // disconnect any previous handlers
	osc.newOSC(\satieProcessHpHz, e['processHpHzHandler'], "/satie/process/hpHz");   // connect handler

	*/

	e;
	};



	/*
	for debugguing

	~satieOSC = ~satieOSCProtocol.value(~osc, ~satie);
	~satieOSC.debugFlag = true;
	~satieOSC.debugFlag = false;
	*/

)