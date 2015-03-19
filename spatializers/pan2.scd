//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

~name = \stereoPanner;
// was  ~function = {|in = 0, vol, delay, azi, ele |


// note:  need to add smoothing for all parameters
// note:  spread: not implemented yet -- note:  0 = full spread, 1 = normal, > 1 = narrower
// note:  update vector:  azimuthRADIANS elevationRADIANS gainDB delayMS lpHZ

~function = {|in = 0, update = #[ 0,0,0,1,22000 ] , spread = 1 |  // note:  sholuld we provide an additional arg: customArray for additional params ???
	var azi = LinLin.kr(update[0], -1.5707963267949, 1.5707963267949,-1,1);   // radians to pan units -- to do:  need true rotation
	var ele = LinLin.kr(update[1], -1.5707963267949, 1.5707963267949,-1,1);   // radians to pan units
	var gain= (update[2]).dbamp;   // convert gainDB to gainAMP
	var delay = update[3]* 0.001;    // convert to milliseconds
	var lpf = update[4];

	var slewRateDelay = 0.3; //  note: this needs to be improved ... smoother
	var slewRateGain = 0.03;
	var slewRateLpf = 0.3;

	LPF.ar(Pan2.ar(DelayC.ar(gain.lag(slewRateGain) * in, maxdelaytime: 0.5, delaytime: delay.lag(slewRateDelay)), azi), lpf.lag(slewRateLpf));
};

