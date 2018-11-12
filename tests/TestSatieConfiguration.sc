TestSatieConfiguration : UnitTest {
	var server, config;

	setUp {
		server = Server(this.class.name);
		config = SatieConfiguration(server);
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
		var rootPath = "/builds/sat-metalab/SATIE/"; // GitLab CI path
		this.assertEquals(config.satieRoot, rootPath, "Satie root path is correctly set");
	}

	test_userSupportDir {
		var userPath = Platform.userHomeDir +/+ ".local/share/satie";
		this.assertEquals(config.satieUserSupportDir, userPath, "User support path is correctly set");
	}

	test_hrirPath {
		var hrirPath = Platform.userHomeDir +/+ ".local/share/HOA/kernels/FIR/hrir/hrir_ku100_lebedev50";
		this.assertEquals(config.hrirPath, hrirPath, "HRIR path is set to proper default value");
	}

	test_initDicts {
		var dicts = [
			\sources,
			\effects,
			\spatializers,
			\mappers,
			\postprocessors,
			\hoa,
			\monitoring,
		];
		dicts.do { |key|
			this.assertEquals(
				config.slotAt(key).class.asSymbol,
				\SatiePlugins,
				"Plugin dictionary % instantiated".format(key)
			)
		}
	}

	test_loadPlugins {
		var path = PathName(config.satieRoot +/+ "plugins");
		path.filesDo { |file|
			var folder = file.folderName.asSymbol;
			var filename = file.fileNameWithoutExtension.asSymbol;
			var category = switch(folder)
				{\sources} {\sources}
				{\effects} {\effects}
				{\hoa} {\hoa}
				{\mappers} {\mappers}
				{\monitoring} {\monitoring}
				{\postprocessors} {\postprocessors}
				{\spatializers} {\spatializers};
			this.assertEquals(
				config.slotAt(category).at(filename).isNil.not,
				true,
				"Plugin %/% loaded successfully".format(folder, filename)
			)
		}
	}

}
