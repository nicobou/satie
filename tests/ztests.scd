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



~scbr.satieGroups[\effect].["resonance-SC:spatOSCsource_1".asSymbol].set(\outputDB,10);
~scbr.satieGroups[\effect].["resonance-SC:spatOSCsource_1".asSymbol].set(\room,0.9);
~scbr.satieGroups[\effect].["resonance-SC:spatOSCsource_1".asSymbol].set(\damp,0.05);


~setProperty.value("resonance-SC:spatOSCsource_1".asSymbol, \outputDB, -30);


~scbr.satieGroups[\default].group;


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


~allSourceNodes["ball_1:spatOSCsource_3".asSymbol].at(\proxy) == ~defaultProx.["ball_1:spatOSCsource_3".asSymbol];



~scbr.satieGroups[\default].group;


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




************~makeSatieGroup:  name:pluck1_group
************~~makeInstance:  name:sourceA_0    synthdef:default    pluck1_groupprox:
************~~makeInstance:  name:sourceC_1    synthdef:default    defaultprox:
************~~makeInstance:  name:sourceD_4    synthdef:default    pluck1_groupprox:
************~~makeInstance:  name:sourceB_5    synthdef:default    pluck1_groupprox:


~scbr.makeSatieGroup(\pluck1_group);
~scbr.makeInstance(\sourceA_0, \default, \pluck1_group);
~scbr.makeInstance(\sourceC_1, \default);
~scbr.makeInstance(\sourceD_4, \default, \pluck1_group);
~scbr.makeInstance(\sourceB_5, \default, \pluck1_group);



~scbr.cleanInstance(\sourceA_0, \pluck1_group);
~scbr.cleanInstance(\sourceC_1);
~scbr.cleanInstance(\sourceD_4, \pluck1_group);
~scbr.cleanInstance(\sourceB_5, \pluck1_group);

~scbr.cleanInstance(\sourceC_1)



~theGroup = \sheefa;
~theGroup = \pluck1_group;
~theGroup = \effect;
~theGroup = \default;
~theGroup = \cpuTest;



~scbr.satieGroups[\nil].group.query;


~scbr.makeSatieGroup(~theGroup);

~killSatieGroup.value( ~theGroup );


~scbr.satieGroups[~theGroup].group.query;
~scbr.satieGroups[~theGroup].existingProxies;
~scbr.satieGroups[~theGroup].group.free;

~scbr.satieGroups[~theGroup].remove;



~allSourceNodes[\sourceB_3].at(\proxySymb)
~allSourceNodes[\sourceD_2].at(\proxySymb)

~scbr.oscInterface.removeSourceOSC(nameSym);



~scbr.satieGroups[groupName.asSymbol];

~scbr.satieGroups[\pluck1_group].free;
~scbr.satieGroups[\pluck1_group].group.query;
~scbr.satieGroups[\pluck1_group].existingProxies;



~scbr.satieGroups[\default]
~scbr.satieGroups[\nil]




~scbr.cleanInstance(\sourceA_0, \pluck1_group)

~scbr.satieGroups[\nil].existingProxies
~scbr.satieGroups[\pluck1_group].existingProxies
~scbr.satieGroups[\default].existingProxies


~scbr.satieGroups[\pluck1_group].stop;


//UGen.browse
//    Ndef.gui

