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

	~scbr.makeSynthDef2(
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

// ********** Kamikaze test *********
// string sounds are loaded and played immediately. Each synth is destroyed
// upon completion (silence is detected at the end of its envelope)
// The side effect of hitting stop is that after a little while all created sounds
// will be killed.

(
// custom group:

~scbr.makeSatieGroup(\kamikaze);

r = Routine {
	loop {
		~scbr.makeKamikaze(
			(\test ++ rrand(0, 10000).asSymbol),
			\string,
			\kamikaze,
			[\t_trig, 1,
				\note, rrand(42, 72),
				\gainDB, rrand(-60, -40),
				\aziDeg, rrand(-180, 180)
			]
		);
		rrand(0.05, 0.5).wait;
	}
};
)

r.play; // you should see Synth number going up and down as it plays

r.stop; // Synths number will eventually go back to 2 (if this example is the only one being run in SC)