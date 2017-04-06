
// based on example:

// ~satie.makeSynthDef2(
// 	\myTestTone2,         // name
// 	\testtone, [],         // audio source + array of busses to write to
// 	[\stereoPanner], [0], // spatializer + index of the first physical output
// 	\exampleMapper,       // name of the mapper to use
// []);                  // default parameters




// tested with 24 channel output

~satie.makeSynthDef2(\zkarpluck1P, \zkarpluck1P, [], [\labodomeVBAP],  [0], \defaultMapper, [~satie.aux[0]]);



1.do( { arg item;
	var nodename=("testNode"++"_"++item).asSymbol;
	var synth;
	synth = ~satie.makeInstance(nodename.asSymbol, \zkarpluck1P, \default);
	synth.set(\gainDB, -20, \randTrigMaxMs, 0);
});

// changing azimuth has no effect
~satie.satieGroupInstances[\default][\testNode_0].set(\aziDeg, 90, \t_trig, 1);
~satie.satieGroupInstances[\default][\testNode_0].set(\aziDeg, -90, \t_trig, 1);

// same with group
~satie.satieGroups[\default].set(\aziDeg, -90, \t_trig, 1);
~satie.satieGroups[\default].set(\aziDeg, 90, \t_trig, 1);


