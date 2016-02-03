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

// 128 speaker layout

VBAPSpeakerArray.maxNumSpeakers = 128;

~spk128 =  VBAPSpeakerArray.new(3, [
     [-175, -5], [-164, -5], [-153, -5], [-142, -5], [-131, -5], [-120, -5], [-109, -5], [ -98, -5], [ -87, -5], [ -76, -5], [ -65, -5], [-54, -5], [ -43, -5], [ -32, -5], [ -21, -5], [ -10, -5], [   1, -5], [  12, -5], [  23, -5], [34, -5], [45, -5], [56, -5], [67, -5], [78, -5], [89, -5], [ 100, -5], [ 111, -5], [ 122, -5], [ 133, -5], [ 144, -5], [ 155, -5], [ 166, -5],
	 [-175, 20], [-164, 20], [-153, 20], [-142, 20], [-131, 20], [-120, 20], [-109, 20], [ -98, 20], [ -87, 20], [ -76, 20], [ -65, 20], [-54, 20], [ -43, 20], [ -32, 20], [ -21, 20], [ -10, 20], [   1, 20], [  12, 20], [  23, 20], [34, 20], [45, 20], [56, 20], [67, 20], [78, 20], [89, 20], [ 100, 20], [ 111, 20], [ 122, 20], [ 133, 20], [ 144, 20], [ 155, 20], [ 166, 20],
     [-175, 40], [-164, 40], [-153, 40], [-142, 40], [-131, 40], [-120, 40], [-109, 40], [ -98, 40], [ -87, 40], [ -76, 40], [ -65, 40], [-54, 40], [ -43, 40], [ -32, 40], [ -21, 40], [ -10, 40], [   1, 40], [  12, 40], [  23, 40], [34, 40], [45, 40], [56, 40], [67, 40], [78, 40], [89, 40], [ 100, 40], [ 111, 40], [ 122, 40], [ 133, 40], [ 144, 40], [ 155, 40], [ 166, 40],
     [-175, 60], [-164, 60], [-153, 60], [-142, 60], [-131, 60], [-120, 60], [-109, 60], [ -98, 60], [ -87, 60], [ -76, 60], [ -65, 60], [-54, 60], [ -43, 60], [ -32, 60], [ -21, 60], [ -10, 60], [   1, 60], [  12, 60], [  23, 60], [34, 60], [45, 60], [56, 60], [67, 60], [78, 60], [89, 60], [ 100, 60], [ 111, 60], [ 122, 60], [ 133, 60], [ 144, 60], [ 155, 60], [ 166, 60]
]);

~vbuf128 = Buffer.loadCollection(s, ~spk128.getSetsAndMatrices);

~name = \spk128VBAP;

~function = {|in = 0, aziDeg = 0, eleDeg = 45, gainDB = 0, delayMs = 1, lpHz = 15000, spread = 1 |
	var gain= gainDB.dbamp;   // convert gainDB to gainAMP
	var delay = delayMs * 0.001;    // convert to seconds
	var slewDelay = 0.3; //  note: this needs to be improved ... smoother
	var slewGain = 0.05;
	var slewLp = 0.3;
	var panWeights;
	var outsig;

	outsig = LPF.ar(
		DelayC.ar(
			Lag.kr(gain, slewGain) * in,
			maxdelaytime: 0.5,
			delaytime: Lag.kr(delay, slewDelay)),
		Lag.kr(lpHz, slewLp));

	panWeights = VBAP.kr(numChans: ~spk128.numSpeakers,
		in: 1.0,
		bufnum: ~vbuf128.bufnum,
		azimuth: aziDeg,
		elevation: eleDeg,
		spread: spread );

	outsig * Lag.kr(panWeights, 0.030);
};


// ~function = {|in = 0, aziDeg = 0.5, eleDeg = 0, gainDB = 0, delayMs = 1, lpHz = 15000, spread = 1 |
// 	var gain= gainDB.dbamp;   // convert gainDB to gainAMP
// 	var delay = delayMs * 0.001;    // convert to seconds
// 	var slewDelay = 0.3; //  note: this needs to be improved ... smoother
// 	var slewGain = 0.05;
// 	var slewLp = 0.3;
// 	VBAP.ar(numChans: ~spk31.numSpeakers,
// 		in:	LPF.ar(
// 			DelayC.ar(
// 				Lag.kr(gain, slewGain) * in,
// 				maxdelaytime: 0.5,
// 			delaytime: Lag.kr(delay, slewDelay)),
// 		Lag.kr(lpHz, slewLp)),
// 		bufnum: ~vbuf31.bufnum,
// 		azimuth: Lag.kr(aziDeg, 0.3),
// 		elevation: Lag.kr(eleDeg, 0.3),
// 	spread: Lag.kr(spread, 0.3) );
// };




