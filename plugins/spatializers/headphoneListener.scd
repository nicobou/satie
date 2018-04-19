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
    nfIndex  (0 == farField Processing,   1 == nearField Processing)
*/


~name = \headphoneListener;
~description = "a stereo listener with near-field rendering";
~numChannels = 2;
~channelLayout = \mono;

~function = {|in = 0, aziDeg = 0, eleDeg = 0, gainDB = -99, delayMs = 1, lpHz = 22050, hpHz = 0.5, spread = 1, nfIndex = 0 |
	var i_headWidth = 22;   // centimeters -  22-23cm ->    660 μs ITD  -  Woodworth (1938)
	var i_interAuralDelay = i_headWidth / 34300;    // head-width-cm /  34300 centimeters per second (speed of sound)
	var gain= gainDB.dbamp;   // convert gainDB to gainAMP
	var delay = delayMs * 0.001;    // convert to seconds
	var slewDelay = 0.3; //  note: this needs to be improved ... smoother
	var slewGain = 0.1;
	var slewFilter = 0.3;   // was 0.6
	var slewHeadShadow = 0.3;
	var slewPanning = 0.02;
	var panWeights;
    var slewIAD = 0.1;
	var slewITD = 0.1;

	var aziScale = 0.01 * (100 - spread);
	var aziRads = aziDeg * 0.017453292519943;
	var rawIndex = aziRads.sin;  // normalized angle index
	var theta = aziScale * aziRads;  // radians
	var rawPanIndex = SinOsc.kr(0, theta );
	var sourceSig, stOutsig;

    //var nfIndexSmoothed = nfIndex.lag(slewFilter);
	// near field processing
	var nfScaler = (0.8 + (0.2 * nfIndex ));    // note: this defines the amount of "cross talk" for the far field
	var nfCutoff = 250;   // nearField shadowed ear cutoff HZ
	var ffCutoff = (SampleRate.ir * 0.5) - nfCutoff;

	var panIndex = rawPanIndex*nfScaler;

	var nfIndexNonlin = nfIndex.pow(2);  // bigger, sooner

	var nfProxDB = 10 * nfIndexNonlin;   // boost lows nDB  in the nearfield to contribute to the "proximity effect"

	var  posXlpfq  = (44100 * 0.5) - ( nfIndex * ffCutoff * rawPanIndex.clip(-1,0).abs.pow(0.5));  // pow offers more, sooner
	var  negXlpfq =  (44100 * 0.5) - ( nfIndex * ffCutoff * rawPanIndex.clip(0,1).pow(0.5));  // pow offers more, sooner


	var negXdelay = (i_interAuralDelay * rawIndex.clip(0,1).abs);
	var posXdelay = (i_interAuralDelay * rawIndex.clip(-1,0).abs);


	//  apply distance  filtering to direct signal
	sourceSig =  LPF.ar( Lag.kr(gain, slewGain)  * in,     Lag3.ar(K2A.ar(lpHz), slewFilter));
	sourceSig = BHiPass.ar(sourceSig, Lag3.ar(K2A.ar(hpHz), slewFilter));

	// apply nearField "proximity effect" bass boost below 200hz
	//sourceSig = BLowShelf.ar(sourceSig,  200, 1,    Lag.ar(K2A.ar(nfProxDB), slewGain));
	sourceSig = BLowShelf.ar(sourceSig,  200, 1,    Lag.kr(nfProxDB, slewGain));


	//  apply delay to direct signal
	sourceSig = DelayC.ar(sourceSig ,
		1.0 ,   // max delay time:   one second  (a sound at a distance of 323 meters or so)
		Lag3.ar(K2A.ar(delay), slewFilter));   //slewFilter

	//  pan direct signal
	stOutsig = Pan2.ar(sourceSig, VarLag.kr(panIndex, slewPanning )  );

	// apply interaural time difference
	stOutsig = DelayC.ar(stOutsig ,
		[ 0.006, 0.006] ,   // max delay time for interaural time difference  -- usually around  660μs  == 0.00066 secs
		[ Lag3.ar(K2A.ar(negXdelay), slewITD), Lag3.ar(K2A.ar(posXdelay), slewITD)]);

	// apply interaural highFq shadowing
   LPF.ar(stOutsig, [ Lag2.kr(negXlpfq, slewHeadShadow) , Lag2.kr(posXlpfq, slewHeadShadow) ]);

};

/*


*/