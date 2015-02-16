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
~cOSCMaker = {
	e = Environment.make({
		var
		// main OSC method
		~newOSC = {|self, id, cb, path|
			"creating newOSC".postln;
			OSCdef(id, cb, path, recvPort: 18032)
		};
		// create all /core/source/*/ at once.
		~sourceOSC = {|self, id, cb|
			self.newOSC(id ++ \prop, cb,  "/spatosc/core/source" +/+ id +/+ "/prop");
			self.newOSC(id ++ \uri, cb,  "/spatosc/core/source" +/+ id +/+ "/uri");
			self.newOSC(id ++ \state, cb,  "/spatosc/core/source" +/+ id +/+ "/state");
			self.newOSC(id ++ \event, cb,  "/spatosc/core/source" +/+ id +/+ "/event");
		};
		// try to remove the OSC definitions.
		~removeSourceOSC = {|self, id|
			OSCdef(id ++ \prop).clear.free;
			OSCdef(id ++ \uri).clear.free;
			OSCdef(id ++ \state).clear.free;
			OSCdef(id ++ \event).clear.free;
		};
	});
	e.know = true;
	e;
};

//e.(\goo, {\gotIt.postln;}, "/goo");
/*
~cOSC = ~cOSCMaker.value();

~cOSC.newOSC(\soo, {'ok'.postln;}, "/soo");
~cOSC.removeOSC(\soo);
*/
)