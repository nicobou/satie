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
	~function: the actual definition of the plugin

*/

~name = \MonoIn;
~description = "A direct input";
~type = \mono;

~function = {
	|t_trig = 0, bus = 0|
	var env = Env([0,1], [1, 1]);
	AudioIn.ar(bus, EnvGen.kr(env, t_trig));
}