(
s = Server.supernova.local;
~satieConfiguration = SatieConfiguration.new(s, [\cube, \stereoListener], 0, [0, 8]);
~satieConfiguration.serverOptions.blockSize = 1024;
~satie = Satie.new(~satieConfiguration);
~satie.boot();
~satie.satieConfiguration.server.waitForBoot{
	~satie.makeSynthDef(\mic, \MonoIn,  [], [], [], ~satie.satieConfiguration.listeningFormat, ~satie.satieConfiguration.outBusIndex, paramsMapper: \nearFarField1);
	~satie.makeSynthDef(\test, \testtone,  [], [], [], ~satie.satieConfiguration.listeningFormat, ~satie.satieConfiguration.outBusIndex, paramsMapper: \nearFarField1);
	~satie.makeSynthDef(\misD, \misDrone,  [], [], [], ~satie.satieConfiguration.listeningFormat, ~satie.satieConfiguration.outBusIndex, paramsMapper: \nearFarField1);
	~satie.satieConfiguration.server.sync;
	~satie.makeSourceInstance(\micro, \mic, \default);
	~satie.groupInstances[\default][\micro].set(\aziDeg, -90, \aziEle, 10, \gainDB, -80, \nfIndex, 0.1, \t_trig, 1);
	~satie.replacePostProcessor([\envfol], 8, 1);
	s.meter;
	s.plotTree;
};

)



(
w = Window.new.front;
EZSlider( w,
	Rect(5, 10, 300, 20),
	label: "factor",
	action: {|ez| ~satie.groupInstances[\default][\micro].set(\nfIndex, ez.value)}
);

// EZSlider( w,
// 	Rect(5, 40, 300, 20),
// 	label: "freq",
// 	controlSpec: ControlSpec(0.01, 200, \lin, 0.01, 50, "Hz"),
// 	action: {|ez| ~satie.groupInstances[\default][\testy].set(\sfreq, ez.value)}
// );

EZSlider( w,
	Rect(5, 60, 300, 20),
	label: "gain",
	controlSpec: \db,
	action: {|ez| ~satie.groupInstances[\default][\micro].set(\gainDB, ez.value)}
);

)
