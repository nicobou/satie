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


// Play a sample buffer



// args:   midiPitch60 == no transposition,  force & incidence  between -1 and 1


~name = \zPsamp1;
~function = { | bufnum = 0, loop = 0, startPos=0, t_trig=0, trimDB=0,  note = #[60, 1, 0.7]  |

	var freq = note[0].midicps;
	var amp = abs (note[1]);
	var incidence = abs (note[2]);   // apprently this does not work
	var rate =  freq/261.6255653006;
	var lpassFq,hpassFq;
	var ampScaled;
	var sig;

	incidence = incidence.clip(0,1);
	amp = amp.clip(-1,1);
	ampScaled = abs(amp) **(0.7);

	lpassFq = 100 + (incidence**(0.7) * 21900) ;  // used to cut highs when incidence is low

	hpassFq = 800 - ( ampScaled * 799) ;  // used to pass lows when force is high

	sig = trimDB.dbamp * PlayBuf.ar(1, bufnum, rate, t_trig, startPos, loop);


	sig = BLowPass.ar(  (ampScaled * sig),  Lag.kr(lpassFq, 0.02) , 5);

    sig = BHiPass.ar( sig ,  Lag.kr(hpassFq, 0.02) , 5);

};



/*  TEST
SynthDef(~name, ~function ).add;



~v1 =Synth.new(~name,  [ \i_doneAction, 0, \randTrigMaxMs , 500, \durMs, 100, \attackBend, 3 , \attackMS, 10]);

~v1 =Synth.new(~name);
~v1.set(\t_trig, 1);


*/




