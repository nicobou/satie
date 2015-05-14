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
~scbrMaker = { | numAudioAux = 0 |
	var e = Environment.make({
		// TODO use try catch with this
		~pluginLoader;
		~synthDefFactory;
		~cOSCMaker;
		~defaultSatieGroup;
		~satieGroups = Dictionary.new;
		~auxbus;
		~aux;

		~makeSynthDef = { | self, name, srcSymbol, spatSymbolArray, busShiftArray = #[0], toBusArray = #[] |
			// TODO try catch
			self.synthDefFactory.makeSynthDef(name,
				self.pluginLoader.audioPlugins.at(srcSymbol),
				spatSymbolArray.collect({ arg item, i;
					self.pluginLoader.spatPlugins.at(item)}),
				busShiftArray,
				toBusArray);
			nil;  // return
		};

		~makeSatieGroup = { | self, name |
			// creating a global ProxySpace
			var prox = ProxySpace(s);
			prox.fadeTime = 0.5;
			// the proxyspace is going to be embedded in the global pargroup
			prox.group = ParGroup.new;
			self.satieGroups.put(name.asSymbol, prox);
			prox;
		};

		~makeInstance = { | self, name, synthDefName, prox = \default |
			// ensuring not extra bus is allocated:
			// (must be the first reference of "name" in the proxyspace
			self.satieGroups[prox][name].ar(0);
			self.satieGroups[prox][name].source = synthDefName;
			nil;
		};

		~cleanInstance = { | self, name, prox = \default |
			self.satieGroups[prox][name].release();
			// fadeTime must be higher than SATIE internal fadeTime:
			self.satieGroups[prox][name].clear(0.03);
			nil;
		};

		~pauseInstance = { | self, name, prox = \default |
			self.satieGroups[prox][name].release();
			nil;
		};

	});  // Environment.make

	e.know = true;
	e.auxbus = Bus.audio(s, numAudioAux);
	e.aux = Array.fill(numAudioAux, {arg i; e.auxbus.index + i });
	e.pluginLoader = ~scbrPlugins.value();
	e.synthDefFactory = ~scbrFactory.value();
	e.oscInterface = ~cOSCMaker.value();
	e.defaultSatieGroup = e.makeSatieGroup();
	e.satieGroups.put(\default, e.defaultSatieGroup);
	e;  // return
};  // scbrMaker
)