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
		srcPreMonitorFuncsArray,
		spatSymbolArray,
		firstOutputIndexes = #[0],
		paramsMapper = \defaultMapper,
		synthArgs = #[]|

		var dico;
		if(spatSymbolArray.isEmpty, {
			"Running with no legacy sptializers".debug;
			^0;
		});
		if(satieConfiguration.audioPlugins.at(srcName) != nil,
			{
				if(satieConfiguration.audioPlugins.at(srcName).type != \mono, {
					"makesynthDef failed: audio source must be mono (% is not mono)".format(srcName).warn;
					^0;
				});
				dico = satieConfiguration.audioPlugins;
				generators.add(id.asSymbol -> srcName.asSymbol);
			}
		);
		if(satieConfiguration.fxPlugins.at(srcName) != nil,
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
		spatSymbolArray.collect({|item, i|
			if(satieConfiguration.spatPlugins.at(item).type != \mono, {
				"makesynthDef failed: spatializer must be mono (% is not mono)".format(item).warn;
				^0;
			});
		});

		SatieFactory.makeSynthDef(
			id,
			dico.at(srcName).function,
			srcPreToBusses,
			srcPostToBusses,
			srcPreMonitorFuncsArray.collect({|item, i|
				satieConfiguration.monitoringPlugins.at(item).function;
			}),
			spatSymbolArray.collect({|item, i|
				satieConfiguration.spatPlugins.at(item).function
			}),
			firstOutputIndexes,
			satieConfiguration.mapperPlugins.at(paramsMapper).function,
			synthArgs
		);
	}

	makeAmbi {|
		name,
		srcName,
		preBusArray,
		postBusArray,
		srcPreMonitorFuncsArray,
		ambiOrder,
		ambiEffectPipeline = #[],
		ambiBusIndex = 0,
		paramsMapper = \defaultMapper,
		synthArgs = #[] |

		var dico;
		if(satieConfiguration.audioPlugins.at(srcName) != nil,
			{
				dico = satieConfiguration.audioPlugins;
				generators.add(name.asSymbol -> srcName.asSymbol);
			}
		);
		if(satieConfiguration.fxPlugins.at(srcName) != nil,
			{
				dico = satieConfiguration.fxPlugins;
				effects.add(name.asSymbol -> srcName.asSymbol);
			}
		);
		if (satieConfiguration.debug,
			{
				"params mapper %".format(paramsMapper).postln;
			}
		);

		if(satieConfiguration.audioPlugins.at(srcName).type == \mono, {
			SatieFactory.makeAmbiFromMono(
				name,
				dico.at(srcName).function,
				preBusArray,
				postBusArray,
				srcPreMonitorFuncsArray.collect({|item, i|
					satieConfiguration.monitoringPlugins.at(item).function;
				}),
				ambiOrder,
				ambiEffectPipeline,
				ambiBusIndex,
				satieConfiguration.mapperPlugins.at(paramsMapper).function,
				synthArgs);
		},{ // else  (assuming type is \ambi
			SatieFactory.makeAmbi(
				name,
				dico.at(srcName).function,
				preBusArray,
				postBusArray,
				srcPreMonitorFuncsArray.collect({|item, i|
					satieConfiguration.monitoringPlugins.at(item).function;
				}),
				ambiOrder,
				ambiEffectPipeline,
				ambiBusIndex,
				satieConfiguration.mapperPlugins.at(paramsMapper).function,
				synthArgs);
		});
	}

	makeInstance {| name, synthDefName, group = \default, synthArgs = #[] |
		var synth, nodeID;
		synth = Synth(synthDefName, args: synthArgs, target: groups[group], addAction: \addToHead);
		if (groupInstances[group][name] != nil,
			{
				this.cleanInstance(name, group: group);
			}
		);
		nodeID = satieConfiguration.server.nextNodeID - 1; // FIXME: this is hack, but is it reliable?
		namesIds.put(name, nodeID);
		groupInstances[group].put(name, synth);
		^synth;
	}

	makeFxInstance{| name, synthDefName, group = \defaultFx, synthArgs = #[] |
		var fx;
		this.makeSatieGroup(group.asSymbol, \addToEffects);
		fx = this.makeInstance(name, synthDefName, group, synthArgs);
		^fx;
	}

	makeSourceInstance{| name, synthDefName, group = \default, synthArgs = #[] |
		var src;
		this.makeSatieGroup(group.asSymbol);
		src = this.makeInstance(name, synthDefName, group, synthArgs);
		^src;
	}

	makeKamikaze {| name, synthDefName, group = \default, synthArgs = #[] |
		var synth = Synth(synthDefName ++ "_kamikaze", args: synthArgs, target: groups[group], addAction: \addToHead);
		^synth;
	}

	makeSatieGroup { |  name, addAction = \addToHead |
		var group;
		//"Creating group %".format(name).postln;
		if ( groups.includesKey(name.asSymbol) == false,
			{
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
		);
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
		namesIds.removeAt(name);
	}

	pauseInstance {|name, group = \default |
		groupInstances[group][name].release();
	}

	makeProcess { | processName, env |
		this.removeProcess(processName);
		inform("satieProcessManager: registering process environment: "++processName);
		processes.put(processName.asSymbol, env);
		env[\satieInstance] = this;
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

		if (processes.includesKey(processName),
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

	// instantiate a process - also creates a unique group
	makeProcessInstance { | id, processName, addAction=\addToHead |
		var groupName, myProcess;
		groupName = (id++"_group").asSymbol;
		this.makeSatieGroup(groupName, addAction);
		myProcess = this.cloneProcess(processName.asSymbol);
		processInstances.put(id, myProcess);
		processInstances[id].setup(id, groupName);
		^processInstances;
	}

	cleanProcessInstance {  | id |
		var name = id;
		processInstances[name].cleanup;
		this.killSatieGroup((name++"_group").asSymbol);
		processInstances.removeAt(name);
	}
}