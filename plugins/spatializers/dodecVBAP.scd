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

~name = \dodecVBAP;
~description = "20 channel layout (3D)";
~numChannels = 20;
~channelLayout = \mono;


~spk20 = VBAPSpeakerArray.new(3, [
[90 , -69.094841 ],
[-90 , -69.094841 ],
[45 , -35.264389 ],
[-45 , -35.264389 ],
[-135 , -35.264389 ],
[135 , -35.264389  ],
[0 , -20.905161  ],
[180 , -20.905161  ],
[69.094841 , 0 ],
[-69.094841 , 0 ],
[-110.905159 , 0 ],
[110.905159 , 0 ],
[0 , 20.905161  ],
[180 , 20.905161  ],
[45 , 35.264389  ],
[-45 , 35.264389  ],
[-135 , 35.264389  ],
[135 , 35.264389  ],
[90 , 69.094841  ],
[-90 , 69.094841 ]]);

// defined by Peter Otto
// define_loudspeakers 3 90. -69.094841 -90. -69.094841 45. -35.264389 -45. -35.264389 -135. -35.264389 135. -35.264389 0. -20.905161 180. -20.905161 69.094841 0. -69.094841 0. -110.905159 0. 110.905159 0. 0. 20.905161 180. 20.905161 45. 35.264389 -45. 35.264389 -135. 35.264389 135. 35.264389 90. 69.094841 -90. 69.094841


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

	panWeights = VBAP.kr(numChans: ~spk20.numSpeakers,
		in: 1.0,
		bufnum: ~vbuf20.bufnum,
		azimuth: aziDeg,
		elevation: eleDeg,
		spread: spread );

	outsig * Lag.kr(panWeights, 0.030);
};


~setup = { |satieInstance|
		~vbuf20 = Buffer.loadCollection(satieInstance.satieConfiguration.server, ~spk20.getSetsAndMatrices);
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




