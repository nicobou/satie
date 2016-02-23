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
							e.createSource.value(sourceName, uriName, groupName);
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
							e.createGroup.value(groupName);
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

							if (~allGroupNodes.includesKey(nodeName.asSymbol),
								{   ~removeGroup.value(nodeName);  },
								// else
								{
									~deleteSource.value(nodeName);   });
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
							e.createConnection.value(sourceName, listenerName);
						}
					)
				};
		);"coreCallback called".postln;};
		~connectionCallback = {};
		~connectionProcessCallback = {};
		~sourceNodeCallback = {};
		~sourceProcessCallback = {};
		~groupCallback = {};
		~createSource = { "createSource called".inform };
		~createSourceProcess = {};
		~createSourceNode = {};
		~createGroup = {};
		~createConnection = { "createConnection called".inform};
		~setSynth = {};
		~setUri = {};
		~setProperty = {};
		~setGroupProperty = {};
		~setState = {};
		~setGroupEvent = { };
		~setEvent = { };
		~addMember = { };
		~dropMember = { };
		~clearScene = { };
		~deleteSource = { };
		~removeGroup = { };
		~clearGroupeNode = { };
		~clearSourceNode = { };
		~globalSetState = { };
		~globalSet = { };
		~dumpConnections = { };
		~dumpNodes = {};
		~dumpGroups = {};
		~isFXuri = {};
		~uriType = { };


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