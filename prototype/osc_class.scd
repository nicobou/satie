(
~myOSC = { | oscContext, satieContext |
	var osc = oscContext;
	var satie = satieContext;
	var e = Environment.make({
		~createSoundSource = {| self, instanceName, synth, group = \default |
			var name = instanceName;
			var syn = synth;
			var sourceGroup = group;
			if (self.groupExists(sourceGroup) == false,
				{ postf("Group  % does not exist, creating one\n", sourceGroup);
					self.createGroup(sourceGroup);
				}
			);
			postf("creating source % using % and adding to group %\n", name, syn, sourceGroup);
			satie.makeInstance(name, syn, sourceGroup);
			osc.createSourceOSC(name, e['coreCallback'], group);
		};

		~createGroup = { | self, groupName, addAction = \addToHead |
			if (self.groupExists(groupName),
				{
					postf("Group % exists\n", groupName);
				},
				{
					postf("Group  % does not exist, creating one\n", groupName);
					satie.makeSatieGroup(groupName, addAction);
					osc.makeGroupOSC(groupName, e['coreCallback']);
				}
			);
		};

		~groupExists = { |self, groupName |
			var ret;
			if (satie.satieGroups[groupName] != nil,
				{ ret = true },
				{ ret = false}
			);
			ret;
		};
		~removeSoundSource = { | self, sourceName, group = \default |
			var name = sourceName;
			var sourceGroup = group;
			postf("Removing and cleaning %\n", name);
			satie.cleanInstance(name, sourceGroup);
		};

		~removeGroup = { | self, group |
			postf("Removing group %\n", group);
			satie.killSatieGroup(group);
		};

		~coreCallback = { | msg |
			var url, dest, obj, command, name, synth;
			url = msg[0].asString.split;
			url.removeAt(0); // remove thefirst empty element
			dest = e.getAddressLevel(url);
			name = msg[2].asSymbol;
			command = msg[1];
			postf("coreCallback argument: %\n", msg);
			postf("message size: %\n", msg.size);
			postf("coreCallback url: %\n", url);
			postf("command is %\n", command);
			switch(command,
				\create,
				{
					switch(dest,
						\system, {
							"***************** received create".postln;
							if (msg.size == 4,
								{
									synth = msg[3];
									postf("creating synth % in default group\n", synth);
									e.createSoundSource(name, synth, \default);

								},
								{
									postf("creating group %\n", name);
									e.createGroup(name);
								}
							);
						},
						\group,  {
							var group, synth;
							group = url[1].asSymbol;
							synth = msg[3].asSymbol;
							postf("create synth named % using % in group %\n", name, synth, group);
							e.createSoundSource(name, synth, group);
						}
					);
				},
				\createFX,
				{
					switch(dest,
						\system, {
							"***************** received createFX".postln;
							e.createGroup.value(name, \addToTail);
						}
					);
				},
				\delete,
				{
					var dest = e.getAddressLevel(url);
					switch(dest,
						\group, { |group|
							group = url[1].asSymbol;
							e.removeGroup(group);

						},
						\instance, { | synthName, group |
							synthName = url[2].asSymbol;
							group = url[1].asSymbol;
							e.removeSoundSource(synthName, group);
						}
					);
				},
				\set,
				{
					var dest, group, props;
					dest = e.getAddressLevel(url);
					group = url[1].asSymbol;
					props = msg.copyRange(2, msg.size - 1);
					switch(dest,
						\group,
						{
							props.pairsDo({ | prop, val |
								postf("** group: set %'s % to %\n", group, prop, val);
								satie.satieGroups[group].group.set(prop, val);
							});
						},
						\instance,
						{
							var name;
							name = url[2].asSymbol;
							props.pairsDo({ | prop, val |
								postf("** instance: set %'s % to %\n", name, prop, val);
								if(prop == \in, // effect's property 'in' needs a special treatment
									{
										// postf("----------FX--------- setting property % on effect to %\n", prop, val);
										satie.satieGroupInstances[name].set(prop, satie.aux[val.asInt]);
									},
									{
										// postf("-=-=-=-=-=-=- got instance property %\n", prop);
										satie.satieGroupInstances[group].[name].set(prop, val);
									}
								);
							});
						}
					);
				},
				\clear,
				{
					// rmove all satie groups
					satie.satieGroups.keysDo {|key | satie.killSatieGroup(key)};
					// free all OSC
					OSCdef.freeAll;
					// re-create satie system level OSC
					osc.newOSC(\satieOSC, e['coreCallback'], "/SATIE");
				}
			);
		};

		~getAddressLevel = { | self, url = #[] |
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

	}); // Environment.make

	e.know = true;
	postf("passed osc env: %\n", osc);
	osc.newOSC(\satieOSC, e['coreCallback'], "/SATIE");
	e;
};

)
/*
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

// handle any OSC message
// eg. /SATIE create name - to create a group
//     /SATIE/default create name - to create an instance of a synth or effect
~coreCallback = { | msg |
var url, dest, obj, command, name, synth;
url = msg[0].asString.split;
url.removeAt(0); // remove thefirst empty element
dest = ~getAddressLevel.value(url);
name = msg[2].asSymbol;
command = msg[1];
postf("coreCallback argument: %\n", msg);
postf("message size: %\n", msg.size);
postf("coreCallback url: %\n", url);
postf("command is %\n", command);
switch(command,
\create,
{
switch(dest,
\system, {
"***************** received create".postln;
if (msg.size == 4,
{
synth = msg[3];
postf("creating synth % in default group\n", synth);
~createSoundSource.value(name, synth, \default);

},
{
~createGroup.value(name);
}
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
},
\createFX,
{
switch(dest,
\system, {
"***************** received createFX".postln;
~createGroup.value(name, \addToTail);
}
);
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
},
\set,
{
var dest, group, props;
dest = ~getAddressLevel.value(url);
group = url[1].asSymbol;
props = msg.copyRange(2, msg.size - 1);
switch(dest,
\group,
{
props.pairsDo({ | prop, val |
postf("** group: set %'s % to %\n", group, prop, val);
~scbr.satieGroups[group].group.set(prop, val);
});
},
\instance,
{
var name;
name = url[2].asSymbol;
props.pairsDo({ | prop, val |
postf("** instance: set %'s % to %\n", name, prop, val);
if(prop == \in, // effect's property 'in' needs a special treatment
{
// postf("----------FX--------- setting property % on effect to %\n", prop, val);
~scbr.satieGroupInstances[name].set(prop, ~scbr.aux[val.asInt]);
},
{
// postf("-=-=-=-=-=-=- got instance property %\n", prop);
~scbr.satieGroupInstances[group].[name].set(prop, val);
}
);
});
}
);
},
\clear,
{
// rmove all satie groups
~scbr.satieGroups.keysDo {|key | ~scbr.killSatieGroup(key)};
// free all OSC
OSCdef.freeAll;
// re-create satie system level OSC
~osc.newOSC(\satieOSC, ~coreCallback, "/SATIE");
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
*/