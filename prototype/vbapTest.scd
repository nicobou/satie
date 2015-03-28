

    o = Server.local.options;
		o.device = "MADIface USB (23635751)";
		o.memSize = 2**18;
		o.numOutputBusChannels = 32;

		//o.blockSize = 2048;
		o.dump;


		s.boot;


// s.makeGui;



 ~spkTest = VBAPSpeakerArray.new(3, [
 	[0, 90],
 	[15, 45], [75, 45], [135, 45], [-165, 45], [-105, 45], [-45, 45],
 	[0, 22.5], [30, 22.5], [60, 22.5], [90, 22.5], [120, 22.5], [150, 22.5], [180, 22.5], [-150, 22.5], [-120, 22.5], [-90, 22.5], [-60, 22.5], [-30, 22.5],
 	[0, 0], [30, 0], [60, 0], [90, 0], [120, 0], [150, 0], [180, 0], [-150, 0], [-120, 0], [-90, 0], [-60, 0], [-30, 0],
 ]);

~spkTest.speakers[1].dump;
~vbufTest = Buffer.loadCollection(s, ~spkTest.getSetsAndMatrices);




y = { |aziDeg = 0, eleDeg = 0, spread = 0|
VBAP.ar(~spkTest.numSpeakers, PinkNoise.ar(1), ~vbufTest.bufnum, aziDeg, eleDeg, spread).scope;
}.play;



y.set(\eleDeg, 90);    // this will  display energy only in channel 1  (zenith)


y.set(\eleDeg, 45);
{[15,75,135,-165,-105,-45 ].do({|ang| y.set(\aziDeg, ang); 1.wait; }) }.fork;   // energy only in channels 1 - 7  (dome top ring)


y.set(\eleDeg, 22.5);
{[0, 30, 60, 90, 120, 150, 180, -150, -120, -90, -60, -30 ].do({|ang| y.set(\aziDeg, ang); 1.wait; }) }.fork;   // energy only in channels 8 - 19 (dome middle ring)


y.set(\eleDeg, 0);
{[0, 30, 60, 90, 120, 150, 180, -150, -120, -90, -60, -30 ].do({|ang| y.set(\aziDeg, ang); 1.wait; }) }.fork;   // energy only in channels 20-31 (dome bottom ring)







w=Window.new("sheefa", Rect(30, 30, 400, 100)).front;
w.view.decorator=FlowLayout(w.view.bounds);
w.view.decorator.gap=8@2;


h = EZSlider(w, 380@20, "azi", ControlSpec(-180, 180, \lin, 1, 0));
h.action_({ |ez| ( y.set(\aziDeg, (ez.value)))});

i = EZSlider(w, 380@20, "ele", ControlSpec(-90, 90, \lin, 1, 0));
i.action_({ |ez| ( y.set(\eleDeg, (ez.value)))});

j = EZSlider(w, 380@20, "spread", ControlSpec(0, 100, \lin, 0.1, 1));
j.action_({ |ez| ( y.set(\spread, (ez.value)))});
