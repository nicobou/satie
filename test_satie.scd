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


// testing...

(
s = Server.supernova.local;
~satie = Satie.new(s);
~satie.satieRoot;
~satie.configure_(s, "stereo");
~satie.satieConfiguration.options.blockSize = 1024;
s.reboot();
s.waitForBoot({
	s.meter;
	s.makeGui;
	s.plotTree;
})
// ~satie.satieConfiguration;
)

(
~printem = {|k, v|
	"%:\nName: %\nDescription: %\nsource%\n".format(
		k, v.getName, v.getDescription, v.getSrc.asCompileString)
	.postln;
}
)

~satie.renderer.makeSatieGroup(\default);
~satie.renderer.makeSatieGroup(\synths);

~satie.renderer.makeSynthDef(\boo, \misDrone, [], [], [\stereoListener], [0]);
~satie.renderer.makeSynthDef(\test, \testtone, [], [], [\stereoListener], [0]);
~satie.renderer.makeInstance(\synth, \boo, group: \synths );
~satie.renderer.makeInstance(\test, \test, group: \default );

~satie.renderer.groups
