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

// 5.1 speaker layout

~spk5 = VBAPSpeakerArray.new(2, [-45, 45, 135, -135, 0]); // 5 channel ring
// output channel assignment order from 0 to 5:   [FL, FR ,SR , SL ,C ,SUB]



~vbuf5 = Buffer.loadCollection(s, ~spk5.getSetsAndMatrices);

~name = \five1VBAP;

~function = {|in = 0, aziDeg = 0, eleDeg = 45, gainDB = -90, delayMs = 1, lpHz = 15000, hpHz = 1, spread = 1 |
	var gain= gainDB.dbamp;   // convert gainDB to gainAMP
	var delay = delayMs * 0.001;    // convert to seconds
	var slewDelay = 0.3; //  note: this needs to be improved ... smoother
	var slewGain = 0.1;
	var slewFilter = 0.6;
	var slewPanning = 0.030;
	var panWeights;
	var outsig , sourceSig;

	sourceSig =  LPF.ar(DelayC.ar(
		Lag.kr(gain, slewGain) * in,
		maxdelaytime: 0.5,
		delaytime: delay.lag(slewDelay)),   lpHz.lag(slewFilter)    );

	sourceSig = BHiPass.ar(sourceSig, VarLag.kr(hpHz, slewFilter )  );

	panWeights = VBAP.kr(numChans: ~spk5.numSpeakers,
		in: 1.0,
		bufnum: ~vbuf5.bufnum,
		azimuth: aziDeg,
		elevation: eleDeg,
		spread: spread );

	outsig = sourceSig * Lag.kr(panWeights, 0.030);

	[outsig[0],outsig[1], outsig[2], outsig[3], outsig[4], sourceSig];   // output array  [FL, FR ,SR , SL ,C ,SUB]
};




