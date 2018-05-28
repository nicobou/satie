// start SATIE

(

~osc = false;
~aziSpec = ControlSpec(-180, 180, \linear, 0.01);
~eleSpec = ControlSpec(-90, 90, \linear, 0.01);


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
	// Start Manual control
	~satie.satieConfiguration.server.sync;
	~acts = Dictionary.new();
	~idx = 0;

	SynthDef(\signal,
		{
			|out = 0, val = 0.0, lag = 0.1|
			var sig;
			sig = K2A.ar(val);
			Out.ar(out,Lag.ar(sig, lag));
	}).add;
	~satie.satieConfiguration.server.sync;
	3.do({|item|
		var name, synth;
		name = "sig_" ++ item;
		synth = Synth(\signal);
		synth.set(\out, item+8);
		~acts.add(name.asSymbol -> synth);
	});
	s.meter;
	s.plotTree;

	// GUI

	w = Window.new.front;
	w.view.decorator = FlowLayout(w.view.bounds);

	// audio tracking
	t = StaticText.new(w, 200@22);
	t.string_("Envelope Tracking Properties");
	t.background = Color.grey;

	w.view.decorator.nextLine;
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

	// manual control
	w.view.decorator.nextLine;
	t = StaticText.new(w, 200@22);
	t.string_("Manual Control");
	t.background = Color.grey;
	w.view.decorator.nextLine;
	~acts.keysValuesDo({|key, synth|
		currentEnvironment[key] = EZSlider( w,
			300@20,
			controlSpec: ControlSpec(-1.0, 1.0, \lin, 0.01, 0.001),
			label: key,
			action: {|ez| synth.set(\val, ez.value)}
		);
		EZSlider( w,
			300@20,
			controlSpec: ControlSpec(0.05, 10, \lin, 0.1, 0.1),
			label: key ++ " lag",
			action: {|ez| synth.set(\lag, ez.value)}
		);
	});

	// panning
	~micPan = Slider2D.new(w, Rect(0, 0, 100, 100));
	~micPan.action_(
		{|sl|
			~satie.groupInstances[\default][\micro].set(
				\aziDeg, ~aziSpec.map(sl.x), \eleDeg, ~eleSpec.map(sl.y));
	});
	~micPan.setXY(~aziSpec.unmap(0), ~eleSpec.unmap(45));

	w.view.decorator.nextLine;
	t = StaticText.new(w, 200@22);
	t.string_("OSC Rx");
	t.background = Color.grey;

	c = CheckBox.new(w, 200@22, "Process OSC");
	c.action = {| val| ~osc = val.value};
	// OSC control
	o = NetAddr.new("127.0.0.1", 18040);

	OSCdef(\haptic,
		{|msg, time, addr, recvPort|
			if (~osc == true,
				{
					~acts[\sig_0].set(\val, msg[1].asFloat);
					~acts[\sig_1].set(\val, msg[2].asFloat);
					~acts[\sig_2].set(\val, msg[3].asFloat);
				}
			);
		},
		'/val',
		recvPort: 18040
	);
};
)


// add simple 3 oscilator thing playing different low frequency (0.1 - 5 Hz) waves
// add slider2D for spatialization control
~satie.postProcessors[\post_proc_1].set(\amp, 20, \lag, 0.1, \add, -10)
