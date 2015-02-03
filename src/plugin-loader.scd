// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

(
~scbrPlugins = {
	var e = Environment.make({
		~audioPlugins = Dictionary.new;
		~loadAudioPlugins = { | self,  path = "./*.scd" |
			path.pathMatch.do{ arg item;
				item.loadPaths;
				self.audioPlugins.put(~name.asSymbol, ~function);
			};
			nil;
		};
		~spatPlugins = Dictionary.new;
		~loadSpatPlugins = { | self,  path = "./*.scd" |
			path.pathMatch.do{ arg item;
				item.loadPaths;
				self.spatPlugins.put(~name.asSymbol, ~function);
			};
			nil;
		};
	});  // Environment.make
	e.know = true;
	e;
};  // scbrPlugins
)
