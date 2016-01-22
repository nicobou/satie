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

// labodome speaker layout
~spk24P = VBAPSpeakerArray.new(3, [
[0, 90],
[0, 60], [45, 60], [90, 60], [135, 60], [180, 60], [-135, 60], [-90, 60], [-45, 60],
[0, 20], [45, 20], [90, 20], [135, 20], [180, 20], [-135, 20], [-90, 20], [-45, 20],
[0, -15], [45, -15], [90, -15], [135, -15], [-135, -10], [-90, -10], [-45, -10],]);

~vbuf24P = Buffer.loadCollection(s, ~spk24P.getSetsAndMatrices);

~name = \labodomeVBAP_P;

~function = { | in = 0, aziDeg = 0, eleDeg = 45, gainDB = -90, delayMs = 1, lpHz = 15000, hpHz = 1, spread = 1, cloudAziScale = 1 |
	var gain= gainDB.dbamp;   // convert gainDB to gainAMP
	var delay = delayMs * 0.001;    // convert to seconds
	var slewDelay = 0.3; //  note: this needs to be improved ... smoother
	var slewGain = 0.1;
	var slewFilter = 0.6;
	var slewPanning = 0.030;
	var panWeights;
	var outsig;

	// extra state for random particle variation
	var randOffsetAzi = Rand(-180, 180);  // random offset for azimuth

	outsig =  LPF.ar(DelayC.ar(
		VarLag.kr(gain, slewGain) * in,
		maxdelaytime: 0.5,
		delaytime: delay.lag(slewDelay)),   lpHz.lag(slewFilter)    );

	outsig = BHiPass.ar(outsig, VarLag.kr(hpHz, slewFilter )  );

	panWeights = VBAP.kr(numChans: ~spk24P.numSpeakers,
		in: 1.0,
		bufnum: ~vbuf24P.bufnum,
	    azimuth: aziDeg + (randOffsetAzi * cloudAziScale),
		elevation: eleDeg,
		spread: spread );

	//SendTrig.kr(Impulse.kr(0.5), 0,  (aziDeg + offsetAzi)   );  //  Enable for debugging
	// SendTrig.kr(Impulse.kr(0.5), 0,  offsetAzi );  //  Enable for debugging
	outsig * Ramp.kr(panWeights, slewPanning);
};


// debug


/*
~OSCrn = OSCresponderNode(s.addr, '/tr', { |time, resp, msg| msg.postln }).add;
~OSCrn.remove;  // when done, you need to clean up the OSCresponderNode
a = ~function.play;
a.free;
*/

//  in synthdef
//SendTrig.kr(Impulse.kr(1), 0, freq);  