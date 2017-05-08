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
var ambiBus;

Quarks.installed.size.do( {|item|
	if (Quarks.installed[item].name == "AmbIEM", { quarkFound = true;});
});

if (quarkFound == false,
	{
		error("ambi3Listener.scd: missing AmbIEM Quark,  Can't Continue.  Try:  Quarks.install(\"AmbIEM\")");
	},
	{
		// else resources are defined, evaluate


		//  this will go away once we have the satie global environment sorted out
		if ( ~satieRootPath == nil,
			{
				error("ambi1Listener:  ~satieRootPath undefined, can't continue");   // this should point to the satie root directory
		});

		BinAmbi3O.kemarPath_(~satieRootPath++"/utils/hrtf/full");
		BinAmbi3O.init('1_4_7_4');   // spearker configuration:  1 top,  4 high, 7 ear level, and 4 low


		s.waitForBoot {

			s.sync;


			// synthDef  outputs named auxBus on named outputChannel
			SynthDef(\ambie3HRTF, { arg inBus,  outChan=0;
				var ambiVec;
				var outsig;

				ambiVec = In.ar(inBus, 16);   // reads the 16 channel encoded ambisonic signal bus
				outsig =  BinAmbi3O.ar(ambiVec);   // decodes for HRTF

				outsig = BLowShelf.ar(
					outsig,
					500,   // freq
					1.0, // q
					18 ); // cut/boost


				Out.ar(outChan, outsig);
			}).add;


			s.sync;

			// start the decoder, reading bus ~ambiBus at the \tail of Group(1)
			if (~ambiemHRTF != nil, {  ~ambiemHRTF.free; });
			~ambiemHRTF = Synth(\ambie3HRTF, [\inBus, ~outBusIndex], 1, \addToTail);   // adding to the tail of Group(1)

			s.sync;

			postf("ambi3Listener.scd:  Creating AmbIEM Binaural listener, receiving 16 channel encoded ambisonic signal at buses: %", ~ambiBus);

		};  // end of wait for boot

});

)


/*
TO MOVE DECODER TO TAIL OF DSP  evalute the following:

~ambiemHRTF.moveToTail;

*/

