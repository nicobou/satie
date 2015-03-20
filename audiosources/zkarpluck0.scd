//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

// /spatosc/core/source/node/event play duration freq
// becomes:
// node.set.(noteON, [duration freq]);
// node.set.(t_noteOn 1);
// NOTE: there is no array length checking, so be careful

// o = OSCresponderNode(s.addr, '/tr', { |time, resp, msg| msg.postln }).add;
// o.remove;  // when done, you need to clean up the OSCresponderNode
// SendTrig.kr(Impulse.kr(4), 0, fb);


~name = \zkarpluck0;
~function = { arg outputDB = 0, lpFq = 12000, pWidth = 0,  combRTsec = 0.1, attkRiseMs = 0, attkDurMs = 0.1,  t_gate = 0, note = #[60,1];  // note gain

	var hpFq = 20;   // highpass for fb delay.
	var burstEnv,attkSig;
	var signalOut,attackEnv;
	var freq = note[0].midicps;

	var attkRiseSec = attkRiseMs*0.001;
	var attkSec = attkDurMs * 0.001, attkExp = pWidth * 24;  // constant curve shape exp maximum
	var attkAmp = note[1].clip(0,10);

	var combDelaySec = freq.reciprocal;
	var fb,fbdel, log001 = log(0.001); // OPTIMISE

		//SendTrig.kr(Impulse.kr(1), 0, freq);


	//combDelaySec.clip((SampleDur.ir * 4), 10000);

	// calculate fb as a function of ringtime
	fbdel = combRTsec.abs;
	fbdel.clip(0.01, 10);  // avoid zero
	fb = exp(log001 * combDelaySec / fbdel);

	//attackEnv = Env.perc(0, 0.001, 1, -24);
	//attackEnv = Env.perc(attkRiseSec, [attkSec, attkSec], 1, [ attkExp + rand2(attkExp/4), attkExp + rand2(attkExp/4)]);
	attackEnv = Env.perc(attkRiseSec, attkSec, 10, attkExp + rand2(attkExp/4));
	burstEnv = EnvGen.ar(attackEnv, t_gate);

	//attkSig = BLowPass.ar( PinkNoise.ar(burstEnv), lpFq, 1 );
 	//signalOut = CombL.ar(attkSig, 1, combDelaySec, combRTsec);

	attkSig = PinkNoise.ar(burstEnv);
    signalOut = LPF.ar(LocalIn.ar(1)+ attkSig,  lpFq.lag(0.3) ); //
    signalOut = DelayC.ar(signalOut, 0.2, combDelaySec - ControlRate.ir.reciprocal);  // correct for buffer size
	LocalOut.ar(fb*signalOut);

	SendTrig.kr(Impulse.kr(4), 0, outputDB);
    outputDB.dbamp*HPF.ar(Mix.new(signalOut), hpFq);

	//DEBUG outputDB.scope;
	//SendTrig.kr(Impulse.kr(4), 0, fb);
};

