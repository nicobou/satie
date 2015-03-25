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

// spat input args:
// aziDeg degrees (-180 to 180)
// elevDeg   degrees (-180 to 180)
// gainDB  decibels
// delaySec  seconds
// lpHz    hertz
// spread  units  (0 == directional, ....,  100 == omni)

// dome speaker layout
~spk = VBAPSpeakerArray.new(3, [
		[0, 90],
		[15, 45], [75, 45], [135, 45], [-165, 45], [-105, 45], [-45, 45],
		[0, 22.5], [30, 22.5], [60, 22.5], [90, 22.5], [120, 22.5], [150, 22.5], [180, 22.5], [-150, 22.5], [-120, 22.5], [-90, 22.5], [-60, 22.5], [-30, 22.5],
		[0, 0], [30, 0], [60, 0], [90, 0], [120, 0], [150, 0], [180, 0], [-150, 0], [-120, 0], [-90, 0], [-60, 0], [-30, 0],
	]);
~vbuf = Buffer.loadCollection(s, ~spk.getSetsAndMatrices);

~name = \domeVBAP;


~function = {|in = 0, aziDeg = 0, eleDeg = 0, gainDB = 0, delayMs = 1, lpHz = 15000, spread = 1 |
	var gain= gainDB.dbamp;   // convert gainDB to gainAMP
	var delay = delayMs * 0.001;    // convert to seconds
	var slewDelay = 0.3; //  note: this needs to be improved ... smoother
	var slewGain = 0.03;
	var slewLp = 0.3;
	VBAP.ar(numChans: ~spk.numSpeakers,
		in:	LPF.ar(
			DelayC.ar(
				gain.lag(slewGain) * in,
				maxdelaytime: 0.5,
				delaytime: delay.lag(slewDelay)),
			lpHz.lag(slewLp)),
		bufnum: ~vbuf.bufnum,
		azimuth: aziDeg,
		elevation: eleDeg,
		spread: spread);
};


/*
// layout for domes > 180 degrees elevation
~spk = VBAPSpeakerArray.new(3, [
[0, 90],
[-7.5, 55], [52.5, 55], [112.5, 55], [172.5, 55], [-127.5, 55], [-67.5, 55],
[7.5, 20], [37.5, 20], [67.5, 20], [97.5, 20], [127.5, 20], [157.5, 20], [-172.5, 20], [-142.5, 20], [-112.5, 20], [-82.5, 20], [-52.5, 20], [-22.5, 20],
[7.5, -15], [37.5, -15], [67.5, -15], [97.5, -15], [127.5, -15], [157.5, -15], [-172.5, -15], [-142.5, -15], [-112.5, -15], [-82.5, -15], [-52.5, -15], [-22.5, -15]
]);
*/