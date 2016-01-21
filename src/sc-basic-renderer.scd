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
~scbrMaker = { | numAudioAux = 0, satieSrcPath |
	var e = Environment.make({
		// TODO use try catch with this
		~pluginLoader;
		~synthDefFactory;
		//~cOSCMaker;
		~defaultSatieGroup;
		~satieGroups = Dictionary.new;
		~satieGroupInstances = Dictionary.new;
		~effectSynthDef = Set.new;
		~auxbus;
		~aux;
		~satieSrcPath;

		// TODO try catch
		~makeSynthDef = { | self, name, srcSymbol, spatSymbolArray, busShiftArray = #[0], toBusArray = #[], synthArgs = #[] |
			// selecting audio source or effect dictionay because
			// make instance require effects to be added to tail
			// and audio source to head
			var dictionary;
			if (nil != self.pluginLoader.audioPlugins.at(srcSymbol),
				{
					dictionary = self.pluginLoader.audioPlugins;
				},
				{
					dictionary = self.pluginLoader.effectPlugins;
					self.effectSynthDef.add(name.asSymbol);
				}
			); //  endif
			// Factory
			self.synthDefFactory.makeSynthDef(name,
				dictionary.at(srcSymbol),
				spatSymbolArray.collect({ arg item, i;
					self.pluginLoader.spatPlugins.at(item)}),
				busShiftArray,
				toBusArray,
				synthArgs);
			nil;  // return
		};
		~makeSynthDef2 = {
			| self,
			name,
			srcSymbol, srcToBusses = #[],
			spatSymbolArray, firstOutputIndexes = #[0],
			paramsMapper,
			synthArgs = #[] |
			// selecting audio source or effect dictionay because
			// make instance require effects to be added to tail
			// and audio source to head
			var dictionary;
			if (nil != self.pluginLoader.audioPlugins.at(srcSymbol),
				{
					dictionary = self.pluginLoader.audioPlugins;
				},
				{
					dictionary = self.pluginLoader.effectPlugins;
					self.effectSynthDef.add(name.asSymbol);
				}
			); //  endif
			// Factory
			self.synthDefFactory.makeSynthDef(
				name: name,
				src: dictionary.at(srcSymbol),
				srcToBusses: srcToBusses,
				spatializers: spatSymbolArray.collect({ arg item, i;
					self.pluginLoader.spatPlugins.at(item)}),
				firstOutputIndexes: firstOutputIndexes,
				paramsMapper: paramsMapper,
				synthArgs: synthArgs);
			nil;  // return
		};

		~makeSatieGroup = { | self, name, addAction = \addToHead |
			// creating a global ProxySpace
			// var prox = ProxySpace(s);
			// prox.fadeTime = 0.5;
			// the proxyspace is going to be embedded in the global pargroup
			var group = ParGroup.new(addAction: addAction);
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


		~makeInstance = { | self, name, synthDefName, group = \default |
			// ensuring not extra bus is allocated:
			// (must be the first reference of "name" in the proxyspace
			// self.satieGroups[name].ar(0);
			// self.satieGroups[name].source = synthDefName;
			var synth = Synth(synthDefName, target: self.satieGroups[group], addAction: \addToHead );
			self.satieGroupInstances[group].put(name, synth);
			// self.satieGroups[group].postln;
			synth;
			// self.satieGroups.postln;
			// self.satieGroups[name];
			//nil;
		};

		~cleanInstance = { | self, name, group = \default |
			self.satieGroupInstances[group][name].release();
			// fadeTime must be higher than SATIE internal fadeTime:
			self.satieGroupInstances[group][name].clear(0.03);
			self.satieGroupInstances[group].removeAt(name);
			nil;
		};

		~pauseInstance = { | self, name, group = \default |
			self.satieGroupInstances[group][name].release();
			nil;
		};
	});  // Environment.make

	e.know = true;
	e.auxbus = Bus.audio(s, numAudioAux);
	e.aux = Array.fill(numAudioAux, {arg i; e.auxbus.index + i });
	e.pluginLoader = ~scbrPlugins.value();
	e.synthDefFactory = ~scbrFactory.value();
	e.defaultSatieGroup = e.makeSatieGroup();
	e.satieGroups.put(\default, e.defaultSatieGroup);
	e.satieGroupInstances.put(\default, Dictionary.new);
	e.satieSrcPath = satieSrcPath;
	// loading plugins
	e.pluginLoader.loadAudioPlugins(e.satieSrcPath ++ "/audiosources/*.scd");
	e.pluginLoader.loadSpatPlugins(e.satieSrcPath ++ "/spatializers/*.scd");
	e.pluginLoader.loadEffectPlugins(e.satieSrcPath ++ "/effects/*.scd");
	e;  // return
};  // scbrMaker
)