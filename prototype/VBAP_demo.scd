//Server.default = s = Server.internal;
// s.quit;
// SCJConnection.getconnections
//
// Quarks.gui
s = Server.local
Server.default;
Server.supernova;
Server
s.reboot;
s.quit;
s.makeGui;
s.scope;

(
// checks it out from svn
// Quarks.checkout("JACK");
// // this installs it
//Quarks.install("JACK");
//Quarks.gui

o = Server.local.options;
// Post the number of output channels
o.numOutputBusChannels.postln;
o.numOutputBusChannels = 128;
o.memSize.postln;
o.memSize = 2**20;
o.blockSize = 2048;
// o.numAudioBusChannels = 512;
// o.numPrivateAudioBusChannels = 512;
// s.reboot

// init
s.waitForBoot{
	var maxdelay = 0.01;
	~pargroup = ParGroup.new;

	// 128 channels
	// VBAPSpeakerArray.maxNumSpeakers = 128;
	// ~spk = VBAPSpeakerArray.new(3, [
	// 	[0,0], [23,0], [46,0], [69,0], [92,0], [115,0], [138,0], [161,0], [184,0], [207,0], [230,0], [253,0], [276,0], [299,0], [322,0], [345,0], [0,10], [23,10], [46,10], [69,10], [92,10], [115,10], [138,10], [161,10], [184,10], [207,10], [230,10], [253,10], [276,10], [299,10], [322,10], [345,10], [0,20], [23,20], [46,20], [69,20], [92,20], [115,20], [138,20], [161,20], [184,20], [207,20], [230,20], [253,20], [276,20], [299,20], [322,20], [345,20], [0,30], [23,30], [46,30], [69,30], [92,30], [115,30], [138,30], [161,30], [184,30], [207,30], [230,30], [253,30], [276,30], [299,30], [322,30], [345,30], [0,40], [23,40], [46,40], [69,40], [92,40], [115,40], [138,40], [161,40], [184,40], [207,40], [230,40], [253,40], [276,40], [299,40], [322,40], [345,40], [0,50], [23,50], [46,50], [69,50], [92,50], [115,50], [138,50], [161,50], [184,50], [207,50], [230,50], [253,50], [276,50], [299,50], [322,50], [345,50], [0,60], [23,60], [46,60], [69,60], [92,60], [115,60], [138,60], [161,60], [184,60], [207,60], [230,60], [253,60], [276,60], [299,60], [322,60], [345,60], [0,70], [23,70], [46,70], [69,70], [92,70], [115,70], [138,70], [161,70], [184,70], [207,70], [230,70], [253,70], [276,70], [299,70], [322,70], [345,70],
	// ]);

	// 55 channels
	//VBAPSpeakerArray.maxNumSpeakers = 64;
	/*~spk = VBAPSpeakerArray.new(3, [
		[0,0], [23,0], [46,0], [69,0], [92,0], [115,0], [138,0], [161,0], [184,0], [207,0], [230,0], [253,0], [276,0], [299,0], [322,0], [345,0], [0,10], [23,10], [46,10], [69,10], [92,10], [115,10], [138,10], [161,10], [184,10], [207,10], [230,10], [253,10], [276,10], [299,10], [322,10], [345,10], [0,20], [23,20], [46,20], [69,20], [92,20], [115,20], [138,20], [161,20], [184,20], [207,20], [230,20], [253,20], [276,20], [299,20], [322,20], [345,20], [0,30], [23,30], [46,30], [69,30], [92,30], [115,30], [138,30]
	]);*/

	// dome
	~spk = VBAPSpeakerArray.new(3, [
		[0, 90],
		[15, 45], [75, 45], [135, 45], [-165, 45], [-105, 45], [-45, 45],
		[0, 22.5], [30, 22.5], [60, 22.5], [90, 22.5], [120, 22.5], [150, 22.5], [180, 22.5], [-150, 22.5], [-120, 22.5], [-90, 22.5], [-60, 22.5], [-30, 22.5],
		[0, 0], [30, 0], [60, 0], [90, 0], [120, 0], [150, 0], [180, 0], [-150, 0], [-120, 0], [-90, 0], [-60, 0], [-30, 0],
	]);

	// mini dome
	// ~spk = VBAPSpeakerArray.new(3, [
	// 	[0, 90],
	// 	[0, 60], [45, 60], [90, 60], [135, 60], [180, 60], [-135, 60], [-90, 60], [-45, 60],
	// 	[0, 30], [45, 30], [90, 30], [135, 30], [180, 30], [-135, 30], [-90, 30], [-45, 30],
	// 	[0, 1], [45, 1], [90, 1], [135, 1], [180, 1], [-135, 1], [-90, 1], [-45, 1]
	// ]);
	// bureau
	// ~spk = VBAPSpeakerArray.new(2, [-180, -120, -60, 0, 60, 120]);
	~spk.speakers[1].dump;
	~vbuf = Buffer.loadCollection(s, ~spk.getSetsAndMatrices);

	e = Bus.control(s, 5); // azi, ele, delay, vol
	e.set(0, 0, 0, 1);

	t = Tuning.just;
	a = Scale.pelog(t);
	a = Scale.major(t);
	~pf = Pfunc({a.ratios.choose},{\reset.postln }).asStream;
	s.sync;

	SynthDef(\oiseausimple, {
	| outbus = 0, freq = 200, spr = 1, azibus = 0, elebus = 0, delaybus = 0, volbus = 0 |
	Out.ar(outbus,
		VBAP.ar(numChans: ~spk.numSpeakers,
				in: DelayC.ar(((In.kr(volbus)/2.0) + Rand(0.5, 1.0) )
					* (PinkNoise.ar() + FSinOsc.ar(freq))
					* EnvGen.kr(Env.sine(dur:3), doneAction: 2),
					maxdelay,
					maxdelay * (In.kr(delaybus) * Rand(0.0, 1.0))),
				bufnum: ~vbuf.bufnum,
				azimuth: ((In.kr(azibus) + Rand(0, 360))%360) - 180,
				elevation: (In.kr(elebus) + Rand(0, 90)).clip(0.0, 90.0),
				spread: 0));
	}).add;

	// SynthDef(\oiseaubouge, {
	// 	| outbus = 0, freq = 200, spr = 1, azibus = 0, elebus = 0, delaybus = 0, volbus = 0 |
	// 	var  browndist, brownele, brownazi;
	// 	browndist = Dbrown.kr(lo: 0.0, hi: 1.0, step: 0.01);
	// 	brownele  = Dbrown.kr(lo: 0.0, hi: 90.0, step: 0.01);
	// 	brownazi  = Dbrown.kr(lo: -180.0, hi: 180.0, step: 0.01);
	// 	Out.ar(outbus,
	// 		VBAP.ar(numChans: ~spk.numSpeakers,
	// 			in: DelayC.ar(browndist.squared
	// 				* (0.2 * PinkNoise.ar() + FSinOsc.ar(freq))
	// 				* EnvGen.kr(Env.sine(dur:3), doneAction: 2),
	// 				maxdelay,
	// 			maxdelay * (1 - browndist)),
	// 			bufnum: ~vbuf.bufnum,
	// 			azimuth: brownazi,
	// 			elevation: brownele,
	// 	spread: 0));
	// }).add;

	SynthDef("rotate",{ arg out=0, gate = 0, orient = 1;
		Out.kr(out,
			Linen.kr(gate, 0.1, 1, 0.1) *
			LFSaw.kr(freq: 0.2, mul: orient * 180.0, add: 180)
		)
	}).add;

	SynthDef("elevate",{ arg out=0, gate = 0, orient = 1;
		Out.kr(out,	Linen.kr(gate, 4, 90, 0.2))
	}).add;

		// auto move
	SynthDef("distate", { arg out = 0, gate = 0;
		var freq = 1;
		Out.kr(out, [
			Linen.kr(gate, 0.1, 1, 0.1) * FSinOsc.kr(freq, mul: 0.5, add: 0.5),
			1 - (Linen.kr(gate, 0.1, 1, 0.1) * FSinOsc.kr(freq, mul: 0.5, add: 0.5) * LFTri.kr(freq, mul: 0.5, add: 0.5))
	]);}).add;

	s.sync;

	// CLUSTER
	r = Routine({
		loop {
			Synth.head(~pargroup, \oiseausimple, [
				buffer: ~afiles.next,
				azibus: e.index,
				elebus: e.index + 1,
				delaybus: e.index + 2,
				volbus: e.index + 3,
				freq: [200, 400, 800].choose * ~pf.next
			]);
			0.5.wait;
			//0.1.yield;
	}});
	r.play;

	// HID
	GeneralHID.buildDeviceList;
	~logitech = GeneralHID.findBy( 1133, 49690 );
	~device = GeneralHID.open( ~logitech );
	GeneralHID.startEventLoop;

	// Get the capabilities of the device in a readable format:
      // a.caps;
	// See if data is coming in:
	~device.debug_( true );
	// Stop it:
	~device.debug_( false );

	// You can also create a generic gui to see what is coming in:
	//a.makeGui;

	~test = Synth("rotate", [\out, e.index]);
	~el = Synth("elevate", [\out, e.index + 1]);
	~dist = Synth("distate", [\out, e.index + 2]);
	// ~test.set(\gate, 0);
	// ~test.set(\gate, 1);
	// ~sound = Synth.new("mysound");

	~device.slots[1].at( 290 ).action_( { |v|
		if (v.value == 1) {
			~dist.set(\gate, 1);
			"dist".postln;
		} {
			~dist.set(\gate, 0);
	}} );
	~device.slots[1].at( 288 ).action_( { |v|
		if (v.value == 1) {
			"dist".postln;
		} {}} );
	~device.slots[3].at( 1 ).action_( { |v|
		if(v.value > 0.6) {~el.set(\gate, 1); ~el.set(\orient, -1); "floor".postln;} {
			if(v.value < 0.4) {~el.set(\gate, 1);~el.set(\orient, 1); "top".postln;}
			{~el.set(\gate, 0);"center".postln;}
	}});
	~device.slots[3].at( 0 ).action_( { |v|
		if(v.value > 0.6) {~test.set(\gate, 1); ~test.set(\orient, 1); "right".postln;} {
			if(v.value < 0.4) {~test.set(\gate, 1);~test.set(\orient, -1); "left".postln;}
			{~test.set(\gate, 0);"center".postln;}
	}});

};
)

