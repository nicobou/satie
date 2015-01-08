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

(  // load files
~afiles = Pseq([
		Buffer.read(s, "./wav/1.wav"),
		Buffer.read(s, "./wav/2.wav"),
		Buffer.read(s, "./wav/3.wav"),
		Buffer.read(s, "./wav/4.wav"),
		Buffer.read(s, "./wav/5.wav"),
		Buffer.read(s, "./wav/6.wav"),
		Buffer.read(s, "./wav/7.wav"),
		Buffer.read(s, "./wav/8.wav"),
		Buffer.read(s, "./wav/9.wav"),
		Buffer.read(s, "./wav/10.wav"),
		Buffer.read(s, "./wav/11.wav"),
		Buffer.read(s, "./wav/12.wav"),
		Buffer.read(s, "./wav/13.wav"),
		Buffer.read(s, "./wav/14.wav"),
		Buffer.read(s, "./wav/15.wav"),
		Buffer.read(s, "./wav/16.wav"),
		Buffer.read(s, "./wav/17.wav"),
		Buffer.read(s, "./wav/18.wav"),
		Buffer.read(s, "./wav/19.wav"),
		Buffer.read(s, "./wav/20.wav"),
		Buffer.read(s, "./wav/21.wav"),
		Buffer.read(s, "./wav/22.wav"),
		Buffer.read(s, "./wav/23.wav"),
		Buffer.read(s, "./wav/24.wav"),
		Buffer.read(s, "./wav/25.wav"),
		Buffer.read(s, "./wav/26.wav"),
		Buffer.read(s, "./wav/27.wav"),
		Buffer.read(s, "./wav/28.wav"),
		Buffer.read(s, "./wav/29.wav"),
		Buffer.read(s, "./wav/30.wav"),
		Buffer.read(s, "./wav/31.wav"),
		Buffer.read(s, "./wav/32.wav"),
		Buffer.read(s, "./wav/33.wav"),
		Buffer.read(s, "./wav/34.wav"),
		Buffer.read(s, "./wav/35.wav"),
		Buffer.read(s, "./wav/36.wav"),
		Buffer.read(s, "./wav/37.wav"),
		Buffer.read(s, "./wav/38.wav"),
		Buffer.read(s, "./wav/39.wav"),
		Buffer.read(s, "./wav/40.wav"),
		Buffer.read(s, "./wav/41.wav"),
		Buffer.read(s, "./wav/42.wav"),
		Buffer.read(s, "./wav/43.wav"),
		Buffer.read(s, "./wav/44.wav"),
		Buffer.read(s, "./wav/45.wav"),
		Buffer.read(s, "./wav/46.wav"),
		Buffer.read(s, "./wav/47.wav"),
		Buffer.read(s, "./wav/48.wav"),
		Buffer.read(s, "./wav/49.wav"),
		Buffer.read(s, "./wav/50.wav"),
		Buffer.read(s, "./wav/51.wav"),
		Buffer.read(s, "./wav/52.wav"),
		Buffer.read(s, "./wav/53.wav"),
		Buffer.read(s, "./wav/54.wav"),
		Buffer.read(s, "./wav/55.wav"),
		Buffer.read(s, "./wav/56.wav"),
		Buffer.read(s, "./wav/57.wav"),
		Buffer.read(s, "./wav/58.wav"),
		Buffer.read(s, "./wav/59.wav"),
		Buffer.read(s, "./wav/60.wav"),
		Buffer.read(s, "./wav/61.wav"),
		Buffer.read(s, "./wav/62.wav"),
		Buffer.read(s, "./wav/63.wav"),
		Buffer.read(s, "./wav/64.wav"),
		Buffer.read(s, "./wav/65.wav"),
		Buffer.read(s, "./wav/66.wav"),
		Buffer.read(s, "./wav/67.wav"),
		Buffer.read(s, "./wav/68.wav"),
		Buffer.read(s, "./wav/69.wav"),
		Buffer.read(s, "./wav/70.wav"),
		Buffer.read(s, "./wav/71.wav"),
		Buffer.read(s, "./wav/72.wav"),
		Buffer.read(s, "./wav/73.wav"),
		Buffer.read(s, "./wav/74.wav"),
		Buffer.read(s, "./wav/75.wav"),
		Buffer.read(s, "./wav/76.wav"),
		Buffer.read(s, "./wav/77.wav"),
		Buffer.read(s, "./wav/78.wav"),
		Buffer.read(s, "./wav/79.wav"),
		Buffer.read(s, "./wav/80.wav"),
		Buffer.read(s, "./wav/81.wav"),
		Buffer.read(s, "./wav/82.wav"),
		Buffer.read(s, "./wav/83.wav"),
		Buffer.read(s, "./wav/84.wav"),
		Buffer.read(s, "./wav/85.wav"),
		Buffer.read(s, "./wav/86.wav"),
		Buffer.read(s, "./wav/87.wav"),
		Buffer.read(s, "./wav/88.wav"),
		Buffer.read(s, "./wav/89.wav"),
		Buffer.read(s, "./wav/90.wav"),
		Buffer.read(s, "./wav/91.wav"),
		Buffer.read(s, "./wav/92.wav"),
		Buffer.read(s, "./wav/93.wav"),
		Buffer.read(s, "./wav/94.wav"),
		Buffer.read(s, "./wav/95.wav"),
		Buffer.read(s, "./wav/96.wav"),
		Buffer.read(s, "./wav/97.wav"),
		Buffer.read(s, "./wav/98.wav"),
		Buffer.read(s, "./wav/99.wav"),
		Buffer.read(s, "./wav/100.wav"),
		Buffer.read(s, "./wav/101.wav"),
		Buffer.read(s, "./wav/102.wav"),
		Buffer.read(s, "./wav/103.wav"),
		Buffer.read(s, "./wav/104.wav"),
		Buffer.read(s, "./wav/105.wav"),
		Buffer.read(s, "./wav/106.wav"),
		Buffer.read(s, "./wav/107.wav"),
		Buffer.read(s, "./wav/108.wav"),
		Buffer.read(s, "./wav/109.wav"),
		Buffer.read(s, "./wav/110.wav"),
		Buffer.read(s, "./wav/111.wav"),
		Buffer.read(s, "./wav/112.wav"),
		Buffer.read(s, "./wav/113.wav"),
		Buffer.read(s, "./wav/114.wav"),
		Buffer.read(s, "./wav/115.wav"),
		Buffer.read(s, "./wav/116.wav"),
		Buffer.read(s, "./wav/117.wav"),
		Buffer.read(s, "./wav/118.wav"),
		Buffer.read(s, "./wav/119.wav"),
		Buffer.read(s, "./wav/120.wav"),
		Buffer.read(s, "./wav/121.wav"),
		Buffer.read(s, "./wav/122.wav"),
		Buffer.read(s, "./wav/123.wav"),
		Buffer.read(s, "./wav/124.wav"),
		Buffer.read(s, "./wav/125.wav"),
		Buffer.read(s, "./wav/126.wav"),
		Buffer.read(s, "./wav/127.wav"),
		Buffer.read(s, "./wav/128.wav"),
		Buffer.read(s, "./wav/129.wav"),
		],
		repeats: inf).asStream;
)

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
	~spk = VBAPSpeakerArray.new(3, [
		[0,0], [23,0], [46,0], [69,0], [92,0], [115,0], [138,0], [161,0], [184,0], [207,0], [230,0], [253,0], [276,0], [299,0], [322,0], [345,0], [0,10], [23,10], [46,10], [69,10], [92,10], [115,10], [138,10], [161,10], [184,10], [207,10], [230,10], [253,10], [276,10], [299,10], [322,10], [345,10], [0,20], [23,20], [46,20], [69,20], [92,20], [115,20], [138,20], [161,20], [184,20], [207,20], [230,20], [253,20], [276,20], [299,20], [322,20], [345,20], [0,30], [23,30], [46,30], [69,30], [92,30], [115,30], [138,30]
	]);

	// dome
	/*~spk = VBAPSpeakerArray.new(3, [
		[0, 90],
		[15, 45], [75, 45], [135, 45], [-165, 45], [-105, 45], [-45, 45],
		[0, 22.5], [30, 22.5], [60, 22.5], [90, 22.5], [120, 22.5], [150, 22.5], [180, 22.5], [-150, 22.5], [-120, 22.5], [-90, 22.5], [-60, 22.5], [-30, 22.5],
		[0, 0], [30, 0], [60, 0], [90, 0], [120, 0], [150, 0], [180, 0], [-150, 0], [-120, 0], [-90, 0], [-60, 0], [-30, 0],
	]);*/

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

	d = Bus.control(s, 5); // azi, ele, spr, distance, spacing ration between oiseau
	d.set(0, 0, 0, 10, 1);

	s.sync;

	SynthDef(\oiseau, {
		| outbus = 0, buffer = 0, spr = 0, azibus = 0, elebus = 0, sprbus = 0, distancebus = 0, srbus = 0 |
		~rand = NRand(lo: -1.0, hi: 1.0, n:1);
		// ~rand.value.postln;
		Out.ar(outbus,
			0.06 * (1.0 - ((
				In.kr(distancebus) * (1.0 + (In.kr(srbus) * ~rand))
			).clip(0.0, 100.0)/100.0)).squared * // volume
			VBAP.ar(
				numChans: ~spk.numSpeakers,
				in: DelayC.ar(  // Doppler
					//BufRd.ar(1, buffer, Line.ar(start:0, end: BufFrames.ir(buffer), dur: BufDur.ir(buffer), doneAction: 2)),
					// 3 * PinkNoise.ar() * EnvGen.kr(Env.perc, doneAction: 2),
					// SinOsc.ar(Rand(200,600)),
					(PinkNoise.ar() + FSinOsc.ar(Rand(200,1000))) * EnvGen.kr(Env.sine(dur:1), doneAction: 2),
					maxdelay,
					maxdelay * (
						In.kr(distancebus) * (1.0 + (In.kr(srbus) * ~rand))
				).clip(0.0, 100.0) / 100.0),
				bufnum: ~vbuf.bufnum,
				azimuth: (
					In.kr(azibus) + (In.kr(srbus) * (180.0 * ~rand))
				).clip(-180.0, 180.0),
				elevation: (
					In.kr(elebus) + (In.kr(srbus) * (10.0 * ~rand))
					).clip(0.0, 90.0),
				spread: In.kr(sprbus)));
	}).add;


	SynthDef(\oiseauStatic, {
		| outbus = 0, buffer = 0, spr = 0.0 |
		var azi = Rand(-180.0, 180.0),
		ele = Rand(0.0, 60.0),
		distance = Rand(0.0, 100.0);
		Out.ar(outbus,
			0.02 * (1.0 - (distance.clip(0.0, 100.0)/100.0).squared ) * // volume
			VBAP.ar(
				numChans: ~spk.numSpeakers,
				in: DelayC.ar(  // Doppler
					BufRd.ar(1, buffer, Line.ar(start:0, end: BufFrames.ir(buffer), dur: BufDur.ir(buffer), doneAction: 2)),
					//PinkNoise.ar(),
					//SinOsc.ar(Rand(200,600)),
					//FSinOsc.ar(Rand(200,1000)) * EnvGen.kr(Env.perc(releaseTime: 0.5)/*sine(dur:1)*/, doneAction: 2),
					maxdelay,
					maxdelay * (distance.clip(0.0, 100.0) / 100.0)),
				bufnum: ~vbuf.bufnum,
				azimuth: azi.clip(-180.0, 180.0),
				elevation: ele.clip(0.0, 90.0),
				spread: spr));
	}).add;


	SynthDef(\bcpOiseauStatic, {
		| outbus = 0, buffer = 0, spr = 0.0 |
		var azi = Rand(-180.0, 180.0),
		ele = Rand(0.0, 60.0),
		distance = Rand(0.0, 100.0);
		Out.ar(outbus,
			0.06 * (1.0 - (distance.clip(0.0, 100.0)/100.0).squared ) * // volume
			VBAP.ar(
				numChans: ~spk.numSpeakers,
				in: DelayC.ar(  // Doppler
					//BufRd.ar(1, buffer, Line.ar(start:0, end: BufFrames.ir(buffer), dur: BufDur.ir(buffer), doneAction: 2)),
					//PinkNoise.ar(),
					//SinOsc.ar(Rand(200,600)),
					SinOsc.ar(Rand(200,1000)) * EnvGen.kr(Env.perc(releaseTime: 0.5)/*sine(dur:1)*/, doneAction: 2),
					maxdelay,
					maxdelay * (distance.clip(0.0, 100.0) / 100.0)),
				bufnum: ~vbuf.bufnum,
				azimuth: azi.clip(-180.0, 180.0),
				elevation: ele.clip(0.0, 90.0),
				spread: spr));
	}).add;

	s.sync;

	// CLUSTER
	r = Routine({
		loop {
			Synth.head(~pargroup, \oiseau, [
				buffer: ~afiles.next,
				azibus: d.index,
				elebus: d.index + 1,
				sprbus: d.index + 2,
				distancebus: d.index + 3,
				srbus: d.index + 4
			]);
			//0.015.wait;
			1.yield;
	}});
	r.play;

	// STATIC RANDOM POSITIONS
	~static_oiseau = Routine({
		loop {
			Synth.head(~pargroup, \oiseauStatic, [
				buffer: ~afiles.next
			]);
			//0.015.wait;
			1.yield;
	}});
	// ~static_oiseau.play;

	~bcp_static_oiseau = Routine({
		loop {
			Synth.head(~pargroup, \bcpOiseauStatic, [
				buffer: ~afiles.next
			]);
			//0.015.wait;
			0.1.yield;
	}});
	//~bcp_static_oiseau.play;

	// Synth.head(~pargroup, \oiseau, [
	// 	buffer: ~afiles.next,
	// 	azibus: d.index,
	// 	elebus: d.index + 1,
	// 	sprbus: d.index + 2,
	// 	distancebus: d.index + 3,
	// srbus: d.index + 4]);

	// azi & ele with mouse
	// { Out.kr(d.index, [ MouseX.kr(-180.0, 180.0), MouseY.kr(1.0, 90.0)]);}.play;


	// auto move
	/*{ Out.kr(d.index, [
		LFSaw.kr(freq: 0.15, mul: 180.0),            // azi
		FSinOsc.kr(freq: 0.1, mul: 30.0) + 30.0,    // ele
		0,                                          // spr
		SinOsc.kr(freq:0.5, mul: 25.0, add: 25.0),      // distance
		MouseX.kr(0, 1.0) // space ration between oiseaux
	]);}.play;
*/

	OSCFunc.newMatching(
		{|msg, time, addr, recvPort|
			// msg[1].postln;
		d.setAt(0, msg[1].asFloat);},
		'/azi',
		recvPort: 3030);
	OSCFunc.newMatching(
		{|msg, time, addr, recvPort|
			// msg[1].postln;
			d.setAt(1, msg[1].asFloat);},
		'/ele',
		recvPort: 3030);
	// // OSC spread
	// OSCFunc.newMatching(
	// 	{|msg, time, addr, recvPort|
	// 		// msg[1].postln;
	// 	d.setAt(2, msg[1].asFloat);},
	// 	'/spr',
	// recvPort: 3030);
	// OSC volume
	 OSCFunc.newMatching(
	 	{ |msg, time, addr, recvPort|
			// msg[1].postln;
			d.setAt(3, msg[1].asFloat);
		},
	 	'/dist',  // from 0 to 100
	 recvPort: 3030);
};
)

// ({
// 	PrintVal.kr(MouseX.kr(0,200));
// 	Out.ar(0, 1 * SinOsc.ar(MouseX.kr(0,200)))
// }.play)

//s.reboot
// for i in `seq 180`; do oscsend localhost 3030 /azi i $i; sleep 1; done
// m = NetAddr("127.0.0.1", 3030); // loopback
// m.sendMsg("/azi", "180");
// m.sendMsg("/azi", "120");
// m.sendMsg("/azi", "90");
// m.sendMsg("/dist", 100.rand.asString);
// m.sendMsg("/dist", "0");
// m.sendMsg("/dist", "50");
// {q.set(\delay, Rand(0, 0.2));};
//
// {Array.fill(1000, {|i| (1000 - i)/10.0; }).do({ |item, i| [item, i].postln; m.sendMsg("/dist", item); 0.01.wait; })}.fork;
// {Array.fill(360, {|i| 180 - i; }).do({ |item, i| [item, i].postln; m.sendMsg("/azi", item); 0.02.wait; })}.fork;
//
// {Out.kr(d, FSinOsc.kr(2,0,0.2));}.fork;