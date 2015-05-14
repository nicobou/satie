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
o.numOutputBusChannels = 128;
o.memSize = 2**20;
o.blockSize = 2048;
s.reboot;
s.makeGui;
s.meter;

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

	// be sure the synthDef is compiled on the server
	s.sync;

};  // s.waitForBoot
)

// ************** usage with Satie  groups (JITlib & ProxySpace) **************
(

// test per instance set and group set
// (here using \default group since no group name is given as makeInstance Third arguments)
~scbr.makeInstance(\test1, \string);
~scbr.makeInstance(\test2, \string);
~scbr.makeInstance(\test3, \pinksin);

// change test3 source
~scbr.makeInstance(\test3, \testtone);

// using default group
~defaultProx = ~scbr.satieGroups[\default];  // Satie Groups are actually ProxySpace
// list internal instances from default group (internal instances are NodeProxy instances):
~defaultProx.existingProxies;

// removing an instance
~scbr.cleanInstance(\test2);
~defaultProx.existingProxies;
~scbr.makeInstance(\test2, \string);
~defaultProx.existingProxies;

//set an a value of an instance
~defaultProx.[\test3].set(\gainDB, -30);
~scbr.pauseInstance(\test3);
~defaultProx.existingProxies;
~scbr.makeInstance(\test3, \testtone);

// per instance set
~defaultProx.[\test1].set(\gainDB, -30);
~defaultProx.[\test2].set(\gainDB, -30);
~defaultProx.[\test1].set(\t_trig, 1, \note, rrand(42,72), 1, 0.5);
~defaultProx.[\test2].set(\t_trig, 1, \note, rrand(42,72), 1, 0.5);
//group set
~defaultProx.group.set(\aziDeg, 90);
~defaultProx.group.set(\t_trig, 1);
~defaultProx.group.set(\gainDB, -20);
// clean all
~scbr.cleanInstance(\test1);
~scbr.cleanInstance(\test2);
~scbr.cleanInstance(\test3);
~defaultProx.existingProxies;

// ******* spatialized effects  (read audio from a bus) ***

// making two trigered sound source
~defaultProx = ~scbr.satieGroups[\default];
~scbr.makeInstance(\test1, \string_third_aux);
~scbr.makeInstance(\test2, \string_third_aux);
~defaultProx.group.set(\gainDB, -20);
~defaultProx[\test1].set(\t_trig, 1, \note, rrand(42,72), 1, 0.5);
~defaultProx[\test2].set(\t_trig, 1, \note, rrand(42,72), 1, 0.5);

// making a reverb effect
// this need a specific group since
// effects need to be added to tail
~effectProx = ~scbr.makeSatieGroup(\effect, \addToTail);
~effectProx[\rev].set(\in, ~scbr.aux[2]);  // reading bus created by Satie
~effectProx[\rev].set(\mix, 1);  //wet only
~effectProx[\rev].set(\room, 0.2);
~effectProx[\rev].set(\damp, 1);
~effectProx[\rev].set(\aziDeg, -180);
~effectProx[\rev].set(\gainDB, -20);
~scbr.makeInstance(\rev, \busreverb, \effect);

// play with reverb
~defaultProx[\test1].set(\t_trig, 1, \note, rrand(42,72), 1, 0.5);
~defaultProx[\test2].set(\t_trig, 1, \note, rrand(42,72), 1, 0.5);

// ********** CPU load test (use supernova with increased memory allocation) *********
// play until all CPU are loaded (~70%)
// (no sound since string must be trigered)

// creating a custom group:
~groupCPU = ~scbr.makeSatieGroup(\cpuTest);
r = Routine {
	loop {
		~scbr.makeInstance((\test ++ rrand(0, 10000).asSymbol), \string, \cpuTest);
		0.1.wait;
	}
};
r.play;
r.stop;

// then triger each string sequentially
~seqtrig = Routine({ ~groupCPU.existingProxies.do({ |item|
		~groupCPU[item].set(
			\t_trig, 1,
			\note, rrand(42, 72), rrand(1, 2), rrand(0.1, 0.9));
		rrand(0.05, 0.1).wait;
	});});
~groupCPU.group.set(\gainDB, -30);
~seqtrig.play;
~seqtrig.stop;

// trig all once
~groupCPU.group.set(\gainDB, -45);
~groupCPU.group.set(\t_trig, 1);
~groupCPU.group.set(\t_trig, 1,
	\note, rrand(42, 72), rrand(1, 2), rrand(0.1, 0.9),
	\aziDeg, rrand(-180,180),
	\eleDeg, rrand(0,90));

// change with gui
w=Window.new("sheefa", Rect(30, 30, 400, 100)).front;
w.view.decorator=FlowLayout(w.view.bounds);
w.view.decorator.gap=8@2;
h = EZSlider(w, 380@20, "azi", ControlSpec(-180, 180, \lin, 0.1, 0));
h.action_({ |ez| ( ~groupCPU.group.set(\aziDeg, (ez.value)))});
i = EZSlider(w, 380@20, "elev", ControlSpec(-90, 90, \lin, 0.1, 0));
i.action_({ |ez| ( ~groupCPU.group.set(\eleDeg, (ez.value)))});
j = EZSlider(w, 380@20, "spread", ControlSpec(0, 100, \lin, 0.1, 5));
j.action_({ |ez| ( ~groupCPU.group.set(\spread, (ez.value)))});

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

// CPU load test
// creating a global ParGroup for supernova
~groupCPU = ParGroup.new; // ~group.freeAll;
r = Routine({
	loop {
		Synth.head(~groupCPU, \string);
		0.1.wait;
}});
// play until all CPU are loaded (~70%)
// (no sound since string must be trigered)
r.play;
r.stop;

// trig all once
~groupCPU.set(\gainDB, -45);
~groupCPU.set(\t_trig, 1,
	\note, rrand(42, 72), rrand(1, 2), rrand(0.1, 0.9),
	\aziDeg, rrand(-180,180),
	\eleDeg, rrand(0,90));
)
