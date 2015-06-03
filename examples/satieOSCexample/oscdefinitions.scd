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

~createSoundSource = {| instanceName, synth, group |
	var name = instanceName;
	var syn = synth;
	var proxy = group;
	postf("creating source % using % and adding to group %\n", name, synth, proxy);
	~scbr.makeInstance(name, synth, proxy);
	~scbr.oscInterface.createSourceOSC(name, ~sourceOSC);
};

~removeSoundSource = { |sourceName|
	var name = sourceName;
	postf("Removing and cleaning %\n", name);
	~scbr.cleanInstance(name);
};

~createGroup = { | groupName |
	var name = groupName;
	~scbr.makeSatieGroup(name);
};


~set = { | sourceName, property, value, group = \default |
	// set parameters
	var name = sourceName.asSymbol;
	var param = property.asSymbol;
	var val = value;
	var sourceGroup = group;
	~scbr.satieGroups[sourceGroup].[name].set(param, val);
};

~sourceOSC = { | args |
	var group, name, props, cmd, size;
	size = args.size;
	props = args.copyRange(2, size - 1);
	group = args[0].asString.split[1].asSymbol;
	name = args[0].asString.split[2].asSymbol;
	cmd = args[1];
	switch(cmd,
		\set,
		{
			props.pairsDo({ | prop, val |
				~scbr.satieGroups[group].[name].set(prop.asSymbol, val);
			});
		}
	);

};

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
		}
	)
};

s.sync;
~scbr.oscInterface.newOSC(\satieOSC, ~coreCallback);

