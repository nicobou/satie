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

// writes spatialized output in ambisonic 3rd order format  to global ambisonic outBus

// Need a GLOBAL VARIABLE with the decoder AuxBusSend

~name = \ambi3;

~function = {|in = 0, aziDeg = 0, eleDeg = 45, gainDB = -90, delayMs = 1, lpHz = 15000, hpHz = 1, spread = 1 |
	var gain= gainDB.dbamp;   // convert gainDB to gainAMP
	var delay = delayMs * 0.001;    // convert to seconds
	var slewDelay = 0.3; //  note: this needs to be improved ... smoother
	var slewGain = 0.1;
	var slewFilter = 0.6;
	var ambiVec;
	var sourceSig;
	var aziRad = aziDeg * 0.01745329251994;
	var eleRad = eleDeg * 0.01745329251994;
	//var aziRad = aziDeg * 1;
	//var eleRad = eleDeg * 1;


	sourceSig =  LPF.ar(DelayC.ar(
		Lag.kr(gain, slewGain) * in,
		maxdelaytime: 0.5,
		delaytime: delay.lag(slewDelay)),   lpHz.lag(slewFilter)    );

	sourceSig = BHiPass.ar(sourceSig, VarLag.kr(hpHz, slewFilter )  );

	//sourceSig = PinkNoise.ar(0.8);
	ambiVec = PanAmbi3O.ar(sourceSig, Lag.kr(aziRad, 0.01),  Lag.kr(eleRad, 0.01) );
	Out.ar(100, ambiVec);

	// KLUGE:    outputs empty stereo and the spatialzied signal so that post-fx sends will work
	// a better way to provide the post-fx-send is neeed
	//
	[DC.ar(0.0), DC.ar(0.0), sourceSig];   // empty output to main outs, but a signal available for the post-spatialization send signal

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
