s.reboot;

(
SynthDef(\doClean,
	{ arg autoFreeFlag=1, amp=0.1, gate=1, pos = 0.14, c1 = 1, c3=20, fb = 2, note = #[60,1];
		var env,inp,son;
		var freq = note[0].midicps;
		env = Env.new([0,1, 1, 0],[0.001,0.006, 0.0005],[5,-5, -8]);
		inp = amp * LFClipNoise.ar(2000) * EnvGen.ar(env, gate);
		son = DWGPluckedStiff.ar(freq, amp, gate,pos,c1,c3,inp, fb);
		DetectSilence.ar(son, 0.001, doneAction:2);
		Out.ar(0, son);   // make sure this is last, so the sound is returned
}).add;

SynthDef(\doNotClean,
	{ arg amp=0.1, gate = 1, pos = 0.14, c1 = 1, c3=20, fb = 2, note = #[60,1];
		var env,inp,son;
		var freq = note[0].midicps;
		env = Env.perc();
		inp = amp * LFClipNoise.ar(2000) * EnvGen.ar(env, gate);
		son = DWGPluckedStiff.ar(freq, amp,1 ,pos,c1,c3,inp, inf, fb);
		Out.ar(0, son);   // make sure this is last, so the sound is returned
}).add;
)


~wos = Synth.tail(s, \doNotClean);
~wos.set(\gate, -1);
~wos.set(\gate, 1);

