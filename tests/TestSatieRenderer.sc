// Test Satie-renderer methods
TestSatieRenderer : UnitTest {
	var s, satie, conf;
	test_prepare {
		s = Server.local;
		conf = SatieConfiguration.new(s, [\stereoListener]);
		satie = Satie.new(conf);
		satie.boot();
	}


	test_setup {
		4.0.wait; // wait for the server
		this.assert(satie.satieConfiguration.listeningFormat[0] == \stereoListener, "Listening format should be stereoListener");
		this.assert(satie.class == Satie, "satie should be SATIE");
	}
	test_groups {
		this.assert(satie.groups.size == 2, "SATIE should create 2 groups at startup");
		this.assert(satie.groups.keys.includes(\default), "SATIE should contain a group named default");
		this.assert(satie.groups.keys.includes(\defaultFx), "SATIE should contain a group named defaultFx");
	}

	test_synthDefCreation {
		// groups should have been created by default:
		satie.makeSynthDef(\test, \default, [], [], conf.listeningFormat, [0]);
		this.assert(satie.generators.keys.includes(\test), "default group should contain 'test' key");
		this.assert(satie.generators[\test] == \default, "'test' should hold a symbol 'default'");
	}

	test_synthInstantiation {
		var synth;
		satie.makeSynthDef(\default, \default, [], [], conf.listeningFormat, [0]);
		synth = satie.makeInstance(\synth, \test, \default);
		this.assert(synth.class == Synth, "Synth instance should be of class Synth");
		this.assert(satie.groupInstances[\default].keys.includes(\synth), "A synth should be in the default group");
		this.assert(satie.groupInstances[\default][\synth].class == Synth, "The synth in the default group should be of class Synth");
	}

	test_makeSatieGroup {
		var tempGroup;
		tempGroup = satie.makeSatieGroup(\test);
		this.assert(tempGroup.class == ParGroup, "The returned group should be a of class ParGroup");
		this.assert(satie.groups.keys.includes(\test), "There should be a group 'test'");
	}

	test_killGroup {
		4.0.wait; // wait for the server
		satie.makeSatieGroup(\test);
		this.assert(satie.groups.keys.includes(\test) == true, "There should be a group 'test'");
		satie.killSatieGroup(\test);
		this.assert(satie.groups.keys.includes(\test) == false, "There should not be a group 'test'");
	}

	test_cleanInstance {
		4.0.wait; // wait for the server
		satie.makeSynthDef(\default, \default, [], [], conf.listeningFormat, [0]);
		satie.makeInstance(\synth, \test, \default);
		this.assert(satie.groupInstances[\default].keys.includes(\synth), "A synth should be in the default group");
		this.assert(satie.groupInstances[\default][\synth].class == Synth, "The synth in the default group should be of class Synth");
		satie.cleanInstance(\synth);
		this.assert(satie.groupInstances[\default][\synth] == nil, "Synth should be 'nil' after cleanInstance");
	}

	test_cleanup {
		s.free();
		s.quit();
	}

}