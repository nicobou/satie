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
//o= nil;

//enable this for debugging
//if (o == nil, {o = OSCresponderNode(s.addr, '/tr', { |time, resp, msg| msg.postln }).add; });


~name = \zparticle1;
~channelLayout = \mono;

~function = {|outbus, t_trig = 0, randTrigMaxMs = 300, attackMs = 10, durMs = 100, centerPitch = 70, pitchRange = 30, attackBend = 3, glissRange = 24,  i_doneAction = 0|
	var durSecs = durMs*0.001;
	var attackSecs = attackMs * 0.001;
	var lowPitch = centerPitch - (pitchRange * 0.5);


	var randTrigMaxSecs = randTrigMaxMs*0.001;
	var sig;


	var delTrigSecs = TRand.kr( 0,  randTrigMaxSecs,  t_trig);

	var delTrig = TDelay.kr(t_trig, delTrigSecs);

	var envFn =  Env([0, 0, 1], [0, durSecs], [ attackBend ] );   // first two values doubled to reset to initial value;  last value for curvature

	var randPitch =  TRand.kr(lowPitch, (lowPitch + pitchRange), delTrig );

	var pitchGliss  = EnvGen.ar(  envFn   , delTrig);


	var envelope =   EnvGen.ar(Env.perc(attackSecs, releaseTime: durSecs),  delTrig );

	sig = envelope * SinOsc.ar( (randPitch + (glissRange*pitchGliss)).midicps, mul: 0.2);


	//Out.ar(0, sig);  //enable this for debugging
	//SendTrig.kr(delTrig, 0, delTrigSecs );  //  in synthdef
};

//SynthDef(~name, ~function ).add;



/*
// to test



~v1 =Synth.new(~name,  [ \i_doneAction, 0, \randTrigMaxMs , 500, \durMs, 100, \attackBend, 3 , \attackMS, 10]);
~v1.set(\t_trig, 1);


*/





/*   DEBUGGING

s.makeGui;
s.meter


Env.new([0, 1, 0.9, 0], [0.1, 0.5, 1],[4, 0, -3]).plot;


Env.new([0, 1, 0], [0.1,  1],[0,0,0]).plot;

Env([0, 1], [0.1 ],[5]);

Env([0, 1], [0.1 ],[5]).test.plot;

{ EnvGen.kr( Env.new( [ 0, 1], [ 0.1 ],[ 5 ]) , TDelay.kr(1, 0.2) )}.play;


Env.perc(0.1, 0.01, 1, 4).test.plot;

*/

/*

 {10.do( { arg item;
	var fq = (item / 19)**5;

~v1 =Synth.new(~name,  [ \i_doneAction, 0, \randTrigMaxMs , 1500  ]);

~v1.set(\t_trig, 1);

0.wait;})}.fork






w=Window.new("spatOSCexamplePreset voicing", Rect(500, 30, 400, 140)).front;
w.view.decorator=FlowLayout(w.view.bounds);
w.view.decorator.gap=8@2;

g = EZSlider(w, 380@20, "pitch ", ControlSpec(40, 110, \lin, 1, 60));
g.action_({ |ez| ( ~v1.set(\note, [ ez.value, i.value, j.value ] ))});

i = EZSlider(w, 380@20, "amp", ControlSpec(0, 1, \lin, 0.01, 0.5));
i.action_({ |ez| (  ~v1.set(\note, [ g.value, ez.value, j.value ] ))});

j = EZSlider(w, 380@20, "incidence", ControlSpec(0, 1, \lin, 0.01, 0.1));
j.action_({ |ez| (  ~v1.set(\note, [ g.value, i.value, ez.value ] ))});

k = EZSlider(w, 380@20, "decayscale", ControlSpec(0.05, 1, \lin, 0.01, 0.1));
k.action_({ |ez| (  ~v1.set(\decayscale, (ez.value)))});

~startButton = Button(w, 75 @ 20);
~startButton.states = [
    ["trigger", Color.red, Color.white(0.7)],
    ["trigger", Color.red, Color.white(0.7)]
];
~startButton.action = {|view|
	"Triggering".postln;
	~v1.set(\t_trig, 1);

	// Synth.new("ztest1",  [ \i_doneAction, 2, \decayscale , k.value, \note,  [g.value,  i.value, j.value]     ]);
};

*/