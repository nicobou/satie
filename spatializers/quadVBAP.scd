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

// Octo 2D speaker layout
// ~spk8 = VBAPSpeakerArray.new(2, [-45, 45, 135, -135, 0, 90, 180, -90]); // 8 channel ring
// ~spk8 = VBAPSpeakerArray.new(2, [-40, 0, 40, 70, 140, 180, -140, -70]); // 8 channel ring
~spk4 = VBAPSpeakerArray.new(2, [-45, 45, 135, -135]); // 8 channel ring
// {[-45, 45, 135, -135, 0, 90, 180, -90].do({|ang| x.set(\azi, ang); 1.wait; }) }.fork;



~vbuf4 = Buffer.loadCollection(s, ~spk4.getSetsAndMatrices);

~name = \quadVBAP;

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

	panWeights = VBAP.kr(numChans: ~spk4.numSpeakers,
		in: 1.0,
		bufnum: ~vbuf4.bufnum,
		azimuth: aziDeg,
		elevation: eleDeg,
		spread: spread );

	outsig * Lag.kr(panWeights, 0.030);
};




