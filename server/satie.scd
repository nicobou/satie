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
~gui = false;
~tree = false;
~listener = "stereoListener";
~blocksize = 1024;
~listListeners = false;
~listSourceTypes = false;
~logPrefix = "";
Server.local.options.numInputBusChannels = 0;

thisProcess.argv.do({
	arg item, i;
	case
	{ item == "numInputs" } { Server.local.options.numInputBusChannels = thisProcess.argv[ i + 1].asInteger; }
	{ item == "logprefix" } { ~logPrefix = thisProcess.argv[ i + 1]; }
	{ item == "listListeners" } { ~listListeners = true; }
	{ item == "listSourceTypes" } { ~listSourceTypes = true; }
	{ item == "meter" } { ~meter = true; }
	{ item == "gui" } { ~gui = true; }
	{ item == "tree" } { ~tree = true; }
	{ item == "listener" } { ~listener = thisProcess.argv[ i + 1]; }
	{ item == "blockSize" } { ~blocksize = thisProcess.argv[ i + 1].asInteger; }
	{ item == "scsynth" } { s = Server.scsynth.local; };
});

~satieConfiguration = SatieConfiguration.new(s, [~listener.asSymbol]);
~satieConfiguration.serverOptions.blockSize = ~blocksize;
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
		//("--------------------------------------- audio" ++ i.asSymbol).postln;
		~satie.makeInstance("audio" ++ i.asSymbol, \MonoIn, synthArgs: [\gainDB: 0, \bus: i, \t_trig: 1]);
		//~satie.makeInstance("audio" ++ i.asSymbol, \misDrone, \default, synthArgs: [\gainDB: 0]);
	});

	~satie.groupInstances.postln;

	if (~meter, {s.meter;});
	if (~gui, {s.makeGui;});
	if (~tree, {s.plotTree;});
});
