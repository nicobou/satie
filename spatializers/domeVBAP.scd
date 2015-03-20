//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

// dome speaker layout
~spk = VBAPSpeakerArray.new(3, [
		[0, 90],
		[15, 45], [75, 45], [135, 45], [-165, 45], [-105, 45], [-45, 45],
		[0, 22.5], [30, 22.5], [60, 22.5], [90, 22.5], [120, 22.5], [150, 22.5], [180, 22.5], [-150, 22.5], [-120, 22.5], [-90, 22.5], [-60, 22.5], [-30, 22.5],
		[0, 0], [30, 0], [60, 0], [90, 0], [120, 0], [150, 0], [180, 0], [-150, 0], [-120, 0], [-90, 0], [-60, 0], [-30, 0],
	]);
~vbuf = Buffer.loadCollection(s, ~spk.getSetsAndMatrices);

~name = \domeVBAP;

~function = {|in = 0, update = #[ 0,0,0,1,22000 ], spread = 1 |  // note:  sholuld we provide an additional arg: customArray for additional params ???
	var azi = LinLin.kr(update[0], -3.14159, 3.14159, -180, 180);   // radians to pan units -- to do:  need true rotation
	var ele = LinLin.kr(update[1], -1.5707963267949, 1.5707963267949, -90 , 90);   // radians to pan units
	var gain= (update[2]).dbamp;   // convert gainDB to gainAMP
	var delay = update[3]* 0.001;    // convert to milliseconds
	var lpf = update[4];

	var slewRateDelay = 0.3; //  note: this needs to be improved ... smoother
	var slewRateGain = 0.03;
	var slewRateLpf = 0.3;

	VBAP.ar(numChans: ~spk.numSpeakers,
		in:	LPF.ar(DelayC.ar(gain.lag(slewRateGain) * in, maxdelaytime: 0.5, delaytime: delay.lag(slewRateDelay)),lpf.lag(slewRateLpf)),
		bufnum: ~vbuf.bufnum,
		azimuth: azi,
		elevation: ele,
		spread: spread);
};



/*
// layout for domes > 180 degrees elevation

~spk = VBAPSpeakerArray.new(3, [
[0, 90], [-7.5, 55], [52.5, 55], [112.5, 55], [172.5, 55], [-127.5, 55], [-67.5, 55], [7.5, 20], [37.5, 20], [67.5, 20], [97.5, 20], [127.5, 20], [157.5, 20], [-172.5, 20], [-142.5, 20], [-112.5, 20], [-82.5, 20], [-52.5, 20], [-22.5, 20], [7.5, -15], [37.5, -15], [67.5, -15], [97.5, -15], [127.5, -15], [157.5, -15], [-172.5, -15], [-142.5, -15], [-112.5, -15], [-82.5, -15], [-52.5, -15], [-22.5, -15]
]);

*/