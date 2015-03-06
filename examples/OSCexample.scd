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



	// NEEDS IMPROVEMENT
	// all plugins (synthDefs) have to be evaluated in "pre-runtime" here
	//
	~scbr.makeSynthDef(\pink, \PinkSin, [\stereoPanner, \monoSpat], [0, 2]);
	~scbr.makeSynthDef(\dust, \DustDust, [\stereoPanner, \monoSpat], [0, 2]);
	~scbr.makeSynthDef(\default, \Default, [\stereoPanner], [0, 2]);

	// be sure the synthDef is compiled on the server
	s.sync;


	~scbr.oscInterface.newOSC(\createSoundSource, ~coreCallback, "/spatosc/core");

	~coreCallback = {

		arg msg;
		var command;
		msg.postln;
		command = msg[1];
		command.postln;

		postf("~coreCallback: command: %, msg: %, \n", command, msg);

		switch (command,
			'createSource', {~createSource.value(msg)},
			'deleteNode', {~deleteSynth.value(msg[2])},
			//'setProperty', {~setProperty.value(msg)}
		);
	};

	~sourceCallback = {
		| args |
		var name, type, values, eventName, state;
		name = args[0].asString.split[4].asSymbol;
		type = args[0].asString.split[5].asSymbol;

		//args.postln;

		switch(type,
			'prop', {~setProperty.value(name, args[1], args[2])},
			'uri', {~setUri.value(name, args[1])},
			'event',
			{
			//postf("~sourceCallback:  nodeName: %  mesageType: %  size: % args: %\n", name, type, args.size, args);
			if ( (args.size < 2 ) ,
					{"~setEvent: OSCrx message with no values".warn;},
					{  // else
						values = args;
						eventName = args[1];
						values.removeAt(0);
						values.removeAt(0);
						~setEvent.value(name, eventName, values);
					}
				)
			},
			'state',
			{
				if ( (args.size > 1) ,
					{
						state = args[2];
						eventName = args[1];
						~setState.value(name, eventName, args[2]);
					},
					{"~setState: OSCrx message with no values".warn; })  // else
			}
		);
	};


	// hold synths references
	~synths = Dictionary();

	// define some functions to handle actions
	~createSource = {
		|args|
		var name;
		name = args[2];
		'creatingSource'.postln;

		if (~synths.includesKey(name),
			{
				'Not adding, synth exists'.postln;
			},
			{
				//create node with default plugin
				~synths.put(name, Synth.tail(s, \default));

				~scbr.oscInterface.sourceOSC(name, ~sourceCallback);

				'adding synth'.postln;
			}
		);
		~synths.postln;
	};

	// update a node's plugin
	~setPlugin = { | name synth |

		'~setPlugin'.postln;

		postf("~setPlugin: creating plugin: %, for: %, \n", synth, name);

		// kill existing synth def
		~synths[name].release;
		~synths.removeAt(name);

		~synths.put(name, Synth.tail(s, synth));
		//~synths.postln;

	};

	~setUri = { | name, value |

		var charIndex, uriPath, type, temp;

		// type://name (i.e. plugin://DustDust, file://<path>

		charIndex = value.asString.find("://");

		temp = value.asString.subStr(charIndex);
		type = value.asString.subStr(0, charIndex-1);
		uriPath = temp.asString.replace("://", "");

		postf("~setUri nodeName: %, type: %  value: %\n", name, type, uriPath);

		switch( type,
			"plugin", {~setPlugin.value(name, uriPath)},
			// "file", {~setPlugin.value(name, uriPath)}  not implemented yet
		);
	};


	// always a keyWord Value pair
	~setProperty = { | nodeName property value |
		//name.postln;
		//postf("~setProperty: seting % of % to %\n", property, nodeName, value);

		~synths[nodeName].set(property, value);
		//~synths[name].postln;
	};

	~setState = { | nodeName state |
		if ( (state > 0),
			{state = 1},
			{state = 0}
		);
		//postf("~setState: seting state of % to %\n", nodeName, state);
		~synths[nodeName].run(state);

		'setState called'.postln;
	};

	// events RX:   /spatosc/core/source/nodename/event eventName v1...vN
	// generates two messages to the node:
	// see below
	~setEvent = { | nodeName eventName args |
		var trigName = "t_"++eventName++"Bang";   // generate trigger name
		trigName.postln;
		if ( (args.size > 0) ,
			{
				~synths[nodeName].set(eventName, args);   // first pass the args
				~synths[nodeName].set(trigName, 1);      // then generate trigger event
			},
			{
				postf("~setEvent: trigger name: % \n",trigName);
				~synths[nodeName].set(trigName, 1);  // no args, just generate trigger event
			}
		)
	};


	~deleteSynth = {
		arg name;
		'deleting synth'.postln;
		~synths[name].release;
		~synths.removeAt(name);
		~scbr.oscInterface.removeSourceOSC(name);


	};
	s.sync;

	//y.postln;
//synth.tail(s, y);
//Synth.tail(s, \PinkSin);
//~synths.postln;
//\PinkSin.postln;
// y.put(s, Synth.tail(s, \PinkSin));

};
)

