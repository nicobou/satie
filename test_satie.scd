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
// s.reboot();
s.waitForBoot({
	~satie.renderer.makeSatieGroup(\default);
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
~satie.renderer.makeSatieGroup()
~satie.renderer.makeSatieGroup(\default);
~satie.renderer.makeSatieGroup(\synths);

~satie.renderer.makeSynthDef(\boo, \misDrone, [], [], [\stereoListener], [0]);
~satie.renderer.makeSynthDef(\test, \testtone, [], [], [\stereoListener], [0]);
~drone = ~satie.renderer.makeInstance(\synth, \boo );
~satie.renderer.makeInstance(\test, \test, group: \default );

~satie.renderer.groups.includesKey(\synth)
~satie.renderer.groupInstances


~drone.set(\freq, 40, \gainDB, 0)


(
20.do( { arg item;
	var nodename=("testNode"++"_"++item).asSymbol;
	var synth;
	synth = ~satie.renderer.makeInstance(nodename.asSymbol, \boo, \default);
	synth.set(\gainDB, rrand(-90, -38), \sfreq, rrand(100, 1000));
});
)

s.initTree