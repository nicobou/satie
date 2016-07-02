// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
// ~name = \sndFile;
// ~function = { | bufnum = 0, loop = 0, startPos=0, rate = 1, t_trig=0 |
// 	// DiskIn.ar(1, bufnum, loop = loop);
// 	PlayBuf.ar(1, bufnum, rate, t_trig, startPos, loop);
// };
//


// Play a sample buffer using global synchronization index

~name = \syncSamp1;


// args:   midiPitch60 == no transposition,  force & incidence  between -1 and 1
// pitch disabled




if ( ~syncBus == nil,
	{
		"\syncSamp1: setting up global Phasor".inform;
		~syncBus = Bus.audio(s,1); // this will be our sync bus
});

// set up needed sync signal generator and bus


SynthDef(\globalPhasor, {| t_trig = 0 |
	Out.ar(~syncBus, Phasor.ar(t_trig, 1, 0, (SampleRate.ir * 6000.0)));         // wraps around once every 100 hours
}).add;


// set up VBAP
~tmpSpkConfig = VBAPSpeakerArray.new(2, [0, 60, 120, 180, -120, -60]); // 6 channel ring
~tmpVbuf= ~tmpSpkConfig.loadToBuffer;

/* NOTE: this generator must be instantiated for the audiosource defined in this file to work
copy the code below into the project file   ".main" to be evaluated
		if (~phasorSync == nil,
			{
		"creating phasorSync generator".inform;
			~phasorSync = Synth.before(s,\globalPhasor);
		});
*/

~function ={| buf = 0, sampAzi = 0, sampSpr = 0, indexSecs = 0, t_trig = 0, loop = 1, durSecs = 4, fadeSecs = 2, trimDB=0,  note = #[60, 1, 1]   |

	var mixdown;
	var mixScalers;
	var vbapMix;
	var bufDur = BufFrames.kr(buf) /  BufSampleRate.kr(buf);
	var framesPerSecond = BufFrames.kr(buf) / bufDur;

	var freq = note[0].midicps;   // not used
	var amp = abs (note[1]);
	var incidence = abs (note[2]);
	var rate =  freq/261.6255653006;  // not used
	var lpassFq,hpassFq;
	var ampScaled;

	var offset =  indexSecs * SampleRate.ir; // convert seconds to samps

	var phasor = In.ar(~syncBus, 1) + offset;  // get the global phasor for sample reading index
	var outSig = BufRd.ar(6, buf, phasor);


	var envShape = Env.new([0, 1, 1, 0], [0.01, durSecs, fadeSecs ],[0, 0, 0]);

	var envelope = EnvGen.ar(envShape, t_trig) ;

	incidence = incidence.clip(0,1);
	amp = amp.clip(-1,1);
	ampScaled = abs(amp) **(0.7);

	lpassFq = 100 + (incidence**(0.7) * 21900) ;  // used to cut highs when incidence is low

	hpassFq = 800 - ( ampScaled * 799) ;  // used to pass lows when force is high



	mixScalers = VBAP.kr(~tmpSpkConfig.numSpeakers, 1.0, ~tmpVbuf.bufnum, sampAzi, 0, sampSpr);
	vbapMix = mixScalers * outSig;


	mixdown =  Mix.ar(vbapMix);

	mixdown = trimDB.dbamp * mixdown * envelope;

	mixdown = BLowPass.ar(  (ampScaled * mixdown),  Lag.kr(lpassFq, 0.02) , 5);

	mixdown = BHiPass.ar( mixdown ,  Lag.kr(hpassFq, 0.02) , 5);
};











/*  TEST
SynthDef(~name, ~function ).add;



~v1 =Synth.new(~name,  [ \i_doneAction, 0, \randTrigMaxMs , 500, \durMs, 100, \attackBend, 3 , \attackMS, 10]);

~v1 =Synth.new(~name);
~v1.set(\t_trig, 1);


*/




