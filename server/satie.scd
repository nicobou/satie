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

s = Server.supernova.local;

~meter = false;
~tree = false;
~listener = "stereoListener";
~blocksize = 1024;
~listListeners = false;
~listSourceTypes = false;
~listDevices = false;
~audioDevice = nil;
~runScsynth = false;
~logPrefix = "";
~inputUI = false;

Server.local.options.numInputBusChannels = 0;

thisProcess.argv.do({
	arg item, i;
	case
	{ item == "numInputs" } { Server.local.options.numInputBusChannels = thisProcess.argv[ i + 1].asInteger; }
	{ item == "logprefix" } { ~logPrefix = thisProcess.argv[ i + 1]; }
	{ item == "listListeners" } { ~listListeners = true; }
	{ item == "listSourceTypes" } { ~listSourceTypes = true; }
	{ item == "listDevices" } { ~listDevices = true; }
	{ item == "device" } { ~audioDevice = thisProcess.argv[ i + 1]; }
	{ item == "meter" } { ~meter = true; }
	{ item == "tree" } { ~tree = true; }
	{ item == "listener" } { ~listener = thisProcess.argv[ i + 1]; }
	{ item == "blockSize" } { ~blocksize = thisProcess.argv[ i + 1].asInteger; }
	{ item == "scsynth" } { ~runScsynth = true; }
	{ item == "inputUI" } { ~inputUI = true; };
});

if (~listDevices == true, {
	Platform.case(
		\osx, {
			ServerOptions.devices.do({arg item; (~logPrefix ++ item.asSymbol).postln});
			thisProcess.shutdown;
			0.exit;
		},
		\linux,     { (~logPrefix ++ "list devices is not supported for Linux").postln; 0.exit; },
		\windows,   { (~logPrefix ++ "list devices is not supported for Windows").postln; 0.exit; }
	);
});

~satieConfiguration = SatieConfiguration.new(s, [~listener.asSymbol]);
Platform.case( \linux, { ~satieConfiguration.serverOptions.blockSize = ~blocksize; });

if (~audioDevice != nil, {
	Platform.case(
		\osx, {
			s.options.device = ~audioDevice.replace("%", " ");
		},
		\linux,     { (~logPrefix ++ "audio device selection is not supported for Linux").postln; 0.exit; },
		\windows,   { (~logPrefix ++ "audio device selection is not supported for Windows").postln; 0.exit; }
	);
});


~ui = {
	var w, v, c, aziSpec, eleSpec, dbSpec, spreadSpec, delayMsSpec, lpHzSpec, hpHzSpec;

	aziSpec = ControlSpec(-180, 180, \linear, 0.01);
	eleSpec = ControlSpec(-90, 90, \linear, 0.01);
	dbSpec = ControlSpec(-50, 0, \linear, 0.01);
	spreadSpec = ControlSpec(0, 100, \linear, 0.01);
	delayMsSpec = ControlSpec(0, 500, \linear, 1);
	lpHzSpec = ControlSpec(0, 19000, \linear, 1);
	hpHzSpec = ControlSpec(0, 18000, \linear, 1);

	w = GUI.window.new("SATIE spatializers", Rect( 200, 100, 10 + 550, 5 + 120*Server.local.options.numInputBusChannels), scroll: true);
	w.view.decorator = FlowLayout( w.view.bounds);
	w.view.background = Color.grey;
	~satie.groupInstances[\default].postln;
	Server.local.options.numInputBusChannels.do({
		arg item, i;
		var container, orient, db, nodeName, spread, delayMs, lpHz, hpHz;
		nodeName = ("audio"++i).asSymbol;
		container = CompositeView.new(w, 550@120);
		container.decorator = FlowLayout(container.bounds);
		container.background = Color.rand;
		StaticText.new(container, Rect(0,0,60, 10)).string_(("%/%%".format("azi".asSymbol, "ele".asSymbol, i).asSymbol));
		orient = Slider2D.new(container, Rect(0, 0, 100, 100));
		orient.action_({|sl|
			~satie.groupInstances[\default][nodeName.asSymbol].set(\aziDeg, aziSpec.map(sl.x), \eleDeg, eleSpec.map(sl.y));
		});
		orient.setXY(aziSpec.unmap(0), eleSpec.unmap(45));

		StaticText.new(container, Rect(0,0,40, 10)).string_("db");
		db = Slider(container, Rect(0, 0, 20, 90));
		db.orientation = \vertical;
		db.action_({|sl|
			~satie.groupInstances[\default][nodeName.asSymbol].set(\gainDB, dbSpec.map(sl.value));
		});
		db.value = dbSpec.unmap(0);

		StaticText.new(container, Rect(0,0,40, 10)).string_("spread");
		spread = Slider(container, Rect(0, 0, 20, 90));
		spread.orientation = \vertical;
		spread.action_({|sl|
			~satie.groupInstances[\default][nodeName.asSymbol].set(\spread, spreadSpec.map(sl.value));
		});
		spread.value = spreadSpec.unmap(1);

		StaticText.new(container, Rect(0,0,40, 10)).string_("delMs");
                delayMs = Slider(container, Rect(0, 0, 20, 90));
		delayMs.orientation = \vertical;
		delayMs.action_({|sl|
			~satie.groupInstances[\default][nodeName.asSymbol].set(\delayMs, delayMsSpec.map(sl.value));
		});
		delayMs.value = delayMsSpec.unmap(0);

		StaticText.new(container, Rect(0,0,40, 10)).string_("lpHz");
		lpHz = Slider(container, Rect(0, 0, 20, 90));
		lpHz.orientation = \vertical;
		lpHz.action_({|sl|
			~satie.groupInstances[\default][nodeName.asSymbol].set(\lpHz, lpHzSpec.map(sl.value));
		});
		lpHz.value = lpHzSpec.unmap(19000);

		StaticText.new(container, Rect(0,0,40, 10)).string_("hpHz");
		hpHz = Slider(container, Rect(0, 0, 20, 90));
		hpHz.orientation = \vertical;
		hpHz.action_({|sl|
			~satie.groupInstances[\default][nodeName.asSymbol].set(\hpHz, hpHzSpec.map(sl.value));
		});
		hpHz.value = hpHzSpec.unmap(5);

	});
	w.front;
};

if (~runScsynth == true, {s = Server.scsynth.local});
~satie = Satie.new(~satieConfiguration);
~satie.boot();


s.waitForBoot({
	s.sync;

	if (~listListeners == true, {
		~satie.spatPlugins.keys.do({arg item; (~logPrefix ++ item.asSymbol).postln});
		thisProcess.shutdown;
		0.exit;
	});

	if (~listSourceTypes == true, {
		~satie.generatedSynthDefs.do({arg item; (~logPrefix ++ item.asSymbol).postln});
		thisProcess.shutdown;
		0.exit;
	});

	// generate
	Server.local.options.numInputBusChannels.do({
		arg item, i;
		var nodeName = ("audio" ++ i);
		~satie.makeInstance(nodeName.asSymbol, \MonoIn, synthArgs: [\gainDB: 0, \bus: i + 1, \t_trig: 1]);
		// ~satie.makeInstance("drone" ++ i.asSymbol, \misDrone, \default, synthArgs: [\gainDB: 0]);
	});

	if (~meter, {s.meter;});
	if (~tree, {s.plotTree;});
	s.sync;
	if (~inputUI, {~ui.value()});

});
