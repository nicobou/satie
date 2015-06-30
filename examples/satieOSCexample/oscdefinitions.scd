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

// This file is loaded automatically by main.scd

~createSoundSource = {| instanceName, synth, group = \default |
	var name = instanceName;
	var syn = synth;
	var sourceGroup = group;
	if (~groupExists.value(sourceGroup) == false,
		{ postf("Group  % does not exist, creating one\n", sourceGroup);
			~createGroup.value(sourceGroup);
		}
	);
	postf("creating source % using % and adding to group %\n", name, synth, sourceGroup);
	~scbr.makeInstance(name, synth, sourceGroup);
	~osc.createSourceOSC(name, ~sourceOSC, group);
};

~createGroup = { | groupName, addAction = \addToHead |
	if (~groupExists.value(groupName),
		{
			postf("Group % exists\n", groupName);
		},
		{
			postf("Group  % does not exist, creating one\n", groupName);
			~scbr.makeSatieGroup(groupName, addAction);
		}
	);
};

~groupExists = { |groupName |
	var ret;
	if (~scbr.satieGroups[groupName] != nil,
		{ ret = true },
		{ ret = false}
	);
	ret;
};

~removeSoundSource = { |sourceName|
	var name = sourceName;
	postf("Removing and cleaning %\n", name);
	~scbr.cleanInstance(name);
};

~setInstance = { | sourceName, property, value, group = \default|
	// set parameters
	var name = sourceName.asSymbol;
	var param = property.asSymbol;
	var val = ~handleBufProperty.value(property, value);
	var sourceGroup = group.asSymbol;
	var proxy;
	if (~groupExists.value(sourceGroup) == true,
		{
			postf("Setting % of % in group % to %\n", param, name, sourceGroup, val);
			~scbr.satieGroups[sourceGroup].[name].set(param, val);
		},
		{ postf("the group % does not exist so not doing anything", sourceGroup); }
	);
};

// kludge!
~handleBufProperty = { |property, value|
	// we need to handle the special case of passing a bufnum to sndFile.
	// sndFile expects a bufnum with its context, either a Buffer object or, in our case, a dictionary entry
	// so we construct the proper object here to allow the user simply call the dictionary entry.
	// we assume the global object ~playBuffers
	// FIXME: for some reason this does not propagate to setGroup
	var val;
	if (property == \bufnum,
		{ val = ~playBuffers[value.asSymbol].bufnum;},
		//{ ~playBuffers[\bleh]; },
		{ val = value; }
	);
	val;
};

~setGroup = { | group, property, value|
	// set parameters
	var param = property.asSymbol;
	var val = ~handleBufProperty.value(property, value);
	var sourceGroup = group.asSymbol;
	var proxy;
	if (~groupExists.value(sourceGroup) == true,
		{
			postf("setting group %'s param % to % \n", sourceGroup, param, val);
			~scbr.satieGroups[sourceGroup].group.set(param, val);
		},
		{ postf("the group % does not exist so not doing anything", sourceGroup); }
	);
};

~sourceOSC = { | args |
	var group, name, props, cmd, size;
	args.postln;
	size = args.size;
	props = args.copyRange(2, size - 1);
	group = args[0].asString.split[2].asSymbol;
	name = args[0].asString.split[3].asSymbol;
	cmd = args[1];
	postf("properties to affect: %\n", props);
	switch(cmd,
		\setInstance,
		{
			props.pairsDo({ | prop, val |
				//~prox.existingProxies;
				postf("** instance: set %'s % to %\n", name, prop, val);
				//~scbr.satieGroups[group].[name].set(prop.asSymbol, val);
				~setInstance.value(name, prop, val, group);
			});
		},
		\setGroup,
		{
			props.pairsDo({ | prop, val |
				//~prox.existingProxies;
				postf("** group: set %'s % to %\n", group, prop, val);
				//~scbr.satieGroups[group].[name].set(prop.asSymbol, val);
				~setGroup.value(group, prop, val);
			});
		}
	);
};

// handle any OSC message
// eg. /SATIE/ createSoundSource pluck string
~coreCallback = { | msg |
	var command, instanceName, synth, group;
	command = msg[1];
	postf("coreCallback argument: %\n", msg);

	switch(command,
		\createSoundSource,
		{
			instanceName = msg[2];
			synth = msg[3];
			postf("creating: %, %, based on message %\n", instanceName, synth, msg);
			postf("there are % arguments \n", msg.size);
			if ((msg.size < 4) ,
				{
					postf("wrong number of arguments %\n", msg);
				},
				{
					postf("coreCallback creates %\n", msg);
					case
					{ msg.size > 4 } {
						group = msg[4];
					}
					{ msg.size == 4 } {
						group = \default;
					};
					postf("-------> % % % \n", instanceName, synth, group);
					~createSoundSource.value(instanceName, synth, group);
				}
			)
		},
		\deleteSoundSource,
		{
			var instanceName = msg[2];
			postf("Removing sound source: ---> %\n", instanceName);
			~osc.removeSourceOSC(instanceName);
			~removeSoundSource.value(instanceName);
		},
		\createGroup,
		{
			var groupName, action;
			groupName = msg[2];
			if(msg[3] != nil,
				{ action = msg[3] },
				{ action = \addToHead }
			);
			if(~groupExists.value(groupName) == false,
				{ 	~createGroup.value(groupName, action) }
			);
		}
	);
};

s.sync;
~osc.newOSC(\satieOSC, ~coreCallback, "/SATIE");

