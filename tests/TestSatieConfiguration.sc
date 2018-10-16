TestSatieConfiguration : UnitTest {
	var server;

	setUp {
		server = Server(this.class.name);
	}

	tearDown {
		server.remove;
	}

	test_newCopyArgs {
		var arguments = [
			server,
			[\stereoListener, \domeVBAP], // listeningFormat
			8, // numAudioAux
			[0, 12], // outBusIndex
			[1, 3], // ambiOrders
			2, // minOutputBusChannels
			"/some/path/string" // hrirPath
		];
		var config = SatieConfiguration(*arguments);
		var values = [
			config.server,
			config.listeningFormat,
			config.numAudioAux,
			config.outBusIndex,
			config.ambiOrders,
			config.minOutputBusChannels,
			config.hrirPath
		];
		this.assertEquals(values, arguments, "SatieConfiguration created with values");
	}

	test_satieRoot {
		var config = SatieConfiguration(server);
		var rootPath = "/builds/sat-metalab/SATIE"; // GitLab CI path
		this.assertEquals(config.satieRoot, rootPath, "Satie root path is correctly set");
	}

	test_userSupportDir {
		var config = SatieConfiguration(server);
		var userPath = Platform.userHomeDir +/+ ".local/share/satie";
		this.assertEquals(config.satieUserSupportDir, userPath, "User support path is correctly set");
	}

	test_hrirPath {
		var config = SatieConfiguration(server);
		var hrirPath = Platform.userHomeDir +/+ ".local/share/HOA/kernels/FIR/hrir/hrir_ku100_lebedev50";
		this.assertEquals(config.hrirPath, hrirPath, "HRIR path is set to proper default value");
	}

}
