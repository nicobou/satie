// UnitTest.reset;

TestSatieIntrospection : UnitTest {
	var s, satie, conf;

	setUp {
		s = Server.local;
		conf = SatieConfiguration.new(s, [\stereoListener]);
		satie = Satie.new(conf);
		this.bootServer;
	}

	tearDown {
		s.quit();
	}

	test_setup {
		this.assert(satie.class == Satie, "satie should be Satie");
	}
}