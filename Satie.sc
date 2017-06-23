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
	}

	configure {
		^satieConfiguration;
	}

	configure_ { | server, listeningFormat = "stereo", numAudioAux = 0, outBusIndex = 0, startupFiles = #[] |
		server = server ? Server.default;
		satieConfiguration = SatieConfiguration.new(server, listeningFormat, numAudioAux, outBusIndex, startupFiles);
	}
}