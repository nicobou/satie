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


//  ~satieRendererCtl    psudo class to manage the SATIE audio renderer state, connecting to the server's globals for output level control, etc.

//
// for debugguing
// ~thisDir = thisProcess.nowExecutingPath.dirname ;
//
//
//
// ~rootSrcPath = ~thisDir++ "/..";
//
// (~rootSrcPath ++ "/src/*.scd").pathMatch.do({arg item; item.loadPaths});
//
//
//
// s.waitForBoot{
//
// 	// create and initialize a sc-basic-renderer, and set environment variable
// 	if (~scbr == nil,{
// 		postln("loading SATIE kernal...");
// 		~scbr = ~scbrMaker.value(numAudioAux: 1, satieSrcPath: ~rootSrcPath);
// 	});
//
// 	if ( ~osc ==nil, {
// 		~osc = ~satieOSCMaker.value("/satie", 18032);
//
// 	});
//
//
// 	s.sync;
//
//
//
// };

// create instance to receive control messages via OSC on the rxPort
//          ~src = ~satieRendererCtl.value(~scbr, ~osc);




(
// psudo class to control  basic-renderer above
// Creates instance to receive control messages via OSC on the rxPort
// note: any OSC bindings of previous instances are destoyed before creation of a new instance
// so it is safe to call repeatedly

~satieRendererCtl = { | satieContext, oscContext |
	var satie = satieContext;
	var oscAddress = "/satie/rendererCtl";

	var e = Environment.make({


		// used for audio renderer control
		~volume = s.volume;     // create hook to global audio engine volume / mute control
		~volume.setVolumeRange(-99, 18);
		~outputDB = 0;    // current state of the supercollider's output
		~outputTrimDB = 0;
		~debugFlag=false;

		// ~satieRendererCallback = { "satieRendererCallback called".inform };
		~satieRendererCallback = {
			arg msg;
			var command = msg[1];

			if (~debugFlag == true,
				{
					postf("~basicRendererCallback: command: %, msg: %, \n", command, msg);
			});

			if (msg.size < 2,
				{"~basicRendererCallback: empty message".warn;
					postf("~basicRendererCallback MESS LEN: %", msg.size);

				},
				// else
				{

					switch (command,
						'setProjectDir',
						{
							if ( (msg.size != 3 ) ,
								{"~basicRendererCallback: setProjectDir bad arg count: expecting 'setProjectDir projectDirPath' ".warn;},
								// else
								{
									e.projectDirectory = msg[2];

									//e.projectDirectory.postln;
									postf("~basicRendererCallback: setProjectDir: % \n", e.projectDirectory);

								}
							)
						},
						'setOutputTrimDB',
						{
							if ( (msg.size < 3 ) ,
								{"~basicRendererCallback: setOutputTrimDB missing value".warn;},
								// else
								{
									e.outputTrimDB = msg[2];
									e.volume.volume = e.outputTrimDB + e.outputDB;
								}
							)
						},
						'setOutputDB',
						{
							if ( (msg.size < 3 ) ,
								{"~basicRendererCallback: setOutputDB missing value".warn;},
								// else
								{
									e.outputDB = msg[2];
									e.volume.volume = e.outputTrimDB + e.outputDB;
								}
							)
						},
						'setOutputDIM',
						{
							if ( (msg.size < 3 ) ,
								{"~basicRendererCallback: setOutputMute missing value".warn;
									// postf("CREATESOURCE MESS LEN: %", msg.size);

								},
								// else
								{
									if (msg [2] > 0,
										{  e.volume.volume = -30;  },
										// else
										{  e.volume.volume =  e.outputDB + e.outputTrimDB;   });
								}
							)
						},
						'freeSynths',
						{
							if ( (msg.size < 3 ) ,
								{"~basicRendererCallback: freeSynths missing group name".warn;
									// postf("freeSynths MESS LEN: %", msg.size);

								},
								// else
								{
									var groupSym = msg [2] .asSymbol;

									satie.satieGroups[groupSym].freeAll;
									postf("basicRendererCallback: freeing all synths in % group", groupSym);
								}
							)
						},
						'setOutputMute',
						{
							//postf("~basicRendererCallback setMute: %\n", msg[2]);
							if ( (msg.size < 3 ) ,
								{"~basicRendererCallback: setOutputDIM missing value".warn;  },
								// else
								{
									if (msg [2] > 0,
										{e.volume.mute;},
										// else
										{e.volume.unmute;} );  // full muting implmentation
								}
							);
						}
					)
			});
		};


		// now connect the OSC callback to this instance
		// OSCdef(~basicRendererCallbackID).clear.free;   // disconnect older instance,  if it exists
		// OSCdef(~basicRendererCallbackID, ~basicRendererCallback, oscAddress, recvPort: rxPort);  // set up OSC callback

	}); // Environment.make
	"satueRendererCtl loaded".inform;
	e.know = true;
		oscContext.removeRendererCtlOSC.value(); // remove any previous OSC  links to callback
		oscContext.makeRendererCtlOSC( e['satieRendererCallback'] );   // create OSC link to callback

	e;
};



)