




// this file defines  a process class, which is ONLY used by source nodes that have that have a URI of type:   "process" , e.g:      uri://process  "sheefa"
	// you can define any number of these process clases, each one, corresponding to a particular type of processing  behavoir you define



// required:  set up class struct

	~sheefa = Environment[
		// required fields
		'nodeName' -> \nil,
		'nodeGroupName' -> \nil,
		'nodeGroup' -> \nil,

		// connection state
		'aziDeg' -> -10,
		'elevDeg' -> 10,
		'gainDB' -> -99,
		'delayMs' -> 0,
		'lpHz' -> 0.5,
		'hpHz' -> 22040,
		// project specific
		'synth' -> \zkarpluck1P,  // \zparticle1P,
		'randAzi' -> 20,
		'randElev' -> 30,
		'randDist' -> 1,
		'cloneCount' -> 20,
		'cloudRadius' -> 5, // 2D particle field radius: 5 meters
		'triggerIntervalMs' -> 500,   // time interval, during which the clones will randomly trigger
		// other state
		'pitchSeqSym' -> \default,
		'pitchSeqLen' -> 1,   // not used
		'pitchSeqIncr' -> 1,   // used, but only to set global sequencer state
		'pitchSeqPos' -> 0,     // not used

	];


	// define any custom "class"  variables, referenced by all "instants"  of "sheefa" class
