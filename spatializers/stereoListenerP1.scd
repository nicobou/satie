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

~spk2 = VBAPSpeakerArray.new(2, [-60, 60]);



~vbuf2 = Buffer.loadCollection(s, ~spk2.getSetsAndMatrices);

~name = \stereoVBAP;

~function = {|in = 0, aziDeg = 0, eleDeg = 45, gainDB = -90, delayMs = 1, lpHz = 15000, hpHz = 1, spread = 1 |
	var gain= gainDB.dbamp;   // convert gainDB to gainAMP
	var delay = delayMs * 0.001;    // convert to seconds
	var slewDelay = 0.3; //  note: this needs to be improved ... smoother
	var slewGain = 0.1;
	var slewFilter = 0.6;
	var slewPanning = 0.030;
	var panWeights;
	var outsig;
	var randOffsetAzi = Rand(-180, 180);  // random offset for azimuth
	var dist = 0.343 * delayMs;   // speedOdSound: meters per milisecond == distance in meters
	var maxDist = 200;  // after 200 meters, the spreader clips to ZERO

	var distScaler = 1 - ( dist.clip(0, maxDist) / maxDist) ;

	var cloudSpread = 10;  	// use this exp value:  smaller values == greater cloud spread


	var offsetAzi = randOffsetAzi * (distScaler**cloudSpread);



	outsig =  LPF.ar(DelayC.ar(
		VarLag.kr(gain, slewGain) * in,
		maxdelaytime: 0.5,
		delaytime: delay.lag(slewDelay)),   lpHz.lag(slewFilter)    );

	outsig = BHiPass.ar(outsig, VarLag.kr(hpHz, slewFilter )  );

	panWeights = VBAP.kr(numChans: ~spk2.numSpeakers,
		in: 1.0,
		bufnum: ~vbuf2.bufnum,
		azimuth: aziDeg,
		elevation: eleDeg,
		spread: spread );
	SendTrig.kr(Impulse.kr(4), 0,  offsetAzi   );  //  Enable for debugging
	outsig * Lag.kr(panWeights, 0.030);
	Out.ar(0,outsig);
};

/*

SynthDef(\sheefa, ~function).add;
x = Synth("sheefa");
x.set("delayMs",0);
x.free;


*/

// debug
/*
o = OSCresponderNode(s.addr, '/tr', { |time, resp, msg| msg.postln }).add;
o.remove;  // when done, you need to clean up the OSCresponderNode
*/


