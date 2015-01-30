(
s.boot;
s.scope(8);
)

// ------------- SOURCE ONLY WRAPPER -------------------------------------------------------
(
// the basic wrapper
~makeSrc = {| name, func, lags |
    SynthDef(name,
		{| i_bus = 0, gate = 1, wet = 1|
			var in, env, lfo;
			in = SynthDef.wrap(func, lags);
			env = Linen.kr(gate, 2, 1, 2, 2); // fade in the effect
			XOut.ar(i_bus, wet * env, in);
		},
		[0, 0, 0.1]).add;};
)

~madefinition = {|srcfreq=100| SinOsc.ar(srcfreq)};

~makeSrc.value(\NSin, ~madefinition);

y = Synth.tail(s, \NSin);
y.release;
y.set(\gate, 0);
y.set(\srcfreq, 200);

// ------------- SOURCE/LISTENER WRAPPER -------------------------------------------------------
(
~makeSrcList = {| name, srcfunc, srclags, destfunc, destlags |
    SynthDef(name,
		{| i_bus = 0, gate = 1, wet = 1|
			var in, in2, env, lfo;
			in = SynthDef.wrap(srcfunc, srclags);
			env = Linen.kr(gate, 2, 1, 2, 2); // fade in the effect
			in2 = SynthDef.wrap(destfunc, destlags, [in]);
			XOut.ar(i_bus, wet * env, in2);
		},
		[0, 0, 0.1]).add;};
)

(
~makeSrcList.value(\NSinNSin,
	srcfunc: {|srcfreq=4| Dust.ar(srcfreq)},
	destfunc: {|in=0, room=1| FreeVerb.ar(in, room)});
)

y = Synth.tail(s, \NSinNSin);
y.release;
y.set(\gate, 0);
y.set(\srcfreq, 8);
y.set(\room, 0);
y.set(\room, 1);
