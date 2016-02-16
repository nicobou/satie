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


~name = \particule1;

~function = {| t_trig = 0, decaySecs = 1, force = 0.75, incidence = 0.75,  pitch = 60 |
		var outsig, z,ampScaler, hfqRolloffAmp, outGainBias;
		var freqscale, excitationSig, attackSecs,attackAmp;

		var klank_freq_array, klank_amp_array, klank_ring_array, attackSig, lpFq, lpFqOffset;
		var pitchScaler = (pitch.midicps / 60.midicps);

		var invIncidence = 1  -   Clip.kr(incidence, 0,1)  ;

		outGainBias = pitchScaler**0.75;  // correct for lower register boost

		hfqRolloffAmp = (1  -  -30.dbamp) * invIncidence;  // higher freq.  rolloff attenuation factor for incidence

		attackSecs = SampleDur.ir + (0.01 * force);
		attackAmp =  0.01 + force**1.6;  // sounds better

		hfqRolloffAmp = (1  -  -60.dbamp) * invIncidence  ;  // higher freq.  rolloff attenuation factor for incidence

		attackSig = EnvGen.ar(Env.perc(attackSecs, 0.0001, attackAmp, -9 ), t_trig) ;
		// attackSig = Decay.ar(   EnvGen.ar(Env.perc(attackSecs, 0.0001, attackAmp, -9 ), t_trig) ,  decaySecs, ClipNoise.ar(0.01) ) ;   //NOT USED-- ADDS  REVERBERaTION



		klank_freq_array = [1383, 2831, 3252, 3446, 4547, 4600, 4832, 5863, 6813, 8683, 11196];
		klank_freq_array.size.do { |i|
			klank_freq_array[i] = Clip.kr( pitchScaler * klank_freq_array[i] * TRand.kr(0.95, 1.05,  t_trig), 5, SampleRate.ir*0.5);
		};

		// freqscale = (pitchScaler * klank_freq_array[0] ) / 2434;
		//-
		// freqscale = freqscale * SampleRate.ir*0.5;
		//
		// lpFq = Clip.kr( ( freqscale ), 200,  SampleRate.ir*0.5 );

		//	attackSig = LPF.ar(Trig.ar(t_trig, SampleDur.ir )!2, lpFq ) * force * 0.1;
		//attackSig =  force * 0.1 * Trig.ar(t_trig, SampleDur.ir )!2 ;




		klank_amp_array = [0.02,0.2,0.01, 0.2,0.04, 0.2,0.4, 0.05,0.5, 0.2, 0.4];
		z = 1 / klank_amp_array.size;

		klank_amp_array.size.do { |i|
			ampScaler = 1 - ( hfqRolloffAmp * ((i*z)**0.01) );   // exponend to extend  attenuation

			klank_amp_array[i] = ampScaler * klank_amp_array[i] * TRand.kr(0.7, 1.3,  t_trig);
		};

		//klank_amp_array.rand(11, 0.01, 0.5);

		klank_ring_array= [ 1, 0.75, 0.5, 0.4, 0.5, 0.25, 0.15, 0.125, 0.2, 0.25, 0.2, 0.3];        //  * freqscale.reciprocal.pow(0.5);   NOT USED YET

		klank_ring_array.size.do { |i|
			klank_ring_array[i] = klank_ring_array[i] * TRand.kr(0.8, 1.2,  t_trig);
		};

    outsig = Klank.ar(
        `[klank_freq_array, klank_amp_array, klank_ring_array],     // specs
         attackSig,   // input
			//delayscale: decaySecs
			1,
			0,  // no pitch offset
			decaySecs   // global delay
		);

		outsig = outsig * outGainBias;


	 //DetectSilence.ar(outsig, doneAction: 2);
	 //Out.ar(0, outsig);  //enable this for debugging
	// SendTrig.kr(Impulse.kr(1), 0, pitchScaler);  // enable this for debugging

};


/*
SynthDef(~name, ~function ).add;

(
x = Synth(~name, [
	\force, 0.9,
	\incidence, 1,
	\decaySecs, 1,
	\pitch,60,
	// \freqs, {12000.0.linrand+800}.dup(12),
           \amps, {0.05.rrand(2)}.dup(12),
	            \rings, {0.01.rrand(1.5)}.dup(12) ] );

)




(
x =  ~scbr.makeKamikaze(\whatever, \particule1, \default, [
					\aziDeg, 10, \eleDeg, 10, \gainDB, 0,\delayMs, 0, \lpHz , 20000, \hpHz, 10,
	\decaySecs, 1, \pitch, 55, \force, 1, \incidence, 1, \t_trig, 1]);



x =  ~scbr.makeKamikaze(\whatever, \particule1, \default);
)
// \t_trig,  1



x.set(\t_trig, 1.0);


(
c=20;
t= Task({ {
	c.do( { arg item;
		var index = item/c ;

		Synth(~name, [
			\force, index,
			\incidence, index,
			\decaySecs, 0.5,
			//\pitch, 50,
			\pitch, (20 +  60*index),
		] );
		0.1.wait;
	});
	0.wait;
}.loop });

t.start;
)
t.stop;




TempoClock.default.sched(1,
	{ Synth("zp1", [
            \freqs, {12000.0.linrand+80}.dup(12),
           \amps, {0.05.rrand(2)}.dup(12),
		\rings, {0.01.rrand(0.5)}.dup(12) ] ); nil });



// open up GUIs for monitoring
if (~plotTree == nil,  { ~plotTree=s.plotTree;});
if (~makeGui == nil,  { ~plotTree=s.makeGui;});
if (~meter == nil,  { ~plotTree=s.meter;});

*/