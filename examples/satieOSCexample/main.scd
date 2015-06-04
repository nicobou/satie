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

Server.supernova;
o = Server.local.options;
o.numOutputBusChannels = 128;
o.memSize = 2**20;
o.blockSize = 2048;
//s.reboot;
s.makeGui;
s.meter;

(
~files = #["satieOSCexample.scd", "oscdefinitions.scd"];

s.waitForBoot {
	var dir = thisProcess.nowExecutingPath.dirname;
	~files.do { |f| f.loadRelative ; s.sync;};
	s.sync;
	"All files loaded".postln;
}; // waitForBoot



)

OSCdef.all;