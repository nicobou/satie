TestSatieConfiguration_server : UnitTest {
	var server;

	setUp {
		server = Server(this.class.name);
	}

	tearDown {
		server.remove;
	}

	test_listeningFormat_numChannels {
		var spat = \domeVBAP;
		var config = SatieConfiguration(server, [spat]);
		var satie = Satie(config);
		satie.boot;
		this.wait({ satie.booted }, "Satie failed to boot after 5 seconds", 5);
		this.assertEquals(
			server.options.numOutputBusChannels,
			satie.config.spatPlugins[spat].numChannels,
			"Server has correct number of output channels"
		);
		satie.quit;
	}

}
