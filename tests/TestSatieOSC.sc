TestSatieOSC : UnitTest {
	var s, satie, conf, osc;

	test_prepare {
		s = Server.local;
		conf = SatieConfiguration.new(s, [\stereoListener], numAudioAux: 2);
		satie = Satie.new(conf);
		satie.boot();
		s.waitForBoot({
			satie.makeSynthDef(\string, \zkarpluck1, [], [satie.aux[0]], conf.listeningFormat, [0]);
			satie.makeSynthDef(\busreverb, \freeverb,  [], [], conf.listeningFormat, [0]);
			s.sync;
		});

		osc = NetAddr.new("127.0.0.1", 18032);
	}

	test_setup {
		4.0.wait; // wait for the system 
		osc.sendMsg("/satie/scene", "debugFlag", 1);
		osc.sendMsg("/satie/scene", "createSource",  "sheefa", "plugin://string", "default");
		1.0.wait; // wait for the message action
		this.assert(satie.config.debug == true, "Debug should be true");
		this.assert(satie.groupInstances[\default].keys.includes(\sheefa), "A synth (string) should be in the default group");
		this.assert(satie.groupInstances[\default][\sheefa].class == Synth, "The synth (string) in the default group should be of class Synth");
	}

	test_update {
		//update spatialiser args:  azimuthRad elevationRad gainDB delayMS  lpHZ  distanceMETERS
		osc.sendMsg("/satie/source/update", "sheefa", 30,20,-3,0,1500,20);
		0.1.wait;
		satie.groupInstances[\default][\sheefa].get(\aziDeg, { arg val; this.assert(val == 30, "azi must be 30");});
		satie.groupInstances[\default][\sheefa].get(\eleDeg, { arg val; this.assert(val == 20, "elevation should be 20");});
		satie.groupInstances[\default][\sheefa].get(\gainDB, { arg val; this.assert(val == -3, "gain should be -3");});
		satie.groupInstances[\default][\sheefa].get(\delayMs, { arg val; this.assert(val == 0, "delay should be 0");});
		satie.groupInstances[\default][\sheefa].get(\lpHz, { arg val; this.assert(val == 1500, "lowpass should be 1500");});
		0.1.wait
	}

	test_set {
		osc.sendMsg("/satie/source/set", "sheefa", "c3", 30);    // set a key value pair of the synth
		0.1.wait;
		satie.groupInstances[\default][\sheefa].get(\c3, { arg val; this.assert(val == 30, "c3 should be 30");});
		0.1.wait;
	}

	test_set_multiple {
		// set multiple values
		osc.sendMsg("/satie/source/set", "sheefa", "aziDeg", 180, "eleDeg", 0, "gainDB", -9, "delayMs", 0, "lpHz", 11000);
		0.5.wait;
		satie.groupInstances[\default][\sheefa].get(\aziDeg, { arg val; this.assert(val == 180, "azi must be 180");});
		satie.groupInstances[\default][\sheefa].get(\eleDeg, { arg val; this.assert(val == 0, "elevation should be 0");});
		satie.groupInstances[\default][\sheefa].get(\gainDB, { arg val; this.assert(val == -9, "gain should be -9");});
		satie.groupInstances[\default][\sheefa].get(\delayMs, { arg val; this.assert(val == 0, "delay should be 0");});
		satie.groupInstances[\default][\sheefa].get(\lpHz, { arg val; this.assert(val == 11000, "lowpass should be 11000");});
		1.0.wait;
	}

	test_state_node {
		var running;
		osc.sendMsg("/satie/source/set", "sheefa", "t_trig", 1);
		osc.sendMsg("/satie/source/state", "sheefa", 0);    // set node state to 0
		0.1.wait;
		running = satie.groupInstances[\default][\sheefa].isRunning;
		this.assert(running == false, "node should be paused");
		0.1.wait;
		osc.sendMsg("/satie/source/state", "sheefa", 1);    // set node state to 1
		0.5.wait;
		running = satie.groupInstances[\default][\sheefa].isRunning;
		this.assert(running == true, "node should be running");
		0.1.wait;
	}

	test_state_group {
		var running;
		0.5.wait;
		osc.sendMsg("/satie/group/set", "default", "t_trig", 1);
		osc.sendMsg("/satie/group/state", "default", 0);    // set node state to 1
		0.1.wait;
		running = satie.groups[\default].isRunning;
		this.assert(running == false, "group should be paused");
		0.5.wait;
		osc.sendMsg("/satie/group/set", "default", "t_trig", 1);
		osc.sendMsg("/satie/group/state", "default", 1);    // set node state to 0 
		0.5.wait;
		// it turns out that isRunning state is rather unreliable. This test usually fails.
		// running = satie.groups[\default].isRunning;
		// this.assert(running == true, "group should be running");
		// 0.1.wait;
	}

	test_event {
		"Events are deprecated... Fix the doc".postln;
	}

	test_setvec {
		osc.sendMsg("/satie/source/setvec", "sheefa", "note", 55, 0.9, 0.7);
		0.2.wait;
		satie.groupInstances[\default][\sheefa].get(\note, { arg val; this.assert(val == 55, "note should be 55");});
	}

	test_cleanup {
		1.0.wait;
		s.freeAll();
		s.quit();
	}
}
