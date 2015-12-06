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

// code is based on the synthdef:  \prayer_bell, by "wondersluyter" (http://sccode.org/wondersluyter)
// canabilised by Zack Settel
// params:
// t_trig;   0:1
// delayscale: 0:n
// i_doneAction: 0=stay alive, 1 = pause when done, 2 = kill when done...
// note:  midi-Pitch, amplitude (unit factor),  incidence (0:1)




~name = \pbell1;

~function = { |outbus, t_trig = 0, decayscale = 0.2, i_doneAction = 0, note = #[60, 0, 0]  |

	var sig, input, first, freqscale,  transient, bellFq, halfSR, lpFq, fqScaler,fqRange, fqLowClip, fqHighClip,fqOffset, incidenceScaler,ampScaler;

	var freq = note[0].midicps;
	var amp = note[1];

	var incidence = note[2].clip(0,1);

	incidence = abs(incidence);
	fqLowClip = 100;   // lowest good sounding note
	fqHighClip = 5000;   // highest good sounding note

	freqscale = Clip.kr( freq, fqLowClip, fqHighClip)  / 2434;

	incidenceScaler = incidence**5;   // lower part of the range is juciest -- don't mess with this now, since the other values are "tuned" around this

	halfSR = 0.5 * SampleRate.ir;

	bellFq = Clip.kr(freq, fqLowClip, fqHighClip );   // juicy notes are in this range

	fqScaler =  ( (bellFq-fqLowClip) / (fqHighClip-fqLowClip))**4;    //  lower freequencies are offset less

	ampScaler = 0.1 + (1 - ( incidence**0.3));   // this mapping is closely linked to the incidenceScaler mapping

	ampScaler = amp * Clip.kr(ampScaler, 0.2, 1.1);   // fine tuning

	fqOffset =  (0.2 * bellFq) + ( fqScaler *  0.8 * bellFq ) ;  // use the note's register to calculate the lowPass fq value.


	// SendTrig.kr(Impulse.kr(1), 0, ampScaler);

	fqRange =   (0.5*SampleRate.ir) - fqOffset;

	lpFq =  fqOffset + (incidenceScaler * fqRange);

	transient = LPF.ar(Trig.ar(t_trig, SampleDur.ir)!2, 10000 * Ramp.kr(freqscale, 0.01));

	input = LPF.ar(transient,  Ramp.kr(lpFq, 0.01)   );    // "mallet"


  sig = ampScaler * DynKlank.ar(`[
    [
      (first = LFNoise1.kr(0.5).range(2424, 2444)) + Line.kr(20, 0, 0.5),
      first + LFNoise1.kr(0.5).range(1,3),
      LFNoise1.kr(1.5).range(5435, 5440) - Line.kr(35, 0, 1),
      LFNoise1.kr(1.5).range(5480, 5485) - Line.kr(10, 0, 0.5),
      LFNoise1.kr(2).range(8435, 8445) + Line.kr(15, 0, 0.05),
      LFNoise1.kr(2).range(8665, 8670),
      LFNoise1.kr(2).range(8704, 8709),
      LFNoise1.kr(2).range(8807, 8817),
      LFNoise1.kr(2).range(9570, 9607),
      LFNoise1.kr(2).range(10567, 10572) - Line.kr(20, 0, 0.05),
      LFNoise1.kr(2).range(10627, 10636) + Line.kr(35, 0, 0.05),
      LFNoise1.kr(2).range(14689, 14697) - Line.kr(10, 0, 0.05)
    ],
    [
      LFNoise1.kr(1).range(-10, -5).dbamp,
      LFNoise1.kr(1).range(-20, -10).dbamp,
      LFNoise1.kr(1).range(-12, -6).dbamp,
      LFNoise1.kr(1).range(-12, -6).dbamp,
      -20.dbamp,
      -20.dbamp,
      -20.dbamp,
      -25.dbamp,
      -10.dbamp,
      -20.dbamp,
      -20.dbamp,
      -25.dbamp
    ],
    [
      10 * freqscale.pow(0.2),
      9 * freqscale.pow(0.2),
      5,
      5,
      0.6,
      0.5,
      0.3,
      0.25,
      0.4,
      0.5,
      0.4,
      0.6
    ] * freqscale.reciprocal.pow(0.5)
  ], input, freqscale, 0, decayscale);

DetectSilence.ar(sig, doneAction: i_doneAction);
  // Out.ar(outbus, sig);  enable this for debugging

	sig;

};

/*   DEBUGGING
SynthDef(\prayer_bell,  ~function  ).add;

~ballSet =Synth.new("prayer_bell",  [ \i_doneAction, 0, \decayscale , 0.7, \note,  [80,1, 0.5]     ]);
~ballSet.set(\i_doneAction, 0);
~ballSet.set(\decayscale, 0.8);
~ballSet.set(\incidence, 1);
~ballSet.set(\t_trig, 1);

 {20.do( { arg item;
	var fq = (item / 19)**5;
	var amp =  (item / 19) ;

	~ballSet=Synth.new("prayer_bell",  [\i_doneAction, 2,  \decayscale , 0.7, \note,  [100,1, (item/19)  ]     ]);
0.1.wait;})}.fork



w=Window.new("spatOSCexamplePreset voicing", Rect(500, 30, 400, 140)).front;
w.view.decorator=FlowLayout(w.view.bounds);
w.view.decorator.gap=8@2;

g = EZSlider(w, 380@20, "pitch ", ControlSpec(40, 110, \lin, 1, 60));
g.action_({ |ez| ( ~ballSet.set(\note, [ ez.value, i.value, j.value ] ))});

i = EZSlider(w, 380@20, "amp", ControlSpec(0, 1, \lin, 0.01, 0.5));
i.action_({ |ez| (  ~ballSet.set(\note, [ g.value, ez.value, j.value ] ))});

j = EZSlider(w, 380@20, "incidence", ControlSpec(0, 1, \lin, 0.01, 0.1));
j.action_({ |ez| (  ~ballSet.set(\note, [ g.value, i.value, ez.value ] ))});

k = EZSlider(w, 380@20, "decayscale", ControlSpec(0.05, 1, \lin, 0.01, 0.1));
k.action_({ |ez| (  ~ballSet.set(\decayscale, (ez.value)))});

~startButton = Button(w, 75 @ 20);
~startButton.states = [
    ["trigger", Color.red, Color.white(0.7)],
    ["trigger", Color.red, Color.white(0.7)]
];
~startButton.action = {|view|
	"Triggering".postln;
	~ballSet.set(\t_trig, 1);

	// Synth.new("prayer_bell",  [ \i_doneAction, 2, \decayscale , k.value, \note,  [g.value,  i.value, j.value]     ]);
};

*/