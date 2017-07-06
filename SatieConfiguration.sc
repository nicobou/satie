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
	var numAudioAux;
	var outBusIndex;

	var <satieRoot;
	var <spat;
	var <serverOptions;
	var debug = true;
	// Plugins needed by the renderer
	var <>audioPlugins;
	var <>fxPlugins;
	var <>spatPlugins;
	var <>mapperPlugins;

	*new {| server, listeningFormat = "stereo", numAudioAux = 0, outBusIndex = 0|
		server = server ? Server.supernova;
		^super.newCopyArgs(server, listeningFormat, numAudioAux, outBusIndex).init;
	}

	init{
		satieRoot = this.class.filenameSymbol.asString.dirname;
		serverOptions = server.options;
		this.handleListening_(listeningFormat);
		// load plugins
		audioPlugins = SatiePlugins.new(satieRoot++"/audiosources/*.scd");
		fxPlugins = SatiePlugins.new(satieRoot++"/effects/*.scd");
		spatPlugins = SatiePlugins.new(satieRoot++"/spatializers/*.scd");
		mapperPlugins = SatiePlugins.new(satieRoot++"/mappers/*.scd");
		if (debug,
			{
				"New configuration: \nRoot: %\nSpat: %\nPlugins: %, %, %".format(
					satieRoot, spat, audioPlugins, fxPlugins, spatPlugins, mapperPlugins
				).postln;
			}
		);
	}

	handleListening_ { arg format;
		switch (format.asString ,
			"dodecNF",
			{
				spat  = \dodecNF;   // vbap to near field... outputs 20 chanels to soundFlower
				serverOptions.numOutputBusChannels = 28;
			},
			"sato",
			{
				spat  = \domeVBAP;
				serverOptions.numOutputBusChannels = 32;
			},
			"dodec",
			{
				spat  = \dodec;
				serverOptions.numOutputBusChannels = 28;
			},
			"labo",
			{
				spat  = \labodomeVBAP;
				serverOptions.numOutputBusChannels = 24;
			},
			"octo",
			{
				spat  = \octoVBAP;
				serverOptions.numOutputBusChannels = 8;
			},
			"cube",
			{
				spat  = \cube;
				serverOptions.numOutputBusChannels = 8;
			},
			"mono",
			{
				spat  = \mono;
				serverOptions.numOutputBusChannels = 1;
			},
			"5one",
			{
				spat  = \five1VBAP;
				serverOptions.numOutputBusChannels = 6;
			},
			"quad",
			{
				spat  = \quadVBAP;
				serverOptions.numOutputBusChannels = 4;
			},
			"stereo",
			{
				spat  = \stereoListener;
				serverOptions.numOutputBusChannels = 2;
			},
			"ambi1",
			{
				spat = \ambi1;
				serverOptions.numOutputBusChannels = 2;
				serverOptions.blockSize = 64;    // ATK -  needs small buffer sizes or it complains
				"  - (Re)setting blocksize to 64, ATK requires small buffer sizes".warn;
			},
			"ambi3",
			{
				spat = \ambi3;
				serverOptions.numOutputBusChannels = 2;
				serverOptions.blockSize = 128;    // ATK -  needs small buffer sizes or it complains
				"  - (Re)setting blocksize to 128, ATK requires small buffer sizes".warn;
			},
			"1474",
			{
				spat = \_1474_VBAP;
				serverOptions.numOutputBusChannels = 16;
			}
		);
		if (debug, {
			postln("%: setting listening format to %\n".format(this.class, format));
		});
	}
}