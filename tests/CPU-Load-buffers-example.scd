(
Server.supernova;
o = Server.local.options;
o.numOutputBusChannels = 8;
o.memSize = 2**20;
o.blockSize = 2048;
s.reboot;
s.makeGui;
s.meter;
s.waitForBoot{
	// finding source directory
	~rootSrcPath = thisProcess.nowExecutingPath.dirname ++ "/..";
	(~rootSrcPath ++ "/src/*.scd").pathMatch.do({arg item; item.loadPaths});

	~num_aux_bus = 5;
	// creating a sc-basic-renderer
	~scbr = ~scbrMaker.value(numAudioAux: ~num_aux_bus, satieSrcPath: ~rootSrcPath);
	// printing internal aux array with bus indexes
	~scbr.aux;
    // ~scbr.auxbus.scope;
	// list plugins
	~scbr.pluginLoader.audioPlugins;
	~scbr.pluginLoader.spatPlugins;
	~scbr.pluginLoader.effectPlugins;
	~scbr.pluginLoader.mapperPlugins;
	// streaming a soundfile from disk
	~playBuffers = (
		// the first one will work only on linux
		\alsaTest: Buffer.cueSoundFile(s, "/usr/share/sounds/alsa/Front_Center.wav", 0, 1, bufferSize: 20*2*o.blockSize),
		\boo: Buffer.cueSoundFile(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav", 0, 1, bufferSize: 40*2*o.blockSize)
	);
	// load sound files using arguments
	~scbr.makeSynthDef2(\snd1, \sndBuffer, [], [\octoVBAP], [0], \defaultMapper, [~playBuffers[\boo].bufnum]);
	//~scbr.makeSynthDef(\snd2, \sndBuffer, [\domeVBAP], [0], [], [~playBuffers[\alsaTest].bufnum]);

~scbr.makeSynthDef2(
		\string,
		\zkarpluck1,
		[],
		[\domeVBAP],
		[0],
		\defaultMapper,
		[]
	);

	// be sure the synthDef is compiled on the server
	s.sync;

};  // s.waitForBoot
)


// ********** CPU load test (use supernova with increased memory allocation) *********
// play until all CPU are loaded (~70%)
// (no sound since string must be trigered)

// creating a custom group:
~scbr.makeSatieGroup(\cpuTest);

r = Routine {
	loop {
		~scbr.makeInstance((\test ++ rrand(0, 10000).asSymbol), \snd2, \cpuTest);
		0.01.wait;
	}
};
r.play;
r.stop;

// see what we have
~scbr.satieGroupInstances[\cpuTest];


// then triger each string sequentially
~seqtrig = Routine({ ~scbr.satieGroupInstances[\cpuTest].do({ |item|
	item.set(
		\loop, 1,
		\gainDB, rrand(-65, -40),
		\t_trig, 1,
		\aziDeg, rrand(-180, 180),
		\eleDeg, rrand(0, 90)
	);
	rrand(0.05, 0.5).wait;
})});
~seqtrig.play;
~seqtrig.reset; // hit it before playing again
~seqtrig.stop;

~scbr.makeInstance(\soundOne, \snd1, \default);
~scbr.makeInstance(\soundTwo, \snd2, \default);


~scbr.satieGroupInstances[\default][\soundOne].set(\gainDB, -30, \loop, 1, \t_trig, 1);
~scbr.satieGroupInstances[\default][\soundTwo].set(\gainDB, -30, \loop, 1);

~scbr.satieGroups[\cpuTest].set(\loop, 0);

2**20