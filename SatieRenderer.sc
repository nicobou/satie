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