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

/*       Spatializer plugin definition

	Each spatializer plugin should define the following global variables:
    ~name: (symbol) name of the spatializer
	~description: (string) a short description
	~numChannels: (int) number of channels
	~function: the definition of the spatializer

	where function should use the following input arguments:

	in
	aziDeg degrees (-180 to 180)
	elevDeg   degrees (-180 to 180)
	gainDB  decibels
	delaySec  seconds
	lpHz    hertz
	spread  units  (0 == directional, ....,  100 == omni)
*/

~name = \domeVBAP;
~description = "31 channel sphere (SAT dome)";
~numChannels = 31;
~type = \mono;

// layout for domes developed by olie
// ~spk31 = VBAPSpeakerArray.new(3, [
// 	[0, 90],
// 	[15, 45], [75, 45], [135, 45], [-165, 45], [-105, 45], [-45, 45],
// 	[0, 22.5], [30, 22.5], [60, 22.5], [90, 22.5], [120, 22.5], [150, 22.5], [180, 22.5], [-150, 22.5], [-120, 22.5], [-90, 22.5], [-60, 22.5], [-30, 22.5],
// 	[0, 0], [30, 0], [60, 0], [90, 0], [120, 0], [150, 0], [180, 0], [-150, 0], [-120, 0], [-90, 0], [-60, 0], [-30, 0],
// ]);
// layout for domes developed by z

~spk31 =  VBAPSpeakerArray.new(3, [
	[0, 90],
	[-7.5, 55], [52.5, 55], [112.5, 55], [172.5, 55], [-127.5, 55], [-67.5, 55],
	[7.5, 20], [37.5, 20], [67.5, 20], [97.5, 20], [127.5, 20], [157.5, 20], [-172.5, 20], [-142.5, 20], [-112.5, 20], [-82.5, 20], [-52.5, 20], [-22.5, 20],
[7.5, -15], [37.5, -15], [67.5, -15], [97.5, -15], [127.5, -15], [157.5, -15], [-172.5, -15], [-142.5, -15], [-112.5, -15], [-82.5, -15], [-52.5, -15], [-22.5, -15] ]);


~function = {|in = 0, aziDeg = 0, eleDeg = 45, gainDB = -90, delayMs = 1, lpHz = 15000, hpHz = 1, spread = 1 |
	var gain= gainDB.dbamp;   // convert gainDB to gainAMP
	var delay = delayMs * 0.001;    // convert to seconds
	var slewDelay = 0.3; //  note: this needs to be improved ... smoother
	var slewGain = 0.1;
	var slewFilter = 0.6;
	var slewPanning = 0.030;
	var panWeights;
	var outsig;

	outsig =  LPF.ar(DelayC.ar(
		Lag.kr(gain, slewGain) * in,
		maxdelaytime: 0.5,
		delaytime: delay.lag(slewDelay)),   lpHz.lag(slewFilter)    );

	outsig = BHiPass.ar(outsig, VarLag.kr(hpHz, slewFilter )  );

	panWeights = VBAP.kr(numChans: ~spk31.numSpeakers,
		in: 1.0,
		bufnum: ~vbuf31.bufnum,
		azimuth: aziDeg,
		elevation: eleDeg,
		spread: spread );

	outsig * Lag.kr(panWeights, 0.030);
};

~setup = { |satieInstance|
		~vbuf31 = Buffer.loadCollection(satieInstance.satieConfiguration.server, ~spk31.getSetsAndMatrices);
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




