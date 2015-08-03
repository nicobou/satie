// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

~randFreq = { |baseFreq = 50, octave = 1, t|
	var ratio, ret;
	ratio = t.ratios.choose;
	postf("randFreq excuting ratio %\n", ratio );
	ret = baseFreq * octave * ratio;
	postf("returning frequency: %\n", ret);
	ret;

};

~name = \testee;
~function = {
var tri = Array.with(
		LeakDC.ar(1-LFTri.ar((SinOsc.kr(0.001)+1)*1000)),
		LeakDC.ar(1-LFTri.ar((SinOsc.kr(0.002)+1)*750)),
		LeakDC.ar(1-LFTri.ar(100)),
		LeakDC.ar(1-LFTri.ar(55.1)),
	);
	var triScale = 0.5;
	var triMix = tri[0] * tri[1] * tri[2] * tri[3] * triScale;
	var verb = FreeVerb.ar(triMix, 0.7, 1, 0.5, Line.kr(0, 0.75, 15));
	verb;
};