/*
t.stop;
a.free;

//  for test of "prop" and "event" messages
{
	a=~function.play;
    s.sync;
	a.set(\outputDB, 0 );
	a.set(\note, #[60, 1]);
	t = Task({ { a.set(\t_gate, 1); 1.wait;}.loop });
	t.start;
}.fork;





// make DEBUGGING SLIDER window



w=Window.new("sheefa", Rect(30, 30, 400, 200)).front;
w.view.decorator=FlowLayout(w.view.bounds);
w.view.decorator.gap=8@2;

g = EZSlider(w, 380@20, "Note ", ControlSpec(48, 84, \lin, 1, 60, \note));
g.action_({ |ez| ( a.set(\note, [ez.value,1]); a.set(\t_gate, 1); ) });

h = EZSlider(w, 380@20, "combRT", ControlSpec(-20, 20, \lin, 0.01, 1));
h.action_({ |ez| ( a.set(\combRTsec,  (ez.value)))});

i = EZSlider(w, 380@20, "outputDB", ControlSpec(-60, 6, \lin, 0.5, -18));
i.action_({ |ez| ( a.set(\outputDB, (ez.value)))});


//j = EZSlider(w, 380@20, "hPassQ", ControlSpec(0, 4, \lin, 0.10, 1));
//j.action_({ |ez| ( a.set(\hpQ, (ez.value)))});

k = EZSlider(w, 380@20, "LPcutoff ", ControlSpec(600, 22050, \exp,1, 22050));
k.action_({ |ez| ( a.set(\lpFq, ez.value))});

l = EZSlider(w, 380@20, "pWidth", ControlSpec(-1, 1, \lin, 0.01, 0));
l.action_({ |ez| ( a.set(\pWidth, ez.value))});

m = EZSlider(w, 380@20, "attkDms", ControlSpec(0.5, 50, \lin, 0.5, 4));
m.action_({ |ez| ( a.set(\attkDurMs, ez.value))});

n = EZSlider(w, 380@20, "attkRms", ControlSpec(0, 50, \lin, 0.1 , 0));
n.action_({ |ez| ( a.set(\attkRiseMs, ez.value))});



a=~function.play;




a=Synth.new(\sheefa);
a=~synths[\sheefa];
a=~synths[\mySound];

a.set(\outLevel, 0 );
a.set(\noteOn, #[60, 1]);   // accessed via the "event" message
a.set(\t_noteOnBang, 1);

*/

/*
transientDur = 100.reciprocal, transientAmp

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

*/


/*
//Define DWGPluckedStiff synthdef
(
SynthDef(\help_dwgplucked, { |out=0, freq=440, amp=0.5, gate=1, c3=20, pan=0,fB = 80|
    var env = Env.new([0,1, 1, 0],[0.001,0.006, 0.0005],[5,-5, -8]);
    var inp = amp * LFClipNoise.ar(2000) * EnvGen.ar(env,gate);
    var son = DWGPluckedStiff.ar(freq, amp, gate,0.1,1,c3,inp,fB);
    DetectSilence.ar(son, 0.001, doneAction:2);
    Out.ar(out, Pan2.ar(son * 0.1, pan));
}).add;
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
a = Scale.new(
    #[0, 1, 3, 5, 7, 8, 10],
    12,
    Tuning.new([0, 0.75, 2, 3.5, 4, 5, 6, 7, 8, 9, 10, 11]),
    "Custom"
);

Pbind(
    \instrument, \help_dwgplucked,
    \scale ,a,
    \delta , Pseq([1,0.5,0.5,0.5,0.5,0.5,0.5,1,0.5,0.5,1,1]*0.25,inf),
    \dur , 2,
    \degree, Pseq([1,8,8,8,8,8,8,-6,Prand([9,10,11],1),1,7,8]-8, inf),
    \amp , Pwhite(0.2,0.8),
    \c3 , Pseq([Pseq([1400],24),Pseq([300],24)],inf),
    \pan , Pwhite(-1,1),
).play;
)

*/


	/*

	~nodeName="sourceC:spatOSCsource_0".asSymbol;


	~createSource.value(~nodeName);
	~createConnection.value(~nodeName, "ear");
	~setUri.value(~nodeName, "plugin://zkarpluck0");

	~allNodes[~nodeName].at( \pluginNode ).run(1);

	~allNodes[~nodeName].at( \pluginNode ).set(\t_gate, 1);

	~allNodes[~nodeName].at( \pluginNode ).set(\outputDB, 18);
~allNodes[~nodeName].at( \pluginNode ).set(\combRTsec, 1);


	~allNodes[~nodeName].at( \pluginNode ).dump;


	~deleteSynth.value(~nodeName);

	~allNodes[~nodeName].at(\groupName).dump;

	~allNodes[~nodeName].at( \pluginNode )
	~allNodes[~nodeName].includesKey( \pluginNode )


	~clearScene.value();


	*/