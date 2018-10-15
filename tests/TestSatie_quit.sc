TestSatie_quit : UnitTest {

	var satie, server;

	setUp {
		server = Server(this.class.name);
		satie = Satie(SatieConfiguration(server));
		satie.boot;
		this.wait({ satie.booted }, "Satie failed to boot in 'setUp'", 5);
		satie.quit;
		this.wait({ satie.booted.not }, "Satie did not quit in 'setUp'", 5);
	}

	tearDown {
		satie = nil;
		server.remove;
	}

	test_booted_false {
		this.assertEquals(
			satie.booted,
			false,
			"Booted is false after quit"
		);
	}

	test_serverRunning_false {
		this.assertEquals(
			server.serverRunning,
			false,
			"Server not running after quit"
		);
	}

	test_groups_free {
		this.assertEquals(
			satie.groups.isEmpty,
			true,
			"Groups where freed after quit"
		);
	}

	//
	// test_processInstance_free
	//

	test_oscDefs_free {
		this.assertEquals(
			satie.osc.oscDefs.isEmpty,
			true,
			"OSCdefs where freed after quit"
		);
	}

	test_cmdPeriod_remove {
		this.assertEquals(
			CmdPeriod.objects.includes(satie),
			false,
			"Satie removed from CmdPeriod"
		);
	}

	test_serverTree_remove {
		this.assertEquals(
			ServerTree.objects.at(server).includes(satie),
			false,
			"Satie removed from ServerTree"
		);
	}

}
