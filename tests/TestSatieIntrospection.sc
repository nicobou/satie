// UnitTest.reset;

TestSatieIntrospection : UnitTest {
	var server, satie, conf;

	setUp {
		server = Server(this.class.name); 
		conf = SatieConfiguration.new(server, [\stereoListener]);
		satie = Satie.new(conf);
		server.bootSync;
	}

	tearDown {
		server.quit;
		server.remove;
	}

	test_setup {
		this.assert(satie.class == Satie, "satie should be Satie");
	}
}
