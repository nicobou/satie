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

+ Satie {

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
		if(satieConfiguration.audioPlugins.at(srcName) != nil,
			{
				dico = satieConfiguration.audioPlugins;
				generators.add(id.asSymbol -> srcName.asSymbol);
			},
			{
				dico = satieConfiguration.fxPlugins;
				effects.add(id.asSymbol -> srcName.asSymbol);
			}
		);
		if (satieConfiguration.debug,
			{
				"params mapper %".format(paramsMapper).postln;
			}
		);

		SatieFactory.makeSynthDef(
			id,
			dico.at(srcName).function,
			srcPreToBusses,
			srcPostToBusses,
			spatSymbolArray.collect({|item, i|
				satieConfiguration.spatPlugins.at(item).function
			}),
			firstOutputIndexes,
			satieConfiguration.mapperPlugins.at(paramsMapper).function,
			synthArgs
		);
	}

	makeInstance {| name, synthDefName, group = \default, synthArgs = #[] |
		var synth = Synth(synthDefName, args: synthArgs, target: groups[group], addAction: \addToHead);
		groupInstances[group].put(name, synth);
		^synth;
	}

	makeKamikaze {| name, synthDefName, group = \default, synthArgs = #[] |
		var synth = Synth(synthDefName ++ "_kamikaze", args: synthArgs, target: groups[group], addAction: \addToHead);
		^synth;
	}

	makeSatieGroup { |  name, addAction = \addToHead |
		var group;
		//"Creating group %".format(name).postln;
		if (addAction == \addToEffects,
			{
				group = ParGroup.new(groups[\defaultFx], \addAfter);
			},
			{
				group = ParGroup.new(addAction: addAction);
		});
		groups.put(name.asSymbol, group);
		groupInstances.put(name.asSymbol, Dictionary.new);
		^group;
	}

	killSatieGroup { | name |
		groups[name].free;
		groupInstances[name].free;
		groups.removeAt(name);
		groupInstances.removeAt(name);
	}

	cleanInstance {|name, group = \default |
		groupInstances[group][name].free();
		groupInstances[group].removeAt(name);
	}

	pauseInstance {|name, group = \default |
		groupInstances[group][name].release();
	}

	makeProcess { | processName, env |
		this.removeProcess(processName);
		inform("satieProcessManager: registering process environment: "++processName);
		processes.put(processName.asSymbol, env);
		env.satieInstance = this;
		env.know = true;
		^env;
	}

	removeProcess { | processName |
		if (  processes.includesKey(processName.asSymbol),
			{
				warn("un-registering process environment: "++processName);
				// FIXME check if free is needed
				processes.removeAt(processName.asSymbol);
		});
	}

	cloneProcess { | processName |
		var processClone = nil;

		if (processes.includesKey(processName.asSymbol),
			{
				var temp = processes.at(processName.asSymbol);
				processClone = temp.copy;
			},
			{
				warn("undefined process environment: "++processName);
				processClone = nil;
		});
		^processClone;
	}
}