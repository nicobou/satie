// Satie4Unity, audio rendering support for Unity
// Copyright (C) 2016  Zack Settel
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
/*
NOTES:
this implementation is based on a one-listener model. In the future, we may wish to exapnd this to integrate more than one.  In such a case, proivision will have to be made so that multiple listener synth-defs can be defined.
Satie4Unity's message specification is inspired from the SPATOSC specification  (see:   http://code.sat.qc.ca/redmine/projects/spatosc/wiki/spec  )
*/


(
~satie4unityprotocol = { | oscContext, satieContext, oscID = \satie4unityOSC |
	var osc = oscContext;
	var satie = satieContext;

	var e = Environment.make({
		~allSourceNodes = Dictionary();        //  ~allSourceNodes.postln;
		~allGroupNodes = Dictionary();        //  ~allGroups.postln;
		~basicRendererCallback = { "basicRendererCallback called".inform };
		~coreCallback = { arg msg;
			var command;
			command = msg[1];
			//postf("~coreCallback: command: %, msg: %, \n", command, msg);

			switch (command,
				'createSource',  // required args:  name uri    <optional>  group
				{
					//postf("~coreCallback: command: %, messLen: %   msg: %, \n", command, msg.size, msg);

					if ( (msg.size < 3 ) ,
						{"~coreCallback: OSCrx createSource message missing values".warn;
							postf("createSource MESS LEN: %", msg.size);

						},
						// else
						{
							var sourceName = msg[2];
							var uriName = "";
							var groupName = "";

							if (msg.size > 3,
								{
									uriName = msg[3];
							});

							if (msg.size > 4,
								{
									groupName = msg[4];
							});
							e.createSource(sourceName, uriName, groupName);
					});
				},
				'createGroup',
				{
					if ( (msg.size < 3 ) ,
						{"~coreCallback: OSCrx createGroup message missing values".warn;
							postf("createGroup MESS LEN: %", msg.size);

						},
						// else
						{
							var groupName = msg[2];
							e.createGroup(groupName);
						}
					)
				},
				'deleteNode',
				{
					if ( (msg.size < 3 ) ,
						{"~coreCallback: OSCrx deleteNode message missing values".warn;},
						// else
						{
							var nodeName = msg[2];

							if (e.allGroupNodes.includesKey(nodeName.asSymbol),
								{   e.removeGroup(nodeName);  },
								// else
								{
									e.deleteSource(nodeName);   });
						}
					)
				},
				'clear', {e.clearScene();},
				'connect',
				{
					if ( (msg.size < 4 ) ,
						{"~coreCallback: OSCrx connect message missing values".warn;},
						// else
						{
							var sourceName, listenerName;
							sourceName = msg[2];
							listenerName = msg[3];
							e.createConnection(sourceName, listenerName);
						}
					)
				};
			);
			"coreCallback called".postln;
		};
		~connectionCallback = {};
		~connectionProcessCallback = {};
		~sourceNodeCallback = {};
		~sourceProcessCallback = {};
		~groupCallback = {};
		~createSource = {| self, sourceName, uriName , groupName = \default |
			if (self.allSourceNodes.includesKey(sourceName),
				{
					postf("~createSource:   % exists, no action \n", sourceName);
				},
				// else create new node
				{
					var type;
					type = self.uriType(uriName);

					switch( type,
						"plugin", {
							self.createSourceNode(sourceName.asSymbol, uriName,groupName )
						},
						"process", {
							self.createSourceProcess(sourceName.asSymbol, uriName,groupName )
						},
						// "file", {~setSynth.value(name, uriPath)}  not implemented yet
					);
				}
			);
			"createSource called".inform };
		~createSourceProcess = { "createSourceProcess called".inform;};
		~createSourceNode = { | self, sourceName, uriName , groupName = \default |
			var synthName;

			if (groupName == "", { groupName = \default; });   // make sure group name is ok

			// check to see if group  exists (even if the corresponding groupNode has not yet been instntiated),  if  not, create it
			if ( satie.satieGroups[groupName.asSymbol] == nil,
				{
					postf("~createSource_groupcheck:   source:%    group:  % undefined,  CREATING GROUP NOW \n", sourceName, groupName);
					self.createGroup(groupName.asSymbol);
				}
			);

			postf("~createSourceNode: %:  uri: %  group: %\n", sourceName, uriName, groupName);
			self.allSourceNodes[sourceName.asSymbol] = Dictionary();   // create node  -- create node-specific dict.
			self.allSourceNodes[sourceName.asSymbol].put(\plugin, \nil);

			// handle any aux send issues here
			if ( groupName == \effect,
				{
					postf("~createSource:  CREATING EFFECTS SOURCE for:%\n", sourceName.asSymbol);

					if (~fxInputBus == nil,    // this should be defined previously in the project's .scd
						{
							postf("~createSource:  ~fxInputBus not defined");
							~fxInputBus = 0;
					});

					// this is an effects node, so save its aux bus assign
					~allSourceNodes[sourceName.asSymbol].put(\auxBus, ~scbr.aux[~fxInputBus]);  //  HACK to set up effects send node
			});

			// now set node's group
			self.allSourceNodes[sourceName.asSymbol].put(\groupNameSym, groupName.asSymbol);

			// call ~setUri to complete instance creation
			//~setUri.value(sourceName.asSymbol,uriName.asSymbol);

			// now set up synth
			if (uriName.asString.contains("plugin://") == false,
				{
					warn("~createSource: WARNING: node: %  bad URI format : %,  setting to \dummyPlugin", sourceName, uriName);
					~setSynth.value(sourceName.asSymbol, \dummyPlugin);
				},
				// else  // path ok, proceed
				{
					var charIndex = uriName.asString.find("://");
					var temp = uriName.asString.subStr(charIndex);
					var type = uriName.asString.subStr(0, charIndex-1);
					synthName = temp.asString.replace("://", "");

					//postf("~setUri nodeName: %, type: %  plugName: %\n", uriName, type, uriPath);
					// still needs to be expanded for soundfiles, adc, web etc..
					switch( type,
						"plugin", {
							self.setSynth(sourceName.asSymbol, synthName)

						},
						// "file", {~setSynth.value(name, uriPath)}  not implemented yet
					);
			});
			osc.sourceOSC(sourceName.asSymbol, ~sourceNodeCallback);   // create OSC callback
			"createSourceNode called".inform;
		};
		~createGroup = { "createGroup called".inform;};
		~createConnection = { "createConnection called".inform;};
		~setSynth = { "setSynth called".inform;};
		~setUri = {};
		~setProperty = {};
		~setGroupProperty = {};
		~setState = {};
		~setGroupEvent = { };
		~setEvent = { };
		~addMember = { };
		~dropMember = { };
		~clearScene = { };
		~deleteSource = { "deletaSource called".inform;};
		~removeGroup = { };
		~clearGroupeNode = { };
		~clearSourceNode = { };
		~globalSetState = { };
		~globalSet = { };
		~dumpConnections = { };
		~dumpNodes = {};
		~dumpGroups = {};
		~isFXuri = {};
		~uriType = { | self, uriPath |
			var charIndex, uriName, type, temp;

			type = nil;

			// type://name (i.e. plugin://DustDust, file://<path>

			// check URI name to make sure its valid

			if (uriPath.asString.contains("://") == false,
				{
					error("~getUriSym:  uri type format error: % ", uriPath);

				},

				// else  // path ok, proceed
				{
					charIndex = uriPath.asString.find("://");

					temp = uriPath.asString.subStr(charIndex);
					type = uriPath.asString.subStr(0, charIndex-1);
					uriName = temp.asString.replace("://", "");
			});
			type;
		};


	}); // Environment.make
	"satie4unityprotol loaded".inform;
	e.know = true;
	postf("passed osc env: %\n", osc);
	// osc.newOSC(oscID, e['coreCallback'], "/SATIE");
	osc.removeBasicRendererOSC(\createSoundSource);

	osc.newOSC(\createSoundSource, e['coreCallback'], "/spatosc/core");

	osc.removeBasicRendererOSC(\brOSC);
	osc.basicRendererOSC(\brOSC,e['basicRendererCallback']);
	e;
};

)