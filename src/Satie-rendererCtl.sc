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


//  Renderer Control   to manage  SATIE's global audio renderer state, connecting to the server's globals for output level control, etc.


+ SatieOSC {


	setOrientationDegHandler {
		^{ | args |

			if (satie.satieConfiguration.debug, {"→    %: message: %".format(this.class.getBackTrace, args).postln});

			if ( (args.size < 3 ) ,
				{"basicRendererCallback: setOrientationDeg: bad arg count: expects 2 args:  azimuth and  elevation".warn;},
				// else
				{
					satie.satieConfiguration.orientationOffsetDeg[0] = args[1].asFloat;
					satie.satieConfiguration.orientationOffsetDeg[1] = args[2].asFloat;
			})
		}
	}
}



/*

// ~satieRendererCallback = { "satieRendererCallback called".inform };
satieRendererCallback = {
arg msg;
var command = msg[1];

if (satie.satieConfiguration.debug, {"→    %: message: %".format(this.class.getBackTrace, msg).postln});



if (msg.size < 2,
{"~basicRendererCallback: empty message".warn;
postf("basicRendererCallback MESS LEN: %", msg.size);

},
// else
{
switch (command,
'setOrientationDeg',
{
if ( (msg.size < 4 ) ,
{"basicRendererCallback: setOrientationDeg missing value".warn;},
// else
{ satie.orientationOffsetDeg[0] = msg[2].asFloat;
satie.orientationOffsetDeg[1] = msg[3].asFloat; } );
},
'setNearFieldRadius',
{
if ( (msg.size < 3 ) ,
{"basicRendererCallback: setNearFieldRadius missing value".warn;},
// else
{ satie.nearFieldRadius = msg[2].asFloat; } );
},
'setNearFieldInvert',
{
if ( (msg.size < 3 ) ,
{"basicRendererCallback: setNearFieldInvert missing value".warn;},
// else
{ ~satie.nearFieldInvert = msg[2].asBoolean; } );
},
'setNearFieldExp',
{
if ( (msg.size < 3 ) ,
{"basicRendererCallback: setNearFieldExp missing value".warn;},
// else
{ ~satie.nearFieldExp = msg[2].asFloat; } );
},
'setOutputTrimDB',
{
if ( (msg.size < 3 ) ,
{"basicRendererCallback: setOutputTrimDB missing value".warn;},
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
{"basicRendererCallback: setOutputDB missing value".warn;},
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
{"basicRendererCallback: setOutputMute missing value".warn;
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
{"basicRendererCallback: freeSynths missing group name".warn;
// postf("freeSynths MESS LEN: %", msg.size);

},
// else
{
var groupSym = msg [2] .asSymbol;

~satie.satieGroups[groupSym].freeAll;
postf("basicRendererCallback: freeing all synths in % group", groupSym);
}
)
},
'setOutputMute',
{
//postf("~basicRendererCallback setMute: %\n", msg[2]);
if ( (msg.size < 3 ) ,
{"basicRendererCallback: setOutputDIM missing value".warn;  },
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
}
*/

