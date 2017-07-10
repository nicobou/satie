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
~satieConfiguration.debug = false;
~satie = Satie.new(~satieConfiguration);
// s.reboot();
s.waitForBoot({
	~satie.makeSatieGroup(\default);
	~satie.makeSynthDef(\boo, \misDrone, [], [], [\stereoListener], [0]);
	~satie.makeSynthDef(\test, \testtone, [], [], [\stereoListener], [0]);
	~satie.makeSynthDef(\string, \zkarpluck1, [], [], [\stereoListener], [0]);
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
	synth = ~satie.makeInstance(nodename.asSymbol, \boo, \default);
	synth.set(\gainDB, rrand(-90, -38), \sfreq, rrand(100, 1000));
});
)
( /*   clean test instances    */
20.do( { |item|
	~satie.cleanInstance(("testNode"++"_"++item).asSymbol);
});
)


(
//process definition
~env = Environment.make({
	~routine;
	~makeRoutine = { |self |
		self.routine = Routine {
			// Here the routine creates sound objects without deleting them util the routine is stopped.
			loop { arg item;
				var nodename=("testNode"++"_"++item).asSymbol;
				var synth;
				var note;
				var elev = Prand([-90, -60, 30, 0, 90]).asStream;
				note = rrand(60, 63);
				synth = ~satie.makeKamikaze(nodename.asSymbol, \string);
				synth.set(
					\t_trig, 1,
					\gainDB, rrand(-40, -30),
					\note, [note, 1, 0.5],
					\aziDeg, rrand(-180,180),
					\spread, 0,
					\eleDeg, elev.next
				);
				0.5.wait;
			}
		};
	};
	~start = { | self | self.routine.play; };
});
)


// will call init
~process = ~satie.makeProcess(\testProcess, ~env);

// invoke specific process functions
~process.makeRoutine;
~process.start;

~satie.processes[\testProcess].makeRoutine
~satie.processes[\testProcess].start
~satie.groups