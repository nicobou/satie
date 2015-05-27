s.makeGui;
s.meter;







~dumpSatieGroups.value();

~dumpSatieGroups = {
	var prox;
	postf("~dumpSatieGroups\n");

	~scbr.satieGroups.keysDo({ arg key;
		prox = ~scbr.satieGroups[key];
		postf("\t  proxySpace: %  group: %  existingProxies:% \n", key, prox.group, prox.existingProxies);

	});
	nil;
};




//~scbr.satieGroups.removeAt(2);


~removeGroup.value(\sheefa);


~removeGroup.value(\cpuTest);



~removeGroup = { | groupName  |
	var groupNameSymb = groupName.asSymbol;
		var index = -1 ;

		~scbr.satieGroups.keysDo({ arg key, i;
		key.postln;
		if ( key == groupNameSymb,
				{
				postf(" FOUND % at item % \n", groupNameSymb, i);
				index = i;
				~scbr.satieGroups[key].group.free;

		});


		});
		if (index > -1,
			{
				~scbr.satieGroups.removeAt(index);

				postf("~removeGroup: group %\n", groupName);
		},
			// else
			{
				postf("~~removeGroup: group %  not found \n", groupName);
		});
					~scbr.satieGroups.postln; };



