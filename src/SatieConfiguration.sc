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
	var <listeningFormat;
	var <numAudioAux;
	var <outBusIndex;
	var <ambiOrders;  // array of wanted orders. Available orders are 1 to 5
	var <minOutputBusChannels;
	var <>hrirPath;
	var <>ambiBusIndex; // array of bus indexes, related to the wanted orders specifyed in ambiOrders
	var <>debug = false;
	var <satieRoot;
	var <satieUserSupportDir;
	var <serverOptions;
	var <>generateSynthdefs = true;

	// Plugins needed by the renderer
	var <>audioPlugins;
	var <>fxPlugins;
	var <>spatPlugins;
	var <>mapperPlugins;
	var <>postprocessorPlugins;
	var <>hoaPlugins;
	var <>monitoringPlugins;

	// other options
	var <>orientationOffsetDeg;

	*new {| server, listeningFormat = #[\stereoListener], numAudioAux = 0, outBusIndex = #[0], ambiOrders = #[], minOutputBusChannels = 0, hrirPath |
		server = server;
		^super.newCopyArgs(server, listeningFormat, numAudioAux, outBusIndex, ambiOrders, minOutputBusChannels, hrirPath).init;
	}

	init {

		if(listeningFormat.size != outBusIndex.size) {
			Error("Mismatched arguments. There should be one outBusIndex value for each listeningFormat.").throw;
		};

		serverOptions = server.options;
		satieRoot = PathName(this.class.filenameSymbol.asString.dirname).parentPath;
		satieUserSupportDir = PathName(Platform.userAppSupportDir).parentPath +/+ "satie";

		hrirPath = hrirPath ?? {HOA.userKernelDir +/+ "FIR/hrir/hrir_ku100_lebedev50"};

		this.initDicts;
		this.initPlugins;

		if (debug, {
			"New configuration: \nRoot: %\nSpat: %\nPlugins: %, %, %, %".format(
				this.satieRoot, listeningFormat, this.audioPlugins, this.fxPlugins, this.spatPlugins, this.mapperPlugins, this.postprocessorPlugins
			).postln;
		});

		this.handleSpatFormat(listeningFormat);
		orientationOffsetDeg = [0, 0];
	}

	initDicts {

		audioPlugins = SatiePlugins.new;
		fxPlugins = SatiePlugins.new;
		spatPlugins = SatiePlugins.new;
		mapperPlugins = SatiePlugins.new;
		postprocessorPlugins = SatiePlugins.new;
		hoaPlugins = SatiePlugins.new;
		monitoringPlugins = SatiePlugins.new;
	}

	initPlugins {
		var userPlugsPath;

		this.loadPluginDir(satieRoot +/+ "plugins");

		userPlugsPath = satieUserSupportDir +/+ "plugins";
		if (PathName(userPlugsPath).isFolder.not) {
			"No plugins directory found at %".format(userPlugsPath).warn
		} {
			this.loadPluginDir(userPlugsPath)
		}
	}

	loadPluginDir { |path|

		audioPlugins.putAll(SatiePlugins.newSource(path +/+ "audiosources" +/+ "*.scd"));
		fxPlugins.putAll(SatiePlugins.newAudio(path +/+ "effects" +/+ "*.scd"));
		spatPlugins.putAll(SatiePlugins.newSpat(path +/+ "spatializers" +/+ "*.scd"));
		mapperPlugins.putAll(SatiePlugins.newAudio(path +/+ "mappers" +/+ "*.scd"));
		postprocessorPlugins.putAll(SatiePlugins.newAudio(path +/+ "postprocessors" +/+ "*.scd"));
		hoaPlugins.putAll(SatiePlugins.newAudio(path +/+ "hoa" +/+ "*.scd"));
		monitoringPlugins.putAll(SatiePlugins.newAudio(path +/+ "monitoring" +/+ "*.scd"));
	}

	handleSpatFormat { |format|
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
		if (serverOptions.numOutputBusChannels < this.minOutputBusChannels,  {serverOptions.numOutputBusChannels = this.minOutputBusChannels;});
	}

}
