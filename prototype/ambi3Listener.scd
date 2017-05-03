// Evaulate this file to create, or overwrite the ambisoinc decoder
// works in conjunction with the a \ambi3 spatializer
//
// Using AmbIEM requres additional supercollider environment configuration
// 1.   install CTK composers tool kit quark)
// Quarks.gui

// or just type:   Quarks.install("AmbIEM");
//
// Atk.createUserSupportDir;    // installation of date sets is not needed sine the HRTF data is already located in the satie project  in  /utils/ATK
//Atk.openUserSupportDir;

// USES GLOBALS;
//   ~satieRootPath
//   NEEDED:   GLOBAL:   ambi3DecodeBus = 100...116



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

		// define 16 channel signal bus to accumulate the ambisonic encoded  output of the source nodes
		ambiBus = Bus.new(\ambi3_bus, 100, 16, s);   // this bus number is hardCoded in the audioSource




		if ( ~satieRootPath == nil,
			{
				~satieRootPath = Platform.userHomeDir++"/Dropbox/Unity3D/audioRendering/satie";
		});

		// ~satieRootPath = Platform.userHomeDir++"/Dropbox/Unity3D/audioRendering/satie";

		// AmbIEM binaural ambisonics hybrid

		// The speaker positions [eleveation],[azimuth]
		// e = [90,40,40,40,40,0,0,0,0,0,0,0,-40,-40,-40,-40];
		// a = [0,45,135,225,315,25,75,130,180,230,285,335,0,90,180,270];

		// adjust your path to the Kemar data
		//Kemar.path = "/Applications/SuperCollider/full/";
		// Kemar.path = ~satieRootPath++"utils/hrtf/full";
		// Kemar.initBuffers(a, e, s,0);



		BinAmbi3O.kemarPath_(~satieRootPath++"/utils/hrtf/full");
		BinAmbi3O.init('1_4_7_4');   // spearker configuration:  1 top,  4 high, 7 ear level, and 4 low





		s.waitForBoot {


/*			// synthDef  outputs named auxBus on named outputChannel
			SynthDef(\amBiPlayerOLD, { arg inChan=100,  outChan=0;
				var ambiVec;
				var decVec;
				var outsig;

				ambiVec = In.ar(inChan, 16);
				decVec = DecodeAmbi3O.ar(ambiVec, '1_4_7_4');
				outsig = Kemar.ar(decVec);

				Out.ar(outChan, outsig);
			}).add;
			*/

			// synthDef  outputs named auxBus on named outputChannel
			SynthDef(\ambie3HRTF, { arg inChan=100,  outChan=0;
				var ambiVec;
				var outsig;

				ambiVec = In.ar(inChan, 16);   // reads the 16 channel encoded ambisonic signal bus
				outsig =  BinAmbi3O.ar(ambiVec);   // decodes for HRTF

				Out.ar(outChan, outsig);
			}).add;


			s.sync;

			// start the decoder, reading bus ~ambiBus at the \tail of Group(1)
			if (~ambiemHRTF != nil, {  ~ambiemHRTF.free; });
			~ambiemHRTF = Synth(\ambie3HRTF, [\inBus, ambiBus], 1, \addToTail);

			postf("ambi3Listener.scd:  Creating AmbIEM Binaural listener, listening on buses: 100 to 116");

		};  // end of wait for boot

});

)


/*
TO MOVE DECODER TO TAIL OF DSP  evalute the following:

~ambiemHRTF.moveToTail;

*/




/*

Server.supernova;
	o = Server.local.options;   // default set up options
	o.blockSize = 128;

s.boot;

	p = ProxySpace.push;
	f = Platform.userHomeDir++"/Dropbox/Unity3D/audioRendering/satie";
	BinAmbi3O.kemarPath_(f++"/utils/hrtf/full");
	BinAmbi3O.init('1_4_7_4');
	~test = { EnvGen.kr(Env.adsr, Impulse.kr(3)) * PinkNoise.ar(0.8); };
	~enc = { PanAmbi3O.ar(~test.ar, MouseX.kr(-pi, pi), MouseY.kr(-pi, pi)) };
	~bin = { BinAmbi3O.ar(~enc.ar) };
	~bin.play

	// a second rendering engine for different output chans
	~bin2 = { BinAmbi3O.ar(~enc.ar) };
	~bin2.playN([2, 3]);

	ProxyMixer(p);
	p.pop





	*/


	