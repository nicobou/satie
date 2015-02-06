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
	~scbr.pluginLoader.audioPlugins;
	// loading spatializer plugins
	~scbr.pluginLoader.loadSpatPlugins(~rootSrcPath ++ "/spatializers/*.scd");
	~scbr.pluginLoader.spatPlugins;
	// generating SynthDef that are going to be used,
	// here a PinkSin source spatialized by
	//   - a stereo panner (starting channel 0)
	//   - a monoSpat (starting channel 1)
	/*~scbr.makeSynthDef(\fool, \PinkSin, [\stereoPanner, \monoSpat], [0, 2]);
	// be sure the synthDef is compiled on the server
	s.sync;

	// initialization is done, create and remove a source + controls
	y = Synth.tail(s, \fool);
	// spat properties
	y.set(\vol, 0.1);
	y.set(\azi, 0.2);
	// source property
	y.set(\sfreq, 100);
	// remove source
	// y.release;*/

};  // s.waitForBoot
)

~synths;
s.sync;
(
// Dictionary to keep references to synths
~synths = Dictionary();
// define and OSC target
OSCdef(\createSoundSource, ~coreCallback, "/spatosc/core");

// our main OSC callback
~coreCallback = {

	arg msg;
	var command;
	msg.postln;
	command = msg[1];
	command.postln;

	switch (command,
		'create', {~createSynth.value(msg)},
		'delete', {~deleteSynth.value(msg[2])},
		'setProperty', {~setProperty.value(msg)}
	);
};

// define some functions to handle actions
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
			~scbr.makeSynthDef(name, synth, [\stereoPanner, \monoSpat], [0, 2]);
			~synths.put(name, Synth.tail(s, name));
			'adding synth'.postln;
		}
	)
};

~setProperty = {
	arg args;
	var name, property, value;
	name = args[2];
	property = args[3];
	value = args[4];
	postf("seting % of % to %", property, name, value);
	~synths[name].set(property, value);
};

~deleteSynth = {
	arg name;
	'deleting synth'.postln;
	~synths[name].release;
	~synths.removeAt(name)

};
)

