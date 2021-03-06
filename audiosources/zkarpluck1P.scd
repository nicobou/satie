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

/* debugging
 OSCFunc.trace(true);    // show OSC RX
 OSCFunc.trace(false);

o = OSCresponderNode(s.addr, '/tr', { |time, resp, msg| msg.postln }).add;

o.remove;  // when done, you need to clean up the OSCresponderNode

SendTrig.kr(Impulse.kr(1), 0, freq);  //  in synthdef

*/


// DESIGNED FOR RESONANT, CONTINUOUSLY UPATED PARTICLES (NON KAMIKAZI)

/*
freq
amp 0 - 1
gate  0, 1
pos	 0 - 1;  pluck position
c1	??  Inverse of DC decay time.
c3	  ??  Hight frequency loss factor.
inp	  SIGNAL
release	   time in seconds.
fB	 ??  Inharmonicity factor.
*/
//freq: 440, amp: 0.5, gate: 1, pos: 0.14, c1: 1, c3: 30, inp: 0, release: 0.1)

~name = \zkarpluck1P;

~function = {  | t_trig=0, c1 = 1, c3=20, fb = 2, randTrigMaxMs = 10000 , note = #[60, 1, 0.5]  |   // note: pitch force incidence
	var env,inp,son;
	var freq;
	var amp;
	var incidence;   // apprently this does not work


	var pos;
	var hfqLoss;
	var idecay;
	var lpassFq;
	// particle use

	var randTrigMaxSecs = (randTrigMaxMs*0.001).clip(0,10);
	var delTrigSecs = TRand.kr( 0,  randTrigMaxSecs,  t_trig);
	var t_trigDel = TDelay.kr(t_trig, delTrigSecs);
    var dnote = [0,0,0];

	dnote = DelayN.kr(note, 10, delTrigSecs);    // delay note-related params by the same amount as trigger

	freq = dnote[0].midicps;
	amp = dnote[1];
	incidence = abs (dnote[2]);   // apprently this does not work


	pos = note[2] * 0.5; // unitVal * positionRange
	hfqLoss= c3 + (1-amp)*c3*2;  // add more dampening when amplitude gets low
	idecay = c1 +  (1-amp)*c1;  //  reduce decay when amplitude gets low
	lpassFq = 100 + (incidence**(0.7) * 21900) ;  // used to cut highs when incidence is low


	//incidence = incidence.clip(0,1);




	//SendTrig.kr(Impulse.kr(1), 0, amp);
	env = Env.perc(0.005,0.01,1,0);
	// the filter blows up for lower Q values (like 1),  some experimenting with smoothing the lpassFq is still needed
	inp =   BLowPass.ar(      (amp * LFClipNoise.ar(2000) * EnvGen.ar( env, t_trigDel  ))     , Lag.kr(lpassFq, 0.02) , 5) ;


	//SendTrig.kr( EnvGen.kr( env, t_trigDel  ) , 0, note[0] );  //  in synthdef


	// note:  "gate" arg fixed to constant of 1, to keep plugin alive, "relase" arg not used:
    son = DWGPluckedStiff.ar(freq, 10, 1 ,pos,idecay,hfqLoss,inp, 1 , fb);
	// Out.ar(100, son);

	// suggestion:  add amplitude-based filtering to the final output
	son;   // make sure this is last, so the sound is returned
	 };

/*
//  for test of "prop" and "event" messages
{
	a=~function.play;
    s.sync;
    a.set(\amp, 1);
a.set(\randTrigMaxMs, 4000);

a.set(\t_trig, 1 );
a.set(\note, [61,1,1]);



//	t = Task({ { a.set(\t_trig, 1); 1.wait; 	a=~function.play;  s.sync; }.loop });
	t = Task({ { a.set(\t_trig, 1); 0.2.wait; }.loop });
	t.start;
}.fork;

a.set(\c1, 30);
a.set(\c3, 50);

*/

