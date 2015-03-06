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




~name = \Default;
~function = { arg amp=1, tremelo=10, t_noteOnBang, noteOn=#[2,60];
	var signal, env;
	env = EnvGen.ar(Env.perc(0.01, noteOn[0], 1), t_noteOnBang, doneAction:0);
	amp*(PinkNoise.ar(0.1)* LFPulse.ar(tremelo) + (env*FSinOsc.ar((noteOn[1]).midicps)));

};

/*  for test of "prop" and "event" messages
a=~function.play;

a.set(\tremelo, 20);   // accessed via the "prop" message
a.set(\amp, 2.reciprocal);   // accessed via the "prop" message

a.set(\noteOn, #[1,60]);   // accessed via the "event" message
a.set(\t_noteOnBang, 1);
*/
