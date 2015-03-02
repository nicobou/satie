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
s.waitForBoot{

	// finding source directory
	~rootSrcPath = thisProcess.nowExecutingPath.dirname ++ "/..";
	(~rootSrcPath ++ "/src/*.scd").pathMatch.do({arg item; item.loadPaths});
	// creating a sc-basic-renderer
	~scbr = ~scbrMaker.value(~rootSrcPath);
	// loading source plugins
	~scbr.pluginLoader.loadAudioPlugins(~rootSrcPath ++ "/audiosources/*.scd");
	// see the loaded plugins in the console
	~scbr.pluginLoader.audioPlugins.postln;
	// loading spatializer plugins
	~scbr.pluginLoader.loadSpatPlugins(~rootSrcPath ++ "/spatializers/*.scd");
	~scbr.pluginLoader.spatPlugins;
	// generating SynthDef that are going to be used,
	// here a PinkSin source spatialized by
	//   - a stereo panner (starting channel 0)
	//   - a monoSpat (starting channel 1)
	~scbr.makeSynthDef(\pink, \PinkSin, [\stereoPanner, \monoSpat], [0, 2]);
	~scbr.makeSynthDef(\dust, \DustDust, [\stereoPanner, \monoSpat], [0, 2]);
	~scbr.makeSynthDef(\input, \MonoIn, [\stereoPanner, \monoSpat], [0, 2]);
	// be sure the synthDef is compiled on the server
	s.sync;

	// initialization is done, create and remove a source + controls
	//y = Synth.tail(s, \fool);
	// spat properties
	//y.set(\vol, 0.1);
	//y.set(\azi, 0.2);
	// source property
	//y.set(\sfreq, 100);
	// remove source
	// y.release;*/

	// s.waitForBoot

	// OSC business
	// our main OSC callback

	~coreCallback = {

		arg msg;
		var command;
		msg.postln;
		command = msg[1];
		command.postln;

		switch (command,
			'createNode', {~createNode.value(msg)},
			'deleteNode', {~deleteSynth.value(msg[2])},
			//'setProperty', {~setProperty.value(msg)}
		);
	};
	~scbr.oscInterface.newOSC(\createSoundSource, ~coreCallback, "/spatosc/core");

	// hold synths references
	~synths = Dictionary();

	// define some functions to handle actions
	~createNode = {
		|args|
		var name;
		name = args[2];
		if (~synths.includesKey(name),
			{
				'Not adding, synth exists'.postln;
			},
			{
				// we need a placeholder before instantiating the synth
				~synths.put(name, name);
				~scbr.oscInterface.newOSC(name ++ \prop, ~setProperty, "/spatosc/core/source" +/+ name +/+ "/prop");
				~scbr.oscInterface.newOSC(name ++ \uri, ~setUri, "/spatosc/core/source" +/+ name +/+ "/uri");
				~scbr.oscInterface.newOSC(name ++ \state, ~setState, "/spatosc/core/source" +/+ name +/+ "/state");
				~scbr.oscInterface.newOSC(name ++ \event, ~setEvent, "/spatosc/core/source" +/+ name +/+ "/event");
			}
		);
		~synths.postln;
	};
	~createSynth = {
		arg args;
		var name, synth;
		'creatingSynth'.postln;
		args.postln;
		name = args[2];
		synth = args[3];
		if (~synths.includesKey(name),
			{ 'Not adding, synth exists'.postln; },
			{
				~synths.put(name, Synth.tail(s, synth));
				'adding synth'.postln;
				~scbr.oscInterface.sourceOSC(name, ~setProperty);
			}
		);
		~synths.postln;
	};
	~setUri = {
		// type://name (i.e. plugin://DustDust, file://<path>
		| args |
		var name, type, plugin;
		name = args[0].asString.split[4].asSymbol;
		type = args[1].asString.split[0].asSymbol;
		plugin = args[1].asString.split[2].asSymbol;
		postf("creating name: %, of type: %, using synth: %\n", name, type, plugin);
		switch (type,
			'plugin:', { ~synths.put(name, Synth.tail(s, plugin))},
			'file:', { postf("unimplemented yet ");  }
		)
	};

	~setProperty = {
		arg args;
		var name, property, value;
		name = args[0].asString.split[4].asSymbol;
		//name.postln;
		property = args[1];
		value = args[2];
		postf("seting % of % to %\n", property, name, value);
		~synths[name].set(property, value);
		~synths[name].postln;
	};
	~setState = {
		'setState called'.postln;
	};
	~setEvent = {
		'setEvent called'.postln;
	};


	~deleteSynth = {
		arg name;
		'deleting synth'.postln;
		~synths[name].release;
		~synths.removeAt(name);
		~scbr.oscInterface.removeSourceOSC(name);


	};
	s.sync;
};
)