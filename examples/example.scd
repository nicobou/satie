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


// s.boot; s.makeGui;

(
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
	//   - a monoSpat (starting channel 2)
	~scbr.makeSynthDef(\fool, \PinkSin, [\stereoPanner, \monoSpat], [0, 2]);
	~scbr.makeSynthDef(\string, \zkarpluck1, [\stereoPanner, \monoSpat], [0, 2]);


	// be sure the synthDef is compiled on the server
	s.sync;

	~group = ParGroup.new;
	~group.freeAll;

	50.do({
		var
		p = ProxySpace(s);
		p.fadeTime = 0.02;
		// p.use({
		// 	~out = { SinOsc.ar(350, 0, 0.2) };
		// });
		p[\out].ar(0);  //  (init ~out) this ensure not extra bus is allocated. this must be the first reference of ~out
		p[\out].group = ~group;
		p[\out].source = \fool;  //this synthdef is already writing to first audio out
		p[\out].bus.postln;  //no extra bus
		nil;
	});

	~group.set(\gainDB, -60);

	// initialization is done, create and remove a source + controls

	// make a bunch of 'em
	//g = Synth.head(s, \fool, [\spread,0]);

	// spat properties
	// g.set(\gainDB, -30);
	// g.set(\aziDeg, );
	// g.set(\eleDeg, 90);
	// g.set(\spread, 0);
	// g.set(\lfoHz, 10);

};  // s.waitForBoot
)

