//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

~name = \Default;
~function = { | freq = 10 , t_|
	WhiteNoise.ar(0.25)*LFPulse.ar(freq); };


// a=~function.play;
// a.set(\freq, 10);