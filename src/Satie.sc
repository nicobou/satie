//  This program is free software: you can redistribute it and/or modify
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
	var <>config;
	var <execFile;
	var options;
	var <>spat;
	var <>debug = true;
	var <satieRoot;

	var <mastering;

	/*    RENDERER     */
	// buses
	var <auxbus;
	var <aux;
	// compiled definitions
	var <generators, <effects, <processes;
	// instantiated
	var <groups, <groupInstances, <processInstances;
	// id associations: Synth.nodeID -> instance.name
	var <namesIds;
	// OSC
	var <osc;

	// introspection
	var <inspector;
	var <>generatedSynthDefs;

	// mastering spatialisation. one unique synth is generater per spatializer
	var <postProcessors;
	var postProcGroup;
	var <ambiPostProcessors;
	var ambiPostProcGroup;
	var <booted = false;
	var <>doneCb = nil;

	*new {|satieConfiguration, execFile = nil|
		^super.newCopyArgs(satieConfiguration, execFile).initRenderer;
	}


	// Private method
	initRenderer {
		// FIXME, remove those member duplication and rename satieConfiguration into a shorter name:
		options = config.serverOptions;
		satieRoot = config.satieRoot;
		debug = config.debug;
		postProcessors = Dictionary.new();
		ambiPostProcessors = Dictionary.new();
		groups = Dictionary.new();
		groupInstances = Dictionary.new();
		processInstances = Dictionary.new();
		generators = IdentityDictionary.new();
		effects = IdentityDictionary.new();
		processes = Dictionary.new();
		mastering = Dictionary.new();  // FIXME what is this for ? it seems useless
		namesIds = Dictionary.new();
	}

	// public method
	boot {
		config.server.boot;
		config.server.doWhenBooted({
			this.postExec();
			osc = SatieOSC(this);
			inspector = SatieIntrospection.new(this);
			ServerTree.add(this, config.server);
			CmdPeriod.add(this);
			booted = true;
			if (doneCb.notNil, {doneCb.value()});

			if(execFile.notNil, {
				"- Executing %".format(execFile).postln;
				this.executeExternalFile(execFile);
			});
		});
	}

	quit { |quitServer = true|
		CmdPeriod.remove(this);
		ServerTree.remove(this, config.server);
		this.cleanUp;
		osc.deleteAll;
		booted = false;
        if(quitServer, { config.server.quit });
	}

	executeExternalFile {|filepath|
		if ( File.existsCaseSensitive(filepath) == false,
			{
				error("SatieOSC: satieFileLoader:   "++filepath++" not found, aborting");
				^nil;
			},
			// else  file exists, process
			{
				if (filepath.splitext.last != "scd",
					{
						error("SatieOSC : satieFileLoader: "++filepath++" must be a file of type  '.scd'  ");
						^nil;
					},
					// else file type is good. Try to load
					{
						this.config.server.waitForBoot {
							try {
								filepath.load;
							}
							{|error|
								"Could not open file % because %".format(filepath, error).postln;
								^nil;
							};
							this.config.server.sync;
						}; // waitForBoot
					});
			});
	}

	doOnServerTree {
		"SATIE - creating default groups".postln;
		this.createDefaultGroups;
	}

	cmdPeriod {
		"SATIE - cleaning up the scene".postln;
		this.cleanUp;
	}

	createDefaultGroups {
		this.makeSatieGroup(\default, \addToHead);
		this.makeSatieGroup(\defaultFx, \addToTail);
		this.makePostProcGroup();
	}

	replacePostProcessor{ | pipeline, outputIndex = 0, spatializerNumber = 0, defaultArgs = #[] |
		config.server.doWhenBooted({
			var postprocname = "post_proc_"++spatializerNumber;
			SynthDef(postprocname,
				{
					var previousSynth = SynthDef.wrap({
						In.ar(config.outBusIndex[spatializerNumber],
							config.spatPlugins[config.listeningFormat[spatializerNumber]].numChannels
						);
					});
					// collecting spatializers
					pipeline.do { arg item;
						previousSynth = SynthDef.wrap(config.postprocessorPlugins.at(item).function, prependArgs: [previousSynth]);
						// add individual pipeline item to the dictionaries used by introspection
						groupInstances[\postProc].put(item.asSymbol, previousSynth);
						mastering.put(item.asSymbol, item.asSymbol);
					};
					ReplaceOut.ar(outputIndex, previousSynth);
			}).add;
			config.server.sync;
			postProcessors.at(postprocname.asSymbol).free();
			postProcessors.put(postprocname.asSymbol, Synth(postprocname.asSymbol, args: defaultArgs, target: postProcGroup));

		});
	}

	makeAmbiPostProcName{ | order = 1, spatializerNumber = 0 |
		^("ambipost_"++"_s"++spatializerNumber++"_o"++order).asString;
	}

	replaceAmbiPostProcessor{ | pipeline, order = 1, outputIndex = 0, spatializerNumber = 0, defaultArgs = #[] |
		config.server.doWhenBooted({
			var ambiPostProcName = this.makeAmbiPostProcName(order, spatializerNumber);
			var bformatBus = 0;
			config.ambiOrders.do { |item, i|
				if (item.asInt == order, {
					bformatBus = config.ambiBusIndex[i];
				});
			};
			SynthDef(ambiPostProcName,
				{
					var previousSynth = SynthDef.wrap({
						In.ar(bus: bformatBus.index, numChannels: (order+1).pow(2).asInt);
					});
					// backing the hoa pipeline
					pipeline.do { arg item;
						previousSynth = SynthDef.wrap(
							config.hoaPlugins.at(item).function,
						prependArgs: [previousSynth, order]);
						// add individual pipeline item to the dictionaries used by introspection
						groupInstances[\ambiPostProc].put(item.asSymbol, previousSynth);
					};
					Out.ar(outputIndex, previousSynth);
			}).add;
			config.server.sync;
			ambiPostProcessors.at(ambiPostProcName.asSymbol).free();
			ambiPostProcessors.put(
				ambiPostProcName.asSymbol,
				Synth(ambiPostProcName.asSymbol, args: defaultArgs, target: ambiPostProcGroup));
		});
	}

	getAmbiPostProc{ | order = 1, spatializerNumber = 0 |
		^ambiPostProcessors.at(this.makeAmbiPostProcName(order, spatializerNumber).asSymbol);
	}

	// private method
	makePostProcGroup {
		ambiPostProcGroup = ParGroup(1,\addToTail);
		groups.put(\ambiPostProc, ambiPostProcGroup);
		groupInstances.put(\ambiPostProc, Dictionary.new());
		postProcGroup = ParGroup(1,\addToTail);
		groups.put(\postProc, postProcGroup);
		groupInstances.put(\postProc, Dictionary.new());
	}

	setAuxBusses {
		postf("THIS IS THE SERVER OUTPUT BUS: %\n", config.server.outputBus);
		auxbus = Bus.audio(config.server, config.numAudioAux);
		postf("THIS IS THE SERVER AUX BUS: %\n", auxbus);

		aux = Array.fill(config.numAudioAux, {arg i; auxbus.index + i});
	}
	setAmbiBusses {
		config.ambiBusIndex = Array.newClear(config.ambiOrders.size());
		config.ambiOrders.do { arg item, i;
			config.ambiBusIndex[i] = Bus.audio(config.server, (item+1).pow(2));
		};
	}

	// private method
	postExec {
		// execute any code needed after the server has been booted
		this.createDefaultGroups;
		this.setAuxBusses();
		this.setAmbiBusses();
		// loading HRIR filters
		HOADecLebedev06.loadHrirFilters(config.server, config.hrirPath);
		HOADecLebedev26.loadHrirFilters(config.server, config.hrirPath);

		// execute setup functions for spatializers
		config.listeningFormat.do { arg item, i;
			// run .setup on spat plugin.
			// TODO: discuss generalization of this for any plugin.
			if ((config.spatPlugins[item.asSymbol].setup == nil).asBoolean,
				{ if(debug,
					{ "% - no setup here".format(config.spatPlugins[item].name).postln; }
				);
				},
				{ config.spatPlugins[item.asSymbol].setup.value(this) }
			);
		};
		config.server.sync;
		if (config.generateSynthdefs, {
			this.setupPlugins;
			this.makePlugins;
		});
	}

	setupPlugins {
		// execute setup functions in plugins
		config.audioPlugins.do { arg item, i;
			if (item.setup.notNil,
				{
					item.setup.value(this);
				});
		};
	}

	makePlugins {
		// generate synthdefs
		config.audioPlugins.do { arg item;
			if ((item.channelLayout == \mono).asBoolean,
				{
					this.makeSynthDef(item.name,item.name, [],[],[], config.listeningFormat, config.outBusIndex);
				});
			config.ambiOrders.do { |order, i|
				this.makeAmbi((item.name ++ "Ambi" ++ order.asSymbol), item.name, [], [], [], order, [], config.ambiBusIndex[i]);
			};
		};
		generatedSynthDefs = config.audioPlugins.keys;

	}
}
