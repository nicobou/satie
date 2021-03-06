// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

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

// ------------- SOURCE/ array of LISTENER -------------------------------------------------------
// for a source having n listeners, this goes like this:
//     /--> listener 1
// src ---> ...
//     \--> listener n

(
~makeSrcList = {| name, srcfunc, destFunArray, busShiftArray = #[0] |
    SynthDef(name,
		{| gate = 1, vol = 1, delay = 0, azi = 0, ele = 0|
			var in, env;
			in = SynthDef.wrap(srcfunc);
			env = Linen.kr(gate, 2, 1, 2, 2); // fade in the effect
			destFunArray.do{ arg item, i;
				var out = SynthDef.wrap(item, prependArgs: [in, vol, delay, azi, ele]);
				Out.ar(busShiftArray.wrapAt(i), env * out);
			}
		}).add;};
)

(
~makeSrcList.value(\NSinNSin,
	srcfunc: {|srcfreq = 4| Dust.ar(srcfreq)},
	destFunArray: [
		{|in = 0, vol, delay, azi, ele, room = 1| vol * FreeVerb.ar(in, room)},
		{|in = 0, vol, delay, azi, ele, room2 = 0| vol * FreeVerb.ar(in, room2)}],
	busShiftArray: [0,1]);
)

y = Synth.tail(s, \NSinNSin);
y.release;
y.set(\gate, 0);
y.set(\srcfreq, 8);
y.set(\room, 0);
y.set(\room, 1);
y.set(\room2, 0);
y.set(\room2, 20);
y.set(\vol, 1);

// ----------------------- FUNCTION ARRAY ---------------------------------------------------------
(
a = [
    { \done_one.postln },
    { \done_two.postln },
    { \done_three.postln }
];
)
~truc = { arg tab; tab.do{ arg item, i; item.value;}};
~truc.value(a);

(
~makeTruc = { arg name, tab;
	SynthDef(name,
		{ arg i_bus = 0;
			tab.do({arg item; item.value;});
			Out.ar(i_bus, SinOsc.ar());
		}
).add;};
)

~makeTruc.value(\truc, a);


// ----------------
(
SynthDef(\multiOut,	{
	Out.ar(0, Dust.ar(2));
	Out.ar(1, Dust.ar(20));
}).add;
)

Synth(\multiOut);
































