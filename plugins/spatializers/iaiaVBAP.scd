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

// IAIA 24-channel speaker layout

~name = \iaiaVBAP;
~description = "24 channel speaker layout on a sphere ( digital dome at IAIA)";
~numChannels = 24;

~spkIAIA_24 = VBAPSpeakerArray.new(3, [

	// IAIA speaker configuration (nov. 2017)
	//Speakers starting front left and incrementing clockwise:
	//1-8. low wall speakers
	//9-16. high wall speakers
	//17-20. ceiling speakers
	//21-24. floor speakers

	// mid-low
	[-22.5, -22.5],
	[22.5, -22.5],
	[67.5, -22.5],
	[112.5, -22.5],
	[157.5, -22.5],
	[-157.5, -22.5],
	[-112.5, -22.5],
	[-67.5, -22.5],

	//mid-high
	[-22.5, 22.5],
	[22.5, 22.5],
	[67.5, 22.5],
	[112.5, 22.5],
	[157.5, 22.5],
	[-157.5, 22.5],
	[-112.5, 22.5],
	[-67.5, 22.5],

	//ceiling
	[-45, 60],
	[45, 60],
	[135, 60],
	[-135, 60],

	//floor
	[-45, -60],
	[45, -60],
	[135, -60],
	[-135, -60]
]);

~function = { | in = 0, aziDeg = 0, eleDeg = 45, gainDB = -90, delayMs = 1, lpHz = 15000, hpHz = 1, spread = 1 |
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

	panWeights = VBAP.kr(numChans: ~spkIAIA_24.numSpeakers,
		in: 1.0,
		bufnum: ~vbufIAIA_24.bufnum,
		azimuth: aziDeg,
		elevation: eleDeg,
		spread: spread );

	outsig * Ramp.kr(panWeights, slewPanning);
};

~setup = { |satieInstance|

	s.waitForBoot {
		s.sync;
		~vbufIAIA_24 = Buffer.loadCollection(satieInstance.satieConfiguration.server, ~spkIAIA_24.getSetsAndMatrices);
	}


};

/*

OFFICIAL LAYOUT

~spkIAIA_24 = VBAPSpeakerArray.new(3, [

	// IAIA speaker configuration (nov. 2017)
	//Speakers starting front left and incrementing clockwise:
	//1-8. low wall speakers
	//9-16. high wall speakers
	//17-20. ceiling speakers
	//21-24. floor speakers

	// mid-low
	[-22.5, -22.5],
	[22.5, -22.5],
	[67.5, -22.5],
	[112.5, -22.5],
	[157.5, -22.5],
	[-157.5, -22.5],
	[-112.5, -22.5],
	[-67.5, -22.5],

	//mid-high
	[-22.5, 22.5],
	[22.5, 22.5],
	[67.5, 22.5],
	[112.5, 22.5],
	[157.5, 22.5],
	[-157.5, 22.5],
	[-112.5, 22.5],
	[-67.5, 22.5],

	//ceiling
	[-45, 60],
	[45, 60],
	[135, 60],
	[-135, 60],

	//floor
	[-45, -60],
	[45, -60],
	[135, -60],
	[-135, -60]
]);

*/