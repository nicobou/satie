fork {
    var tests;

    // list test classnames
    tests = [
        TestSatie_Server,
        TestSatie_quit,
        TestSatieConfiguration,
        TestSatieConfiguration_server,
    ];

    // run each test
    // don't reset test results
    tests.do { |test|
        {test.run(reset: false)}.value
    };

    // report the results
    UnitTest.report;

    "quiting sclang...".postln;
    0.exit
}

