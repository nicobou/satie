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
Server.supernova;
o = Server.local.options;
o.numOutputBusChannels = 8;
o.memSize = 2**20;
o.blockSize = 2048;
//s.reboot;
s.waitForBoot {
	~rootSrcPath = thisProcess.nowExecutingPath.dirname ++ "/..";
	(~rootSrcPath ++ "/src/*.scd").pathMatch.do({arg item; item.loadPaths});

	~num_aux_bus = 5;
	// creating a sc-basic-renderer
	~satie = ~satieMaker.value(numAudioAux: ~num_aux_bus, satieSrcPath: ~rootSrcPath);
	// printing internal aux array with bus indexes
	// ~satie.aux;
	// ~satie.auxbus.scope;

	// generating SynthDef that are going to be used,
	// here a PinkSin source spatialized by
	//   - a stereo panner (starting channel 0)
	//   - a monoSpat (starting channel 2)
	~satie.makeSynthDef(\fool, \PinkSin, [], [], [\octoVBAP, \monoSpat], [0, 2]);

	~satie.makeSynthDef(\string, \zkarpluck1, [], [], [\stereoPanner], [0]);
	~satie.makeSynthDef(\pinksin, \PinkSin, [], [],  [\quadVBAP], [0]);
	// generate a synth and change its defaults
	~satie.makeSynthDef(\pink400, \PinkSin, [], [], [\stereoPanner], [0], \defaultMapper, [800]);

	~satie.makeSynthDef(\testtone, \testtone, [], [], [\stereoPanner], [0]);
	// writing to all aux busses (first is starting a 0):
	~satie.makeSynthDef(\string_all_aux, \zkarpluck1, ~satie.aux, [], [\stereoPanner], [0]);
	// writing to only to the third audio bus
	~satie.makeSynthDef(\string_third_aux, \zkarpluck1, [~satie.aux[2]], [], [\stereoPanner], [0]);
	// spatilized reverb effect (input will be set at creation):
	~satie.makeSynthDef(\busreverb, \freeverb, [], [], [\stereoPanner], [0]);
	// mono input
	~satie.makeSynthDef(\monoIn, \MonoIn, [], [], [\stereoPanner], [0]);
	~satie.makeSynthDef(\tastee, \testee, [], [], [\octoVBAP], [0]);
	// streaming a soundfile from disk
	// - load soundfiles
	~playBuffers = Dictionary();
	~playBuffers.add(\bleh -> Buffer.cueSoundFile(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav", 0, 1));
	// create player
	~satie.makeSynthDef(\snd1, \sndFile, [], [], [\stereoPanner], [0], \defaultMapper, [~playBuffers[\bleh].bufnum]);
	// be sure the synthDef is compiled on the server
	~osc = ~satieOSCMaker.value();
	s.sync;
	s.makeGui;
	s.meter;
	s.plotTree;
	(~rootSrcPath ++ "/src/satieOSC.scd").load;
	s.sync;
};
)


~satie.makeInstance(\soundOne, \snd1, \default);
~satie.satieGroupInstances[\default][\soundOne].set(\gainDB, -30, \loop, 1);
~satie.satieGroups[\default].set(\loop, 0);
