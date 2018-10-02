TestSatie_Server : UnitTest {

    var server, satie;

    setUp {
        server = Server(this.class.name);
        satie = Satie(SatieConfiguration(server));
    }

    tearDown {
        server.quit;
        server.remove;
        satie = nil;
    }

    test_boot {
        satie.boot;
        this.wait({ satie.booted }, "Satie boot timed out", 8);
    }

    test_bootCallback {
        var timeout, cond = Condition();

        satie.doneCb = { cond.unhang };
        timeout = fork { 8.wait; cond.unhang };

        satie.boot;
        cond.hang;

        this.assertEquals(satie.booted, true, "Satie booted succesfully");

        timeout.stop;
        cond = nil;
    }

}
