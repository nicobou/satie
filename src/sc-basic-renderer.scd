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
~scbrMaker = { | srcPath = "."|
	var e = Environment.make({
		// TODO use try catch with this
		~pluginLoader;
		~synthDefFactory;
		~cOSCMaker;

		~makeSynthDef = { | self, name, srcSymbol, spatSymbolArray, busShiftArray = #[0] |
			// TODO try catch
			self.synthDefFactory.makeSynthDef(name,
				self.pluginLoader.audioPlugins.at(srcSymbol),
				spatSymbolArray.collect({ arg item, i;
					self.pluginLoader.spatPlugins.at(item)}),
				busShiftArray);
			nil;
		};
	});  // Environment.make
	e.know = true;
	e.pluginLoader = ~scbrPlugins.value();
	e.synthDefFactory = ~scbrFactory.value();
	e.oscInterface = ~cOSCMaker.value();
	e;
};  // scbrMaker
)