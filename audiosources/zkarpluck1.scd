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




~name = \zkarpluck1;
~function = { arg listenerName = \myListener, hpQ = 2.reciprocal, hpFq = 11, outLevel = -99, pWidth = 0, delayDecay = 2.reciprocal, delayMS = 10, t_noteOnBang = 0, noteOn=#[60,1];  // note gain

	//var transientEnv = [0, 1000.reciprocal, 1, -8];
	var burstEnv, att = 0, dec = 0.001;
	var signalOut;
	var midiPitch = noteOn[0];
	var amp = noteOn[1];
	//var gain = shitfuck.dbamp;
	var delayTime = [midiPitch, midiPitch + 12, midiPitch + 24].midicps.reciprocal;

	//outLevel.scope;
	//SendTrig.kr(Impulse.kr(4), 0, outLevel);
	//Env.perc(0, 1000.reciprocal, 1, -24).test.plot;

	burstEnv = EnvGen.ar(Env.perc(0, 100.reciprocal, 10, pWidth), t_noteOnBang);

	signalOut = PinkNoise.ar(burstEnv);
	//signalOut = burstEnv*Decay.ar(Impulse.ar(1000, pWidth), dec );
	//signalOut = (burstEnv*Impulse.ar(1000, pWidth)).scope;

	signalOut = 3.reciprocal * CombL.ar(signalOut, 1, delayTime, delayDecay);
	outLevel.dbamp*BHiPass.ar(Mix.new(signalOut), hpFq, hpQ );
	//DetectSilence.ar(signalOut, doneAction:0);
};

/*  for test of "prop" and "event" messages

a=~synths[\mySound];

a=~function.play;

a.set(\outLevel, 0 );
a.set(\noteOn, #[60, 1]);   // accessed via the "event" message
a.set(\t_noteOnBang, 1);

// make DEBUGGING SLIDER window

w=Window.new.front;
w.view.decorator=FlowLayout(w.view.bounds);
w.view.decorator.gap=2@2;

g = EZSlider(w, 380@20, "Note ", ControlSpec(24, 60, \lin, 1, 36, \note));
g.action_({ |ez| ( a.set(\noteOn, ez.value); a.set(\t_noteOnBang, 1); ) });

h = EZSlider(w, label: "Decay");
h.action_({ |ez| ( a.set(\delayDecay, LinLin.kr(ez.value, 0,1,1000.reciprocal, 20)); a.set(\t_noteOnBang, 1); ) });

i = EZSlider(w, 380@20, "Output");
i.action_({ |ez| ( a.set(\outLevel, LinLin.kr(ez.value, 0,1,-66, 0));) });


j = EZSlider(w, label: "hPassQ");
j.action_({ |ez| ( a.set(\hpQ, [ LinLin.kr(ez.value, 0,1,0, 1), 1]); ) });

k = EZSlider(w, 380@20, "HPcutoff ", ControlSpec(0.1, 5000, \exp,0.01,1000,\Hz));
k.action_({ |ez| ( a.set(\hpFq, ez.value))});

l = EZSlider(w, 380@20, "pWidth ", ControlSpec(-24, 24, \lin, 1, 0));
l.action_({ |ez| ( a.set(\pWidth, ez.value))});


o = OSCresponderNode(s.addr, '/tr', { |time, resp, msg| msg.postln }).add;




o.remove;  // when done, you need to clean up the OSCresponderNode


Env.perc(0, 100.reciprocal, 10, -24).test.plot;

*/





