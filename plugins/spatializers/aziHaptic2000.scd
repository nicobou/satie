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

	in);
	aziDeg degrees (-180 to 180)
	elevDeg   degrees (-180 to 180)
	gainDB  decibels
	delaySec  seconds
	lpHz    hertz
	spread  units  (0 == directional, ....,  100 == omni)
*/

~name = \aziHaptic2000;
~description = "(Azimut only) 9 channel layout for haptic2000 prototype";
~numChannels = 9;
~channelLayout = \mono;

~function = {|in = 0, aziDeg = 0, eleDeg = 45, gainDB = -90, delayMs = 1, lpHz = 15000, hpHz = 1, spread = 1 |
	var gain= gainDB.dbamp;   // convert gainDB to gainAMP
	var delay = delayMs * 0.001;    // convert to seconds
	var slewDelay = 0.3; //  note: this needs to be improved ... smoother
	var slewGain = 0.1;
	var slewFilter = 0.6;
	var slewPanning = 0.030;
	var panWeights;
	var outsig;
	var a,b,c,d,e;
	var inrange_coef;
	var outrange_coef;

	inrange_coef = abs(cos((Clip.kr(aziDeg - [-90, -45, 0, 45, 90], -90, 90) ) * 0.01745329251994)).cubed;
	outrange_coef = (1 - abs((aziDeg - aziDeg.fold(-90, 90) / 180))).cubed;

	outsig =  LPF.ar(DelayC.ar(
		Lag.kr(gain, slewGain) * in,
		maxdelaytime: 0.5,
		delaytime: delay.lag(slewDelay)), lpHz.lag(slewFilter));

	outsig = BHiPass.ar(outsig, VarLag.kr(hpHz, slewFilter));

	#a, b, c, d, e = inrange_coef * outrange_coef;
	panWeights = [e, d, 0, a, b, c, 0, b, d]; // reorder to speaker arrangement

	outsig * Lag.ar(K2A.ar(panWeights), 0.030);
};


// s.reboot;
// s.meter;
//
//
// (
// {
// 	[0.01, 0.04, 0.9].normalize;
//
// 	Normalizer.ar([0.01,0.005,0.7]);
// }.scope;
// );
// (
// {
// 	var angle = -120;
// 	var inrange_coef;
// 	var outrange_coef;
// 	inrange_coef = cos((angle.clip(-90,90) - [-90, -45, 0, 45, 90]) * 0.01745329251994).normalize.cubed;
// 	outrange_coef = (1 - abs((angle - angle.fold(-90, 90) / 180))).cubed;
// 	SinOsc.ar() * inrange_coef * [outrange_coef, outrange_coef, outrange_coef, outrange_coef, outrange_coef];
// }.scope;
// )












































