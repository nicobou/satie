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

// debugging
//  OSCFunc.trace(true);
//  OSCFunc.trace(false);

//NOTE: OSC RX message specification is based on the SPATOSC specification  (see:   http://code.sat.qc.ca/redmine/projects/spatosc/wiki/spec  )

s.quit

(
s = Server.local;
// Server.default;
Server.supernova;
o = Server.local.options;
// Post the number of output channels
// o.numOutputBusChannels.postln;
o.numOutputBusChannels = 32;
// o.memSize.postln;
o.memSize = 2**20;
o.blockSize = 2048;

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
	// ~scbr.makeSynthDef(\pink, \PinkSin, [\stereoPanner, \monoSpat], [0, 2]);
	// ~scbr.makeSynthDef(\dust, \DustDust, [\stereoPanner, \monoSpat], [0, 2]);
	// ~scbr.makeSynthDef(\default, \default, [\stereoListener], [0]);
	// ~scbr.makeSynthDef(\zkarpluck1, \zkarpluck1, [\stereoListener], [0]);
	~scbr.makeSynthDef(\pink, \PinkSin, [\domeVBAP], [0]);
	~scbr.makeSynthDef(\dust, \DustDust, [\domeVBAP], [0]);
	~scbr.makeSynthDef(\default, \default, [\domeVBAP], [0]);
	~scbr.makeSynthDef(\zkarpluck0, \zkarpluck0, [\domeVBAP], [0]);
	~scbr.makeSynthDef(\zkarpluck1, \zkarpluck1, [\domeVBAP], [0]);


	// be sure the synthDef is compiled on the server
	s.sync;

	OSCdef(\createSoundSource).clear.free;  // just in case newOSC will be re-evaluated.
	~scbr.oscInterface.newOSC(\createSoundSource, ~coreCallback, "/spatosc/core");


	// dictionarys for nodes
	~allNodes = Dictionary();        //  ~allNodes.postln;
	~allConnections = Dictionary();   // separate for faster access  // ~allConnections.postln;


	~coreCallback = {
		arg msg;
		var command;
		command = msg[1];
		postf("~coreCallback: command: %, msg: %, \n", command, msg);


		switch (command,
			'createSource',
			{
				if ( (msg.size < 3 ) ,
					{"~coreCallback: OSCrx createSource message missing values".warn;},
					// else
					{
						var sourceName = msg[2];
						~createSource.value(sourceName);
					}
				)
			},
			'createSoundSource',   // this will be dropped as soon as spatOSC is updated to use the "createSource" message instead
			{
				if ( (msg.size < 3 ) ,
					{"~coreCallback: OSCrx createSource message missing values".warn;},
					// else
					{
						var sourceName = msg[2];
						~createSource.value(sourceName);
					}
				)
			},
			'deleteNode',
			{
				if ( (msg.size < 3 ) ,
					{"~coreCallback: OSCrx deleteNode message missing values".warn;},
					// else
					{
						var sourceName = msg[2];
						~deleteSynth.value(sourceName);
					}
				)
			},
			'clear', {~clearScene.value();},
			'connect',
			{
				if ( (msg.size < 4 ) ,
					{"~coreCallback: OSCrx connect message missing values".warn;},
					// else
					{
						var sourceName, listenerName;
						sourceName = msg[2];
						listenerName = msg[3];
						~createConnection.value(sourceName, listenerName);
					}
				)
			};
		);
	};

	// /spatosc/core/connection/source->listener/update azi elev delayMS gainDB lpHZ
	// /spatosc/core/connection/source->listener/spread  exp   // exponent for incidence effect

	~connectionCallback = { | args |
		var nodeName, listenerName, connectionName, type, values, temp, charIndex;
		//args.postln;

		connectionName = args[0].asString.split[4].asSymbol;   // this is terrible.  Suggests that the spatOSC message format is dumb
		type = args[0].asString.split[5].asSymbol;
		charIndex = connectionName.asString.find("->");

		//temp = value.asString.subStr(charIndex);
		nodeName = connectionName.asString.subStr(0, charIndex-1);
		//listenerName = connectionName.asString.subStr(charIndex+2,255 );

		//postf("~connectionCallback:  connectionName: %  type: %  size: % args: %\n", connectionName, type, args.size, args);

		switch(type,
			'update',
			{
				if ( (args.size != 6 ) ,
					{"connectionCallback: OSCrx update message missing values".warn;},
					// else
					{
						values = args;
						values.removeAt(0);

						//postf("~connectionCallback:  nodeName: %  update:  argc: %  argv: %\n", nodeName, args.size, values);
						//values.postln;
						// ~allConnections[\sheefa].at( \listener );
						~allConnections[nodeName.asSymbol].at( \listener ).put( \update, values );  // update state register
						~allNodes[nodeName.asSymbol].at( \pluginNode ).set(\update, values );   // update node state
					}
				)
			},
			'spread',
			{
				if ( (args.size > 0 ) ,
					{
						var spread = args[1];
						args.postln;
						~allConnections[nodeName.asSymbol].at( \listener ).put( \spread, spread ); // update state register
						~allNodes[nodeName.asSymbol].at( \pluginNode ).set( \spread, spread );   // update node state
					},
					// else
					{"~connectionCallback: OSCrx spread message with no values".warn; })
			};
		);
	};


	// e.g  /spatosc/core/source/nodename/prop  key val
	~sourceCallback = {
		| args |
		var name, type, values, eventName, state;
		name = args[0].asString.split[4].asSymbol;
		type = args[0].asString.split[5].asSymbol;

		//'~sourceCallback'.postln;

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
			},
			{postf("~sourceCallback:  UNMATCHED:  nodeName: %  mesageType: %  size: % args: %\n", name, type, args.size, args)};
		);
	};


	// define some functions to handle actions
	~createSource = { | sourceName |
		'creating Source'.postln;

		if (~allNodes.includesKey(sourceName),
			{
				'Not adding, synth exists'.postln;
			},
			// else create new node
			{
				~allNodes[sourceName.asSymbol] = Dictionary();   // create node  -- create node-specific dict.
				~allConnections[sourceName.asSymbol] = Dictionary();   // create dict. for node's listener(s)
				~allNodes[sourceName.asSymbol].put(\groupName, Group.new);  // create node-specific group and add to node dict.
				~allNodes[sourceName.asSymbol].put(\state, Dictionary());  //  create dict. for node's properies state
				~allNodes[sourceName.asSymbol].put(\pluginName, \nil);

				~scbr.oscInterface.sourceOSC(sourceName.asSymbol, ~sourceCallback);

				'adding synth'.postln;
			}
		);
		~allNodes.postln;
	};

	~createConnection = { |sourceName listenerName |
		var connectionName = sourceName ++ "->" ++ listenerName;

		if ( ~allConnections[sourceName.asSymbol].includesKey(\listener),
			{
				'Not adding, connection exists'.postln;
			},
			// else create new one
			{
				~allConnections[sourceName.asSymbol].put(\listener, Dictionary.newFrom(List[\update, #[0,0,0,1,22050], \spread, 1, \name, connectionName.asSymbol]));
		});
		postf("~createConnection:  connecting: %  to   %\n", sourceName, listenerName);
		~scbr.oscInterface.connectionOSC(connectionName, ~connectionCallback);
		'adding connection'.postln;
	};

	// update a node's plugin (synthdef)
	// note: if the source synthdef contains the argument "autoFreeFlag = 1", new instances of the synthdef will be generated each time an "event" message is received
	~setPlugin = { | nodeName pluginName |

		var nodeNameSym = nodeName.asSymbol;
		var pluginNameSym = pluginName.asSymbol;

		postf("~setPlugin: instantiating plugin: %, for: %, \n", pluginName, nodeName);

		~allNodes[nodeNameSym].at(\groupName).freeAll;   //  clear all active synthNodes in group
		~allNodes[nodeNameSym].at(\state).clear;   // clear node's properties states
		~allNodes[nodeNameSym].put(\pluginName, pluginNameSym);   // set URI:
		~allNodes[nodeNameSym].put(\autoFree, false);



		//  create fresh node.
		~allNodes[nodeNameSym].put(\pluginNode, Synth(~allNodes[nodeNameSym].at(\pluginName),nil,~allNodes[nodeNameSym].at(\groupName),\addToHead));

		// update node's connection to current values

		// make sure listener exists
		if ( ~allConnections[nodeNameSym].includesKey(\listener) ,
			{
				~allNodes[nodeNameSym].at( \pluginNode ).set(\update, ~allConnections[nodeNameSym].at(\listener).at(\update));
				~allNodes[nodeNameSym].at( \pluginNode ).set(\update, ~allConnections[nodeNameSym].at(\listener).at(\spread));
		});



		// is this a selfFreeing synthdef ?
		a = SynthDescLib.global; // the global library of SynthDescs
		x = a.synthDescs.at(pluginNameSym); // get the default SynthDesc

		x.controls.do { |ctl| //[\name, ctl.name, \defaultValue, ctl.defaultValue].postln;
			//ctl.value.postln;
			if ( (ctl.name == \autoFreeFlag) && (ctl.defaultValue != 0 ),
				{  'setting \autoFreeFlag == TRUE'.postln;
					~allNodes[nodeNameSym].put(\autoFree, true);   // set status for node's synthdef to autoFree
					// ~allNodes[\sheefa].at(\autoFree);
				}
			);
		};
	};


	// value is a uri path:   file://~/Desktop/sheefa8.aif, plugin://testnoise~ , adc://1

	~setUri = { | name, value |
		var charIndex, uriPath, type, temp;

		// type://name (i.e. plugin://DustDust, file://<path>

		charIndex = value.asString.find("://");

		temp = value.asString.subStr(charIndex);
		type = value.asString.subStr(0, charIndex-1);
		uriPath = temp.asString.replace("://", "");

		postf("~setUri nodeName: %, type: %  value: %\n", name, type, uriPath);


		// still needs to be expanded for soundfiles, adc, web etc..
		switch( type,
			"plugin", {~setPlugin.value(name, uriPath)},
			// "file", {~setPlugin.value(name, uriPath)}  not implemented yet
		);
	};


	// always a keyWord Value pair
	~setProperty = { | nodeName property value |
		//name.postln;
		//postf("~setProperty: seting % of % to %\n", property, nodeName, value);
		~allNodes[nodeName.asSymbol].at(\state).put(property.asSymbol, value);   // write propery state to node's state register
		~allNodes[nodeName.asSymbol].at( \pluginNode ).set(property.asSymbol, value);   // set Prop  -- update node
	};


	// enable/disable node
	~setState = { | nodeName,  state |
		if ( (state > 0),
			{state = 1},
			{state = 0}
		);
		//postf("~setState: seting state of % to %\n", nodeName, state);

		if (  ~allNodes[nodeName.asSymbol].includesKey( \pluginNode ),
			{
				~allNodes[nodeName.asSymbol].at( \pluginNode ).run(state);
				'setState called'.postln;
		});

	};

	// events RX:   /spatosc/core/source/nodename/event eventName v1...vN
	// generates two messages to the node:
	// see below
	~setEvent = { | nodeName, eventName,  args |
		var valueCount = args.size-1;
		var triggerFlag = false;


		// make sure plugin is defined
		if (~allNodes[nodeName.asSymbol].includesKey( \pluginNode ), {


			if (  eventName.asString.beginsWith("t_"), { triggerFlag = true});

			if ( (valueCount > 1) ,   // pass list of values
				{
					~allNodes[nodeName.asSymbol].at( \pluginNode ).set(eventName, args);
				},
				// else  "active" triggering event,  such as
				{
					if ( (valueCount == 1) ,    // pass value
						{
							~allNodes[nodeName.asSymbol].at( \pluginNode ).set(eventName, args[0]);
						},
						// else  no args.. just pass 1
						{
							~allNodes[nodeName.asSymbol].at( \pluginNode ).set(eventName, 1);  // no args, just generate trigger event
						}
					);
				}
			);

			// if \autoFree mode, and event has set triggerFlag,  create new instance of node's plugin (synthdef) for next time
			if (  ~allNodes[nodeName.asSymbol].at(\autoFree)  && triggerFlag,
				{
					//'setEvent: \autoFree and triggeringFlag are TRUE, generating new synthdef instance'.postln;
					//postln("setEvent: \autoFree and triggeringFlag are TRUE, generating new synthdef instance:" ++nodeName );
					// create new instance
					~allNodes[nodeName.asSymbol].put(\pluginNode, Synth(~allNodes[nodeName.asSymbol].at(\pluginName),nil,~allNodes[nodeName.asSymbol].at(\groupName),\addToHead));

					// if listener exists, update new node with current params
					if ( ~allConnections[nodeName.asSymbol].includesKey(\listener) , {
						~allNodes[nodeName.asSymbol].at( \pluginNode ).set(\update, ~allConnections[nodeName.asSymbol].at(\listener).at(\update));
						~allNodes[nodeName.asSymbol].at( \pluginNode ).set(\update, ~allConnections[nodeName.asSymbol].at(\listener).at(\spread));
					});


					// update new node with current node state
					// ~allNodes[\sheefa].at(\state)
					//~allNodes[\sheefa].at( \pluginNode ).inspect


					// copy node's current properties states to new instance
					~allNodes[nodeName.asSymbol].at(\state).keysValuesDo { |key, value|
						~allNodes[nodeName.asSymbol].at( \pluginNode ).set(key, value);
						//postln("the key: " ++ key ++ " the value: " ++ value)

					};

			});
		});
	};

	//  ~clearScene.value(0);

	~clearScene = {
		'CLEARING SCENE'.postln;
		~allNodes.keysDo { |key |
			key.postln;

			~deleteSynth.value(key)
		};

	};

	// ~allNodes.postln;
	~deleteSynth = { | nodeName |
		if ( ~allNodes.includesKey(nodeName) ,
			{
				'deleting synth'.postln;
				~allNodes[nodeName.asSymbol].at(\groupName).free;   //  clear group and all active synthNodes
				~allNodes[nodeName.asSymbol].release;
				~allNodes.removeAt(nodeName.asSymbol);

				~scbr.oscInterface.removeSourceOSC(nodeName);

				~deleteConnections.value(nodeName);
		});
	};


	//     ~deleteSynth.value(\sheefa);
	//     ~deleteConnections.value(\sheefa);
	//     ~connections.postln;

	~deleteConnections = { | nodeName |

		var connectionName;

		connectionName = ~allConnections[nodeName.asSymbol].at(\listener).at(\name);

		postf("~deleteConnections  for node: %\n", nodeName);

		~scbr.oscInterface.removeConnectionOSC(connectionName.asSymbol);
		~allConnections[nodeName.asSymbol].release;
		~allConnections.removeAt(nodeName.asSymbol);
	};


	s.sync;

	/*

	~nodeName=\mySound;


	~createSource.value(~nodeName);
	~createConnection.value(~nodeName, "ear");
	~setUri.value(~nodeName, "plugin://zkarpluck1");

	~allNodes[~nodeName].at( \pluginNode ).run(1);

	~deleteSynth.value(~nodeName);

	~allNodes[~nodeName].at(\groupName).dump;

	~allNodes[~nodeName].at( \pluginNode )
	~allNodes[~nodeName].includesKey( \pluginNode )


	~clearScene.value();






	*/
};
)

