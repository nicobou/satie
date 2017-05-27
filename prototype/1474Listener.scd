// Evaulate this file to create, or overwrite the ambisoinc decoder
// works in conjunction with the a \ambi3 spatializer
//
// Using AmbIEM requres additional supercollider environment configuration
// 1.   install AmbIEM Quark
// Quarks.gui

// or just type:   Quarks.install("AmbIEM");
//
// Atk.createUserSupportDir;    // installation of date sets is not needed sine the HRTF data is already located in the satie project  in  /utils/ATK
//Atk.openUserSupportDir;

// USES GLOBALS;
//   ~satieRootPath
//   ~outBusIndex    // bus with multi-channel ambisonic encoded signal  --- NEED GLOBAL ENVIRONMENT VARIABLE



(   // start of this local environment

var quarkFound = false;

Quarks.installed.size.do( {|item|
	if (Quarks.installed[item].name == "AmbIEM", { quarkFound = true;});
});

if (quarkFound == false,
	{
		error("1474Listener.scd: missing AmbIEM Quark,  Can't Continue.  Try:  Quarks.install(\"AmbIEM\")");
	},
	{
		// else resources are defined, evaluate


		//  this will go away once we have the satie global environment sorted out
		if ( ~satieRootPath == nil,
			{
				error("1474Listener:  ~satieRootPath undefined, can't continue");   // this should point to the satie root directory
		});

		// the famous 1_4_7_4  sixteen channel speaker configuration:  1 top, 4 upper, 7 ear-level, 4 below
		// a VBAP spatializer feeds to this inBus
		// The speaker positions [eleveation],[azimuth]
		e = [90,40,40,40,40,0,0,0,0,0,0,0,-40,-40,-40,-40];
		a = [0,45,135,225,315,25,75,130,180,230,285,335,0,90,180,270];

		// adjust your path to the Kemar data
		// this is relative to the SC3 folder
		Kemar.path = "/Users/zack/Dropbox/Unity3D/audioRendering/satie/prototype/.."++"/utils/hrtf/full";
		Kemar.initBuffers(a, e, s);



		s.waitForBoot {

			s.sync;


			// synthDef  outputs named auxBus on named outputChannel
			SynthDef(\_1474_to_binaural, { arg inBus,  outChan=0;
				var sigVec;
				var outsig;

				sigVec = In.ar(inBus, 16);   // reads the 16 channel spatiaized
				outsig =  Kemar.ar( sigVec);


				outsig = BLowShelf.ar(
				 	outsig,
				 	500,   // freq
				 	1.0, // q
				 18 ); // cut/boost




				Out.ar(outChan, outsig);
			}).add;


			s.sync;

			// start the decoder, reading bus ~ambiBus at the \tail of Group(1)
			if (~vbap2binaural != nil, {  ~vbap2binaural.free; });
			~vbap2binaural = Synth(\_1474_to_binaural, [\inBus, ~outBusIndex], 1, \addToTail);   // adding to the tail of Group(1)

			~vbap2binaural.set(\outChan, 0);

			s.sync;

			postf("1474Listener.scd:  Creating AmbIEM Binaural listener, receiving 16 channel VBAP signal at buses: %", ~outBusIndex);

		};  // end of wait for boot

});

)


/*
TO MOVE DECODER TO TAIL OF DSP  evalute the following:

~ambiemHRTF.moveToTail;

*/

