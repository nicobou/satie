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
// dome speaker layout


~name = \VBAP1474;
~description = "16 channel dome (IEM)";
~numChannels = 16;
~channelLayout = \mono;

/* speaker positions used by ambIEM
https://github.com/supercollider-quarks/AmbIEM/blob/master/Classes/DecodeAmbi.sc

azi: [0,45,135,225,315,25,75,130,180,230,285,335,0,90,180,270]
elev: [90,40,40,40,40,0,0,0,0,0,0,0,-40,-40,-40,-40],

*/

// note, this is a global variable, used by specialized listeners to decode the output format.
~speakerConfig1474 = [
[0 , 90 ],  // top
[45 , 40 ], // upper
[135 , 40 ],
[-135 , 40 ],
[-45 , 40 ],
[25 , 0 ],   // middle
[75 , 0  ],
[130 , 0  ],
[180 , 0  ],
[-130 , 0 ],
[-75 , 0 ],
[-25 , 0 ],
[0 , -40  ],  // lower
[90 , -40  ],
[180 , -40  ],
[-90 , -40 ]];

~spk16 = VBAPSpeakerArray.new(3, ~speakerConfig1474 );

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

	panWeights = VBAP.kr(numChans: ~spk16.numSpeakers,
		in: 1.0,
		bufnum: ~vbuf16.bufnum,
		azimuth: aziDeg,
		elevation: eleDeg,
		spread: spread );

	outsig * Lag.kr(panWeights, 0.030);
};

~setup = { |satieInstance|

		~vbuf16 = Buffer.loadCollection(satieInstance.satieConfiguration.server, ~spk16.getSetsAndMatrices);

};


