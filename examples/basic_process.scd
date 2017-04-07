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
Exception.debug = true;
Server.supernova;
o = Server.local.options;
o.numOutputBusChannels = 2;
o.memSize = 2**20;
o.blockSize = 2048;
s.waitForBoot {
	~rootSrcPath = thisProcess.nowExecutingPath.dirname ++ "/..";
	(~rootSrcPath ++ "/src/*.scd").pathMatch.do({arg item; item.loadPaths});
	~satie = ~satieMaker.value(numAudioAux: 0, satieSrcPath: ~rootSrcPath);
	~satie.makeSynthDef(\string, \zkarpluck1, [], [], [\stereoPanner], [0], \defaultMapper, []);
	s.sync;
	s.meter;
	s.plotTree;
	s.makeGui;
};
)



(
//process definition
~env = Environment.make({
	~aziDeg = 0;
	~routine;
	~makeRoutine = { |self |
		self.aziDeg = 0;
		self.routine = Routine {
			// Here the routine creates sound objects without deleting them util the routine is stopped.
			loop { arg item;
				var nodename=("testNode"++"_"++item).asSymbol;
				var synth;
				var note;
				note = rrand(60, 63);
				synth = ~satie.makeKamikaze(nodename.asSymbol, \string, \default);
				synth.set(
					\t_trig, 1,
					\gainDB, rrand(-40, -30),
					\note, [note, 1, 0.5],
				\aziDeg, self.aziDeg);
				0.5.wait;
			}
		};
	};
	~start = { | self | self.routine.play; };
	~setAzideg = {| self, aziDeg | self.aziDeg = aziDeg; }
});
)

// will call init
~process = ~satie.makeProcess(\testProcess, ~env);

// invoke specific process functions
~process.makeRoutine;
~process.start;

(
// change azimut from UI
w=Window.new("basic process", Rect(30, 30, 400, 130)).front;

w.view.decorator=FlowLayout(w.view.bounds);
w.view.decorator.gap=8@2;

h = EZRanger(w, 380@20, "azi", ControlSpec(-180, 180, \lin, 0.1), initVal:[-10, 10],
	action: {|sl|
		~process.setAzideg(rrand(sl.value[0], sl.value[1]))
		});
)

