//  compare attack transient (risetime: 0.0001)   of synth below when run WITH and WITHOUT SuperNova enabled
// --- note that ATTACK is seriously softened  when running under supernova
//  my guess:   VBAP does not initialize itself for the first sample, as it does when running on the normal server

//Server.quitAll;

(                    // evaluate this block FIRST

Server.supernova;    // comment this out to run without supernova --- you may have to quit SC and relaunch when changing from one to the other
// Server.scsynth;

o = Server.local.options;   // default set up options
o.blockSize = 2048;
o.numOutputBusChannels = 2;
o.dump;

s.waitForBoot {
	s.sync;
	s.scope;
};
)


(                   // evaluate this block LAST
x = Synth(\sheefa, [
	\force, 0.4,
	\incidence, 1,
	\decayMs, 1,
	\pitch,47,
	\t_trig, 1,
	\bufferCount, 1   // delaying the impulse by a buffer preserves the attack when using supernova
] );
)

(                      // evaluate this block SECOND
~spk24 = VBAPSpeakerArray.new(3, [
[0, 90],
[0, 60], [45, 60], [90, 60], [135, 60], [180, 60], [-135, 60], [-90, 60], [-45, 60],
[0, 20], [45, 20], [90, 20], [135, 20], [180, 20], [-135, 20], [-90, 20], [-45, 20],
[0, -15], [45, -15], [90, -15], [135, -15], [-135, -10], [-90, -10], [-45, -10],]);

~vbuf24 = Buffer.loadCollection(s, ~spk24.getSetsAndMatrices);


SynthDef(\sheefa, {| t_trig = 0, decayMs = 1, force = 0.75, incidence = 0.75,  pitch = 60, bufferCount = 0 |
	var outsig, z,ampScaler, hfqRolloffAmp, outGainBias;
	var freqscale, excitationSig, attackSecs,attackAmp, panWeights;

	var klank_freq_array, klank_amp_array, klank_ring_array, attackSig, lpFq, lpFqOffset;
	var pitchScaler = (pitch.midicps / 60.midicps);

	var invIncidence = 1  -   Clip.kr(incidence, 0,1)  ;

     var delayTime = ControlDur.ir * bufferCount;

	outGainBias = pitchScaler**0.75;  // correct for lower register boost

	hfqRolloffAmp = (1  -  -30.dbamp) * invIncidence;  // higher freq.  rolloff attenuation factor for incidence

	attackSecs = SampleDur.ir + (0.01 * force);
	attackAmp =  0.01 + force**1.6;  // sounds better

	hfqRolloffAmp = (1  -  -60.dbamp) * invIncidence  ;  // higher freq.  rolloff attenuation factor for incidence

	attackSig = EnvGen.ar(Env.perc(attackSecs, 0.0001, attackAmp, -9 ), t_trig) ;

	klank_freq_array = [1383, 2831, 3252, 3446, 4547, 4600, 4832, 5863, 6813, 8683, 11196];
	klank_freq_array.size.do { |i|
		klank_freq_array[i] = Clip.kr( pitchScaler * klank_freq_array[i] * TRand.kr(0.95, 1.05,  t_trig), 5, SampleRate.ir*0.5);
	};

	klank_amp_array = [0.02,0.2,0.01, 0.2,0.04, 0.2,0.4, 0.05,0.5, 0.2, 0.4];
	z = 1 / klank_amp_array.size;

	klank_amp_array.size.do { |i|
		ampScaler = 1 - ( hfqRolloffAmp * ((i*z)**0.01) );   // exponend to extend  attenuation

		klank_amp_array[i] = ampScaler * klank_amp_array[i] * TRand.kr(0.7, 1.3,  t_trig);
	};

	klank_ring_array= [ 1, 0.75, 0.5, 0.4, 0.5, 0.25, 0.15, 0.125, 0.2, 0.25, 0.2, 0.3];        //  * freqscale.reciprocal.pow(0.5);   NOT USED YET

	klank_ring_array.size.do { |i|
		klank_ring_array[i] = klank_ring_array[i] * TRand.kr(0.8, 1.2,  t_trig);
	};

	outsig = Klank.ar(
		`[klank_freq_array, klank_amp_array, klank_ring_array],     // specs
		attackSig,   // input
		1,
		0,  // no pitch offset
		decayMs   // global delay
	);

	outsig = outsig * outGainBias;

	outsig =  LPF.ar(DelayC.ar(
		outsig,
		maxdelaytime: 0.5,
		delaytime: delayTime  ),   22050);

	outsig = BHiPass.ar(outsig, 0);

	// calculate panning weights
	panWeights = VBAP.kr(numChans: ~spk24.numSpeakers,
		in: 1,
		bufnum: ~vbuf24.bufnum,
		azimuth: 0,
		elevation: 0,
		spread: 0 );

	SendTrig.kr(Impulse.kr(0), 0, panWeights   );  //  Enable for debugging

	Out.ar(0, Mix.new(
		outsig * Ramp.kr(panWeights, 0)));    // apply panning weights

	DetectSilence.ar(outsig, doneAction: 2);

}).add;

)






//z = OSCresponderNode(s.addr, '/tr', { |time, resp, msg| msg.postln }).add;
//z.remove;  // when done, you need to clean up the OSCresponderNode

