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
	var <>satieConfiguration;
	var options;
	var <>spat;
	var <>debug = true;
	var <satieRoot;

	// Plugins needed by the renderer
	var <>audioPlugins;
	var <>fxPlugins;
	var <>spatPlugins;
	var <>mapperPlugins;
	var <>postprocessorPlugins;

	/*    RENDERER     */
	// buses
	var <auxbus;
	var <aux;
	// compiled definitions
	var <generators, <effects, <processes;
	// instantiated
	var <groups, <groupInstances;

	var <osc;

	// introspection
	var <inspector;

	// mastering spatialisation. one unique synth is generater per spatializer
	var <postProcessors;
	var postProcGroup;

	*new {|satieConfiguration|
		^super.newCopyArgs(satieConfiguration).initRenderer;
	}


	// Private method
	initRenderer {
		options = satieConfiguration.serverOptions;
		satieRoot = satieConfiguration.satieRoot;
		debug = satieConfiguration.debug;
		audioPlugins = satieConfiguration.audioPlugins;
		fxPlugins = satieConfiguration.fxPlugins;
		spatPlugins = satieConfiguration.spatPlugins;
		mapperPlugins = satieConfiguration.mapperPlugins;
		postprocessorPlugins = satieConfiguration.postprocessorPlugins;
		postProcessors = Dictionary.new();
		groups = Dictionary.new();
		groupInstances = Dictionary.new();
		generators = IdentityDictionary.new();
		effects = IdentityDictionary.new();
		processes = Dictionary.new();

		postf("THIS IS THE SERVER OUTPUT BUS: %\n", satieConfiguration.server.outputBus);



		auxbus = Bus.audio(satieConfiguration.server, satieConfiguration.numAudioAux);
		postf("THIS IS THE SERVER AUX BUS: %\n", auxbus);

		aux = Array.fill(satieConfiguration.numAudioAux, {arg i; auxbus.index + i});
		osc = SatieOSC(this);
		inspector = SatieIntrospection.new(this);
	}

	boot {

		// pre-boot
		satieConfiguration.listeningFormat.do { arg item, i;
			if (item.asSymbol == \ambi3,
				{
					"%:  forcing the server block size to 128 as required by % spatializer ".format(this.class, item).warn;
					options.blockSize = 128;
				});
		};

		// boot
		satieConfiguration.server.boot;

		// post-boot
		satieConfiguration.server.doWhenBooted({this.makeSatieGroup(\default, \addToHead)});
		satieConfiguration.server.doWhenBooted({this.makeSatieGroup(\defaultFx, \addToTail)});
		satieConfiguration.server.doWhenBooted({this.makePostProcGroup()});
		satieConfiguration.server.doWhenBooted({this.postExec()});
	}

	// public method
	replacePostProcessor{ | pipeline, outputIndex = 0, spatializerNumber = 0, defaultArgs = #[] |
		satieConfiguration.server.doWhenBooted({
			var postprocname = "satie_post_processor_"++spatializerNumber;
			SynthDef(postprocname,
				{
					var previousSynth = SynthDef.wrap({
						In.ar(satieConfiguration.outBusIndex[spatializerNumber],
							this.spatPlugins[satieConfiguration.listeningFormat[spatializerNumber]].numChannels
						);
					});
					// collecting spatializers
					pipeline.do { arg item;
						previousSynth = SynthDef.wrap(postprocessorPlugins.at(item).function, prependArgs: [previousSynth]);
					};
					ReplaceOut.ar(outputIndex, previousSynth);
			}).add;
			satieConfiguration.server.sync;
			postProcessors.at(postprocname.asSymbol).free();
			postProcessors.put(postprocname.asSymbol, Synth(postprocname.asSymbol, args: defaultArgs, target: postProcGroup));
		});
	}

	// private method
	makePostProcGroup {
		postProcGroup = ParGroup(1,\addToTail);
	}

	// private method
	postExec {
		// execute any code needed after the server has been booted
		satieConfiguration.listeningFormat.do { arg item, i;
			// run .setup on spat plugin.
			// TODO: discuss generalization of this for any plugin.
			if ((spatPlugins[item.asSymbol].setup == nil).asBoolean,
				{ if(debug, 
					{ "% - no setup here".format(spatPlugins[item].name).postln; }
				);
				},
				{ spatPlugins[item.asSymbol].setup.value(this) }
			);
		}
	}
}