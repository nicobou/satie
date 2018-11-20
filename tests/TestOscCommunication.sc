TestOscCommunication : UnitTest {
	var server, satie, addr, resp;

	setUp {
		server = Server(this.class.name);
		satie = Satie(SatieConfiguration(server));
		addr = NetAddr("localhost", 18032);
		satie.boot;
		this.wait({ satie.booted }, "Satie failed to boot in 5 seconds", 5);
	}

	tearDown {
		satie.quit;
		satie = nil;
		server.remove;
	}

	test_introspection_plugins {
		var resp;
		OSCFunc({ |msg| resp = msg[0] }, '/plugins');
		addr.sendMsg("/satie/plugins");
		server.sync;
		this.assertEquals(resp, '/plugins', "Requested '/satie/plugings' introspection message received");
	}

	test_introspection_pluginargs {
		var resp;
		OSCFunc({ |msg| resp = msg[0] }, '/arguments');
		addr.sendMsg("/satie/pluginargs", "testtone");
		server.sync;
		this.assertEquals(resp, '/arguments', "Requested '/satie/plugingargs' introspection message received");
	}

}
