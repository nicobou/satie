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

// === spat input args:
// aziDeg degrees (-180 to 180)
// elevDeg   degrees (-180 to 180)
// gainDB  decibels
// delaySec  seconds
// lpHz    hertz
// spread  units  (0 == directional, ....,  100 == omni)

// === Octo 3D speaker layout
// front left, front right, back left, back rigth


~name = \cube;

~function = {|in = 0, aziDeg = 0, eleDeg = 45, gainDB = -90, delayMs = 1, lpHz = 15000, hpHz = 1, spread = 0.0 |
	var gain= gainDB.dbamp;   // convert gainDB to gainAMP
	var delay = delayMs * 0.001;    // convert to seconds
	var slewDelay = 0.3; //  note: this needs to be improved ... smoother
	var slewGain = 0.1;
	var slewFilter = 0.6;
	var slewPanning = 0.030;
	var panWeights;
	var outsig;
	var max_ele = 30;
	var min_ele = -60;
	var aziSin;
	var aziCos;
	var eleFact;
	spread = spread.clip(0.0, 100.0) / 100.0;
	aziSin = (aziDeg * 0.01745329251994).sin;
	aziSin = aziSin.linlin(-1.0, 1.0, -1.0 + spread, 1.0 - spread);
	aziCos = (aziDeg * 0.01745329251994).cos;
	aziCos = aziCos.linlin(-1.0, 1.0, -1.0 + spread, 1.0 - spread);
	eleFact = (eleDeg.clip(min_ele, max_ele) - min_ele) / (max_ele - min_ele);
	eleFact = eleFact.linlin(0.0, 1.0, 0.0 + (spread / 2.0), 1.0 - (spread / 2.0));

	outsig =  LPF.ar(DelayC.ar(
		Lag.kr(gain, slewGain) * in,
		maxdelaytime: 0.5,
		delaytime: delay.lag(slewDelay)), lpHz.lag(slewFilter));

	outsig = BHiPass.ar(outsig, VarLag.kr(hpHz, slewFilter));

	// top first, then bottom
	panWeights = Pan4.kr(eleFact, aziSin, aziCos) ++ Pan4.kr(1.0 - eleFact, aziSin, aziCos);

	outsig * Lag.kr(panWeights, slewPanning);
};