TestSatie_Server : UnitTest {

	var server, satie;

	setUp {
		server = Server(this.class.name);
		satie = Satie(SatieConfiguration(server));
		server.bootSync;
	}

	tearDown {
		server.quit.remove;
	}

	test_boot_success {
		var booted = satie.satieConfiguration.server.serverRunning;
		this.assertEquals(booted, true, "Satie booted succesfully")
	}

}
