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

	~satie.makeSynthDef2(
		\string,
		\zkarpluck1,
		[],
		[\octoVBAP],
		[0],
		\defaultMapper,
		[]
	);

};  // s.waitForBoot
)

// ********** CPU load test (use supernova with increased memory allocation) *********
// play until all CPU are loaded (~70%)
// (no sound since string must be trigered)

// creating a custom group:
~satie.makeSatieGroup(\cpuTest);

r = Routine {
	loop {
		~satie.makeInstance((\test ++ rrand(0, 10000).asSymbol), \string, \cpuTest);
		0.1.wait;
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
		\t_trig, 1,
		\aziDeg, rrand(-180,180),
		\eleDeg, rrand(0,90),
		\note, rrand(42, 72), rrand(1, 2), rrand(0.1, 0.9));
	rrand(0.05, 0.1).wait;
	});});
~satie.satieGroups[\cpuTest].set(\gainDB, -50);
~seqtrig.play;
~seqtrig.reset; // hit it before playing again
~seqtrig.stop;