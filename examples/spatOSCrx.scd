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

/*
NOTES:
this implementation is based on a one-listener model. In the future, we may wish to exapnd this to integrate more than one.  In such a case, proivision will have to be made so that multiple listener synth-defs can be defined.
OSC RX message specification is based on the SPATOSC specification  (see:   http://code.sat.qc.ca/redmine/projects/spatosc/wiki/spec  )
*/

//  s.makeGui;
// s.reboot;


(
//  s.quit;

//~superNovaFlag = true;
//~domePlayback = true;
// ~labodome = true;


// Server.default.options.outDevice_("MADIface USB (23635751)")


if ( ~labodome != nil,
	{
		o = Server.local.options;
		o.device = "MADIface USB (23635751)";
		o.numOutputBusChannels = 32;
		o.dump;
});

// Server.default.options.dump;

if ( ~superNovaFlag != nil,
	{
		s = Server.local;

		'using supernova server'.postln;
		// Server.default;
		Server.supernova;
		o = Server.local.options;
		// Post the number of output channels
		// o.numOutputBusChannels.postln;
		if ( ~domePlayback == nil,
			{ o.numOutputBusChannels = 32;});
		// o.memSize.postln;
		o.memSize = 2**22;
		o.blockSize = 2048;
	}
);

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



	~scbr.makeSynthDef(\dummyPlugin, \emptySource, [\emptySpat], [0]);    // dummy synthdef, used for new nodes

	if ( ~domePlayback == nil,
		{
			// NEEDS IMPROVEMENT
			// all plugins (synthDefs) have to be evaluated in "pre-runtime" here
			//
			'generating synthdefs'.postln;

			~scbr.makeSynthDef(\pink, \PinkSin, [\stereoPanner, \monoSpat], [0, 2]);
			~scbr.makeSynthDef(\dust, \DustDust, [\stereoPanner, \monoSpat], [0, 2]);
			~scbr.makeSynthDef(\default, \default, [\stereoListener], [0]);
			~scbr.makeSynthDef(\zkarpluck0, \zkarpluck0, [\stereoListener], [0]);
			~scbr.makeSynthDef(\zkarpluck1, \zkarpluck1, [\stereoListener], [0]);
			~scbr.makeSynthDef(\labodomeTest, \default, [\labodomeVBAP], [0]);
	},
		// else evalualte for dome listeners
		{
			'generating synthdefs for dome'.postln;
			~scbr.makeSynthDef(\pink, \PinkSin, [\domeVBAP], [0]);
			~scbr.makeSynthDef(\dust, \DustDust, [\domeVBAP], [0]);
			~scbr.makeSynthDef(\default, \default, [\domeVBAP], [0]);
			~scbr.makeSynthDef(\zkarpluck0, \zkarpluck0, [\domeVBAP], [0]);
			~scbr.makeSynthDef(\zkarpluck1, \zkarpluck1, [\domeVBAP], [0]);
		}
	);

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
						~deleteSource.value(sourceName);
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
		var aziDeg, eleDeg, gainDB, delayMs, lpHz, spread;
		var connectionState;
		var thisNode;

		//args.postln;

		connectionName = args[0].asString.split[4].asSymbol;   // this is terrible.  Suggests that the spatOSC message format is dumb
		type = args[0].asString.split[5].asSymbol;
		charIndex = connectionName.asString.find("->");

		nodeName = connectionName.asString.subStr(0, charIndex-1);

		//postf("~connectionCallback:  connectionName: %  type: %  size: % args: %\n", connectionName, type, args.size, args);

		thisNode = ~allNodes[nodeName.asSymbol];
		connectionState = thisNode.at(\connectionState);  // writing to this will write to the node's dictionary

		switch(type,
			'update',
			{
				if ( (args.size != 6 ) ,
					{"connectionCallback: OSCrx update message missing values".warn;},
					// else
					{
						values = args;
						values.removeAt(0);

						// get values from vector, and write to connectionState
						connectionState[0] = aziDeg = values[0].raddeg;
						connectionState[1] = eleDeg= values[1].raddeg;
						connectionState[2] = gainDB = values[2];
						connectionState[3] = delayMs = values[3];
						connectionState[4] = lpHz = values[4];

						// update plugin synthDef state
						~allNodes[nodeName.asSymbol].at( \pluginNode ).set(\aziDeg, aziDeg, \eleDeg, eleDeg, \gainDB, gainDB, \delayMs, delayMs, \lpHz, lpHz);
					}
				)
			},
			'spread',
			{
				if ( (args.size > 0 ) ,
					{
						connectionState[5] = spread = args[1];  // get values from vector, and write to connectionState
						args.postln;
						~allNodes[nodeName.asSymbol].at( \pluginNode ).set( \spread, spread );   // update plugin synthDef state
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
				~allNodes[sourceName.asSymbol].put(\groupName, ParGroup.new);  // create node-specific group and add to node dict.
				~allNodes[sourceName.asSymbol].put(\pluginName, \dummyPlugin);

				// create client-side state register for connection values
				~allNodes[sourceName.asSymbol].put(\connectionState,  Array.with(0,0,0,1,15000,1)); // aziDeg = 0, eleDeg = 0, gainDB = 0, delayMs = 1, lpHz = 15000, spread = 1

				//  instantiate an empty synthdef for new node, so that its listener state is defined and can be updated
				~allNodes[sourceName.asSymbol].put(\pluginNode, Synth(~allNodes[sourceName.asSymbol].at(\pluginName),nil,~allNodes[sourceName.asSymbol].at(\groupName),\addToHead));

				~scbr.oscInterface.sourceOSC(sourceName.asSymbol, ~sourceCallback);

				'adding synth'.postln;
			}
		);
		~allNodes.postln;
	};

	~createConnection = { |sourceName listenerName |
		var connectionName = sourceName ++ "->" ++ listenerName;

		if (  ~allNodes.includesKey(sourceName.asSymbol) == false ,
			// source not defined,  so create it
			{
				~createSource.value(sourceName.asSymbol);
		});

		if ( ~allNodes[sourceName.asSymbol].includesKey(\connectionName),
			{
				'~createConnection:  connection already exists, no action taken'.postln;
			},
			// else create new one
			{
				~allNodes[sourceName.asSymbol].put(\connectionName, connectionName.asSymbol);

				~scbr.oscInterface.connectionOSC(~allNodes[sourceName.asSymbol].at(\connectionName),~connectionCallback );

				// postf("~createConnection: creating callback for  %  ", ~allNodes[sourceName.asSymbol].at(\connectionName));
		});
	};

	// update a node's plugin (synthdef)
	// note: if the source synthdef contains the argument "autoFreeFlag = 1", new instances of the synthdef will be generated each time an "event" message is received
	~setPlugin = { | nodeName pluginName |

		var nodeNameSym = nodeName.asSymbol;
		var pluginNameSym = pluginName.asSymbol;
		var thisNode = ~allNodes[nodeNameSym];
	    var connectionState = thisNode.at(\connectionState);

		// get current connectionState
		var aziDeg = connectionState[0];  // aziDeg = 0, eleDeg = 0, gainDB = 0, delayMs = 1, lpHz = 15000, spread = 1
		var eleDeg = connectionState[1];
		var gainDB = connectionState[2];
		var delayMs = connectionState[3];
		var lpHz = connectionState[4];
		var spread = connectionState[5];


		// postf("~setPlugin: instantiating plugin: %, for: %, \n", pluginName, nodeName);

		thisNode.at(\groupName).freeAll;   //  clear current synthNode(s) in group

		thisNode.put(\pluginName, pluginNameSym);   // set URI:

		// create fresh synthDef plugin.
		thisNode.put(\pluginNode, Synth(~allNodes[nodeNameSym].at(\pluginName),nil,~allNodes[nodeNameSym].at(\groupName),\addToHead));

		// set connection to current state
		thisNode.at( \pluginNode ).set(\aziDeg, aziDeg, \eleDeg, eleDeg, \gainDB, gainDB, \delayMs, delayMs, \lpHz, lpHz, \spread, spread );

	};


	// value is a uri path:   file://~/Desktop/sheefa8.aif, plugin://testnoise~ , adc://1
	~setUri = { | name, value |
		var charIndex, uriPath, type, temp;

		// type://name (i.e. plugin://DustDust, file://<path>

		charIndex = value.asString.find("://");

		temp = value.asString.subStr(charIndex);
		type = value.asString.subStr(0, charIndex-1);
		uriPath = temp.asString.replace("://", "");

		// postf("~setUri nodeName: %, type: %  value: %\n", name, type, uriPath);


		// still needs to be expanded for soundfiles, adc, web etc..
		switch( type,
			"plugin", {~setPlugin.value(name, uriPath)},
			// "file", {~setPlugin.value(name, uriPath)}  not implemented yet
		);
	};


	// always a keyWord Value pair
	~setProperty = { | nodeName property value |
		//postf("~setProperty: seting % of % to %\n", property, nodeName, value);

		~allNodes[nodeName.asSymbol].at( \pluginNode ).set(property.asSymbol, value);   // set Prop  -- update synthDef plugin
	};


	// enable/disable node
	~setState = { | nodeName,  state |
		if ( (state > 0),
			{state = 1},
			{state = 0}
		);
		//postf("~setState: seting state of % to %\n", nodeName, state);

		~allNodes[nodeName.asSymbol].at( \pluginNode ).run(state);

	};

	// events RX:   /spatosc/core/source/nodename/event eventName v1...vN
	~setEvent = { | nodeName, eventName,  args |
		var valueCount = args.size-1;

		//postln("~setEvent: node:" ++nodeName ++" event name:"++eventName++"  arg(s): "++ args );

		if ( (valueCount == 1) ,    // pass value
			{
				~allNodes[nodeName.asSymbol].at( \pluginNode ).set(eventName, args[0]);
			},
			// else  no args.. just pass 1
			{
				~allNodes[nodeName.asSymbol].at( \pluginNode ).set(eventName, 1);  // no args, just generate trigger event
			}
		);
	};


	~clearScene = {
		'CLEARING SCENE'.postln;
		~allNodes.keysDo { |key |
			key.postln;

			~deleteSource.value(key)
		};

	};


	~deleteSource = { | nodeName |
		if ( ~allNodes.includesKey(nodeName) ,
			{
				var connectionName = ~allNodes[nodeName.asSymbol].at(\connectionName);
				'deleting synth'.postln;
				// postf("~deleteConnection:  %  for node: %\n",connectionName,  nodeName);

				// disconnect callbacks
				~scbr.oscInterface.removeConnectionOSC(connectionName.asSymbol);
				~scbr.oscInterface.removeSourceOSC(nodeName);

				~allNodes[nodeName.asSymbol].at(\groupName).free;   //  clear group and all active synthNodes
				~allNodes[nodeName.asSymbol].release;
				~allNodes.removeAt(nodeName.asSymbol);
		});
	};


	s.sync;

	/*  TEMP

	~nodeName="sourceC:spatOSCsource_0".asSymbol;

	~nodeName=\sheefa;

	~nodeName=\mySound;
	~listenerName=\ear;
	~connectionName= ~nodeName ++ "->" ++ ~listenerName;


	~createSource.value(~nodeName);

	~createConnection.value(~nodeName, "ear");

	~setUri.value(~nodeName, "plugin://labodomeTest");

	~allNodes[~nodeName].put(\connectionState,  Array.with(90,0,0,1,15000,100));   // create client-side state register for connection values


	~connectionState = ~allNodes[~nodeName].at(\connectionState);


	~connectionState[5] = 222;

	~allNodes[~nodeName].at(\connectionState)[4];


	~allNodes[~nodeName].at(\connectionState)[4];

	 // \aziDeg, 0, \eleDeg, 0, \gainDB, 0, \delayMs, 1, \lpHz, 15000, \spread, 1  // default connection values



	~setUri.value(~nodeName, "plugin://default");

	~setUri.value(~nodeName, "plugin://labodomeTest");

	~allNodes[~nodeName].at(\pluginName);

	~allNodes[~nodeName].at( \pluginNode ).run(1);

	~allNodes[~nodeName].at( \pluginNode ).set(\t_gate, 1);

	~allNodes[~nodeName].at( \pluginNode ).set(\outputDB, 18);


	~allNodes[~nodeName].at( \pluginNode ).set(\spread, 9);

	~allNodes[~nodeName].at( \pluginNode ).get(\spread, { arg value; ("spread is now:" + value ).postln });


	~spread.postln;

	~allNodes[~nodeName].at( \pluginNode ).dump;

	~allNodes[~nodeName].at(\groupName).dump;

	~allNodes[~nodeName].at( \pluginNode )

	~allNodes[~nodeName].includesKey( \pluginNode )


	~connectionCallback.value( ["/spatosc/core/connection/"++ ~connectionName ++"/spread", 5]);


	~deleteSynth.value(~nodeName);
	~clearScene.value();

	*/
};
)

