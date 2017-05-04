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


(
~satieMaker = { | numAudioAux = 0, satieSrcPath|
	var e = Environment.make({
		// TODO use try catch with this
		~pluginLoader;
		~synthDefFactory;
		//~spatOSCMaker;
		~defaultSatieGroup;
		~satieGroups = Dictionary.new;
		~satieGroupInstances = Dictionary.new;
		~effectSynthDef = IdentityDictionary.new;
		~generatorSynthDef = IdentityDictionary.new;
		~auxbus;
		~aux;
		~satieSrcPath;
		// processes
		~processes = Dictionary.new;
		// near field attenuation radius -  attenuates all sounds beyond the near field radius around the listener
		~nearFieldRadius=0;     // disabled when ==  0, othwewise defines the radius for a spherical region of attenuation around the listener
		~nearFieldExp=1;   // transition quality across the region:   linear transition when == 1, otherwise exponential
		~nearFieldInvert = false;  // a when == true,  attenuates all sounds within the near field radius around the listener

		~makeSynthDef = {
			| self,
			name,
			srcSymbol, srcPreToBusses = #[], srcPostToBusses = #[],
			spatSymbolArray, firstOutputIndexes = #[0],
			paramsMapper = \defaultMapper,
			synthArgs = #[] |
			// selecting audio source or effect dictionay because
			// make instance require effects to be added to tail
			// and audio source to head
			var dictionary;
			if (nil != self.pluginLoader.audioPlugins.at(srcSymbol),
				{
					dictionary = self.pluginLoader.audioPlugins;
					postln("adding "++name.asSymbol++"->"++srcSymbol.asSymbol++" to generatorSynthDef");
					self.generatorSynthDef.add(name.asSymbol -> srcSymbol.asSymbol);
				},
				{
					dictionary = self.pluginLoader.effectPlugins;
					postln("adding "++name.asSymbol++"->"++srcSymbol.asSymbol++" to effectSynthDef");
					self.effectSynthDef.add(name.asSymbol -> srcSymbol.asSymbol);  // ? this needs to be figured out
				}
			); //  endif
			// Factory
			self.synthDefFactory.makeSynthDef(
				/*name:*/ name,
				/*src:*/ dictionary.at(srcSymbol),
				/*srcPreToBusses:*/ srcPreToBusses,
				/*srcPostToBusses:*/ srcPostToBusses,
				/*spatializers:*/ spatSymbolArray.collect({ arg item, i;
					self.pluginLoader.spatPlugins.at(item)}),
				/*firstOutputIndexes:*/ firstOutputIndexes,
				/*paramsMapper:*/ self.pluginLoader.mapperPlugins.at(paramsMapper),
				/*synthArgs:*/ synthArgs);
			nil;  // return
		};

		~makeSatieGroup = { | self, name, addAction = \addToHead |
			var group = ParGroup.new(addAction: addAction);  //adds groups to the default  Group(1)
			self.satieGroups.put(name.asSymbol, group);
			self.satieGroupInstances.put(name.asSymbol, Dictionary.new);
			group;
		};

		~killSatieGroup = { | self, name |
			// self.satieGroups[name].end;
			self.satieGroups[name].free;
			self.satieGroupInstances[name].free;
			self.satieGroups.removeAt(name);
			self.satieGroupInstances.removeAt(name);
			nil;
		};

		~makeInstance = { | self, name, synthDefName, group = \default, synthArgs = #[] |
			var synth = Synth(synthDefName, args: synthArgs, target: self.satieGroups[group], addAction: \addToHead );
			self.satieGroupInstances[group].put(name, synth);
			synth;
		};

		~makeKamikaze = { | self, name, synthDefName, group = \default, synthArgs = #[] |
			var synth = Synth(synthDefName ++ "_kamikaze", args: synthArgs, target: self.satieGroups[group], addAction: \addToHead );
			synth;
		};

		~cleanInstance = { | self, name, group = \default |
			// self.satieGroupInstances[group][name].release();
			// fadeTime must be higher than SATIE internal fadeTime:
			// self.satieGroupInstances[group][name].clear(0.03);
			// FIXME: the above method applied to NodeProxy handling. For now we will be a little more violent
			self.satieGroupInstances[group][name].free();
			self.satieGroupInstances[group].removeAt(name);
			nil;
		};

		~pauseInstance = { | self, name, group = \default |
			self.satieGroupInstances[group][name].release();
			nil;
		};

		// processes
		~makeProcess = { | self, processName, env |
			self.removeProcess(processName);
			inform("satieProcessManager: registering process environment: "++processName);
			self.processes.put(processName.asSymbol, env);
			env.know = true;
			env;
		};

		~cloneProcess = { | self, processName |
			var processClone = nil;

			if (self.processes.includesKey(processName.asSymbol),
				{
					var temp = self.processes.at(processName.asSymbol);
					processClone = temp.copy;
				},
				{
					warn("undefined process environment: "++processName);
					processClone = nil;
			});
			processClone;
		};

		~removeProcess =  { | self, processName |
			if (  self.processes.includesKey(processName.asSymbol) == true,
				{
					warn("un-registering process environment: "++processName);
					// FIXME check if free is needed
					self.processes.removeAt(processName.asSymbol);
			});
			nil;  // return nil
		};

	});  // Environment.make

	e.know = true;
	e.auxbus = Bus.audio(s, numAudioAux);
	e.aux = Array.fill(numAudioAux, {arg i; e.auxbus.index + i });
	e.pluginLoader = ~satiePlugins.value();
	e.synthDefFactory = ~satieFactory.value();
	e.makeSatieGroup(\defaultFx, \addToHead); // create defalutFx group
	e.defaultSatieGroup = e.makeSatieGroup(\default, \addToHead); // create default group in front of defaultFx group
	e.satieSrcPath = satieSrcPath;
	// loading plugins
	e.pluginLoader.loadAudioPlugins(e.satieSrcPath ++ "/audiosources/*.scd");
	e.pluginLoader.loadSpatPlugins(e.satieSrcPath ++ "/spatializers/*.scd");
	e.pluginLoader.loadEffectPlugins(e.satieSrcPath ++ "/effects/*.scd");
	e.pluginLoader.loadMapperPlugins(e.satieSrcPath ++ "/mappers/*.scd");
	e;  // return
};  // satieMaker
)
