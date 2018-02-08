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
	var <outBusIndex;
	var <>hrirPath;
	var <ambiOrders;  // array of wanted orders. Available orders are 1 to 5
	var <>ambiBusIndex; // array of bus indexes, related to the wanted orders specifyed in ambiOrders
	var <>debug = false;
	var <satieRoot;
	var <serverOptions;

	// Plugins needed by the renderer
	var <>audioPlugins;
	var <>fxPlugins;
	var <>spatPlugins;
	var <>mapperPlugins;
	var <>postprocessorPlugins;
	var <>hoaPlugins;

	// other options
	var <>orientationOffsetDeg;

	*new {| server, listeningFormat = #[\stereoListener, \stereoListener], numAudioAux = 0, outBusIndex = #[0], hrirPath = "~/.local/share/satie/ambitools/FIR/hrir/hrir_ku100_lebedev50/", ambiOrders = #[] |
		server = server;
		^super.newCopyArgs(server, listeningFormat, numAudioAux, outBusIndex, hrirPath.asString, ambiOrders).init;
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
		audioPlugins = SatiePlugins.newSource(pluginsPath++"/audiosources/*.scd");
		fxPlugins = SatiePlugins.newAudio(pluginsPath++"/effects/*.scd");
		spatPlugins = SatiePlugins.newSpat(pluginsPath++"/spatializers/*.scd");
		mapperPlugins = SatiePlugins.newAudio(pluginsPath++"/mappers/*.scd");
		postprocessorPlugins = SatiePlugins.newAudio(pluginsPath++"/postprocessors/*.scd");
		hoaPlugins = SatiePlugins.newAudio(pluginsPath++"/hoa/*.scd");
		if (debug, {
			"New configuration: \nRoot: %\nSpat: %\nPlugins: %, %, %, %".format(
				this.satieRoot, listeningFormat, this.audioPlugins, this.fxPlugins, this.spatPlugins, this.mapperPlugins, this.postprocessorPlugins
			).postln;
		});
		this.handleSpatFormat(listeningFormat);
		orientationOffsetDeg = [0, 0];
	}

	handleSpatFormat { arg format;
		serverOptions.numOutputBusChannels = outBusIndex.minItem;

		format.do { arg item, i;
			var spatPlugin = this.spatPlugins[item.asSymbol];
			serverOptions.numOutputBusChannels = serverOptions.numOutputBusChannels + spatPlugin.numChannels;
			if (debug, {
				postln("%: setting listening format to %\n".format(this.class, format));
				if (hrirPath != nil,
					{
						postln("\t %: setting HRIR path  to %\n".format(this.class, hrirPath));
				});
			});
		};
	}
}
