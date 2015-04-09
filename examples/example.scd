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


// s.reboot; s.makeGui;

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

};  // s.waitForBoot
)

// ******************** usage with JITlib & ProxySpace *********************
(
// creating a global ParGroup for supernova
~group = ParGroup.new; // ~group.freeAll;
// creating a global ProxySpace
~prox = ProxySpace(s);
// the proxyspace is going to be embedded in the global pargroup
~prox.group = ~group;

//instance factory
~makeinstance = { | name = \out, p, src = \string |
	p.fadeTime = 0.02;
	// ensuring not extra bus is allocated:
	// (must be the first reference of "name" in the proxyspace
	p[name].ar(0);
	p[name].source = src;
	nil;
};

// test per instance set and group set
~makeinstance.value(\test1, ~prox, \string);
~makeinstance.value(\test2, ~prox, \string);

// per instance set
~prox[\test1].set(\gainDB, -30);
~prox[\test2].set(\gainDB, -30);
~prox[\test1].set(\t_trig, 1, \note, rrand(42,72), 1, 0.5);
~prox[\test2].set(\t_trig, 1, \note, rrand(42,72), 1, 0.5);
//group set
~group.set(\aziDeg, 90);
~group.set(\t_trig, 1);


// CPU load test
~groupCPU = ParGroup.new; // ~group.freeAll;
// creating a global ProxySpace
~proxCPU = ProxySpace(s);
// the proxyspace is going to be embedded in the global pargroup
~proxCPU.group = ~groupCPU;

r = Routine({
	loop {
		~makeinstance.value(
			(\test ++ rrand(0, 10000).asSymbol),
			~proxCPU,
			\string);
		0.1.wait;
}});
// play until all CPU are loaded (~70%)
// (no sound since string must be trigered)
r.play;
r.stop;

// list ProxySpace internal proxies:
~proxCPU.existingProxies;

// triger each string sequentially
~seqtrig = Routine({ ~proxCPU.existingProxies.do({ |item|
		~proxCPU[item].set(
			\t_trig, 1,
			\note, rrand(42, 72), rrand(1, 2), rrand(0.1, 0.9));
		rrand(0.05, 0.1).wait;
	});});
~groupCPU.set(\gainDB, -30);
~seqtrig.play;
~seqtrig.stop;

// trig all once
~groupCPU.set(\gainDB, -45);
~groupCPU.set(\t_trig, 1);

)

// ****************** usage with synth creation ************************
(
// initialization is done, create and remove a source + controls
g = Synth.head(s, \fool, [\spread,0]);

// spat properties
g.set(\gainDB, -30);
g.set(\aziDeg, rrand(-180, 180));
g.set(\eleDeg, 90);
g.set(\spread, 0);
g.set(\lfoHz, 10);

// source properties
g.set(\sfreq, rrand(200, 400));
)
