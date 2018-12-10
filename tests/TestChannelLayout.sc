TestChannelLayout : UnitTest {
	var server, satie;

	setUp {
		server = Server(this.class.name);
	}

	tearDown {
		satie.quit;
		server.remove;
	}

	test_outputChannels {
		var results, buffer, cond = Condition.new;
		var layout = [1, 3]; // channels 1 and 4
		var spat = [\monoSpat, \monoSpat];
		var config = SatieConfiguration(
			server: server,
			listeningFormat: spat,
			outBusIndex: layout,
			minOutputBusChannels: 4
		);
		satie = Satie(config);
		satie.boot;
		this.wait({ satie.booted }, "Satie failed to boot after 5 seconds", 5);

		satie.makeInstance(\foo, \testtone, synthArgs: [\gainDB, -9]);
		buffer = Buffer.alloc(server, 64, 4);
		OSCFunc({ cond.unhang }, '/n_end');
		server.sync;

		{
			BufWr.ar(
				In.ar(0, 4),
				buffer,
				Phasor.ar(0, 1, 0, 64),
				loop: 0
			);
			Line.kr(dur: 0.01, doneAction: 2);
			Silent.ar;
		}.play(server, addAction: 'addToTail');
		cond.hang;

		buffer.getToFloatArray(0, 4, action: { |array| results = array });
		server.sync;

		this.assertEquals(
			results > 0.0,
			[false, true, false, true],
			"Satie is playing on all configured output channels"
		)
	}

}

