

    o = Server.local.options;
		o.device = "MADIface USB (23635751)";
		o.memSize = 2**18;
		o.numOutputBusChannels = 32;

		//o.blockSize = 2048;
		o.dump;

Server.supernova;

Server.default;

		s.boot;
         s.quit;


s.makeGui;

s.meter;


// ~spkTest = VBAPSpeakerArray.new(3, [
// 	[0, 90],
// 	[15, 45], [75, 45], [135, 45], [-165, 45], [-105, 45], [-45, 45],
// 	[0, 22.5], [30, 22.5], [60, 22.5], [90, 22.5], [120, 22.5], [150, 22.5], [180, 22.5], [-150, 22.5], [-120, 22.5], [-90, 22.5], [-60, 22.5], [-30, 22.5],
// 	[0, 0], [30, 0], [60, 0], [90, 0], [120, 0], [150, 0], [180, 0], [-150, 0], [-120, 0], [-90, 0], [-60, 0], [-30, 0],
// ]);


// ~spkTest =  VBAPSpeakerArray.new(3, [
// 	[0, 90],
// 	[-7.5, 55], [52.5, 55], [112.5, 55], [172.5, 55], [-127.5, 55], [-67.5, 55],
// 	[7.5, 20], [37.5, 20], [67.5, 20], [97.5, 20], [127.5, 20], [157.5, 20], [-172.5, 20], [-142.5, 20], [-112.5, 20], [-82.5, 20], [-52.5, 20], [-22.5, 20],
// [7.5, -15], [37.5, -15], [67.5, -15], [97.5, -15], [127.5, -15], [157.5, -15], [-172.5, -15], [-142.5, -15], [-112.5, -15], [-82.5, -15], [-52.5, -15], [-22.5, -15] ]);


// LABODOME
~spkTest = VBAPSpeakerArray.new(3, [
[0, 90],
[0, 60], [45, 60], [90, 60], [135, 60], [180, 60], [-135, 60], [-90, 60], [-45, 60],
[0, 20], [45, 20], [90, 20], [135, 20], [180, 20], [-135, 20], [-90, 20], [-45, 20],
[0, -15], [45, -15], [90, -15], [135, -15], [-135, -10], [-90, -10], [-45, -10],]);



~spkTest.speakers[1].dump;
~vbufTest = Buffer.loadCollection(s, ~spkTest.getSetsAndMatrices);

SynthDef(\vbapTest,  { |freq = 440,  aziDeg = 0, eleDeg = 0, spread = 1, aziOffset=0|
	Out.ar(  0,
		VBAP.ar(~spkTest.numSpeakers,
			SinOsc.ar(freq),
			~vbufTest.bufnum,
			VarLag.kr(aziDeg+aziOffset, 0.2),
			VarLag.kr(eleDeg,0.2),
			VarLag.kr(spread, 0.2) ))}).add;



SynthDef(\vbapTest2,  { |freq = 550,  aziDeg = 0, eleDeg = 0, spread = 1, aziOffset=0|
	var gainVec;

	gainVec = VBAP.kr(~spkTest.numSpeakers,
			1.0,
			~vbufTest.bufnum,
			aziDeg,
			eleDeg,
			spread );
	Out.ar(0, Lag.kr(gainVec, 0.06) * SinOsc.ar(freq))}).add;



~myGroup = ParGroup.new();

~myGroup.freeAll;



1.do(   { arg item;
	var offset = rand(360);
	Synth.new(\vbapTest, [\freq, (333+offset), \aziOffset, offset], ~myGroup );
	//syn.set(\freq, 220+offset);
});


1.do(   { arg item;
	var offset = rand(360);
	Synth.new(\vbapTest2, [\freq, (200+offset), \aziOffset, offset], ~myGroup );
	//syn.set(\freq, 220+offset);
});




w=Window.new("sheefa", Rect(30, 30, 400, 100)).front;
w.view.decorator=FlowLayout(w.view.bounds);
w.view.decorator.gap=8@2;


h = EZSlider(w, 380@20, "azi", ControlSpec(-180, 180, \lin, 1, 0));
h.action_({ |ez| ( ~myGroup.set(\aziDeg, (ez.value)))});

i = EZSlider(w, 380@20, "ele", ControlSpec(-90, 90, \lin, 1, 0));
i.action_({ |ez| ( ~myGroup.set(\eleDeg, (ez.value)))});

j = EZSlider(w, 380@20, "spread", ControlSpec(0, 100, \lin, 0.1, 1));
j.action_({ |ez| ( ~myGroup.set(\spread, (ez.value)))});





~myGroup.set(\aziDeg, 39);


~myGroup.set(\eleDeg, 90);    // this will  display energy only in channel 1  (zenith)


~myGroup.set(\eleDeg, 45);
{[15,75,135,-165,-105,-45 ].do({|ang| y.set(\aziDeg, ang); 1.wait; }) }.fork;   // energy only in channels 1 - 7  (dome top ring)


~myGroup.set(\eleDeg, 22.5);
{[0, 30, 60, 90, 120, 150, 180, -150, -120, -90, -60, -30 ].do({|ang| y.set(\aziDeg, ang); 1.wait; }) }.fork;   // energy only in channels 8 - 19 (dome middle ring)


~myGroup.set(\eleDeg, 0);
{[0, 30, 60, 90, 120, 150, 180, -150, -120, -90, -60, -30 ].do({|ang| y.set(\aziDeg, ang); 1.wait; }) }.fork;   // energy only in channels 20-31 (dome bottom ring)






