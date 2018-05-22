Server.local.options.numOutputBusChannels = 3;
s.boot;
s.meter;
s.makeGui;

~acts = Dictionary.new();
~idx = 0;
(
SynthDef(\signal,
	{
		|out = 0, val = 0.0|
		var sig;
		sig = K2A.ar(val);
		sig.scope;
		Out.ar(out,sig);
	}).add;
)

(
3.do({|item|
	var name, synth;
	name = "sig_" ++ item;
	synth = Synth(\signal);
	synth.set(\out, item);
	~acts.add(name.asSymbol -> synth);
});
)
/*
(
~acts.keysValuesDo({|key, synth|
	synth.set(\out, ~idx);
	~idx = ~idx + 1;
});
)
*/
(
w = Window.new.front;

w.view.decorator = FlowLayout(w.view.bounds);

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