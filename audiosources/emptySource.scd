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




~name = \emptySource;    // this source is used as a default for newly created nodes
~function = {
	var dummy;

	DC.ar(0);

};
