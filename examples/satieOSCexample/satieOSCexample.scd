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

// This file is loaded by main.scd in the same directory

// finding source directory
~rootSrcPath = thisProcess.nowExecutingPath.dirname ++ "/../..";
(~rootSrcPath ++ "/src/*.scd").pathMatch.do({arg item; item.loadPaths});

~num_aux_bus = 5;
~oscSys = \satieOSC;
// creating a sc-basic-renderer
~scbr = ~scbrMaker.value(numAudioAux: ~num_aux_bus, oscSystem: ~oscSys);
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

// initialize the instance manager

//~im = ~instanceManager.value(context: ~scbr);

// generating SynthDef that are going to be used,
// here a PinkSin source spatialized by
//   - a stereo panner (starting channel 0)
//   - a monoSpat (starting channel 2)
~scbr.makeSynthDef(\fool, \PinkSin, [\stereoPanner, \monoSpat], [0, 2]);

//~scbr.makeSynthDef(\string, \zkarpluck1, [\stereoPanner, \monoSpat], [0, 2]);
~scbr.makeSynthDef(\string, \zkarpluck1, [\octoVBAP], [0]);
~scbr.makeSynthDef(\pinksin, \PinkSin, [\stereoPanner], [0]);
~scbr.makeSynthDef(\testtone, \testtone, [\stereoPanner], [0]);
// writing to all aux busses (first is starting a 0):
~scbr.makeSynthDef(\string_all_aux, \zkarpluck1, [\stereoPanner], [0], ~scbr.aux);
// writing to only to the third audio bus
~scbr.makeSynthDef(\string_third_aux, \zkarpluck1, [\domeVBAP], [0], [~scbr.aux[2]]);
// spatilized reverb effect (input will be set at creation):
~scbr.makeSynthDef(\busreverb, \freeverb, [\stereoPanner], [0]);
// streaming a soundfile from disk
~scbr.makeSynthDef(\snd, \sndFile, [\stereoPanner], [0]);
// be sure the synthDef is compiled on the server
s.sync;
~playBuffers = Dictionary();
~playBuffers.add(\bleh -> Buffer.cueSoundFile(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav", 0, 1));
~playBuffers.add(\alsaTest -> Buffer.cueSoundFile(s, "/usr/share/sounds/alsa/Front_Center.wav", 0, 1));
s.sync;
