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
	~satie = ~satieMaker.value(numAudioAux: ~num_aux_bus, satieSrcPath: ~rootSrcPath);

	~satie.makeSynthDef2(\testtone, \testtone, [], [\octoVBAP], [0], \defaultMapper, []);

	// be sure the synthDef is compiled on the server
	s.sync;

};  // s.waitForBoot
)


// ********** CPU load test (use supernova with increased memory allocation) *********
// play until all CPU are loaded (~70%)
// (no sound since string must be trigered)

// creating a custom group:
~satie.makeSatieGroup(\cpuTest);

r = Routine {
	loop {
		~satie.makeInstance((\test ++ rrand(0, 10000).asSymbol), \testtone, \cpuTest);
		0.01.wait;
	}
};
r.play;
r.next;
r.stop;


// see what we have
~satie.satieGroupInstances[\cpuTest];


// then triger each string sequentially
~seqtrig = Routine({ ~satie.satieGroupInstances[\cpuTest].do({ |item|
	item.set(
		\aziDeg, rrand(-180,180),
		\eleDeg, rrand(0,90),
		\sfreq, rrand(50, 18000),
		\gainDB, rrand(-140, -95)
);})});
~seqtrig.play;
~seqtrig.reset; // hit it before playing again
~seqtrig.stop;

