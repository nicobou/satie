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

SatiePlugins : Dictionary {

	*newAudio {|path|
		^super.new.audioPath(path);
	}

	*newSpat {|path|
		^super.new.spatializerPath(path);
	}


	/*
	*  Append plugins from path
	*/
	audioPath { arg path;
		path.pathMatch.do{arg item;
			item.loadPaths;
			this.add(~name.asSymbol -> SatiePlugin.new(~name, ~description, ~function));
		};

	}

	spatializerPath { arg path;
		path.pathMatch.do{arg item;
			item.loadPaths;
			this.add(~name.asSymbol -> SpatializerPlugin.new(~name, ~description, ~function, ~numChannels));
		};


	}

	showPlugins {
		// post the key and associated plugin description
		"\n- Showing plugins for %".format(this.inspect).postln;
		this.keysValuesDo{|key, value| "% -> %".format(key, value.description.asString.quote).postln;};
		"----".postln;
	}
}