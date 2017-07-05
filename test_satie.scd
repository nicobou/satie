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
~satieConfiguration = SatieConfiguration.new(s, "stereo");
~satieConfiguration.serverOptions.blockSize = 1024;
~satie = Satie.new(~satieConfiguration);
// s.reboot();
s.waitForBoot({
	~satie.makeSatieGroup(\default);
	~satie.makeSynthDef(\boo, \misDrone, [], [], [\stereoListener], [0]);
	~satie.makeSynthDef(\test, \testtone, [], [], [\stereoListener], [0]);
	s.meter;
	s.makeGui;
	s.plotTree;
})
// ~satie.satieConfiguration;
)

// create another group
~satie.makeSatieGroup(\synths);


( /*   create some test sound instances in the default group  */
20.do( { arg item;
	var nodename=("testNode"++"_"++item).asSymbol;
	var synth;
	synth = ~satie.makeInstance(nodename.asSymbol, \test, \default);
	synth.set(\gainDB, rrand(-90, -38), \sfreq, rrand(100, 1000));
});
)
( /*   clean test instances    */
20.do( { |item|
	~satie.cleanInstance(("testNode"++"_"++item).asSymbol);
});
)