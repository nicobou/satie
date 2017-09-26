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
				{
					"→    %: message: bad arg count: expects 2 values:  azimuth and  elevation".format(this.class.getBackTrace).error
				},
				// else
				{
					satie.satieConfiguration.orientationOffsetDeg[0] = args[1].asFloat;
					satie.satieConfiguration.orientationOffsetDeg[1] = args[2].asFloat;
			})
		}
	}


	setOutputDBHandler {
		^{ | args |

			if (satie.satieConfiguration.debug, {"→    %: message: %".format(this.class.getBackTrace, args).postln});

			if ( (args.size < 2 ) ,
				{
					"→    %: message: bad arg count: expects 1 value:  outputDB".format(this.class.getBackTrace).error
				},
				// else
				{
					outputDB = args[1].asFloat;
					satie.satieConfiguration.server.volume = outputTrimDB + outputDB;
			})
		}
	}

	setOutputDBTrimHandler {
		^{ | args |

			if (satie.satieConfiguration.debug, {"→    %: message: %".format(this.class.getBackTrace, args).postln});

			if ( (args.size < 2 ) ,
				{
					"→    %: message: bad arg count: expects 1 value:  outputDBTrim".format(this.class.getBackTrace).error
				},
				// else
				{
					outputTrimDB = args[1].asFloat;
					satie.satieConfiguration.server.volume = outputTrimDB + outputDB;
			})
		}
	}

	setOutputMuteHandler {
		^{ | args |

			if (satie.satieConfiguration.debug, {"→    %: message: %".format(this.class.getBackTrace, args).postln});

			if ( (args.size < 2 ) ,
				{
					"→    %: message: bad arg count: expects 1 value:  muteFlag".format(this.class.getBackTrace).error
				},
				// else
				{
					if (args [1] > 0,
						{satie.satieConfiguration.server.volume.mute;},
						// else
						{satie.satieConfiguration.server.volume.unmute;} );  // full muting implmentation

			})
		}
	}

	setOutputDimHandler {
		^{ | args |

			if (satie.satieConfiguration.debug, {"→    %: message: %".format(this.class.getBackTrace, args).postln});

			if ( (args.size < 2 ) ,
				{
					"→    %: message: bad arg count: expects 1 value:  dimFlag".format(this.class.getBackTrace).error
				},
				// else
				{

					if (args [1] > 0,
						{  satie.satieConfiguration.server.volume = -30;  },
						// else
						{  satie.satieConfiguration.server.volume =  outputDB + outputTrimDB;   });

			})
		}
	}

		freeSynthsHandler {
		^{ | args |

			if (satie.satieConfiguration.debug, {"→    %: message: %".format(this.class.getBackTrace, args).postln});

			if ( (args.size < 2 ) ,
				{
					"→    %: message: bad arg count: expects 1 symbol:  groupName".format(this.class.getBackTrace).error
				},
				// else
				{
					var groupName = args [1].asSymbol;

					if ( satie.groups[groupName] != nil,
						{
							satie.groups[groupName].freeAll;
							postf("SatieOSC.freeSynthsHandler: freeing all synths in % group/n", groupName);
					});

			});
		}
	}




}


/*    THE REMAINING HOOKS RELATE TO THE NEAR FIELD PROCESSING, AND NEED TO BE REDEPLOYED IN SATIE

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




*/