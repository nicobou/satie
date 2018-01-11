// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
// ~name = \sndFile;
// ~function = { | bufnum = 0, loop = 0, startPos=0, rate = 1, t_trig=0 |
// 	// DiskIn.ar(1, bufnum, loop = loop);
// 	PlayBuf.ar(1, bufnum, rate, t_trig, startPos, loop);
// };
//

/*       Audio plugin definition

	Each audio plugin should define the following global variables:
    ~name: (symbol) name of the spatializer
	~description: (string) a short description
	~function: the actual definition of the plugin

*/



~name = \sndBuffer;

// note:  bufnum must be first arg !!
~description = "Play a buffer";
~type = \mono;


~function = { | bufnum = 0, loop = 0, startPos=0, rate = 1, t_trig=0, trimDB=0, tone=1,  amp=1 |
	var lpassFq;
	var sig;

	tone = abs (tone);
	amp = amp.clip(0,1);
	tone = tone.clip(0,1);

	lpassFq = 100 + (tone**(0.7) * 21900) ;  // used to cut highs when incidence is low

	sig = trimDB.dbamp * PlayBuf.ar(1, bufnum, rate, t_trig, startPos, loop);


	BLowPass.ar( amp * sig ,  Lag.kr(lpassFq, 0.02) , 5);

};







