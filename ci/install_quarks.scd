fork {
    ~path = "/builds/sat-metalab/SATIE";
    if (File.exists(~path +/+ "SATIE.quark")) {
        Quarks.install(~path);
    } {
        "SATIE quark file not found at: %".format(~path).postln
    };
    5.wait;
    0.exit
}

