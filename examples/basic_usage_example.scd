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
o.numOutputBusChannels = 8;
o.memSize = 2**20;
o.blockSize = 2048;
// s.reboot;
s.makeGui;
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
	~scbr.makeSynthDef(\fool, \PinkSin, [], [], [\octoVBAP, \monoSpat], [0, 2], \defaultMapper, []);

	~scbr.makeSynthDef(\string, \zkarpluck1, [], [], [\stereoPanner], [0], \defaultMapper, []);
	~scbr.makeSynthDef(\pinksin, \PinkSin, [], [], [\quadVBAP], [0], \defaultMapper, []);
	// generate a synth and change its defaults
	~scbr.makeSynthDef(\pink400, \PinkSin, [], [], [\stereoPanner], [0], \defaultMapper, [800]);

	~scbr.makeSynthDef(\testtone, \testtone, [], [], [\stereoPanner], [0], \defaultMapper, []);
	// writing to all aux busses (first is starting a 0):
	~scbr.makeSynthDef(\string_all_aux, \zkarpluck1, ~scbr.aux, [], [\stereoPanner], [0], \defaultMapper, []);
	// writing to only to the third audio bus
	~scbr.makeSynthDef(\string_third_aux, \zkarpluck1, [], [~scbr.aux[2]], [\stereoPanner], [0], \defaultMapper, []);
	// spatilized reverb effect (input will be set at creation):
	~scbr.makeSynthDef(\busreverb, \freeverb, [], [], [\stereoPanner], [0], \defaultMapper, []);
	// mono input
	~scbr.makeSynthDef(\monoIn, \MonoIn, [], [], [\stereoPanner], [0], \defaultMapper, []);
	~scbr.makeSynthDef(\tastee, \testee, [], [], [\octoVBAP], [0], \defaultMapper, []);
	// streaming a soundfile from disk
	// - load soundfiles
	~playBuffers = Dictionary();
	~playBuffers.add(\bleh -> Buffer.cueSoundFile(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav", 0, 1));
	~playBuffers.add(\alsaTest -> Buffer.cueSoundFile(s, "/usr/share/sounds/alsa/Front_Center.wav", 0, 1));
	// create players
	~scbr.makeSynthDef(\snd1, \sndFile, [], [], [\stereoPanner], [0], \defaultMapper, [~playBuffers[\bleh].bufnum]);
	~scbr.makeSynthDef(\snd2, \sndFile, [], [], [\stereoPanner], [0], \defaultMapper, [~playBuffers[\alsaTest].bufnum]);
	// be sure the synthDef is compiled on the server
	~osc = ~satieOSCMaker.value();
	s.sync;
	(~rootSrcPath ++ "/protocols/satieOSC.scd").load;
	s.sync;
};
)

// Basic usage example

// SATIE creates a \default group by default

~scbr.satieGroups[\default];

// create another group
~scbr.makeSatieGroup(\synths);

// populate default group with some test tones. We can set some properties
// on each instance immediately upon creation
(
20.do( { arg item;
	var nodename=("testNode"++"_"++item).asSymbol;
	var synth;
	synth = ~scbr.makeInstance(nodename.asSymbol, \testtone, \default);
	synth.set(\gainDB, rrand(-90, -38), \sfreq, rrand(100, 1000));
});
)
// act on individual instances
(
20.do( {|item|
	var nodename=("testNode"++"_"++item);
	~scbr.satieGroupInstances[\default][nodename.asSymbol].set(\sfreq, rrand(200, 2000));
});
)
(
20.do( {|item|
	var nodename=("testNode"++"_"++item);
	~scbr.satieGroupInstances[\default][nodename.asSymbol].set(\gainDB, rrand(-100, -40));
});
)
(
// the above can be done in one pass and
20.do( {|item|
	var nodename=("testNode"++"_"++item);
	~scbr.satieGroupInstances[\default][nodename.asSymbol].set(
		\sfreq, rrand(200, 2000),
		\gainDB, rrand(-110, -50),
		\aziDeg, rrand(-90, 90));
});
)
// set properties to an entire group
~scbr.satieGroups[\default].set(\gainDB, -90)
~scbr.satieGroups[\default].set(\gainDB, -65, \sfreq, 220)

// add 2 different instances of another synth to \synths group
~scbr.makeInstance(\drone, \tastee, \synths);
~scbr.makeInstance(\drone2, \tastee, \synths);

// set parameters on one instance
~scbr.satieGroupInstances[\synths][\drone].set(\aziDeg, 30);
// or a group
~scbr.satieGroups[\synths].set(\gainDB, -50);
~scbr.satieGroups[\synths].set(\gainDB, -50);

// satieGroups return a ParGroup
~scbr.satieGroups[\synths];
// inspect instances in a group
~scbr.satieGroupInstances[\synths]

// clean an instance
~scbr.cleanInstance(\drone2, \synths)
// kill a group
~scbr.killSatieGroup(\default)
