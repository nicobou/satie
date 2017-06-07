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

// Set this value to the number of near field speakers you are using
~the1474PlayerCount = 4;   // default.  This will generate 8 listeners, evenly separated on the unit circle by 360/8 == 45 degrees


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
		// a VBAP spatializer feeds with this configuration to this inBus
		// Below, the speaker positions [azimuth, elevation] of the configuration

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

		BinAmbi3O.kemarPath_(~satieRootPath++"/utils/hrtf/full");
		BinAmbi3O.init('1_4_7_4');   // spearker configuration:  1 top,  4 high, 7 ear level, and 4 low

		// generate parGroups for supernova use
		if (~parGroups == nil,
			{
				~parGroups = Array.new(16);
				16.do( {|item|
					~parGroups.add( ParGroup(1,\addToTail));
				});
		});

		~speakerConfig1474Rad = Array.new(16);    // translate the configuration in radians for ambIEM
		~speakerConfig1474.size.do( {|item|
			~speakerConfig1474Rad.add([~speakerConfig1474[item][0].degrad, ~speakerConfig1474[item][1].degrad]);
		});

		s.waitForBoot {

			s.sync;

			// synthDef  outputs named auxBus on named outputChannel
			SynthDef(\_1474_to_binaural, { arg inBus,  outChan=0, rotAziDeg=0;
				var sigVec, rotVec;

				var ambiVec;
				var rotAziRad = rotAziDeg*0.017453292519943;
				var outsig;

				sigVec = In.ar(inBus, 16);   // reads the 16 channel spatiaized audio bus

				// send each channel of the signal to a corresponding ambisonics panner and accumulate a 16-channel ambisonics signal
				ambiVec = PanAmbi3O.ar(sigVec[0], ~speakerConfig1474Rad[ 0][0] + rotAziRad,   ~speakerConfig1474Rad[ 0][1] );
				ambiVec = ambiVec + PanAmbi3O.ar(sigVec[1], ~speakerConfig1474Rad[ 1 ][0] + rotAziRad,   ~speakerConfig1474Rad[ 1 ][1] );
				ambiVec = ambiVec + PanAmbi3O.ar(sigVec[2], ~speakerConfig1474Rad[ 2 ][0] + rotAziRad,   ~speakerConfig1474Rad[ 2 ][1] );
				ambiVec = ambiVec + PanAmbi3O.ar(sigVec[3], ~speakerConfig1474Rad[ 3 ][0] + rotAziRad,   ~speakerConfig1474Rad[ 3 ][1] );
				ambiVec = ambiVec + PanAmbi3O.ar(sigVec[4], ~speakerConfig1474Rad[ 4 ][0] + rotAziRad,   ~speakerConfig1474Rad[ 4 ][1] );
				ambiVec = ambiVec + PanAmbi3O.ar(sigVec[5], ~speakerConfig1474Rad[ 5 ][0] + rotAziRad,   ~speakerConfig1474Rad[ 5 ][1] );
				ambiVec = ambiVec + PanAmbi3O.ar(sigVec[6], ~speakerConfig1474Rad[ 6 ][0] + rotAziRad,   ~speakerConfig1474Rad[ 6 ][1] );
				ambiVec = ambiVec + PanAmbi3O.ar(sigVec[7], ~speakerConfig1474Rad[ 7 ][0] + rotAziRad,   ~speakerConfig1474Rad[ 7 ][1] );
				ambiVec = ambiVec + PanAmbi3O.ar(sigVec[8], ~speakerConfig1474Rad[ 8 ][0] + rotAziRad,   ~speakerConfig1474Rad[ 8 ][1] );
				ambiVec = ambiVec + PanAmbi3O.ar(sigVec[9], ~speakerConfig1474Rad[ 9 ][0] + rotAziRad,   ~speakerConfig1474Rad[ 9 ][1] );
				ambiVec = ambiVec + PanAmbi3O.ar(sigVec[10], ~speakerConfig1474Rad[ 10 ][0] + rotAziRad,   ~speakerConfig1474Rad[ 10 ][1] );
				ambiVec = ambiVec + PanAmbi3O.ar(sigVec[11], ~speakerConfig1474Rad[ 11 ][0] + rotAziRad,   ~speakerConfig1474Rad[ 11 ][1] );
				ambiVec = ambiVec + PanAmbi3O.ar(sigVec[12], ~speakerConfig1474Rad[ 12 ][0] + rotAziRad,   ~speakerConfig1474Rad[ 12 ][1] );
				ambiVec = ambiVec + PanAmbi3O.ar(sigVec[13], ~speakerConfig1474Rad[ 13 ][0] + rotAziRad,   ~speakerConfig1474Rad[ 13 ][1] );
				ambiVec = ambiVec + PanAmbi3O.ar(sigVec[14], ~speakerConfig1474Rad[ 14 ][0] + rotAziRad,   ~speakerConfig1474Rad[ 14 ][1] );
				ambiVec = ambiVec + PanAmbi3O.ar(sigVec[15], ~speakerConfig1474Rad[ 15 ][0] + rotAziRad,   ~speakerConfig1474Rad[ 15 ][1] );

				outsig =  BinAmbi3O.ar(ambiVec);   // decodes for HRTF
				outsig = BLowShelf.ar(
					outsig,
					500,   // freq
					1.0, // q
					18 ); // cut/boost



/*				outsig = BPeakEQ.ar(
					outsig,
					eqHz,   // center frequeency
					1, // rq
					eqDB); // attenuation*/


				Out.ar(outChan, outsig);
			}).add;

			s.sync;

			// GENERATE  N  OUTPUT LISTENERS

			// 1.  clean the player array if need be
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
			});

			// 2.  generate N players
			~the1474PlayerCount.do( {|item|
				var itemName = "item"++item;
				var azimuthDelta = 360/~the1474PlayerCount;
				~vbap2binauralPlayers.put(itemName.asSymbol,
					Synth(\_1474_to_binaural,
						[\inBus, ~outBusIndex, \rotAziDeg, item*azimuthDelta, \outChan, item*2],
						~parGroups[item] ));

				postf("1474Listener: creating 1474 player with offset: %  on output % \n", item*azimuthDelta, item*2+1);
			});

			s.sync;

			postf("1474Listener.scd:  Creating AmbIEM Binaural listener, receiving 16 channel VBAP signal at buses: %", ~outBusIndex);

		};  // end of wait for boot

});

)   // end of local environment


/*

~vbap2binauralGroup2 = ParGroup(1,\addToTail);    // run the players in the context of a parallell group for supernova


a=Synth(\_1474_to_binaural, [\inBus, ~outBusIndex, \rotAziDeg, 0, \outChan,0], ~vbap2binauralGroup );

a.free


b=Synth(\_1474_to_binaural, [\inBus, ~outBusIndex, \rotAziDeg, 0, \outChan,2], 1, \addToTail   );
b=Synth(\_1474_to_binaural, [\inBus, ~outBusIndex, \rotAziDeg, 0, \outChan,2], ~vbap2binauralGroup2 );

b.free

~the1474PlayerCount = 4;   // default

~vbap2binauralPlayers.at(\item0).set(\rotAziDeg, 155);
~vbap2binauralPlayers.at(\item0).set(\rotAziDeg, 0);







TO MOVE DECODER TO TAIL OF DSP  evalute the following:

~ambiemHRTF.moveToTail;

*/

