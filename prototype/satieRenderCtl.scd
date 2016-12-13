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




/*
for debugguing

// uncomment only for debugging


~src = ~satieRendererCtl.value(~oscInterface,~scbr);
~src.debugFlag = true;

*/


(
~satieRendererCtl = { | oscContext, satieContext, oscID = \satieRendererCtlOSC |
	var osc = oscContext;
	var satie = satieContext;

	var e = Environment.make({


		// used for audio renderer control
		~volume = s.volume;     // create hook to global audio engine volume / mute control
		~volume.setVolumeRange(-99, 18);
		~outputDB = 0;    // current state of the supercollider's output
		~outputTrimDB = 0;
		~debugFlag=false;



		// ~basicRendererCallback = { "basicRendererCallback called".inform };
		~basicRendererCallback = {
			arg msg;
			var command = msg[1];
			//postf("~basicRendererCallback: command: %, msg: %, \n", command, msg);

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
	}); // Environment.make
	"satie4unityprotol loaded".inform;
	e.know = true;
	//postf("passed osc env: %\n", osc);



	osc.removeBasicRendererOSC(\brOSC);   // remove if already instantiated
	osc.basicRendererOSC(\brOSC,e['basicRendererCallback']);
	e;
};



)