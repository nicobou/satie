(
s = Server.supernova.local;
~satieConfiguration = SatieConfiguration.new(s, [\cube, \stereoListener], [], [0, 8]);
~satieConfiguration.serverOptions.blockSize = 1024;
~satie = Satie.new(~satieConfiguration);
s.boot();
~satie.satieConfiguration.server.waitForBoot{
	~satie.makeSynthDef(\dust, \DustDust,  [], [], [], ~satie.satieConfiguration.listeningFormat, ~satie.satieConfiguration.outBusIndex, paramsMapper: \nearFarField1);
	~satie.satieConfiguration.server.sync;
	s.meter;
};

)

~satie.makeSourceInstance(\dusty, \dust, \default);
~satie.groupInstances[\default][\dusty].set(\aziDeg, 10, \aziEle, 10, \gainDB, 0, \nfIndex, 0)