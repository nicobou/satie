// start SATIE

(
s = Server.supernova.local;
~satieConfiguration = SatieConfiguration.new(s, [\cube, \dboxThree], 0, [0, 8]);
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
l
)

// Start Manual control

(
~acts = Dictionary.new();
~idx = 0;

SynthDef(\signal,
	{
		|out = 0, val = 0.0|
		var sig;
		sig = K2A.ar(val);
		sig.scope;
		Out.ar(out,Lag(sig));
	}).add;
)

(
3.do({|item|
	var name, synth;
	name = "sig_" ++ item;
	synth = Synth(\signal);
	synth.set(\out, item+8);
	~acts.add(name.asSymbol -> synth);
});
)
)

// GUI

(
w = Window.new.front;
w.view.decorator = FlowLayout(w.view.bounds);



EZSlider( w,
	300@20,
	label: "factor",
	action: {|ez| ~satie.groupInstances[\default][\micro].set(\nfIndex, ez.value)}
);

EZSlider( w,
	300@20,
	label: "gain",
	controlSpec: \db,
	action: {|ez| ~satie.groupInstances[\default][\micro].set(\gainDB, ez.value)}
);

EZSlider( w,
	300@20,
	label: "lag",
	controlSpec: ControlSpec(0, 10, \lin, 1, 2),
	action: {|ez| ~satie.postProcessors[\post_proc_1].set(\lag, ez.value )}
);



~acts.keysValuesDo({|key, synth|
	EZSlider( w,
		300@20,
		controlSpec: ControlSpec(-1.0, 1.0, \lin, 0.01, 0.001),
		label: key,
		action: {|ez| synth.set(\val, ez.value)}
	);
	[key, synth].postln;
});

)

// OSC control
(
o = NetAddr.new("127.0.0.1", 18040);    // connect to satie's RX port

// ~osc_cb = {|msg, time, addr, recvPort|
// 	msg.postln;
// };

OSCdef(\haptic, {|msg, time, addr, recvPort|
	~acts[\sig_0].set(\val, msg[1]);
	~acts[\sig_1].set(\val, msg[2]);
	~acts[\sig_2].set(\val, msg[3]);
}, '/val',  recvPort: 18040);



)