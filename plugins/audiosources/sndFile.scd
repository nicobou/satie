// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

/*       Audio plugin definition

	Each audio plugin should define the following global variables:
    ~name: (symbol) name of the spatializer
	~description: (string) a short description
	~function: the actual definition of the plugin

*/

~name = \sndFile;
~description = "Stream a soundfile from disk";
~type = \mono;

~function = { | bufnum = 0, loop = 0 |
	DiskIn.ar(1, bufnum, loop = loop);
};

/*
~name = \sndFile;
~function = { | sfile = '/usr/share/sounds/alsa/Front_Center.wav' |
	var buf;
	var sf = sfile.asString;
	buf = Buffer.cueSoundFile(s, sf, 0, 1);
	DiskIn.ar(1, buf.bufnum);
};

*/