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

~name = \sndFileHOA;

// note:  bufnum must be first arg !!
~description = "Play a multichannel buffer";
~channelLayout = \ambi;

~function = { | bufnum = 0, order = 2, loop = 1, mul = 1|
	SynthDef.wrap(~diskins.at(order), prependArgs: [loop, bufnum]);
};

~setup = { |satieInstance|
	var orders = satieInstance.satieConfiguration.ambiOrders;
	~diskins = Array.fill(6, {0});
	~diskins.do({|i, index|
		var idx, numChannels, func;
		idx = index;
		numChannels = (idx + 1).pow(2).asInt;
		func = { |bufnum, loop|
			var sig = DiskIn.ar(numChannels, bufnum, BufRateScale.kr(bufnum));
		};
		~diskins.put(idx, func);
	});
};