if (~sheefa_pitchSequences == nil,
		{
			~sheefa_pitchSequences = Dictionary.new();
			~sheefa_pitchSequences.put(\default, Dictionary.new());
			~sheefa_pitchSequences.at(\default).put(\pitches, [60]);
			~sheefa_pitchSequences.at(\default).put(\pos, 0);
			~sheefa_pitchSequences.at(\default).put(\incr,1);
			~sheefa_pitchSequences.at(\default).put(\size,1);

	});





	// required functions and state

	~sheefa.know=true;
	~sheefa.property =  {| self, property, value |
		self.put(property.asSymbol, value);
	};

	// register process to environment
	if (~allProcesses == nil, {
		~allProcesses = ();         // environment namespace for project functions
	});

	// if already registered, re-register
	if (  ~allProcesses.includesKey(\sheefa) == true,
		{
			'un-registering process: sheefa'.postln;
			~allProcesses.removeAt(\sheefa);
	});

	'registering process: sheefa'.postln;
	~allProcesses.put(\sheefa, ~sheefa);


	// required


	~sheefa.cleanup = { | self |

		// add code here to manage project-specific stuff
		postf("~sheefa.clearSynths: clearing synths in node: % group \n", self.nodeName);

		self.cloneCount.do( { arg item;
			var nodename=(self.nodeName++"_"++item).asSymbol;
			~scbr.cleanInstance(nodename.asSymbol, self.nodeGroupName);
		});
	};


	// required but project specific
	// generates N synths
	~sheefa.setup = { | self, nodeName, nodeGroupName, nodeGroup |
		var thisGroup ;

		self.nodeName = nodeName;
		self.nodeGroupName = nodeGroupName;
		self.nodeGroup = nodeGroup;



		postf("~sheefa.setup:  generating % synthVoices for group %\n",  self.cloneCount, self.nodeGroupName);

		// now generate   self.cloneCount  synths in advance
		//  when the state problem is fixed, this can be done in the context of trigger, and synths can destroy  themselves after sounding
		self.cloneCount.do( { arg item;
			var nodename=(self.nodeName++"_"++item).asSymbol;
			var synth;

			synth = ~scbr.makeInstance(nodename.asSymbol, self.synth.asSymbol, self.nodeGroupName);
			synth.set(\gainDB, -99);  // instantiate full attenuated
		});
	};


	// end of required class functions

	// the functions below are not requied
	// however if defined, they will be called by satie4unity when node's "update" message is received
	// otherwise satie4unity will send the  "update" message to the node's group
	~sheefa.updateConnection = { | self, aziDeg, eleDeg, gainDB, delayMs, lpHz |

		var 	thisGroup = self.nodeGroup; // ~allSourceNodes[self.nodeName.asSymbol].at(\proxy);

		// saving the connection state in case its needed
		self.aziDeg = aziDeg;
		self.elevDeg = eleDeg;
		self.gainDB = gainDB;
		self.delayMs = delayMs;
		self.lpHz = lpHz;
		self.hpHz = 0.5;  // to be added

		//postf("sheefa.updateConnection: called for node: %    azi: %  \n", self.nodeName, aziDeg);

		// updating the connection of all this node's clones (via group message)
		thisGroup.set(\aziDeg, self.aziDeg, \eleDeg, self.elevDeg, \gainDB, self.gainDB , \delayMs, self.delayMs, \lpHz, self.lpHz, \hpHz, self.hpHz);
	};


	// if defined, will be called when node's "spread" message is received
	// otherwise the "spread" message will be applided to the node's group
	~sheefa.spread = { | self, spreadVal |

		var 	thisGroup = self.nodeGroup;
		// updating the spread param of all this node's clones (via group message)

		thisGroup.set(\spread, spreadVal);
	};


	// totally custom functions.  Calls to these functions result from OSC events received by satie4unity from Unity, and then applied to these functions,  if they exist

	// custom method
	~sheefa.trigger = { arg self, items = #[1,2,3] ;
		var thisGroup = self.nodeGroup;
		var gain = self.gainDB;
		var seqName, pitch, position, incr, size, vel, incidence;

			if ( items.size != 3,
			{
				postf("~sheefa.trigger:  bad item count, expecing '[ pitch vel incidence]' , received: % items\n",items.size);
			},
			{ // else

				seqName = self.pitchSeqSym;
				vel =  items[1].asFloat;

				// find out why incidence fucks the dog
				incidence = 1; items[2].asFloat;

				// incidence.postln;

				// update all nodes in group

				// thisGroup.set(\gainDB, gain);  not necessary, since this is handled in the update connection

				thisGroup.set(\randTrigMaxMs, self.triggerIntervalMs);

					// assign pitches  for each particle
				self.cloneCount.do( { arg item;
					var nodename=(self.nodeName++"_"++item).asSymbol;

					// this is where we could calculate the exact position of each clone, with respect to this node
					// but its expensive

					/* instance specific look up not used
					pitch = ~sheefa_pitchSequences[self.pitchSeqSym][self.pitchSeqPos];
					self.pitchSeqPos = (self.pitchSeqPos + self.pitchSeqIncr) % self.pitchSeqLen;
					*/
					position = ~sheefa_pitchSequences.at(seqName.asSymbol).at(\pos);
					incr = ~sheefa_pitchSequences.at(seqName.asSymbol).at(\incr);
					size = ~sheefa_pitchSequences.at(seqName.asSymbol).at(\size);

					pitch = ~sheefa_pitchSequences.at(seqName.asSymbol).at(\pitches)[position];
					~sheefa_pitchSequences.at(seqName.asSymbol).put(\pos,  ((position + incr) % size) );

					~scbr.satieGroupInstances[ self.nodeGroupName.asSymbol ][ nodename.asSymbol ].set(\note, [ pitch, vel, incidence ] );

					~scbr.satieGroupInstances[ self.nodeGroupName.asSymbol ][ nodename.asSymbol ].set(\t_trig, 1);
				});

				// calculate azimuths for each particle


				// finally  update and trigger all cloned synths (particles)
/*				thisGroup.set(\gainDB, gain);

				thisGroup.set(\randTrigMaxMs, self.triggerIntervalMs);*/

				//thisGroup.set(\t_trig, 1);
				//postf("~sheefa.trigger: triggering synths in node: % group \n",self.nodeName);

				//~sheefa_pitchSequences.at(seqName.asSymbol).at(\pos).postln;

		});
	};

	// custom method
	~sheefa.readPitches = { arg self, items = #["/tmp"] ;

		var pitchList, seqName, file, csvmidifilePath;

		//postf("readPitches:   arg 0: % \n",  items[0] );

		if ( items.size != 1,
			{
				warn("~sheefa.readPitches:  bad item count, expecting one filePath arg, received: % items\n",items.size);
			},
			//else
			{
				csvmidifilePath = items[0].asString;

				if (csvmidifilePath[0] != $/,
					{
						csvmidifilePath = ~projectDirectory++"/"++csvmidifilePath;
				});

				csvmidifilePath.postln;

				pitchList = List.new();
				seqName = csvmidifilePath.split.last;
				file = File(csvmidifilePath.standardizePath,"rb");

				// process only if pitch sequence has not yet been loaded
				if ( ~sheefa_pitchSequences.includesKey(seqName.asSymbol),
					{

						//  file already loaded, just set instance  specific state
						postf("sheefa.readPitches:  sequence % already loaded, skipping file load\n", seqName);
						self.pitchSeqSym = seqName.asSymbol;
						self.pitchSeqLen = ~sheefa_pitchSequences.at(seqName.asSymbol).at(\size);
						self.pitchSeqPos = 0;

						// and reset sequence's global state
						~sheefa_pitchSequences.at(seqName.asSymbol).put(\pos, 0);
						~sheefa_pitchSequences.at(seqName.asSymbol).put(\incr, self.pitchSeqIncr);   // using instance specific state.. may overwrite


					},
					// else  read file and create pitch sequence
					{
						//postf("file % length:  %\n", csvmidifilePath, file.length);

						file.do({
							var value, event;

							value = file.getLine();

							if (value.contains("Note_on_c"),
								{
									event = value.split($,);
									pitchList.add(event[4].asInt);
							});
						});

						file.close;

						if (pitchList.size > 0,
							{
								postf("% pitches read from file %\n", pitchList.size,  csvmidifilePath);
								// add sequence to dictionary

								~sheefa_pitchSequences.removeAt(seqName.asSymbol);   // overwrite previous

								~sheefa_pitchSequences.put(seqName.asSymbol, Dictionary.new());
								~sheefa_pitchSequences.at(seqName.asSymbol).put(\pitches, pitchList);
								~sheefa_pitchSequences.at(seqName.asSymbol).put(\size, pitchList.size);
								~sheefa_pitchSequences.at(seqName.asSymbol).put(\pos, 0);
								~sheefa_pitchSequences.at(seqName.asSymbol).put(\incr, 1);


								//~sheefa_pitchSequences.removeAt(seqName.asSymbol);
								//~sheefa_pitchSequences.put(seqName.asSymbol, pitchList);
								//~sheefa_pitchSequences.put(seqName.asSymbol,

								// set instance local state -- currently not used, but available for future deployment
								self.pitchSeqSym = seqName.asSymbol;
								self.pitchSeqLen = pitchList.size;
								self.pitchSeqPos = 0;
							},
							//else
							{
								warn("no pitches found in file: "++csvmidifilePath);
						});
				});
		});
	};

/*
testing

~myFile =  "/Users/zack/Dropbox/Unity3D/projects_unity5/balljamDemoSATIE_2015_unity5/Assets/StreamingAssets/midi/pitchSequences/bjGroove.mid.mid.txt";
~sheefa.readPitches(~myFile);
~sheefa.pitchSeqLen;
~sheefa.pitchSeqName;

*/
