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
s.reboot;
s.makeGui;
s.meter;
s.waitForBoot{
	// finding source directory
	~rootSrcPath = thisProcess.nowExecutingPath.dirname ++ "/..";
	(~rootSrcPath ++ "/src/*.scd").pathMatch.do({arg item; item.loadPaths});

	~num_aux_bus = 5;
	// creating a sc-basic-renderer
	~scbr = ~scbrMaker.value(numAudioAux: ~num_aux_bus, satieSrcPath: ~rootSrcPath);
	// printing internal aux array with bus indexes
	~scbr.aux;
    // ~scbr.auxbus.scope;
	// list plugins
	~scbr.pluginLoader.audioPlugins;
	~scbr.pluginLoader.spatPlugins;
	~scbr.pluginLoader.effectPlugins;
	~scbr.pluginLoader.mapperPlugins;
	// generating SynthDef that are going to be used,
	// here a PinkSin source spatialized by
	//   - a stereo panner (starting channel 0)
	//   - a monoSpat (starting channel 2)
	~scbr.makeSynthDef(\fool, \PinkSin, [], [], [\stereoPanner, \monoSpat], [0, 2]);

	~scbr.makeSynthDef(\string, \zkarpluck1, [], [], [\domeVBAP], [0]);
	~scbr.makeSynthDef(\pinksin, \PinkSin, [], [], [\stereoPanner], [0]);
	~scbr.makeSynthDef(\testtone, \testtone, [], [], [\stereoPanner], [0]);
	// writing to all aux busses (first is starting a 0):
	~scbr.makeSynthDef(\string_all_aux, \zkarpluck1, ~scbr.aux, [], [\domeVBAP], [0], \defaultMapper);
	// writing to only to the third audio bus
	~scbr.makeSynthDef(\string_third_aux, \zkarpluck1, [~scbr.aux[2]], [], [\domeVBAP], [0], \defaultMapper);
	// spatilized reverb effect (input will be set at creation):
	~scbr.makeSynthDef(\busreverb, \freeverb, [], [], [\stereoPanner], [0]);
	// streaming a soundfile from disk
	~playBuffers = (
		// the first one will work only on linux
		\alsaTest: Buffer.cueSoundFile(s, "/usr/share/sounds/alsa/Front_Center.wav", 0, 1),
		\boo: Buffer.cueSoundFile(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav", 0, 1)
	);
	// load sound files using arguments
	~scbr.makeSynthDef(\snd1, \sndFile, [], [], [\stereoPanner], [0], \defaultMapper, [~playBuffers[\boo].bufnum]);
	~scbr.makeSynthDef(\snd2, \sndFile, [], [], [\stereoPanner], [0], \defaultMapper, [~playBuffers[\alsaTest].bufnum]);
	// load synths with arguments
	~scbr.makeSynthDef(\pink400, \PinkSin, [], [], [\stereoPanner], [0], \defaultMapper, [], [400]);
	~scbr.makeSynthDef(\pink800, \PinkSin, [], [], [\stereoPanner], [0], \defaultMapper, [], [800]);
	// be sure the synthDef is compiled on the server
	s.sync;

};  // s.waitForBoot
)


// ********** CPU load test (use supernova with increased memory allocation) *********
// play until all CPU are loaded (~70%)
// (no sound since string must be trigered)

// creating a custom group:
~scbr.makeSatieGroup(\cpuTest);

r = Routine {
	loop {
		~scbr.makeInstance((\test ++ rrand(0, 10000).asSymbol), \string, \cpuTest);
		0.1.wait;
	}
};
r.play;
r.stop;

// see what we have
~scbr.satieGroupInstances[\cpuTest];


// then triger each string sequentially
~seqtrig = Routine({ ~scbr.satieGroupInstances[\cpuTest].do({ |item|
	item.set(
		\t_trig, 1,
		\aziDeg, rrand(-180,180),
		\eleDeg, rrand(0,90),
		\note, rrand(42, 72), rrand(1, 2), rrand(0.1, 0.9));
	rrand(0.05, 0.1).wait;
	});});
~seqtrig.play;
~seqtrig.reset; // hit it before playing again
~seqtrig.stop;

// trig all once
~scbr.satieGroups[\cpuTest].set(\gainDB, -45);
~scbr.satieGroups[\cpuTest].set(\t_trig, 1);
~scbr.satieGroups[\cpuTest].set(\t_trig, 1,
	\note, rrand(42, 72), rrand(1, 2), rrand(0.1, 0.9),
	\aziDeg, rrand(-180,180),
	\eleDeg, rrand(0,90));


// change with gui
w=Window.new("sheefa", Rect(30, 30, 400, 130)).front;
w.view.decorator=FlowLayout(w.view.bounds);
w.view.decorator.gap=8@2;
h = EZRanger(w, 380@20, "azi", ControlSpec(-180, 180, \lin, 0.1), initVal:[-60, 60],
	action: {|sl|
		~scbr.satieGroupInstances[\cpuTest].do({|item|
			item.set(\aziDeg, rrand(sl.value[0], sl.value[1]))
		});
	}
);
i = EZRanger(w, 380@20, "elev", ControlSpec(0, 90, \lin, 0.1), initVal:[30, 60],
	action: {|sl|
		~scbr.satieGroupInstances[\cpuTest].do({|item|
			item.set(\eleDeg, rrand(sl.value[0], sl.value[1]))
		});
	}
);
i = EZRanger(w, 380@20, "note", ControlSpec(42, 84, \lin, 0.25), initVal:[42, 60],
	action: {|sl|
		~scbr.satieGroupInstances[\cpuTest].do({|item|
			var note = rrand(sl.value[0], sl.value[1]);
			note.postln;
			item.set(\note, note, rrand(1, 2), rrand(0.1, 0.9));
		});
	}
);

j = EZSlider(w, 380@20, "spread", ControlSpec(0, 100, \lin, 0.1, 5));
j.action_({ |ez| ( ~scbr.satieGroups[\cpuTest].set(\spread, (ez.value)))});
b = Button(w, Rect(20, 20, 80, 26)).states_([["play", Color.black, Color.rand]]);
b.action_({|ez| ~scbr.satieGroups[\cpuTest].set(\t_trig, 1)});




/*
// change with gui
w=Window.new("sheefa", Rect(30, 30, 400, 100)).front;
w.view.decorator=FlowLayout(w.view.bounds);
w.view.decorator.gap=8@2;
h = EZSlider(w, 380@20, "azi", ControlSpec(-180, 180, \lin, 0.1, 0));
h.action_({ |ez| ( ez.value.postln; ~scbr.satieGroups[\cpuTest].set(\aziDeg, (ez.value)))});
i = EZSlider(w, 380@20, "elev", ControlSpec(-90, 90, \lin, 0.1, 0));
i.action_({ |ez| ( ~scbr.satieGroups[\cpuTest].set(\eleDeg, (ez.value)))});
j = EZSlider(w, 380@20, "spread", ControlSpec(0, 100, \lin, 0.1, 5));
j.action_({ |ez| ( ~scbr.satieGroups[\cpuTest].set(\spread, (ez.value)))});
b = Button(w, Rect(20, 20, 80, 26)).states_([["play", Color.black, Color.rand]]);
b.action_({|ez| ~scbr.satieGroups[\cpuTest].set(\t_trig, 1)});
*/
