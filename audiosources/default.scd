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
//


~name = \Default;
~function = { arg amp=1, t_noteOn, noteOn=#[1,10];
	var signal, env;
	env = EnvGen.ar(Env.perc(0.01, noteOn[0], amp), t_noteOn, doneAction:0);
	env * WhiteNoise.ar(0.25) * LFPulse.ar(noteOn[1]); };


/*  test of event method
a=~function.play;

a.set(\noteOn, #[1,8]);
a.set(\t_noteOn, 1);

*/