/*
//PLAY it.
(
a = Scale.new(
    #[0, 1, 3, 5, 7, 8, 10],
    12,
    Tuning.new([0, 0.75, 2, 3.5, 4, 5, 6, 7, 8, 9, 10, 11]),
    "Custom"
);

Pbind(
    \instrument, \zkarpluck1,
    \scale ,a,
    \delta , Pseq([1,0.5,0.5,0.5,0.5,0.5,0.5,1,0.5,0.5,1,1]*0.25,inf),
    \dur , 2,
    \degree, Pseq([1,8,8,8,8,8,8,-6,Prand([9,10,11],1),1,7,8]-8, inf),
    \amp , Pwhite(0.2,0.8),
    \c3 , Pseq([Pseq([1400],24),Pseq([300],24)],inf),
    //\pan , Pwhite(-1,1),
).play;
)


w=Window.new("sheefa", Rect(30, 30, 400, 200)).front;
w.view.decorator=FlowLayout(w.view.bounds);
w.view.decorator.gap=8@2;


g = EZSlider(w, 380@20, "pitch ", ControlSpec(40, 110, \lin, 1, 60));
g.action_({ |ez| ( a.set(\note, [ ez.value, 1, 0.5 ] );a.set(\t_trig, 1);)});


h = EZSlider(w, 380@20, "amp", ControlSpec(0, 1, \lin, 0.01, 0.5));
h.action_({ |ez| ( a.set(\amp, (ez.value)))});

/*
i = EZSlider(w, 380@20, "pos", ControlSpec(0.0, 1, \lin, 0.01, 0.14));
i.action_({ |ez| ( a.set(\pos, (ez.value));a.set(\t_trig, 1))});
*/

j = EZSlider(w, 380@20, "c1", ControlSpec(0.0, 10, \lin, 0.01, 1));
j.action_({ |ez| ( a.set(\c1, (ez.value)))});


k = EZSlider(w, 380@20, "c3", ControlSpec(0.1, 22050, \exp,1, 22050));
k.action_({ |ez| ( a.set(\c3, (ez.value)))});

l = EZSlider(w, 380@20, "fb", ControlSpec(0.0, 100, \lin, 0.1, 20));
l.action_({ |ez| ( a.set(\fb, (ez.value)))});


*/

/*


a=~function.play;
a=Synth.new(\sheefa);
a=~synths[\sheefa];
a=~synths[\mySound];

a.set(\outLevel, 0 );
a.set(\noteOn, #[60, 1]);   // accessed via the "event" message
a.set(\t_t_trig, 1);




o = OSCresponderNode(s.addr, '/tr', { |time, resp, msg| msg.postln }).add;
o.remove;  // when done, you need to clean up the OSCresponderNode

Env.perc(0, 100.reciprocal, 10, -24).test.plot;

oscsend localhost 18032 /spatosc/core ss createSource sheefa
oscsend localhost 18032 /spatosc/core sss connect sheefa myListener
oscsend localhost 18032 /spatosc/core/source/sheefa/uri s plugin://zkarpluck1
oscsend localhost 18032 "/spatosc/core/connection/sheefa->myListener/update" fffff 0 0 2 0 1000

(
// a synthdef browswer
SynthDescLib.global.read;
SynthDescLib.global.browse;
)


//Define DWGPlucked synthdef
(
SynthDef(\help_dwgplucked, { |out=0, freq=440, amp=0.5, gate=1, c3=20, pan=0|
    var env = Env.new([0,1, 1, 0],[0.001,0.006, 0.0005],[5,-5, -8]);
    var inp = amp * LFClipNoise.ar(2000) * EnvGen.ar(env,gate);
    var son = DWGPlucked.ar(freq, amp, gate,0.1,1,c3,inp);
    DetectSilence.ar(son, 0.001, doneAction:2);
    Out.ar(out, Pan2.ar(son * 0.1, pan));
}).add;
)

//Define DWGPlucked2 synthdef
(
SynthDef(\help_dwgplucked2, { |out=0, freq=440, amp=0.5, gate=1, c3=20, pan=0|
    var env = Env.new([0,1, 1, 0],[0.001,0.006, 0.0005],[5,-5, -8]);
    var inp = amp * LFClipNoise.ar(2000) * EnvGen.ar(env,gate);
    var son = DWGPlucked2.ar(freq, amp, gate,0.1,1,c3,inp);
    DetectSilence.ar(son, 0.001, doneAction:2);
    Out.ar(out, Pan2.ar(son * 0.1, pan));
}).add;
)


//PLAY it.
(
z = Scale.new(
    #[0, 1, 3, 5, 7, 8, 10],
    12,
    Tuning.new([0, 0.75, 2, 3.5, 4, 5, 6, 7, 8, 9, 10, 11]),
    "Custom"
);

Pbind(
    \instrument, \sheefaSynth,
    \scale ,z,
    \delta , Pseq([1,0.5,0.5,0.5,0.5,0.5,0.5,1,0.5,0.5,1,1]*0.25,inf),
    \dur , 2,
    \degree, Pseq([1,8,8,8,8,8,8,-6,Prand([9,10,11],1),1,7,8]-8, inf),
    \amp , Pwhite(0.2,0.8),
    \c3 , Pseq([Pseq([1400],24),Pseq([300],24)],inf),
    \pan , Pwhite(-1,1),
).play;
)

*/


