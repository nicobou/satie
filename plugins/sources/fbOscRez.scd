//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/*       Audio plugin definition

	Each audio plugin should define the following global variables:
    ~name: (symbol) name of the spatializer
	~description: (string) a short description
	~channelLayout: (symbol) \mono or other, channel layout affects use with spatializers
	~function: the actual definition of the plugin

*/
~name = \fbOscRez;  // ripped from http://sccode.org/1-5ah#c814 and slightly enhanced
~description = "Feedback oscilator with resonant filter infinite drone";
~channelLayout = \mono;
~function = {|freq = 440, fundamental = 110, amp = 0.1, gate = 1, att = 2.0, dec = 0.3, sus = 0.5, rel = 1,vibFreq=7, vibAmp=0,vibAdd=0.5,lpfFreq = 0.5, lpfRes = 0.5|
	var snd, env;
	lpfFreq = lpfFreq * (freq * 3) + fundamental;
	lpfRes = 1 - lpfRes * 0.9 + 0.1;
	env = EnvGen.ar(Env.adsr(att, dec, sus, rel, amp), gate, doneAction: 2);
	snd = SinOscFB.ar( freq, SinOsc.kr(rrand(0.001, 0.05), mul:0.1, add:1)*vibAmp, SinOsc.kr(rrand(0.001, 0.05), mul:0.1, add:1)*amp);
	snd = snd * SinOsc.kr(vibFreq*15, mul:vibAmp, add:vibAdd);
	snd = snd * env;
	RLPF.ar(snd, SinOsc.kr(rrand(0.001, 0.05), mul:0.1, add:1)*lpfFreq,lpfRes)
};