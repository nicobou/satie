// Using ATK requres additional supercollider environment configuration
// 1.   install CTK composers tool kit quark)
// Quarks.gui

// or just type:   Quarks.install("Ctk");
//
// Atk.createUserSupportDir;    // installation of date sets is not needed sine the HRTF data is already located in the satie project  in  /utils/ATK
//Atk.openUserSupportDir;

// USES GLOBALS;
//   ~satieRootPath
//   ~ambiBus    // bus with multi-channel ambisonic encoded signal




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

		//  this will go away once we have the satie globals sorted out
		if ( ~satieRootPath == nil,
			{
				~satieRootPath = Platform.userHomeDir++"/Dropbox/Unity3D/audioRendering/satie";
		});


		Atk.userSupportDir=~satieRootPath++"/utils/ATK";   // this is need after each boot

		decoder = FoaDecoderKernel.newListen(1002, s);   // create a binaural decoder using listening set 1002

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
			~atkHRTF = Synth(\ambie1HRTF, [\inBus, ~ambiBus], 1, \addToTail);   // adding to the tail of Group(1)

			s.sync;

			postf("ambi1Listener.scd:  Creating AmbIEM Binaural listener, receiving 4 channel encoded ambisonic signal at buses: %", ~ambiBus);

		};   // end of waitForBoot

});   // end of IF / ELSE

)  // end of this local environment



/*
TO MOVE DECODER TO TAIL OF DSP  evalute the following:

~atkHRTF.moveToTail;

*/




/*
// Test Encoding Synth
SynthDef(\foaEncode3, {arg outBus, duration = 0.05, theta, phi;
var src, foa, env;

// our mono source
src = PinkNoise.ar(-6.dbamp);

// amplitude scaling envelope
env = EnvGen.kr(
Env([0, 1, 0], [0.5, 0.5], \sin),
timeScale: duration,
doneAction: 2);

// Encode into our foa signal
foa = FoaPanB.ar(src, theta, phi, env);

Out.ar(outBus, foa);
}).add;


// use a Routine to start many encoded signals at random angles
Routine.run({
20.do({
Synth(\foaEncode3, [\outBus, ambiBus, \theta, pi.rand2, \phi, 0]);
0.1.wait;
})
});


*/

/*
// next we define a synth using FoaPanB, and decoder using FoaDecode
SynthDef(\foaEncode1, {
var src, theta, phi, foa, out;

// our source: pink noise
src = PinkNoise.ar(-6.dbamp);

// theta is our angle on the X-Y plane and phi is our elevation
// use a MouseX to control theta in real time, from pi to -pi
theta = MouseX.kr(pi, -pi);
phi = 0;

// Encode into our foa signal
foa = FoaPanB.ar(src, theta, phi);

// decode our signal using our decoder defined above
out = FoaDecode.ar(foa, decoder);

Out.ar(0, out);
}).add;


// play the synth
a = Synth(\foaEncode1);

//free the synth
a.free;
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
