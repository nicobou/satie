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




~name = \default;
~function = { arg amp=1, lfoHz=10, t_gate=0, note=#[60,1];
	var signal, env;

	env = EnvGen.ar(Env.perc(0.01, 0.3, 0.5), gate: t_gate, doneAction:0);
	amp*(PinkNoise.ar(1)* LFPulse.ar(lfoHz) + (env*FSinOsc.ar((note[0]).midicps)));

};

/*  for test of "prop" and "event" messages
a=~function.play;

a.set(\tremelo, 20);   // accessed via the "prop" message
a.set(\amp, 2.reciprocal);   // accessed via the "prop" message

a.set(\note, #[1,60]);   // accessed via the "event" message
a.set(\t_trigger, 1);
*/
