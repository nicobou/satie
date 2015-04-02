~name = \zbell1;

~function = {   arg outbus, t_trig = 0, note = #[60, 1, 0.5], decay = 0.3, lag = 0.01, i_doneAction = 0 ;
	var freq = note[0].midicps;
	var amp = note[1];
	var pos = note[2] * 0.5; // unitVal * positionRange


	var sig, input, first, freqscale, decayscale, mallet, sing;
	freqscale = freq / 2434;
	freqscale = Lag3.kr(freqscale, lag);
	decayscale = Lag3.kr(decay, lag);

	mallet = LPF.ar(Trig.ar(t_trig, SampleDur.ir)!2, 10000 * freqscale);
	input = mallet * amp;


	sig = DynKlank.ar(`[
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
			20 * freqscale.pow(0.2),
			20 * freqscale.pow(0.2),
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
	sig;
}



/*
a = ~function.play;

a.set(\t_trig, 1, \note,  #[64, 0.1]);
a.set(\t_trig, 1, \decayscale, 0.07);

a.free;


w =Window.new("sheefa", Rect(30, 30, 400, 100)).front;
w.view.decorator=FlowLayout(w.view.bounds);
w.view.decorator.gap=8@2;


g = EZSlider(w, 380@20, "pitch ", ControlSpec(40, 110, \lin, 1, 60));
g.action_({ |ez| ( a.set(\note, [ ez.value, 1, 0.5 ] );a.set(\t_trig, 1);)});


h = EZSlider(w, 380@20, "decay", ControlSpec(0.01, 10,  \exp, 0.01, 0.5));
h.action_({ |ez| ( a.set(\decay, (ez.value)))});





/*i = EZSlider(w, 380@20, "pos", ControlSpec(0.0, 1, \lin, 0.01, 0.14));
i.action_({ |ez| ( a.set(\pos, (ez.value));a.set(\t_gate, 1))});

j = EZSlider(w, 380@20, "c1", ControlSpec(0.0, 10, \lin, 0.01, 1));
j.action_({ |ez| ( a.set(\c1, (ez.value)))});


k = EZSlider(w, 380@20, "c3", ControlSpec(0.1, 22050, \exp,1, 22050));
k.action_({ |ez| ( a.set(\c3, (ez.value)))});

l = EZSlider(w, 380@20, "fb", ControlSpec(0.0, 100, \lin, 0.1, 20));
l.action_({ |ez| ( a.set(\fb, (ez.value)))});*/
*/
