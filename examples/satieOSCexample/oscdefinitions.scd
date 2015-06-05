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

// ****************** usage with OSC ************************

~createSoundSource = {| instanceName, synth, group = \default |
	var name = instanceName;
	var syn = synth;
	var sourceGroup = group;
	if (~scbr.satieGroups[sourceGroup] != nil,
		{ postf("Group % exists\n", sourceGroup); },
		{
			postf("Group  % does not exist, creating one\n", sourceGroup);
			~scbr.makeSatieGroup(sourceGroup);
		}
	);
	postf("creating source % using % and adding to group %\n", name, synth, sourceGroup);
	~scbr.makeInstance(name, synth, sourceGroup);
	~scbr.oscInterface.createSourceOSC(name, ~sourceOSC);
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

~set = { | sourceName, property, value, group = \default |
	// set parameters
	var name = sourceName.asSymbol;
	var param = property.asSymbol;
	var val = value;
	var sourceGroup = group.asSymbol;
	var proxy;
	if (group == "", { sourceGroup = \default });

	if (~scbr.satieGroups[sourceGroup] != nil,
		{	postf("Setting % of % in group % to %\n", param, name, sourceGroup, val);
			~scbr.satieGroups[sourceGroup].[name].set(param, val);
		},
		{ "the group does not exist so not doing anything".postln; }
	);
	//proxy.[name].set(param, val);
	// p.group.set(param, val);
	//proxy.existingProxies;
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
		\set,
		{
			props.pairsDo({ | prop, val |
				~prox.existingProxies;
				postf("set %'s % to %\n", name, prop, val);
				//~scbr.satieGroups[group].[name].set(prop.asSymbol, val);
				~set.value(name, prop, val, group);
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
			~scbr.oscInterface.removeSourceOSC(instanceName);
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
~scbr.oscInterface.newOSC(\satieOSC, ~coreCallback, "/SATIE");

