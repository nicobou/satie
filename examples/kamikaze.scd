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
s.meter;
s.plotTree;
s.waitForBoot {
	~rootSrcPath = thisProcess.nowExecutingPath.dirname ++ "/..";
	(~rootSrcPath ++ "/src/*.scd").pathMatch.do({arg item; item.loadPaths});
	~scbr = ~scbrMaker.value(numAudioAux: 0, satieSrcPath: ~rootSrcPath);
	~scbr.makeSynthDef(\string, \zkarpluck1, [], [], [\stereoPanner], [0], \defaultMapper, []);
	s.sync;
	s.makeGui;
};
)

// The makeKamikaze method creates self-destructing sound objects. Destruction is trigered with the embedded "DetectSilence" done-action.
// These kamikaze are particularly effective for numerous sound objects that are associated with localized events, such as a particles in a swarm,
// as opposed to singular virtual objects.
// The creation of many kamikaze sound sources avoids the need for the SATIE client to maintain a state for monitoring these sound objects,
// and accordingly reduce the number of messages required for killing sound objects.
(
// Here the routine creates sound objects without deleting them util the routine is stopped.
r = Routine {
	loop { arg item;
	var nodename=("testNode"++"_"++item).asSymbol;
		var synth;
		var note;
		note = rrand(60, 63);
		synth = ~scbr.makeKamikaze(nodename.asSymbol, \string, \default);
		synth.set(
			\t_trig, 1,
			\gainDB, rrand(-40, -30),
			\note, [note, 1, 0.5],
			\aziDeg, rrand(-20, 20));
		0.5.wait;
		}
};
r.play;
)

r.stop;

)
