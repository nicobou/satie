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

// Server
s.reboot;
s.makeGui;
s.scope;


(
s = Server.local;
// Server.default;
Server.supernova;
o = Server.local.options;
// Post the number of output channels
// o.numOutputBusChannels.postln;
o.numOutputBusChannels = 32;
// o.memSize.postln;
o.memSize = 2**20;
o.blockSize = 2048;

s.waitForBoot{

	// finding source directory
	~rootSrcPath = thisProcess.nowExecutingPath.dirname ++ "/..";
	(~rootSrcPath ++ "/src/*.scd").pathMatch.do({arg item; item.loadPaths});
	// creating a sc-basic-renderer
	~scbr = ~scbrMaker.value(~rootSrcPath);
	// loading source plugins
	~scbr.pluginLoader.loadAudioPlugins(~rootSrcPath ++ "/audiosources/*.scd");
	// see the loaded plugins in the console
	~scbr.pluginLoader.audioPlugins;
	// loading spatializer plugins
	~scbr.pluginLoader.loadSpatPlugins(~rootSrcPath ++ "/spatializers/*.scd");
	~scbr.pluginLoader.spatPlugins;
	// generating SynthDef that are going to be used,
	// here a PinkSin source spatialized by
	//   - a stereo panner (starting channel 0)
	//   - a monoSpat (starting channel 1)
	~scbr.makeSynthDef(\fool, \PinkSin, [\domeVBAP], [0]);
	// be sure the synthDef is compiled on the server
	s.sync;

	// initialization is done, create and remove a source + controls
	y = Synth.tail(s, \fool);
	// spat properties
	y.set(\vol, 0.10);
	y.set(\azi, 0.5);
	// source property
	y.set(\sfreq, 100);
	// remove source
	// y.release;

};  // s.waitForBoot
)
