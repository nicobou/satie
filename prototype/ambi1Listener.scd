// Using ATK requres additional supercollider environment configuration
// 1.   install CTK composers tool kit quark)
// Quarks.gui

// or just type:   Quarks.install("Ctk");
//
// Atk.createUserSupportDir;    // installation of date sets is not needed sine the HRTF data is already located in the satie project  in  /utils/ATK
//Atk.openUserSupportDir;

// USES GLOBALS;
//   ~satieRootPath
//   ~outBusIndex    // bus with multi-channel ambisonic encoded signal  --- NEED GLOBAL ENVIRONMENT VARIABLE




(   // start of this local environment

var quarkFound = false;
var decoder;
var ambiBus;

Quarks.installed.size.do( {|item|
	if (Quarks.installed[item].name == "Ctk", { quarkFound = true;});
});

if (quarkFound == false,
	{
		error("ambi1Listener.scd: missing Ctk quark,  Can't Continue.  Try:  Quarks.install(\"Ctk\")");
	},
	{

		//  this will go away once we have the satie global environment sorted out
		if ( ~satieRootPath == nil,
			{
				error("ambi1Listener:  ~satieRootPath undefined, can't continue");   // this should point to the satie root directory
		});


		Atk.userSupportDir=~satieRootPath++"/utils/ATK";   // this is need after each boot

		decoder = FoaDecoderKernel.newListen(1002, s);   // create a binaural decoder using listening set 1002  -  see list of possible id values below

		s.waitForBoot {

			s.sync;

			// Decoding Synth
			SynthDef(\ambie1HRTF, {arg inBus, outChan=0;
				var foa, out;

				// read in 4 channels (B-format) from inBus
				foa = In.ar(inBus, 4);

				// decode to stereo
				out = FoaDecode.ar(foa, decoder);

				Out.ar(outChan, out);
			}).add;

			s.sync;

			// start the decoder, reading bus ~ambiBus at the \tail of Group(1)

			if (~atkHRTF != nil, {  ~atkHRTF.free; });
			~atkHRTF = Synth(\ambie1HRTF, [\inBus, ~outBusIndex], 1, \addToTail);   // adding to the tail of Group(1)

			s.sync;

			postf("ambi1Listener.scd:  Creating AmbIEM Binaural listener, receiving 4 channel encoded ambisonic signal at buses: %", ~ambiBus);

		};   // end of waitForBoot

});   // end of IF / ELSE

)  // end of this local environment


/*
TO MOVE DECODER TO TAIL OF DSP  evalute the following:

~atkHRTF.moveToTail;

*/

// valid newListen id's
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
