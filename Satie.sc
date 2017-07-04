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

/*
 * SATIE for SuperCollider3
 *
 */
Satie {

	var <server;
	var options;
	var <>spat;
	var <>debug = true;
	var <satieRoot;
	var <>satieConfiguration;
	// Plugins needed by the renderer
	var <>audioPlugins;
	var <>fxPlugins;
	var <>spatPlugins;
	var <>mapperPlugins;

	var <renderer;

	*new{|server|
		^super.new.init(server);
	}

	init {|server|
		"    - server: %".format(server).postln;
		//(satieRoot ++ "/src/*.scd").pathMatch.do({arg item; item.loadPaths});
		this.satieConfiguration = SatieConfiguration.new(this.server);
		options = this.satieConfiguration.options;
		satieRoot = satieConfiguration.satieRoot;
		debug = satieConfiguration.debug;
		audioPlugins = satieConfiguration.audioPlugins;
		fxPlugins = satieConfiguration.fxPlugins;
		spatPlugins = satieConfiguration.spatPlugins;
		mapperPlugins = satieConfiguration.mapperPlugins;

		renderer = SatieRenderer.new(satieConfiguration);
	}

	configure {
		^satieConfiguration;
	}

	configure_ { | server, listeningFormat = "stereo", numAudioAux = 0, outBusIndex = 0, startupFiles = #[] |
		server = server ? Server.default;
		satieConfiguration = SatieConfiguration.new(server, listeningFormat, numAudioAux, outBusIndex, startupFiles);
	}
}