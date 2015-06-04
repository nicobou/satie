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
~satieOSCMaker = { | rootPath = "/SATIE" |
	var rootURI = rootPath;
	var e = Environment.make({

		// main OSC method
		~newOSC = {|self, id, cb , path = \default|
			var idsym = id.asSymbol;
			OSCdef(idsym, cb, path, recvPort: 18032)
		};

		~deleteOSC = {|self, id|
			//postf("~deleteOSC  id: %\n",id.asSymbol);
			OSCdef(id.asSymbol ).free;
		};

		// make a synth instance
		~createSourceOSC = {|self, sourceName, cb, groupName = \default|
			self.newOSC(sourceName, cb,  rootURI +/+ groupName +/+ sourceName);
		};


		// create a group
		~makeGroup = {|self, groupName, cb|
			self.newOSC(groupName, cb,  rootURI +/+ groupName);
		};

		// try to remove the OSC definitions.
		~removeSourceOSC = {|self, sourceName|
			self.deleteOSC(sourceName);
		};

		// try to remove the OSC definitions.
		~removeGroup = {|self, groupName|
			self.deleteOSC(groupName);
		};

	});
	e.know = true;
	postf("satieOSC interface loaded\n");
	e;
};

//e.(\goo, {\gotIt.postln;}, "/goo");
/*
~cOSC = ~cOSCMaker.value();

~cOSC.newOSC(\soo, {'ok'.postln;}, "/soo");
~cOSC.removeOSC(\soo);
*/
)