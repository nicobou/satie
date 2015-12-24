


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
	~scbr.makeSynthDef(\busreverb, \freeverb, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\busgverb, \gverb, [~listeningFormat], [0]);

	// initialize the OSC interpreter here
	~oscInterface = ~cOSCMaker.value();

	s.sync;






	// set up a process class

	~sheefa = Environment[
		'nodeName' -> \nil, // required field
		'nodeGroupName' -> \nil, // required field
		'nodeGroupProxy' -> \nil, // required field
		'synth' -> \zparticle1,
		'randAzi' -> 20,
		'randElev' -> 30,
		'randDist' -> 1,
		'cloneCount' -> 20,
		'cloudRadius' -> 5, // 2D particle field radius: 5 meters
		'triggerIntervalMs' -> 500,   // time interval, during which the clones will randomly trigger
		// connection state
		'aziDeg' -> -10,
		'elevDeg' -> 10,
		'gainDB' -> -99,
		'delayMs' -> 0,
		'lpHz' -> 0.5,
		'hpHz' -> 22040,
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

	// custom method
	~sheefa.trigger = { arg self, items = #[1,2,3] ;
		var thisProxy = self.nodeGroupProxy.group;
		var gain = self.gainDB;

		if ( items.size != 3,
			{
				postf("~sheefa.trigger:  bad item count, expecing 3, received: % items\n",items.size);
			},
			{ // else

				// calculate gains for each particle
				self.cloneCount.do( { arg item;
					var nodename=(self.nodeName++"_"++item).asSymbol;
					// this is where we could calculate the exact position of the clone, with respect to this node
					// but its expensive
					//~scbr.satieGroups[ self.nodeGroupName.asSymbol ].[ nodename.asSymbol ].set(\gainDB, gain);

				});
				// calculate azimuths for each particle


				// finally  update and trigger all cloned synths (particles)
				thisProxy.set(\gainDB, gain);
				//thisProxy.set(\durMs, self.triggerIntervalMs);
				thisProxy.set(\randTrigMaxMs, self.triggerIntervalMs);
				thisProxy.set(\t_trig, 1);
				//postf("~sheefa.trigger: triggering synths in node: % group \n",self.nodeName);
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






};


