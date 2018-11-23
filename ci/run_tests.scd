fork {
    var tests;

    // list test classnames
    tests = [
        TestSatie_Server,
        TestSatie_quit,
        TestSatieConfiguration,
        TestSatieConfiguration_server,
        TestOscCommunication,
    ];

    // run each test
    // don't reset test results
    tests.do { |test|
        {test.run(reset: false)}.value
    };

    // report the results
    UnitTest.report;

    "quiting sclang...".postln;
    if(UnitTest.failures.size > 0) {
        1.exit
    } {
        0.exit
    }
}

