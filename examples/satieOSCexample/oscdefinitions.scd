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
	postf("creating source % using % and adding to group %\n", name, syn, sourceGroup);
	~scbr.makeInstance(name, syn, sourceGroup);
	~osc.createSourceOSC(name, ~coreCallback, group);
};

~createFX = { |instanceName, effect, bus = 0, fxGroup = \fx |
	postf("creating an FX % named % in group % on bus %\n", effect, instanceName, fxGroup, bus);
	~scbr.makeInstance(instanceName, effect, fxGroup);
	~scbr.satieGroups[instanceName].set(\in, ~scbr.aux[bus]);
};

~createGroup = { | groupName, addAction = \addToHead |
	if (~groupExists.value(groupName),
		{
			postf("Group % exists\n", groupName);
		},
		{
			postf("Group  % does not exist, creating one\n", groupName);
			~scbr.makeSatieGroup(groupName, addAction);
			~osc.makeGroupOSC(groupName, ~coreCallback);
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

~removeSoundSource = { |sourceName, group = \default |
	var name = sourceName;
	var sourceGroup = group;
	postf("Removing and cleaning %\n", name);
	~scbr.cleanInstance(name, sourceGroup);
};

~removeGroup = { | group |
	postf("Removing group %\n", group);
	~scbr.killSatieGroup(group);
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
		\set,
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
// eg. /SATIE create name - to create a group
//     /SATIE/default create name - to create an instance of a synth or effect
~coreCallback = { | msg |
	var url, obj, command, name ;
	url = msg[0].asString.split;
	url.removeAt(0); // remove thefirst empty element
	name = msg[2].asSymbol;
	command = msg[1].asSymbol;
	postf("coreCallback argument: %\n", msg);
	postf("coreCallback url: %\n", url);

	switch(command,
		\create,
		{

			var dest = ~getAddressLevel.value(url);
			switch(dest,
				\system, {
					switch(command,
						\create, { ~createGroup.value(name);},
						\createFX, { ~createGroup.value(name, \addToTail);}
					);
				},
				\group,  {
					var group, synth;
					group = url[1].asSymbol;
					synth = msg[3].asSymbol;
					postf("create synth named % using % in group %\n", name, synth, group);
					~createSoundSource.value(name, synth, group);
				}
			);

			/*instanceName = msg[2];
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
			)*/
		},
		\delete,
		{
			var dest = ~getAddressLevel.value(url);
			switch(dest,
				\group, { |group|
					group = url[1].asSymbol;
					~removeGroup.value(group);

				},
				\instance, { | synthName, group |
					synthName = url[2].asSymbol;
					group = url[1].asSymbol;
					~removeSoundSource.value(synthName, group);
				}
			);
			/*var instanceName = msg[2].asSymbol;
			postf("Removing sound source: ---> %\n", instanceName);
			~osc.removeSourceOSC(instanceName);
			~removeSoundSource.value(instanceName);
			*/
		},
		\set,
		{
			"set message received".postln;
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
		},
		\createEffect,
		{
			var name, effect, bus, fxGroup;
			name = msg[2];
			effect = msg[3];
			bus = msg[4];
			fxGroup = msg[5];
			~createFX.value(name, effect, bus, fxGroup);
		}
	);
};

~getAddressLevel = { | url = #[] |
	url.postln;
	switch(url.size,
		1, {
			if(url[0] == "SATIE",
				\system,
				{
					\nope;
					postf("Wrong system address, expected /SATIE, got %\n", url[0]);
					nil;
				}
			);
		},
		2, { \group },
		3, { \instance },
		{ postf("Wrong address: %\n", url.join); }
	);
};

s.sync;
~osc.newOSC(\satieOSC, ~coreCallback, "/SATIE");

