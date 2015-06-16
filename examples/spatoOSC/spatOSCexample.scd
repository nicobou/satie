


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


	s.sync;

}


//~nodeSpwan = { | nodename, 