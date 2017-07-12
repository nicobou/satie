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

// outputs a 16-channel spatialized output in ambisonic 3rd order format

~name = \ambi3;
~description = "16-channel spatialized output in ambisonic 3rd order format";
~numChannels = 16;

~function = {|in = 0, aziDeg = 0, eleDeg = 45, gainDB = -90, delayMs = 1, lpHz = 15000, hpHz = 1, spread = 1 |
	var gain= gainDB.dbamp;   // convert gainDB to gainAMP
	var delay = delayMs * 0.001;    // convert to seconds
	var slewDelay = 0.3; //  note: this needs to be improved ... smoother
	var slewGain = 0.1;
	var slewFilter = 0.6;
	var ambiVec;
	var sourceSig;
	var aziRad = aziDeg  * 0.01745329251994;
	var eleRad = eleDeg * 0.01745329251994;

	sourceSig =  LPF.ar(DelayC.ar(
		Lag.kr(gain, slewGain) * in,
		maxdelaytime: 0.5,
		delaytime: delay.lag(slewDelay)),   lpHz.lag(slewFilter)    );

	sourceSig = BHiPass.ar(sourceSig, VarLag.kr(hpHz, slewFilter )  );

	ambiVec = PanAmbi3O.ar(sourceSig, Lag.kr(aziRad, 0.01),  Lag.kr(eleRad, 0.01) );

};

/*

{
	Out.ar(10, PinkNoise.ar(0.8));
}.play;


SynthDef(\sheefa, ~function).add;
x = Synth("sheefa");
x.set(\gainDB, 0);
x.set(\in, 10);

x.set(\aziDeg, 1.15773);
x.set(\aziDeg, 3.14150);



x.free;

*/
