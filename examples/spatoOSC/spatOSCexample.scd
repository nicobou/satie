


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
	~scbr.makeSynthDef(\pink, \PinkSin, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\dust, \DustDust, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\default, \default, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\zkarpluck0, \zkarpluck0, [~listeningFormat], [0]);
	//~scbr.makeSynthDef(\zkarpluck1, \zkarpluck1, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\test, \testtone,  [~listeningFormat], [0]);
	~scbr.makeSynthDef(\zbell1, \zbell1, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\zkarpluck1, \zkarpluck1, [~listeningFormat], [0], [~scbr.aux[~fxInputBus]]);
	~scbr.makeSynthDef(\busreverb, \freeverb, [~listeningFormat], [0]);

	// initialize the OSC interpreter here
	~oscInterface = ~cOSCMaker.value();

	s.sync;







	// set up a process class

	~sheefa = Environment[
		'randAzi' -> 20,
		'randElev' ->
		'randDist' -> 1,
		'cloneCount' -> 20,
	];


	// generic stuff
	~sheefa.know=true;

	~sheefa.property =  {| self, property, value |
		self.put(property.asSymbol, value);
	};


	~registerProcess.value(\sheefa, ~sheefa);


	// project specific stuff
	~sheefa.setup = { | self, args |

		var cloneCount = args[0];
		var randAzi = args[1];
		var randElev = args[2];
		var randDist = args[3];

		if (args.size != 4,
			{ '~sheefa.setup: bad arg count'.postln;});

		'~sheefa.setup'.postln;
		self.cloneCount = cloneCount;
		self.randAzi = randAzi;
		self.randElev = randElev;
		self.randDist = randDist;
	};



	~sheefa.trigger = { |self, groupName |

		postf("~sheefa.trigger: update group: % \n", groupName);
	};





};


