// start SATIE

(

~osc = false;
~sinOn = false;
~acts = Dictionary.new();
~sins = Dictionary.new();

~idx = 0;
~aziSpec = ControlSpec(-180, 180, \linear, 0.01);
~eleSpec = ControlSpec(-90, 90, \linear, 0.01);


s = Server.supernova.local;
// ~satieConfiguration = SatieConfiguration.new(s, [\cube, \haptic2000], 0, [0, 8]);
//
~satieConfiguration = SatieConfiguration.new(s, [\stereoListener, \stereoListener, \aziHaptic2000], 0, [0, 6, 8]);
~satieConfiguration.serverOptions.numOutputBusChannels = 16;
~satie = Satie.new(~satieConfiguration);
~satie.boot();
~satie.satieConfiguration.server.waitForBoot{
	~satie.makeSynthDef(\mic, \MonoIn,  [], [], [], ~satie.satieConfiguration.listeningFormat, ~satie.satieConfiguration.outBusIndex, paramsMapper: \haptic2000map);
	~satie.makeSynthDef(\fbOscRez, \fbOscRez,  [], [], [], ~satie.satieConfiguration.listeningFormat, ~satie.satieConfiguration.outBusIndex, paramsMapper: \haptic2000map);
	~satie.makeSynthDef(\misD, \misDrone,  [], [], [], ~satie.satieConfiguration.listeningFormat, ~satie.satieConfiguration.outBusIndex, paramsMapper: \nearFarField1);
	~satie.makeSourceInstance(\micro, \mic, \default);
	~satie.makeSourceInstance(\rez1, \fbOscRez, \default, synthArgs:[\freq: 120, \vibAmp: 0.7, \lpfFreq: 200, \vibAdd: 1.2, \lpfRes: 20, \amp: 0.8, \att: 2, \gainDB: -99]);
	~satie.groupInstances[\default][\micro].set(\aziDeg, -45, \aziEle, 30, \gainDB, -80, \t_trig, 1);
	// ~satie.groupInstances[\default][\rez1].set(\aziDeg, 0, \aziEle, 10, \gainDB, -20, \nfIndex, 1);
	~satie.replacePostProcessor([\delay], 0, 0);
	~satie.replacePostProcessor([\delay], 2, 1);
	~satie.replacePostProcessor([\envfol], 8, 2);
	~satie.satieConfiguration.server.sync;


	// Start Manual control

	/*************************************
	* sinusoids
	*/
	SynthDef(\sinus,
		{
			|out = 0, freq = 0.5, amp = -99, mul = 2, add = -1|
			var sig;
			sig = SinOsc.ar(freq * rrand(0.1, 0.5), mul: mul, add: add);
			Out.ar(out,sig * amp.dbamp);
	}).add;

	~satie.satieConfiguration.server.sync;
	9.do({|item|
		var name, synth;
		name = "sinus_" ++ item;
		synth = Synth.new(\sinus, addAction: \addToTail);
		synth.set(\out, item+8);
		~sins.add(name.asSymbol -> synth);
	});
	// END sinusoids


	/*************************************
	* discreet signal control
	*/
	SynthDef(\signal,
		{
			|out = 0, val = 0.0, lag = 0.1|
			var sig;
			sig = K2A.ar(val);
			Out.ar(out,Lag.ar(sig, lag));
	}).add;
	~satie.satieConfiguration.server.sync;
	9.do({|item|
		var name, synth;
		name = "sig_" ++ item;
		synth = Synth.new(\signal, addAction: \addToTail);
		synth.set(\out, item+8);
		~acts.add(name.asSymbol -> synth);
	});
	// END discreet
	s.meter;
	s.plotTree;

	/*************************************
	* GUI
	*/

	w = Window.new.front;
	w.bounds = 315@1030;
	w.view.decorator = FlowLayout(w.view.bounds);

	// audio tracking
	t = StaticText.new(w, 200@22);
	t.string_("Test sound");
	t.background = Color.grey;

	w.view.decorator.nextLine;
	EZSlider( w,
		300@20,
		label: "floor orient",
		controlSpec: ControlSpec(-180, 180, \linear, 0.01),
		action: {|ez| ~satie.groupInstances[\default][\micro].set(\aziOffset, ez.value)}
	);

	EZSlider( w,
		300@20,
		label: "input gain",
		controlSpec: \db,
		action: {|ez| ~satie.groupInstances[\default][\micro].set(\gainDB, ez.value)}
	);

	EZSlider( w,
		300@20,
		label: "synth gain",
		controlSpec: \db,
		initVal: -99,
		action: {|ez| ~satie.groupInstances[\default][\rez1].set(\gainDB, ez.value)}
	);

	EZSlider( w,
		300@20,
		label: "LPF",
		controlSpec: ControlSpec(0, 10, \lin, 0.1, 0.5),
		action: {|ez| ~satie.postProcessors[\post_proc_1].set(\lpf, ez.value )}
	);
	// panning
	~micPan = Slider2D.new(w, Rect(0, 0, 100, 100));
	~micPan.action_(
		{|sl|
			var azi, ele;
			azi = ~aziSpec.map(sl.x);
			ele = ~eleSpec.map(sl.y);
			~satie.groupInstances[\default][\micro].set(
				\aziDeg,  azi, \eleDeg,  ele);
			~satie.groupInstances[\default][\rez1].set(
				\aziDeg,  azi, \eleDeg,  ele);
	});
	~micPan.setXY(~aziSpec.unmap(0), ~eleSpec.unmap(45));


	// sinusoids control
	w.view.decorator.nextLine;
	t = StaticText.new(w, 200@22);
	t.string_("Sinusoids ON/OFF");
	t.background = Color.grey;
	w.view.decorator.nextLine;
	~sins.order.do({|key|
		currentEnvironment[key] = EZSlider( w,
			300@20,
			controlSpec: ControlSpec(0.001, 5.0, \lin, 0.01, 0.1),
			label: key,
			action: {|ez| ~sins[key].set(\freq, ez.value)}
		);
	});
	EZSlider(w,
		300@20,
		controlSpec: \db,
		initVal: -99,
		label: "sinusoids global amplitude",
		action: {|ez|
			~sins.keysValuesDo({|key, synth|
				synth.set(\amp, ez.value);
			})
		}
	);

	// manual control
	w.view.decorator.nextLine;
	t = StaticText.new(w, 200@22);
	t.string_("Manual Control");
	t.background = Color.grey;
	w.view.decorator.nextLine;
	~acts.order.do({|key|
		currentEnvironment[key] = EZSlider( w,
			300@20,
			controlSpec: ControlSpec(-1.0, 1.0, \lin, 0.01, 0.001),
			label: key,
			action: {|ez| ~acts[key].set(\val, ez.value)}
		);
		EZSlider( w,
			300@20,
			controlSpec: ControlSpec(0.05, 10, \lin, 0.1, 0.1),
			label: key ++ " lag",
			action: {|ez| ~acts[key].set(\lag, ez.value)}
		);
	});
	EZSlider(w,
		300@20,
		controlSpec: ControlSpec(-1.0, 1.0, \lin, 0.01, 0.001),
		initVal: 1,
		label: "manual global",
		action: {|ez|
			~acts.keysValuesDo({|key, synth|
				synth.set(\val, ez.value);
			})
		}
	);


	// OSC control
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
					~acts[\sig_5].set(\val, msg[1].asFloat);
					~acts[\sig_4].set(\val, msg[2].asFloat);
					~acts[\sig_3].set(\val, msg[3].asFloat);
					~acts[\sig_0].set(\val, msg[4].asFloat);
					~acts[\sig_8].set(\val, msg[5].asFloat);
					~acts[\sig_1].set(\val, msg[6].asFloat);
					~acts[\sig_7].set(\val, msg[7].asFloat);
				}
			);
		},
		'/val',
		recvPort: 18040
	);
	~satie.satieConfiguration.server.sync;
	~satie.postProcessors[\post_proc_0].set(\del, 0.122);
	~satie.postProcessors[\post_proc_1].set(\del, 0.122);
	~satie.postProcessors[\post_proc_2].set(\lpf, 5);
	~satie.groupInstances[\default][\rez1].set( \freq, 60, \vibFreq, 22,\vibAmp, 0.5, \lpfFreq, 5, \vibAdd, 1.3, \lpfRes, 1, \amp, 0.5, \att, 2);

};

)