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
	~maxdelay = 0.02;
	~pargroup = ParGroup.new;

	// dome
	// ~spk = VBAPSpeakerArray.new(3, [
	// 	[0, 90],
	// 	[15, 45], [75, 45], [135, 45], [-165, 45], [-105, 45], [-45, 45],
	// 	[0, 22.5], [30, 22.5], [60, 22.5], [90, 22.5], [120, 22.5], [150, 22.5], [180, 22.5], [-150, 22.5], [-120, 22.5], [-90, 22.5], [-60, 22.5], [-30, 22.5],
	// 	[0, 0], [30, 0], [60, 0], [90, 0], [120, 0], [150, 0], [180, 0], [-150, 0], [-120, 0], [-90, 0], [-60, 0], [-30, 0],
	// ]);

	~spk = VBAPSpeakerArray.new(3, [
		[0, 0], [60, 0], [120, 0], [180, 0], [-120, 0], [-60, 0], [-30, 0],
		[0, 90],

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

	f = Bus.control(s, 1); // move
	f.set(0);

	t = Tuning.just;
	~scale = Scale.pelog(t);
	~period = 0.2;
	~duration = 3;
	//~scale = Scale.major(t);
	~pf = Pfunc({~scale.ratios.choose},{\reset.postln }).asStream;
	~streamdel = Pfunc({~period}, {\reset.postln}).asStream;
	~tone = 55;
	s.sync;

	SynthDef(\oiseaubouge, { | outbus = 0, freq = 200, moveb = 0, dur = 3 |
		var locdist, locazi, locele;
		locdist = In.kr(moveb)
		* FSinOsc.kr(freq: Rand(0.2, 1), mul:0.3, add: 0.7);
		locazi = In.kr(moveb)
		* FSinOsc.kr(freq: Rand(0.01, 0.2), mul: ([1, -1].choose * 180), add: 180);
		locele = In.kr(moveb)
		* FSinOsc.kr(freq: Rand(0.01, 0.2), mul: ([1, -1].choose * 45), add: 45);
		Out.ar(outbus,
			VBAP.ar(numChans: ~spk.numSpeakers,
				in: DelayC.ar(
					(1 - locdist).squared
					* SinOsc.ar(freq)
					* EnvGen.kr(Env.sine(dur: dur), doneAction: 2),
					~maxdelay,
					~maxdelay * locdist
				),
				bufnum: ~vbuf.bufnum,
				azimuth: (locazi + Rand(0, 360)) % 360,
				elevation: (locele + Rand(0, 90)) % 90 ,
				spread: 0)
		);
	}).add;

	SynthDef(\move, { arg out = 0, gate = 0;
		Out.kr(out,
			Linen.kr(gate, 1, 1, 1));
	}).add;

	s.sync;

	r = Routine({
		loop {
			Synth.head(~pargroup, \oiseaubouge, [
				\freq, [~tone, ~tone*2, ~tone*4, ~tone*8].choose * ~pf.next,
				\moveb, f.index,
				\dur, ~duration
			]);
			~streamdel.next.wait;
			//0.1.yield;
	}});
	r.play;

	~move = Synth(\move, [\out, f.index]);
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


	~device.slots[1].at( 290 ).action_( { |v|
		if (v.value == 1) {
			~move.set(\gate, 1);
			"dist".postln;
		} {
			~move.set(\gate, 0);
	}} );
	~device.slots[1].at( 288 ).action_( { |v|
		if (v.value == 1) {
			~tone = rrand(50, 71);
			// ~scale = Scale.major(t);
			~tone.postln;
		} {}} );
	~device.slots[1].at( 293 ).action_( { |v|
		if (v.value == 1) {
			~period = (~period/2.0).clip(0.005, 1);
			("nextdel" + ~period).postln;
		} {
	}} );
	~device.slots[1].at( 292 ).action_( { |v|
		if (v.value == 1) {
			~period = (~period * 2.0).clip(0.005, 1);
			("nextdel" + ~period).postln;
		} {
	}} );
	~device.slots[1].at( 295 ).action_( { |v|
		if (v.value == 1) {
			~duration = (~duration - 0.1).clip(0.06, 3);
			("duration " + ~duration).postln;
		} {
	}} );
	~device.slots[1].at( 294 ).action_( { |v|
		if (v.value == 1) {
			~duration = (~duration + 0.1).clip(0.06, 3);
			("duration" + ~duration).postln;
		} {
	}} );



	// ~device.slots[3].at( 1 ).action_( { |v|
	// 	if(v.value > 0.6) {~el.set(\gate, 1); ~el.set(\orient, -1); "floor".postln;} {
	// 		if(v.value < 0.4) {~el.set(\gate, 1);~el.set(\orient, 1); "top".postln;}
	// 		{~el.set(\gate, 0);"center".postln;}
	// }});
	// ~device.slots[3].at( 0 ).action_( { |v|
	// 	if(v.value > 0.6) {~test.set(\gate, 1); ~test.set(\orient, 1); "right".postln;} {
	// 		if(v.value < 0.4) {~test.set(\gate, 1);~test.set(\orient, -1); "left".postln;}
	// 		{~test.set(\gate, 0);"center".postln;}
	// }});

};
)

