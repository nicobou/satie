// this is the new version!
(
s = Server.default;
s.boot;
)


(
SynthDef(\zglass, {

	|t_trig = 1.0, audioOutBus = 0|

	var major_hit_times, major_hit_deltas, major_hit_levels, major_hit_impulse_levels, major_hit_impulses;
	var major_hit_amp, major_hit_envGen, major_hit_out;
	var klank_freq_array, klank_out;
	var noise, noise_out;
	var additional_tinkles;
	var initial_impact_pitch_envGen, initial_impact_amp_envGen, initial_impact;
	var comb_out, output;

	var last_time;

	major_hit_times = [0.02, 0.1, 0.21, 0.28, 0.32, 0.48, 0.6, 0.69];
	major_hit_deltas = [];
	last_time = 0.0;
	major_hit_times.size.do { |i|
		major_hit_deltas = major_hit_deltas ++
			[
			SampleDur.ir,
			((major_hit_times[i] - last_time) * TRand.kr(0.4, 1.6, t_trig)) - SampleDur.ir
			];

		last_time = major_hit_times[i];
	};
	major_hit_levels = [1.0, 0.3, 0.7, 0.4, 0.65, 0.87, 0.27, 0.4];
	major_hit_levels.size.do { |i|

		major_hit_levels[i] = major_hit_levels[i] * TRand.kr(0.7, 1.0, t_trig);

	};
	major_hit_impulse_levels = [major_hit_levels, 0 ! major_hit_times.size].lace(major_hit_times.size * 2);
	major_hit_impulses = Duty.ar(
		Dseq(major_hit_deltas, 1), K2A.ar(t_trig), Dseq(major_hit_impulse_levels, 1)
		);
	major_hit_amp = Gate.ar(major_hit_impulses, major_hit_impulses);
	major_hit_envGen = EnvGen.ar(Env.perc(0.0, 0.03, 1, -9), major_hit_impulses) * major_hit_amp;
	major_hit_out = major_hit_envGen * WhiteNoise.ar * 0.6;
	major_hit_out = major_hit_out + major_hit_impulses;

	klank_freq_array = [1383, 2831, 3252, 3446, 4547, 4600, 4832, 5863, 6813, 8683, 11196];
	klank_freq_array.size.do { |i|

		klank_freq_array[i] = klank_freq_array[i] * TRand.kr(0.8, 1.2,  Impulse.kr(20));
	};
	klank_out = DynKlank.ar(`[klank_freq_array, nil, 0.2], major_hit_out * 0.05);
	klank_out = DelayC.ar(klank_out, 0.2, 0.009);



		output = (klank_out * 0.5);

	//output = (klank_out * 0.5) + (major_hit_out * 0.45);
	//output = (output * 0.86) + DelayC.ar(output, 0.2, 0.01);
	//output = output + (noise_out * 0.32) + (additional_tinkles * 0.044) + (initial_impact * 0.2);
   // output = output + (noise_out * 0.32) + (initial_impact * 0.2);

	comb_out = CombC.ar(output, 0.1, [0.028, 0.031], 0.52, 0.23);
	comb_out = LPF.ar(comb_out, 3000);
	comb_out = HPF.ar(comb_out, 110);
	//output = output + comb_out;
	Out.ar(audioOutBus, output);

}).send(s);

)
x = Synth(\zglass, [\audioOutBus, 0], s);
x.set(\t_trig, 1.0);

(
SynthDef("zp1",
	{| t_trig = 1, decaySecs = 1, attackMs = 0, attackAmp = 1, pitch = 60,  tone = 0.5 |
		var z;
		var freqscale, excitationSig, attackSecs;

		var klank_freq_array, klank_amp_array, klank_ring_array, attackSig, lpFq, lpFqOffset;
		var pitchScaler = (pitch.midicps / 60.midicps);


		attackSecs=attackMs*0.001;

		klank_freq_array = [1383, 2831, 3252, 3446, 4547, 4600, 4832, 5863, 6813, 8683, 11196];
		klank_freq_array.size.do { |i|

			klank_freq_array[i] = Clip.kr( pitchScaler * klank_freq_array[i] * TRand.kr(0.95, 1.05,  t_trig), 5, SampleRate.ir*0.5);
		};

		freqscale = (pitchScaler * klank_freq_array[0] ) / 2434;

		freqscale = freqscale * SampleRate.ir*0.5;

		lpFqOffset =  (tone - 0.5)*1* freqscale;

		lpFq = Clip.kr( ( freqscale   + lpFqOffset  ), 200,  SampleRate.ir*0.5 );


		SendTrig.kr(Impulse.kr(1), 0, lpFqOffset);  //  in synthdef


		attackSig = LPF.ar(Trig.ar(t_trig, SampleDur.ir )!2, lpFq ) * attackAmp * 0.1;

		//attackSig = EnvGen.ar(Env.perc(attackSecs, 0.01, attackAmp, -9), t_trig) ;

		// excitationSig = Decay.ar(attack , decayMS, ClipNoise.ar(0.01));   NOT USED-- ADDS  REVERBERaTION

		klank_amp_array = [0.02,0.2,0.01, 0.2,0.04, 0.2,0.4, 0.05,0.5, 0.2, 0.4];

		klank_amp_array.size.do { |i|
			klank_amp_array[i] = klank_amp_array[i] * TRand.kr(0.7, 1.3,  t_trig);
		};

		//klank_amp_array.rand(11, 0.01, 0.5);

		klank_ring_array= [
			// 20 * freqscale.pow(0.2),
			// 20 * freqscale.pow(0.2),
			1,
			0.75,
			0.5,
			0.4,
			0.5,
			0.25,
			0.15,
			0.125,
			0.2,
			0.25,
			0.2,
			0.3
		];        //  * freqscale.reciprocal.pow(0.5);   NOT USED YET

		klank_ring_array.size.do { |i|
			klank_ring_array[i] = klank_ring_array[i] * TRand.kr(0.8, 1.2,  t_trig);
		};

    z = Klank.ar(
        `[klank_freq_array, klank_amp_array, klank_ring_array],     // specs
         attackSig,   // input
			//delayscale: decaySecs
			1,
			0,  // no pitch offset
			decaySecs   // global delay
		);

	DetectSilence.ar(z, doneAction: 2);
    Out.ar(0, z*10);
}).add;
)

