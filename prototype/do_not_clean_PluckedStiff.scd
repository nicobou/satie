//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

s.reboot;

(

SynthDef(\doNotClean,
	{ arg amp=0.1, pos = 0.14, c1 = 1, c3=20, fb = 2, note = #[60,1];
		var env,inp,son;
		var freq = note[0].midicps;
		env = Env.perc();
		inp = amp
		* LFClipNoise.ar(200)
		* EnvGen.ar(env, \gate.tr);
		son = DWGPluckedStiff.ar(freq, amp,1 ,pos,c1,c3,inp, inf, fb);
		Out.ar(0, son);   // make sure this is last, so the sound is returned
}).add;
)


~wos = Synth.tail(s, \doNotClean);
(
~wos.set(
	\gate, 1,
	\note, rrand(30,40),
	\pos, rrand(0.5,1),
	\c3, rrand(5,20)
);
)
