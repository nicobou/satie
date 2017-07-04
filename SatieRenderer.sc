SatieRenderer {
	var <satieConfig;

	var <groups, <groupInstances, generators, effects;


	*new {|satieConfig|
		^super.newCopyArgs(satieConfig).initRenderer;
	}

	initRenderer {
		groups = Dictionary.new();
		groupInstances = Dictionary.new();
		generators = IdentityDictionary.new();
		effects = IdentityDictionary.new();
		groupInstances.put(\default, Dictionary.new);
		this.makeSatieGroup(\default);
	}

	makeSynthDef {|
		id,
		srcName,
		srcPreToBusses,
		srcPostToBusses,
		spatSymbolArray,
		firstOutputIndexes = #[0],
		paramsMapper = \defaultMapper,
		synthArgs = #[]|

		var dico;
		if(nil != satieConfig.audioPlugins.at(srcName),
			{
				dico = satieConfig.audioPlugins;
				generators.add(id.asSymbol -> srcName.asSymbol);
			},
			{
				dico = satieConfig.fxPlugins;
				effects.add(id.asSymbol -> srcName.asSymbol);
			}
		);

		"params mapper %".format(paramsMapper).postln;

		SatieFactory.makeSynthDef(
			id,
			dico.at(srcName).function,
			srcPreToBusses,
			srcPostToBusses,
			spatSymbolArray.collect({|item, i|
				satieConfig.spatPlugins.at(item).function
			}),
			firstOutputIndexes,
			satieConfig.mapperPlugins.at(paramsMapper).function,
			synthArgs
		);
	}

	makeInstance {| name, synthDefName, group = \default, synthArgs = #[] |
		var synth = Synth(synthDefName, args: synthArgs, target: groups[group], addAction: \addToHead);
		groupInstances[group].put(name, synth);
		^synth;
	}

	makeSatieGroup { |  name, addAction = \addToHead |
		var group = ParGroup.new(addAction: addAction);
		groups.put(name.asSymbol, group);
		groupInstances.put(name.asSymbol, Dictionary.new);
		^group;
	}
}