(
x = Synth("zp1", [
	\tone, 0,
	\attackAmp, 1,
	\decaySecs, 1,
	\pitch,80,
	// \freqs, {12000.0.linrand+800}.dup(12),
           \amps, {0.05.rrand(2)}.dup(12),
	            \rings, {0.01.rrand(1.5)}.dup(12) ] );

)
x.set(\t_trig, 1.0);


TempoClock.default.sched(1,
	{ Synth("zp1", [
            \freqs, {12000.0.linrand+80}.dup(12),
           \amps, {0.05.rrand(2)}.dup(12),
		\rings, {0.01.rrand(0.5)}.dup(12) ] ); nil });




x = OSCresponderNode(s.addr, '/tr', { |time, resp, msg| msg.postln }).add;
x.remove;  // when done, you need to clean up the OSCresponderNode

SendTrig.kr(Impulse.kr(1), 0, freq);  //  in synthdef








//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

// A tweaked version of the phonebell synthdef, to take an on/off from outside, and incorporate the striker
(
SynthDef(\dsaf_phonebell2, { |gate=1, freq=465, strength=1, decay=3, amp=1|
	var trigs, striker, son;
	trigs = Impulse.ar(14) * gate;
	striker = WhiteNoise.ar(EnvGen.ar(Env.perc(0.0000001, 0.01), trigs));
	son = Klank.ar(`[
		// frequency ratios
		[0.501, 1, 0.7,   2.002, 3, 9.6,   2.49, 11, 2.571,  3.05, 6.242, 12.49, 13, 16, 24],
		// amps
		[0.002,0.02,0.001, 0.008,0.02,0.004, 0.02,0.04,0.02, 0.005,0.05,0.05, 0.02, 0.03, 0.04],
		// ring times - "stutter" duplicates each entry threefold
		[1.2, 0.9, 0.25, 0.14, 0.07].stutter(3)
		]
	, striker, freq, 0, decay);
	Out.ar(0, Pan2.ar(son * amp));
}).store
)


// Here we start the phone bells constantly ringing. We put them in a group for convenience
~bellgroup = Group.new(s);
~bell1 = Synth(\dsaf_phonebell2, [\freq, 749], ~bellgroup);
~bell2 = Synth(\dsaf_phonebell2, [\freq, 439], ~bellgroup);

// Now we add the bakelite
y = Synth(\dsaf_phonecase1, [\mix, -0.65], target: ~bellgroup, addAction: \addAfter);

// OK, shush for now
~bellgroup.set(\gate, 0);

// Now let's turn them on and off in a telephone-like pattern.
// This could be done using a synth, but let's use a (client-side) pattern:
p = Pbind(\type, \set, \id, ~bellgroup.nodeID, \args, [\gate], \gate, Pseq([1,0], inf), \dur, 2).play
p.stop





//--------------------------

//Tibetan prayer bells by wondersluyter (wondersluyter) @ Code


(
SynthDef(\prayer_bell, { |outbus, t_trig = 1, sing_switch = 0, freq = 2434, amp = 0.5, decayscale = 1, lag = 0.01, i_doneAction = 0|
  var sig, input, first, freqscale, mallet, sing;
  freqscale = freq / 2434;
  freqscale = Lag3.kr(freqscale, lag);
  decayscale = Lag3.kr(decayscale, lag);

  mallet = LPF.ar(Trig.ar(t_trig, SampleDur.ir)!2, 10000 * freqscale);
 /* sing = LPF.ar(
    LPF.ar(
      {
        PinkNoise.ar * Integrator.kr(sing_switch * 0.001, 0.999).linexp(0, 1, 0.01, 1) * amp
      } ! 2,
      2434 * freqscale
    ) + Dust.ar(0.1), 10000 * freqscale
  ) * LFNoise1.kr(0.5).range(-45, -30).dbamp;
*/ // input = mallet + (sing_switch.clip(0, 1) * sing);
  input = mallet;


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
  Out.ar(outbus, sig);
}).add;
)


/*
~bell1 = Synth(\prayer_bell, [\freq, 2434]);
~bell2 = Synth(\prayer_bell, [\freq, 1436]);





~bell1.set(\t_trig, 1, \freq, 2000);
~bell1.set(\t_trig, 1, \decayscale, 0.07);

~bell2.set(\t_trig, 1, \freq, 2435);


~bell1.free;

*/

(
Pdef(\bell_1,
  Pmono(\prayer_bell,
    \dur, Pseq([8, 20], inf),
    \freq, Pseq([2500, 500], inf),
    \amp, 0.5,
    \lag, 0,
    \trig, Pseq([0.1], inf) * Pwhite(0.5, 1, inf) * Pwrand([0, 1], [1, 5].normalizeSum, inf),
    \sing_switch, Pseq((0!4) ++ (1!4), inf)
  )
);

Pdef(\bell_2,
  Pmono(\prayer_bell,
    \dur, Pwhite(8, 20, inf),
    \trig, Pwhite(0.05, 0.09),
    \sing_switch, Pwrand([0, 1], [5, 3].normalizeSum, inf),
    \freq, Prand((240, 360 .. 2000), inf),
    \amp, 0.5
  )
);

Pdef(\bell_3,
  Ppar([
    Pmono(\prayer_bell,
      \freq, 100,
      \dur, 1,
      \trig, 0,
      \sing_switch, Pwrand([0, 1], [10, 3].normalizeSum, inf),
      \amp, Pwhite(0.1, 0.5)
    ),
    Pmono(\prayer_bell,
      \freq, 200,
      \dur, 1,
      \trig, 0,
      \sing_switch, Pwrand([0, 1], [10, 3].normalizeSum, inf),
      \amp, Pwhite(0.1, 0.5)
    ),
    Pmono(\prayer_bell,
      \freq, 300,
      \dur, 1,
      \trig, 0,
      \sing_switch, Pwrand([0, 1], [10, 3].normalizeSum, inf),
      \amp, Pwhite(0.1, 0.5)
    )
  ])
);

Pdef(\bell_1).play;
Pdef(\bell_2).play;
Pdef(\bell_3).play;
)