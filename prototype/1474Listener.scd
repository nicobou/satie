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




(
// start of this local environment

var quarkFound = false;
var vbapSpeakerArray;
var vbapBuffer;

// Set this value to the number of near field speakers you are using
~the1474PlayerCount = 8;   // default.  This will generate 8 listeners, evenly separated on the unit circle by 360/8 == 45 degrees


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
		// used also by corresponding spatializer
		// the famous 1_4_7_4  sixteen channel speaker configuration:  1 top, 4 upper, 7 ear-level, 4 below
		// a VBAP spatializer feeds to this inBus
		// The speaker positions [eleveation],[azimuth]
		e = [90,40,40,40,40,0,0,0,0,0,0,0,-40,-40,-40,-40];
		a = [0,45,135,225,315,25,75,130,180,230,285,335,0,90,180,270];

		// the aboves, represented using an array of azi,elev pairs
		~speakerConfig1474 = [
			[0 , 90 ],  // top
			[45 , 40 ], // upper
			[135 , 40 ],
			[-135 , 40 ],
			[-45 , 40 ],
			[25 , 0 ],   // middle
			[75 , 0  ],
			[130 , 0  ],
			[180 , 0  ],
			[-130 , 0 ],
			[-75 , 0 ],
			[-25 , 0 ],
			[0 , -40  ],  // lower
			[90 , -40  ],
			[180 , -40  ],
			[-90 , -40 ]];

		// adjust your path to the Kemar data
		// this is relative to the SC3 folder
		Kemar.path = "/Users/zack/Dropbox/Unity3D/audioRendering/satie/prototype/.."++"/utils/hrtf/full";
		Kemar.initBuffers(a, e, s);

		vbapSpeakerArray = VBAPSpeakerArray.new(3, ~speakerConfig1474 );
		vbapBuffer = Buffer.loadCollection(s, vbapSpeakerArray.getSetsAndMatrices);


		s.waitForBoot {

			s.sync;

			// synthDef  outputs named auxBus on named outputChannel
			SynthDef(\_1474_to_binaural, { arg inBus,  outChan=0, rotAziDeg=0;
				var sigVec, rotVec;
				var outsig;

				sigVec = In.ar(inBus, 16);   // reads the 16 channel spatiaized audio bus

				// send each channel of the signal to a corresponding vbap and accumulates a 16-channel output
				rotVec = VBAP.ar(16, sigVec[0], vbapBuffer.bufnum, ~speakerConfig1474[ 0][0]  + rotAziDeg,   ~speakerConfig1474[ 0][1] );
				rotVec =  rotVec + VBAP.ar(16, sigVec[1], vbapBuffer.bufnum, ~speakerConfig1474[ 1][0]  + rotAziDeg,   ~speakerConfig1474[ 1][1] );
				rotVec =  rotVec + VBAP.ar(16, sigVec[2], vbapBuffer.bufnum, ~speakerConfig1474[ 2][0]  + rotAziDeg,   ~speakerConfig1474[ 2][1] );
				rotVec =  rotVec + VBAP.ar(16, sigVec[3], vbapBuffer.bufnum, ~speakerConfig1474[ 3][0]  + rotAziDeg,   ~speakerConfig1474[ 3][1] );
				rotVec =  rotVec + VBAP.ar(16, sigVec[4], vbapBuffer.bufnum, ~speakerConfig1474[ 4][0]  + rotAziDeg,   ~speakerConfig1474[ 4][1] );
				rotVec =  rotVec + VBAP.ar(16, sigVec[5], vbapBuffer.bufnum, ~speakerConfig1474[ 5][0]  + rotAziDeg,   ~speakerConfig1474[ 5][1] );
				rotVec = rotVec + VBAP.ar(16, sigVec[6], vbapBuffer.bufnum, ~speakerConfig1474[ 6 ][0]  + rotAziDeg,   ~speakerConfig1474[ 6][1] );
				rotVec = rotVec + VBAP.ar(16, sigVec[7], vbapBuffer.bufnum, ~speakerConfig1474[ 7 ][0]  + rotAziDeg,   ~speakerConfig1474[ 7][1] );
				rotVec = rotVec + VBAP.ar(16, sigVec[8], vbapBuffer.bufnum, ~speakerConfig1474[ 8 ][0]  + rotAziDeg,   ~speakerConfig1474[ 8][1] );
				rotVec = rotVec + VBAP.ar(16, sigVec[9], vbapBuffer.bufnum, ~speakerConfig1474[ 9 ][0]  + rotAziDeg,   ~speakerConfig1474[ 8][1] );
				rotVec = rotVec + VBAP.ar(16, sigVec[10], vbapBuffer.bufnum, ~speakerConfig1474[ 10 ][0]  + rotAziDeg,   ~speakerConfig1474[ 10][1] );
				rotVec = rotVec + VBAP.ar(16, sigVec[11], vbapBuffer.bufnum, ~speakerConfig1474[ 11 ][0]  + rotAziDeg,   ~speakerConfig1474[ 11][1] );
				rotVec = rotVec + VBAP.ar(16, sigVec[12], vbapBuffer.bufnum, ~speakerConfig1474[ 12 ][0]  + rotAziDeg,  ~speakerConfig1474[ 12][1] );
				rotVec = rotVec + VBAP.ar(16, sigVec[13], vbapBuffer.bufnum, ~speakerConfig1474[ 13 ][0]  + rotAziDeg,  ~speakerConfig1474[13][1] );
				rotVec = rotVec + VBAP.ar(16, sigVec[14], vbapBuffer.bufnum, ~speakerConfig1474[ 14 ][0]  + rotAziDeg,   ~speakerConfig1474[ 14][1] );
				rotVec = rotVec + VBAP.ar(16, sigVec[15], vbapBuffer.bufnum, ~speakerConfig1474[ 15 ][0]  + rotAziDeg,   ~speakerConfig1474[ 15][1] );

				//rotVec.scope;

				outsig =  Kemar.ar( rotVec);   // convert to binaural


				outsig = BLowShelf.ar(
					outsig,
					500,   // freq
					1.0, // q
					18 ); // cut/boost

				Out.ar(outChan, outsig);
			}).add;


			s.sync;

			// GENERATE N  OUTPUT PLAYERS
			// clean the player array if need be
			if (~vbap2binauralPlayers!=nil,
				{
					~vbap2binauralPlayers.size.do( {|item|
						var itemName = "item"++item;
						~vbap2binauralPlayers.at(itemName.asSymbol).free;});
					~vbap2binauralPlayers.clear
				},
				// else its the first time,  create dictionary and ParGroup
				{
					~vbap2binauralPlayers = Dictionary.new;
					~vbap2binauralGroup = ParGroup(1,\addToTail);    // run the players in the context of a parallell group for supernova
			});

			// generate N players
			~the1474PlayerCount.do( {|item|
				var itemName = "item"++item;
				var azimuthDelta = 360/~the1474PlayerCount;
				~vbap2binauralPlayers.put(itemName.asSymbol,
					Synth(\_1474_to_binaural,
						[\inBus, ~outBusIndex, \rotAziDeg, item*azimuthDelta, \outChan, item*2],
						~vbap2binauralGroup ));

				postf("1474Listener: creating 1474 player with offset: %  on output % \n", item*azimuthDelta, item*2);
			});

			s.sync;

			postf("1474Listener.scd:  Creating AmbIEM Binaural listener, receiving 16 channel VBAP signal at buses: %", ~outBusIndex);

		};  // end of wait for boot

});

)   // end of local environment



/*


~the1474PlayerCount = 4;   // default

~vbap2binauralPlayers.at(\item0).set(\rotAziDeg, 155);
~vbap2binauralPlayers.at(\item0).set(\rotAziDeg, 0);

*/



/*
TO MOVE DECODER TO TAIL OF DSP  evalute the following:

~ambiemHRTF.moveToTail;

*/

