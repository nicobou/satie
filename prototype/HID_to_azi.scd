s.boot;
s.scope;
s.makeGui;
~posbus = Bus.control(s, 2);

SynthDef

GeneralHID.buildDeviceList;
b = GeneralHID.findBy( 1133, 49690 );
a = GeneralHID.open( b );
GeneralHID.startEventLoop;

// Get the capabilities of the device in a readable format:
a.caps;
// there are different types of slots:
// button (type 1), has only on/off (1/0) states
// relative (type 2), counts up or down (scrollwheel for example)
// absolute (type 3), continuous value between 0 and 1
// See if data is coming in:
a.debug_( true );
// Stop it:
a.debug_( false );

// You can also create a generic gui to see what is coming in:
a.makeGui;

(
SynthDef("rotate",{ arg out=0, gate = 0, orient = 1;
	Out.kr(out,
		Linen.kr(gate, 0.5, 1, 0.5) * LFSaw.kr(freq: 0.5, mul: orient)
	)
}).add;
)

(
SynthDef(\mysound,{ |out = 0, pos = 0|
	Out.ar(out, PanAz.ar(6, 0.2 * Blip.ar(SinOsc.kr(freq: 0.5, mul: 10, add: 20)), In.kr(pos)));
}).add;
)

~test = Synth("rotate");
~test.set(\gate, 0);
~test.set(\gate, 1);
~sound = Synth.new("mysound");

(
a.slots[1].at( 290 ).action_( { "hello".postln; } );
a.slots[3].at( 1 ).action_( { |v| if(v.value > 0.6) {"floor".postln;} {
		if(v.value < 0.4) {"top".postln;}{"center".postln;}
	}});
a.slots[3].at( 0 ).action_( { |v|
	if(v.value > 0.6) {~test.set(\gate, 1); ~test.set(\orient, 1); "right".postln;} {
		if(v.value < 0.4) {~test.set(\gate, 1);~test.set(\orient, -1); "left".postln;}
		{~test.set(\gate, 0);"center".postln;}
}});
)


a.close;
GeneralHID.stopEventLoop