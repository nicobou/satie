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
	var server;
	var <>listeningFormat;
	var numAudioAux;
	var outBusIndex;
	var startupFiles;

	var <satieRoot;
	var <spat;
	var <options;
	var debug = true;
	// Plugins needed by the renderer
	var <>audioPlugins;
	var <>fxPlugins;
	var <>spatPlugins;
	var <>mapperPlugins;

	*new {| server, listeningFormat = "stereo", numAudioAux = 0, outBusIndex = 0, startupFiles = #[] |
		server = server ? Server.default;
		^super.newCopyArgs(server, listeningFormat, numAudioAux, outBusIndex, startupFiles).init;
	}

	init{
		satieRoot = this.class.filenameSymbol.asString.dirname;
		options = server.options;
		this.spatializer_(listeningFormat);
		// load plugins
		audioPlugins = SatiePlugins.new(satieRoot++"/audiosources/*.scd");
		fxPlugins = SatiePlugins.new(satieRoot++"/effects/*.scd");
		spatPlugins = SatiePlugins.new(satieRoot++"/spatializers/*.scd");
		mapperPlugins = SatiePlugins.new(satieRoot++"/mappers/*.scd");
		"New configuration: \nRoot: %\nSpat: %\nPlugins: %, %, %".format(
			this.satieRoot, spat, this.audioPlugins, this.fxPlugins, this.spatPlugins, this.mapperPlugins
		).postln;


	}

	handleListening_ { arg format;
		switch (format.asString ,
			"dodecNF",
			{
				spat  = \dodecNF;   // vbap to near field... outputs 20 chanels to soundFlower
				options.numOutputBusChannels = 28;
			},
			"sato",
			{
				spat  = \domeVBAP;
				options.numOutputBusChannels = 32;
			},
			"dodec",
			{
				spat  = \dodec;
				options.numOutputBusChannels = 28;
			},
			"labo",
			{
				spat  = \labodomeVBAP;
				options.numOutputBusChannels = 24;
			},
			"octo",
			{
				spat  = \octoVBAP;
				options.numOutputBusChannels = 8;
			},
			"cube",
			{
				spat  = \cubeVBAP;
				options.numOutputBusChannels = 8;
			},
			"mono",
			{
				spat  = \mono;
				options.numOutputBusChannels = 1;
			},
			"5one",
			{
				spat  = \five1VBAP;
				options.numOutputBusChannels = 6;
			},
			"quad",
			{
				spat  = \quadVBAP;
				options.numOutputBusChannels = 4;
			},
			"stereo",
			{
				spat  = \stereoListener;
				options.numOutputBusChannels = 2;
			},
			"ambi1",
			{
				spat = \ambi1;
				options.numOutputBusChannels = 2;
				options.blockSize = 64;    // ATK -  needs small buffer sizes or it complains
				"  - (Re)setting blocksize to 64, ATK requires small buffer sizes".warn;
			},
			"ambi3",
			{
				spat = \ambi3;
				options.numOutputBusChannels = 2;
				options.blockSize = 128;    // ATK -  needs small buffer sizes or it complains
				"  - (Re)setting blocksize to 128, ATK requires small buffer sizes".warn;
			},
			"1474",
			{
				spat = \_1474_VBAP;
				options.numOutputBusChannels = 16;
			}
		);
		"debug is %".format(debug).postln;
		// if (debug, {"yea".postln});
		if (debug, {
			postln("%: setting listening format to %\n".format(this.class, format));
		})
	}

		spatializer {
		^spat
	}

	spatializer_ { arg newSpat;
		this.handleListening_(newSpat);
	}
}