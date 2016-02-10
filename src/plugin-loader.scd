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
~scbrPlugins = {
	var e = Environment.make({
		~audioPlugins = Dictionary.new;
		~loadAudioPlugins = { | self,  path = "./*.scd" |
			path.pathMatch.do{ arg item;
				item.loadPaths;
				self.audioPlugins.put(~name.asSymbol, ~function);
			};
			nil;
		};
		~spatPlugins = Dictionary.new;
		~loadSpatPlugins = { | self,  path = "./*.scd" |
			path.pathMatch.do{ arg item;
				item.loadPaths;
				self.spatPlugins.put(~name.asSymbol, ~function);
			};
			nil;
		};
		~effectPlugins = Dictionary.new;
		~loadEffectPlugins = { | self,  path = "./*.scd" |
			path.pathMatch.do{ arg item;
				item.loadPaths;
				self.effectPlugins.put(~name.asSymbol, ~function);
			};
			nil;
		};
		~mapperPlugins = Dictionary.new;
		~loadMapperPlugins = { | self,  path = "./*.scd" |
			path.pathMatch.do{ arg item;
				item.loadPaths;
				self.mapperPlugins.put(~name.asSymbol, ~function);
			};
			nil;
		};
	});  // Environment.make
	e.know = true;
	e;
};  // scbrPlugins
)
