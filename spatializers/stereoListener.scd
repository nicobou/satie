//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.


// fed by the following osc message
// /spatosc/core/connection/sourceNode->listenerNode/update azimuthRADIANS elevationRADIANS delayMS gainDB lpHZ

~name = \stereoListener;

// note:  spread:  // need to invert this value:  so 0 = full spread, 1 = normal, > 1 = narrower
// note:  update vector:  azimuthRADIANS elevationRADIANS delayMS gainDB lpHZ

~function = {|in = 0, update = #[ 0,0,0,1,22000 ] , spread = 1 |
	var azi = update[0];
	var ele = update[1];
	var delay = update[2];
	var gain = update[3];
	var lpf = update[4];

	Pan2.ar(DelayC.ar(gain * in, maxdelaytime: 0.5, delaytime: delay), azi);

};

