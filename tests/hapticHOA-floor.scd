(
s = Server.supernova.local;
~satieConfiguration = SatieConfiguration.new(s, [\cube], outBusIndex: [0], ambiOrders: [2], minOutputBusChannels: 17);
~satie = Satie.new(~satieConfiguration);
~satie.boot();
)

(
s.waitForBoot({
	~satie.replaceAmbiPostProcessor([\hapticHOA], spatializerNumber: 1, order: 2, outputIndex: ~satieConfiguration.outBusIndex+8);
	~satieConfiguration.ambiBusIndex[0].do {|item| item.scope;};
	~satie.satieConfiguration.server.sync;
	~satie.makeSourceInstance(\micro, \MonoIn, \default);
	~satie.makeSourceInstance(\microAmbi, \MonoInAmbi2, \default);
	~satie.satieConfiguration.server.sync;
	s.meter;
	s.plotTree;
});
)
(
~satie.groupInstances[\default][\micro].set(\t_trig, 1, \aziDeg, 90, \aziEle, 20, \gainDB, -10);
~satie.groupInstances[\default][\microAmbi].set(\t_trig, 1, \aziDeg, 90, \aziEle, 20, \gainDB, 0);
)