


s.waitForBoot{

	// finding source directory
	~rootSrcPath = thisProcess.nowExecutingPath.dirname ++ "/../..";
	(~rootSrcPath ++ "/src/*.scd").pathMatch.do({arg item; item.loadPaths});

	~num_aux_bus = 5;
	~fxInputBus = 0;  // relative aux bus number that satie will use for this project's synthdef sends to fx synthdefs

	// creating a sc-basic-renderer
	if (~scbr == nil,{
		~scbr = ~scbrMaker.value(numAudioAux: ~num_aux_bus);});
	// printing internal aux array with bus indexes
	~scbr.aux;
	// loading source plugins
	~scbr.pluginLoader.loadAudioPlugins(~rootSrcPath ++ "/audiosources/*.scd");
	// see the loaded plugins in the console
	~scbr.pluginLoader.audioPlugins;
	// loading spatializer plugins
	~scbr.pluginLoader.loadSpatPlugins(~rootSrcPath ++ "/spatializers/*.scd");
	~scbr.pluginLoader.spatPlugins;

	~scbr.pluginLoader.loadEffectPlugins(~rootSrcPath ++ "/effects/*.scd");
	~scbr.pluginLoader.effectPlugins;


	postf("generating example project synthdefs for % format \n", ~listeningFormat);
	~scbr.makeSynthDef(\zparticle1, \zparticle1, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\pink, \PinkSin, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\dust, \DustDust, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\default, \default, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\zkarpluck0, \zkarpluck0, [~listeningFormat], [0]);
	//~scbr.makeSynthDef(\zkarpluck1, \zkarpluck1, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\test, \testtone,  [~listeningFormat], [0]);
	//~scbr.makeSynthDef(\zbell1, \zbell1, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\pbell1, \pbell1, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\zkarpluck1, \zkarpluck1, [~listeningFormat], [0], [~scbr.aux[~fxInputBus]]);
	~scbr.makeSynthDef(\zkarpluck1P, \zkarpluck1P, [~listeningFormat], [0], [~scbr.aux[~fxInputBus]]);
	~scbr.makeSynthDef(\busreverb, \freeverb, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\busgverb, \gverb, [~listeningFormat], [0]);

	// initialize the OSC interpreter here
	~oscInterface = ~cOSCMaker.value();

	s.sync;


	// set up class

	// "class"  variables, referenced by all "instants"  of "sheefa" class

	// custom

	if (~sheefa_pitchSequences == nil,
		{
			~sheefa_pitchSequences = Dictionary.new();
			~sheefa_pitchSequences.put(\default, Dictionary.new());
			~sheefa_pitchSequences.at(\default).put(\pitches, [60]);
			~sheefa_pitchSequences.at(\default).put(\pos, 0);
			~sheefa_pitchSequences.at(\default).put(\incr,1);
			~sheefa_pitchSequences.at(\default).put(\size,1);

	});


	~sheefa = Environment[
		'nodeName' -> \nil, // required field
		'nodeGroupName' -> \nil, // required field
		'nodeGroupProxy' -> \nil, // required field
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





	// generic stuff
	~sheefa.know=true;
	~sheefa.property =  {| self, property, value |
		self.put(property.asSymbol, value);
	};




	// required
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


	// required but project specific
	// generates N synths
	~sheefa.setup = { | self, nodeName, nodeGroupName, nodeGroupProxy |
		var thisProxy ;

		self.nodeName = nodeName;
		self.nodeGroupName = nodeGroupName;
		self.nodeGroupProxy = nodeGroupProxy;

		thisProxy = self.nodeGroupProxy.group;


		postf("~sheefa.setup:  generating % synthVoices for group %\n",  self.cloneCount, self.nodeGroupName);

		// now generate   self.cloneCount  synths in advance
		//  when the state problem is fixed, this can be done in the context of trigger, and synths can destroy  themselves after sounding
		self.cloneCount.do( { arg item;
			var nodename=(self.nodeName++"_"++item).asSymbol;
			var synth;

			synth = ~scbr.makeInstance(nodename.asSymbol, self.synth.asSymbol, self.nodeGroupName);
			// synth.set(\gainDB, self.gainDB);
			// no state setting is possible at this stage
		});
	};


	// the functions below are not requied


	// if defined, will be called when node's "update" message is received
	// otherwise the "update" message will be applided to the node's group
	~sheefa.updateConnection = { | self, aziDeg, eleDeg, gainDB, delayMs, lpHz |

		var 	thisProxy = ~allSourceNodes[self.nodeName.asSymbol].at(\proxy);

		//'~sheefa.updateConnection'.postln;
		self.aziDeg = aziDeg;
		self.elevDeg = eleDeg;
		self.gainDB = gainDB;
		self.delayMs = delayMs;
		self.lpHz = lpHz;
		self.hpHz = 0.5;  // to be added

		//postf("sheefa.updateConnection: called for node: % \n", self.nodeName);

		thisProxy.set(\aziDeg, self.aziDeg, \eleDeg, self.elevDeg, \gainDB, self.gainDB , \delayMs, self.delayMs, \lpHz, self.lpHz, \hpHz, self.hpHz);


	};


	// if defined, will be called when node's "spread" message is received
	// otherwise the "spread" message will be applided to the node's group
	~sheefa.spread = { | self, spreadVal |

		'~sheefa.spread'.postln;

	};

	~sheefa.setIncrement = { arg self, items = #[1] ;

		if ( items.size != 1,
			{
				warn("~sheefa.setIncrement:  bad item count,  takes one float arg, received: % items\n",items.size);
			},
			//else
			{
				~sheefa_pitchSequences.at(self.pitchSeqSym).put(\incr, items[0].asFloat);
				//postf("sheefa.setIncrement:  increment = % \n", ~sheefa_pitchSequences.at(self.pitchSeqSym).at);
		});
	};


	// custom method
	~sheefa.trigger = { arg self, items = #[1,2,3] ;
		var thisProxy = self.nodeGroupProxy.group;
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

				thisProxy.set(\gainDB, gain);
				thisProxy.set(\randTrigMaxMs, self.triggerIntervalMs);

					// assign pitches  for each particle
				self.cloneCount.do( { arg item;
					var nodename=(self.nodeName++"_"++item).asSymbol;
					// this is where we could calculate the exact position of the clone, with respect to this node
					// but its expensive
					//~scbr.satieGroups[ self.nodeGroupName.asSymbol ].[ nodename.asSymbol ].set(\gainDB, gain);


					/* instance specific look up not used
					pitch = ~sheefa_pitchSequences[self.pitchSeqSym][self.pitchSeqPos];
					self.pitchSeqPos = (self.pitchSeqPos + self.pitchSeqIncr) % self.pitchSeqLen;
					*/
					position = ~sheefa_pitchSequences.at(seqName.asSymbol).at(\pos);
					incr = ~sheefa_pitchSequences.at(seqName.asSymbol).at(\incr);
					size = ~sheefa_pitchSequences.at(seqName.asSymbol).at(\size);

					pitch = ~sheefa_pitchSequences.at(seqName.asSymbol).at(\pitches)[position];
					~sheefa_pitchSequences.at(seqName.asSymbol).put(\pos,  ((position + incr) % size) );

					//[ self.nodeGroupName.asSymbol, nodename.asSymbol ] .postln;

					~scbr.satieGroups[ self.nodeGroupName.asSymbol ].[ nodename.asSymbol ].set(\note, [ pitch, vel, incidence ] );
					~scbr.satieGroups[ self.nodeGroupName.asSymbol ].[ nodename.asSymbol ].set(\t_trig, 1);


					//~scbr.satieGroups[ self.nodeGroupName.asSymbol ].[ nodename.asSymbol ].set(\gainDB, gain);
					//~scbr.satieGroups[ self.nodeGroupName.asSymbol ].[ nodename.asSymbol ].set(\randTrigMaxMs, self.triggerIntervalMs);
					//~scbr.satieGroups[ self.nodeGroupName.asSymbol ].[ nodename.asSymbol ].set(\t_trig, 1);



				});
				// calculate azimuths for each particle


				// finally  update and trigger all cloned synths (particles)
/*				thisProxy.set(\gainDB, gain);

				thisProxy.set(\randTrigMaxMs, self.triggerIntervalMs);*/

				//thisProxy.set(\t_trig, 1);
				//postf("~sheefa.trigger: triggering synths in node: % group \n",self.nodeName);

				//~sheefa_pitchSequences.at(seqName.asSymbol).at(\pos).postln;

		});
	};




	// custom method
	~sheefa.clearSynths = { | self |
		//var thisProxy = ~allSourceNodes[self.nodeName.asSymbol].at(\proxy);

		postf("~sheefa.clearSynths: clearing synths in node: % group \n", self.nodeName);

		self.cloneCount.do( { arg item;
			var nodename=(self.nodeName++"_"++item).asSymbol;
			~scbr.cleanInstance(nodename.asSymbol, self.nodeGroupName);
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


};  // end of  waitforboot

/*
testing

~myFile =  "/Users/zack/Dropbox/Unity3D/projects_unity5/balljamDemoSATIE_2015_unity5/Assets/StreamingAssets/midi/pitchSequences/bjGroove.mid.mid.txt";
~sheefa.readPitches(~myFile);
~sheefa.pitchSeqLen;
~sheefa.pitchSeqName;

*/
