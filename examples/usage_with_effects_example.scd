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
s.meter;
s.plotTree;
s.waitForBoot {
	~rootSrcPath = thisProcess.nowExecutingPath.dirname ++ "/..";
	(~rootSrcPath ++ "/src/*.scd").pathMatch.do({arg item; item.loadPaths});

	~num_aux_bus = 5;
	// creating a sc-basic-renderer
	~scbr = ~scbrMaker.value(numAudioAux: ~num_aux_bus, satieSrcPath: ~rootSrcPath);
	// printing internal aux array with bus indexes
	// ~scbr.aux;
	// ~scbr.auxbus.scope;

	// generating SynthDef that are going to be used,
	// here a PinkSin source spatialized by
	//   - a stereo panner (starting channel 0)
	//   - a monoSpat (starting channel 2)
	~scbr.makeSynthDef(\fool, \PinkSin, [], [\octoVBAP, \monoSpat], [0, 2]);

	//~scbr.makeSynthDef(\string, \zkarpluck1, [\stereoPanner, \monoSpat], [0, 2]);
	~scbr.makeSynthDef(\string, \zkarpluck1, [], [\stereoPanner], [0]);
	~scbr.makeSynthDef(\pinksin, \PinkSin, [], [\quadVBAP], [0]);
	// generate a synth and change its defaults
	~scbr.makeSynthDef(\pink400, \PinkSin, [], [\stereoPanner], [0], \defaultMapper, [], [800]);

	~scbr.makeSynthDef(\testtone, \testtone, [], [\stereoPanner], [0]);
	// writing to all aux busses (first is starting a 0):
	~scbr.makeSynthDef(\string_all_aux, \zkarpluck1, [], [\stereoPanner], [0], \defaultMapper, ~scbr.aux);
	// writing to only to the third audio bus
	~scbr.makeSynthDef(\string_third_aux, \zkarpluck1, [], [\stereoPanner], [0], \defaultMapper, [~scbr.aux[2]]);
	// spatilized reverb effect (input will be set at creation):
	~scbr.makeSynthDef(\busreverb, \freeverb, [], [\stereoPanner], [0]);
	// mono input
	~scbr.makeSynthDef(\monoIn, \MonoIn, [], [\stereoPanner], [0]);
	~scbr.makeSynthDef(\tastee, \testee, [], [\octoVBAP], [0]);
	// streaming a soundfile from disk
	// - load soundfiles
	~playBuffers = Dictionary();
	~playBuffers.add(\bleh -> Buffer.cueSoundFile(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav", 0, 1));
	~playBuffers.add(\alsaTest -> Buffer.cueSoundFile(s, "/usr/share/sounds/alsa/Front_Center.wav", 0, 1));
	// create players
	~scbr.makeSynthDef(\snd1, \sndFile, [], [\stereoPanner], [0], \defaultMapper, [~playBuffers[\bleh].bufnum]);
	~scbr.makeSynthDef(\snd2, \sndFile, [], [\stereoPanner], [0], \defaultMapper, [~playBuffers[\alsaTest].bufnum]);
	// be sure the synthDef is compiled on the server
	~osc = ~satieOSCMaker.value();
	s.sync;
	(~rootSrcPath ++ "/protocols/satieOSC.scd").load;
	s.sync;
	s.makeGui;
};
)

// ******* spatialized effects  (read audio from a bus) ***

// making two trigered sound source
~scbr.makeInstance(\test1, \string_third_aux);
~scbr.makeInstance(\test2, \string_third_aux);
// ~defaultProx.group.set(\gainDB, -20);
~scbr.satieGroups[\default].set(\gainDB, -20);
~scbr.satieGroupInstances[\default][\test1].set(\t_trig, 1, \note, rrand(42,72), 1, 0.5);
~scbr.satieGroupInstances[\default][\test2].set(\t_trig, 1, \note, rrand(42,72), 1, 0.5);
// ~defaultProx[\test1].set(\t_trig, 1, \note, rrand(42,72), 1, 0.5);
// ~defaultProx[\test2].set(\t_trig, 1, \note, rrand(42,72), 1, 0.5);

// making a reverb effect
// this need a specific group since
// effects need to be added to tail
~scbr.makeSatieGroup(\effect, \addToTail);

~scbr.makeInstance(\rev, \busreverb, \effect);
~scbr.satieGroupInstances[\effect][\rev].set(\in, ~scbr.aux[2]);  // reading bus created by Satie
~scbr.satieGroupInstances[\effect][\rev].set(\mix, 1);  //wet only
~scbr.satieGroupInstances[\effect][\rev].set(\room, 0.9);
~scbr.satieGroupInstances[\effect][\rev].set(\damp, 1);
~scbr.satieGroupInstances[\effect][\rev].set(\aziDeg, -180);
~scbr.satieGroupInstances[\effect][\rev].set(\gainDB, -20);

// play with reverb
~scbr.satieGroupInstances[\default][\test1].set(\t_trig, 1, \note, rrand(42,72), 1, 0.5);
~scbr.satieGroupInstances[\default][\test2].set(\t_trig, 1, \note, rrand(42,72), 1, 0.5);