//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.


~name = \FuMaIn;
~description = "A live ambisonic input (FuMa)";
~channelLayout = \ambi;

~function = {|order=1, t_trig = 0, bus = 0 |
	var env = Env([0,1], [1, 1]);
	HOAConvert.ar(
		order,
		SoundIn.ar(Array.series((order + 1).pow(2), bus, 1), EnvGen.kr(env, t_trig)),
		\FuMa,
		\ACN_N3D
	);
}
