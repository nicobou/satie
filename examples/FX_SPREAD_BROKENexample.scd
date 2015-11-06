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

Server.supernova;
o = Server.local.options;
o.numOutputBusChannels = 24;
o.memSize = 2**20;
o.blockSize = 2048;
s.reboot;
s.makeGui;
s.meter;
o.outDevice =  "HDSPe MADI (23453676)"

(
s.waitForBoot{
	// finding source directory
	~rootSrcPath = thisProcess.nowExecutingPath.dirname ++ "/..";
	(~rootSrcPath ++ "/src/*.scd").pathMatch.do({arg item; item.loadPaths});

	~num_aux_bus = 5;
	// creating a sc-basic-renderer
	~scbr = ~scbrMaker.value(numAudioAux: ~num_aux_bus);
	// printing internal aux array with bus indexes
	~scbr.aux;
    // ~scbr.auxbus.scope;
	// loading source plugins
	~scbr.pluginLoader.loadAudioPlugins(~rootSrcPath ++ "/audiosources/*.scd");
	~scbr.pluginLoader.audioPlugins;  // list audio plugins
	// loading spatializer plugins
	~scbr.pluginLoader.loadSpatPlugins(~rootSrcPath ++ "/spatializers/*.scd");
	~scbr.pluginLoader.spatPlugins;
	// loading effect plugins
	~scbr.pluginLoader.loadEffectPlugins(~rootSrcPath ++ "/effects/*.scd");
	~scbr.pluginLoader.effectPlugins;
	// generating SynthDef that are going to be used,
	// here a PinkSin source spatialized by
	//   - a stereo panner (starting channel 0)
	//   - a monoSpat (starting channel 2)
	~scbr.makeSynthDef(\fool, \PinkSin, [\stereoPanner, \monoSpat], [0, 2]);

	//~scbr.makeSynthDef(\string, \zkarpluck1, [\stereoPanner, \monoSpat], [0, 2]);
	~scbr.makeSynthDef(\string, \zkarpluck1, [\domeVBAP], [0]);
	~scbr.makeSynthDef(\pinksin, \PinkSin, [\stereoPanner], [0]);
	~scbr.makeSynthDef(\testtone, \testtone, [\stereoPanner], [0]);
	// writing to all aux busses (first is starting a 0):
	~scbr.makeSynthDef(\string_all_aux, \zkarpluck1, [\domeVBAP], [0], ~scbr.aux);
	// writing to only to the third audio bus
	~scbr.makeSynthDef(\string_third_aux, \zkarpluck1, [\domeVBAP], [0], [~scbr.aux[2]]);
	// spatilized reverb effect (input will be set at creation):
	~scbr.makeSynthDef(\busreverb, \freeverb, [\stereoPanner], [0]);
	// streaming a soundfile from disk
	~playBuffers = (
		// the first one will work only on linux
		\alsaTest: Buffer.cueSoundFile(s, "/usr/share/sounds/alsa/Front_Center.wav", 0, 1),
		\boo: Buffer.cueSoundFile(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav", 0, 1)
	);
	// load sound files using arguments
	~scbr.makeSynthDef(\snd1, \sndFile, [\stereoPanner], [0], [], [~playBuffers[\boo].bufnum]);
	~scbr.makeSynthDef(\snd2, \sndFile, [\stereoPanner], [0], [], [~playBuffers[\alsaTest].bufnum]);
	// load synths with arguments
	~scbr.makeSynthDef(\pink400, \PinkSin, [\stereoPanner], [0], [], [400]);
	~scbr.makeSynthDef(\pink800, \PinkSin, [\stereoPanner], [0], [], [800]);
	// be sure the synthDef is compiled on the server
	s.sync;

};  // s.waitForBoot
)

/// using default group
~defaultProx = ~scbr.satieGroups[\default];  // Satie Groups are actually ProxySpace
/// ******* spatialized effects  (read audio from a bus) ***

// making  trigered sound source
~defaultProx = ~scbr.satieGroups[\default];
~scbr.makeInstance(\test1, \string_third_aux);
~defaultProx.group.set(\test1, -20);
~defaultProx[\test1].set(\t_trig, 1, \note, rrand(42,72), 1, 0.5);


// making a reverb effect
// this need a specific group since
// effects need to be added to tail
~effectProx = ~scbr.makeSatieGroup(\effect, \addToTail);
~effectProx[\rev].set(\in, ~scbr.aux[2]);  // reading bus created by Satie
~effectProx[\rev].set(\mix, 1);  //wet only
~effectProx[\rev].set(\room, 10);
~effectProx[\rev].set(\damp, 0.4);
~effectProx[\rev].set(\aziDeg, -180);
~effectProx[\rev].set(\gainDB, -0);
~scbr.makeInstance(\rev, \busreverb, \effect);


~defaultProx[\test1].set(\spread, 0);
~defaultProx[\test1].set(\spread, 100);


~effectProx[\rev].set(\spread, 0);
~effectProx[\rev].set(\spread, 100);
/
/ play with reverb
~defaultProx[\test1].set(\t_trig, 1, \note, rrand(42,72), 1, 0.5);


