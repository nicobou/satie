s.makeGui;
s.meter;

// Exception.debug = true;		// enable
// Exception.debug = false;	// disable

SynthDescLib.global.read;
SynthDescLib.global.browse;

Quarks.gui;

SequenceableCollection.browse;
Server.default.options.dump;

	~dumpNodes.value();

	~dumpGroups.value();





~defaultProx.group.


~defaultProx.["ball_1:spatOSCsource_3".asSymbol].set(\t_trig, 1)



~satie.satieGroups[\effect].["resonance-SC:spatOSCsource_1".asSymbol].set(\outputDB,10);
~satie.satieGroups[\effect].["resonance-SC:spatOSCsource_1".asSymbol].set(\room,0.9);
~satie.satieGroups[\effect].["resonance-SC:spatOSCsource_1".asSymbol].set(\damp,0.05);


~setProperty.value("resonance-SC:spatOSCsource_1".asSymbol, \outputDB, -30);


~satie.satieGroups[\default].group;


~dumpSatieGroups.value();

~dumpSatieGroups = {
	var prox;
	postf("~dumpSatieGroups\n");

	~satie.satieGroups.keysDo({ arg key;
		prox = ~satie.satieGroups[key];
		postf("\t  proxySpace: %  group: %  existingProxies:% \n", key, prox.group, prox.existingProxies);

	});
	nil;
};


~allSourceNodes["ball_1:spatOSCsource_3".asSymbol].at(\proxy) == ~defaultProx.["ball_1:spatOSCsource_3".asSymbol];



~satie.satieGroups[\default].group;


//~satie.satieGroups.removeAt(2);


~removeGroup.value(\sheefa);


~removeGroup.value(\cpuTest);



~removeGroup = { | groupName  |
	var groupNameSymb = groupName.asSymbol;
		var index = -1 ;

		~satie.satieGroups.keysDo({ arg key, i;
		key.postln;
		if ( key == groupNameSymb,
				{
				postf(" FOUND % at item % \n", groupNameSymb, i);
				index = i;
				~satie.satieGroups[key].group.free;

		});


		});
		if (index > -1,
			{
				~satie.satieGroups.removeAt(index);

				postf("~removeGroup: group %\n", groupName);
		},
			// else
			{
				postf("~~removeGroup: group %  not found \n", groupName);
		});
					~satie.satieGroups.postln; };




************~makeSatieGroup:  name:pluck1_group
************~~makeInstance:  name:sourceA_0    synthdef:default    pluck1_groupprox:
************~~makeInstance:  name:sourceC_1    synthdef:default    defaultprox:
************~~makeInstance:  name:sourceD_4    synthdef:default    pluck1_groupprox:
************~~makeInstance:  name:sourceB_5    synthdef:default    pluck1_groupprox:


~satie.makeSatieGroup(\pluck1_group);
~satie.makeInstance(\sourceA_0, \default, \pluck1_group);
~satie.makeInstance(\sourceC_1, \default);
~satie.makeInstance(\sourceD_4, \default, \pluck1_group);
~satie.makeInstance(\sourceB_5, \default, \pluck1_group);



~satie.cleanInstance(\sourceA_0, \pluck1_group);
~satie.cleanInstance(\sourceC_1);
~satie.cleanInstance(\sourceD_4, \pluck1_group);
~satie.cleanInstance(\sourceB_5, \pluck1_group);

~satie.cleanInstance(\sourceC_1)



~theGroup = \sheefa;
~theGroup = \pluck1_group;
~theGroup = \effect;
~theGroup = \default;
~theGroup = \cpuTest;



~satie.satieGroups[\nil].group.query;


~satie.makeSatieGroup(~theGroup);

~killSatieGroup.value( ~theGroup );


~satie.satieGroups[~theGroup].group.query;
~satie.satieGroups[~theGroup].existingProxies;
~satie.satieGroups[~theGroup].group.free;

~satie.satieGroups[~theGroup].remove;



~allSourceNodes[\sourceB_3].at(\proxySymb)
~allSourceNodes[\sourceD_2].at(\proxySymb)

~satie.oscInterface.removeSourceOSC(nameSym);



~satie.satieGroups[groupName.asSymbol];

~satie.satieGroups[\pluck1_group].free;
~satie.satieGroups[\pluck1_group].group.query;
~satie.satieGroups[\pluck1_group].existingProxies;



~satie.satieGroups[\default]
~satie.satieGroups[\nil]




~satie.cleanInstance(\sourceA_0, \pluck1_group)

~satie.satieGroups[\nil].existingProxies
~satie.satieGroups[\pluck1_group].existingProxies
~satie.satieGroups[\default].existingProxies


~satie.satieGroups[\pluck1_group].stop;


//UGen.browse
//    Ndef.gui

