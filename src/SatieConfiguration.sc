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

SatieConfiguration {
	var <server;
	var <>listeningFormat;
	var <numAudioAux;
	var outBusIndex;
	var <>debug = false;

	var <satieRoot;
	var <serverOptions;

	// Plugins needed by the renderer
	var <>audioPlugins;
	var <>fxPlugins;
	var <>spatPlugins;
	var <>mapperPlugins;

	// other options
	var <>orientationOffsetDeg;

	*new {| server, listeningFormat = \stereoListener, numAudioAux = 0, outBusIndex = 0|
		server = server ? Server.supernova;
		^super.newCopyArgs(server, listeningFormat, numAudioAux, outBusIndex).init;
	}

	init{
		var thisPath, pluginsPath;

		// the path of this class
		thisPath = PathName.new(this.class.filenameSymbol.asString.dirname);
		// the root of the SATIE quark
		satieRoot = thisPath.parentPath;
		// plugins
		pluginsPath = satieRoot+/+PathName("plugins");
		pluginsPath = pluginsPath.fullPath;
		serverOptions = server.options;
		// load plugins
		audioPlugins = SatiePlugins.newAudio(pluginsPath++"/audiosources/*.scd");
		fxPlugins = SatiePlugins.newAudio(pluginsPath++"/effects/*.scd");
		spatPlugins = SatiePlugins.newSpat(pluginsPath++"/spatializers/*.scd");
		mapperPlugins = SatiePlugins.newAudio(pluginsPath++"/mappers/*.scd");
		if (debug, {
			"New configuration: \nRoot: %\nSpat: %\nPlugins: %, %, %".format(
				this.satieRoot, listeningFormat, this.audioPlugins, this.fxPlugins, this.spatPlugins, this.mapperPlugins
			).postln;
		});
		this.handleSpatFormat(listeningFormat.asSymbol);
		orientationOffsetDeg = [0, 0];
	}

	handleSpatFormat { arg format;
		var thisPlugin = this.spatPlugins[format.asSymbol];
		serverOptions.numOutputBusChannels = thisPlugin.numChannels;
		if (debug, {
			postln("%: setting listening format to %\n".format(this.class, format));
		});
	}
}