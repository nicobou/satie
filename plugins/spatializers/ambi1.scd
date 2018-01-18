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

// outputs a 4-channel spatialized output in ambisonic 1st order format

~name = \ambi1;
~description = "4-channel spatialized output in ambisonic 1st order format";
~numChannels = 4;
~channelLayout = \mono;

~function = {|in = 0, aziDeg = 0, eleDeg = 45, gainDB = -90, delayMs = 1, lpHz = 15000, hpHz = 1, spread = 1 |
	var gain= gainDB.dbamp;   // convert gainDB to gainAMP
	var delay = delayMs * 0.001;    // convert to seconds
	var slewDelay = 0.3; //  note: this needs to be improved ... smoother
	var slewGain = 0.1;
	var slewFilter = 0.6;
	var ambiVec;
	var sourceSig;
	var aziRad = aziDeg *  -0.01745329251994;   // invert azi for compatibility with other satie spatializers
	var eleRad = eleDeg * 0.01745329251994;


	sourceSig =  LPF.ar(DelayC.ar(
		Lag.kr(gain, slewGain) * in,
		maxdelaytime: 0.5,
		delaytime: delay.lag(slewDelay)),   lpHz.lag(slewFilter)    );

	sourceSig = BHiPass.ar(sourceSig, VarLag.kr(hpHz, slewFilter )  );

	ambiVec =   FoaPanB.ar(sourceSig, Lag.kr(aziRad, 0.01),  Lag.kr(eleRad, 0.01) );

};



~setup = { |satieInstance|
	// only install resource if the listening format requires it
	if ( satieInstance.satieConfiguration.listeningFormat.indexOf(\ambi1) != nil,
		{
			if (
				{
					var found = false;

					Quarks.installed.size.do( {|item|
						if (Quarks.installed[item].name == "Ctk", { found = true;});
					});
					found;}.value == false,
				{
					error("ambi1setup.scd: missing Ctk Quark,  Can't Continue.  Try:  Quarks.install(\"Ctk\")");
				},
				{
					// else resources are defined, evaluate
					var spatializerNumber = satieInstance.satieConfiguration.listeningFormat.indexOf(\ambi1);
					var outBusIndex = satieInstance.satieConfiguration.outBusIndex[spatializerNumber];
					Atk.userSupportDir=satieInstance.satieConfiguration.hrtfPath;   // this is need after each boot

					~atkFoaDecoder = FoaDecoderKernel.newListen(1002, s);   // create a global binaural decoder using listening set 1002  -  see list of possible id values below

					if (satieInstance.debug,
						{ postln("ambi1.scd->setup:  Configuring  ATK class instance"); }
					);

					satieInstance.satieConfiguration.hrtfPath.postln;   //time needed for this to initialize on the server side
					s.waitForBoot {
						s.sync;
						satieInstance.replacePostProcessor([\ambi1BinauralDecoder], outBusIndex, spatializerNumber);   // relies on global binaural decoder
					};
					"%:  automatically installing ambi1BinauralDecoder preprocessor for use with ambi1 listening format, " ++
					"with outBusIndex = % ".format(this.class, outBusIndex).warn;
			});
	});
}


// valid FoaDecoderKernel listening id's
/*
1002
1003
1004
1005
1006
1007
1008
1009
1012
1013
1014
1015
1016
1017
1018
1020
1021
1022
1023
1025
1026
1028
1029
1030
1031
1032
1033
1034
1037
1038
1039
1040
1041
1042
1043
1044
1045
1046
1047
1048
1049
1050
1051
1052
1053
1054
1055
1056
1057
1058
1059
*/





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
