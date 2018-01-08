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
	{ item == "scsynth" } { ~runScsynth = true; };
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
		~satie.makeInstance("audio" ++ i.asSymbol, \MonoIn, synthArgs: [\gainDB: 0, \bus: i, \t_trig: 1]);
		//~satie.makeInstance("audio" ++ i.asSymbol, \misDrone, \default, synthArgs: [\gainDB: 0]);
	});

	if (~meter, {s.meter;});
	if (~tree, {s.plotTree;});
});


