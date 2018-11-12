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

~name = \sndFileHOA;

// note:  order must be first arg !!
~description = "Play a multichannel buffer";
~channelLayout = \ambi;

~function = { | order = 2, bufnum = 0, loop = 1, mul = 1|
	SynthDef.wrap(~diskins.at(order), prependArgs: [loop, bufnum]);
};

~setup = { |satieInstance|
	var orders = satieInstance.config.ambiOrders;
	~diskins = Array.fill(6, {0});
	~diskins.do({|i, index|
		var idx, numChannels, func;
		idx = index;
		numChannels = (idx + 1).pow(2).asInt;
		func = { |loop, bufnum|
			DiskIn.ar(numChannels, bufnum, BufRateScale.kr(bufnum));
		};
		~diskins.put(idx, func);
	});
};
