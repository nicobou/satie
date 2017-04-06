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
// s.reboot;
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
	~satie.makeSynthDef(\fool, \PinkSin, [], [], [\octoVBAP, \monoSpat], [0, 2], \defaultMapper, []);

	~satie.makeSynthDef(\string, \zkarpluck1, [], [], [\stereoPanner], [0], \defaultMapper, []);
	~satie.makeSynthDef(\pinksin, \PinkSin, [], [], [\quadVBAP], [0], \defaultMapper, []);
	// generate a synth and change its defaults
	~satie.makeSynthDef(\pink400, \PinkSin, [], [], [\stereoPanner], [0], \defaultMapper, [800]);

	~satie.makeSynthDef(\testtone, \testtone, [], [], [\stereoPanner], [0], \defaultMapper, []);
	// writing to all aux busses (first is starting a 0):
	~satie.makeSynthDef(\string_all_aux, \zkarpluck1, ~satie.aux, [], [\stereoPanner], [0], \defaultMapper, []);
	// writing to only to the third audio bus
	~satie.makeSynthDef(\string_third_aux, \zkarpluck1, [], [~satie.aux[2]], [\stereoPanner], [0], \defaultMapper, []);
	// spatilized reverb effect (input will be set at creation):
	~satie.makeSynthDef(\busreverb, \freeverb, [], [], [\stereoPanner], [0], \defaultMapper, []);
	// mono input
	~satie.makeSynthDef(\monoIn, \MonoIn, [], [], [\stereoPanner], [0], \defaultMapper, []);
	~satie.makeSynthDef(\tastee, \testee, [], [], [\octoVBAP], [0], \defaultMapper, []);
	// streaming a soundfile from disk
	// - load soundfiles
	~playBuffers = Dictionary();
	~playBuffers.add(\bleh -> Buffer.cueSoundFile(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav", 0, 1));
	~playBuffers.add(\alsaTest -> Buffer.cueSoundFile(s, "/usr/share/sounds/alsa/Front_Center.wav", 0, 1));
	// create players
	~satie.makeSynthDef(\snd1, \sndFile, [], [], [\stereoPanner], [0], \defaultMapper, [~playBuffers[\bleh].bufnum]);
	~satie.makeSynthDef(\snd2, \sndFile, [], [], [\stereoPanner], [0], \defaultMapper, [~playBuffers[\alsaTest].bufnum]);
	// be sure the synthDef is compiled on the server

	// instantiate a renderer control object
	~srCtl = ~satieRendererCtlMaker.value(~satie);

	~osc = ~satieOSCMaker.value();   // create an OSC RX message mapper object receiveing on port 18032 by default


	// now connect OSC RX message callbacks for rendererControl object

	// to be safe,  remove any previous OSC  callbacks  (if any)
	~osc.removeRendererCtlOSC.value();

	// create OSC callbacks to control audio renderer
	// e.g.  /satie/rendererCtl/setOutputDB -12
	~osc.makeRendererCtlOSC( ~srCtl['satieRendererCallback'] );


	s.sync;
	s.makeGui;
	s.meter;
	s.plotTree;
	(~rootSrcPath ++ "/src/satieOSC.scd").load;
	s.sync;
};
)

// Basic usage example

// SATIE creates a \default group by default

~satie.satieGroups[\default];

// create another group
~satie.makeSatieGroup(\synths);

// populate default group with some test tones. We can set some properties
// on each instance immediately upon creation
(
20.do( { arg item;
	var nodename=("testNode"++"_"++item).asSymbol;
	var synth;
	synth = ~satie.makeInstance(nodename.asSymbol, \testtone, \default);
	synth.set(\gainDB, rrand(-90, -38), \sfreq, rrand(100, 1000));
});
)
// act on individual instances
(
20.do( {|item|
	var nodename=("testNode"++"_"++item);
	~satie.satieGroupInstances[\default][nodename.asSymbol].set(\sfreq, rrand(200, 2000));
});
)
(
20.do( {|item|
	var nodename=("testNode"++"_"++item);
	~satie.satieGroupInstances[\default][nodename.asSymbol].set(\gainDB, rrand(-100, -40));
});
)
(
// the above can be done in one pass and
20.do( {|item|
	var nodename=("testNode"++"_"++item);
	~satie.satieGroupInstances[\default][nodename.asSymbol].set(
		\sfreq, rrand(200, 2000),
		\gainDB, rrand(-110, -50),
		\aziDeg, rrand(-90, 90));
});
)
// set properties to an entire group
~satie.satieGroups[\default].set(\gainDB, -90)
~satie.satieGroups[\default].set(\gainDB, -65, \sfreq, 220)

// add 2 different instances of another synth to \synths group
~satie.makeInstance(\drone, \tastee, \synths);
~satie.makeInstance(\drone2, \tastee, \synths);
~satie.satieGroups[\synths].set(\gainDB, -20)

// set parameters on one instance
~satie.satieGroupInstances[\synths][\drone].set(\aziDeg, 30);
// or a group
~satie.satieGroups[\synths].set(\gainDB, -50);
~satie.satieGroups[\synths].set(\gainDB, -50);

// satieGroups return a ParGroup
~satie.satieGroups[\synths];
// inspect instances in a group
~satie.satieGroupInstances[\synths]

// clean an instance
~satie.cleanInstance(\drone2, \synths)
// kill a group
~satie.killSatieGroup(\default)
