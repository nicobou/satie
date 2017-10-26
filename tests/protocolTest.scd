// Tester for satieOSC protocol


// EVALUATE THIS BLOCK FIRST

// GLOBAL:  listeningFormat   can be optionally set here:
// defaults to:
//~listeningFormat = \stereoListener;
// optional formats:
//  Uncomment to use a different listening format
//~listeningFormat = \ambi1;
//~listeningFormat = \ambi3;
//~listeningFormat = \domeVBAP;
//~listeningFormat = \labodomeVBAP;
//~listeningFormat = \octoVBAP;
//~listeningFormat = \stereoListener;

//(thisProcess.nowExecutingPath.dirname++"/../../prototype/bootSatie.scd").load;

(
// project state
~listeningFormat = \ambi1;  // default listener for project
~auxBusCount = 4;
~outBusIndex = 0;

s = Server.supernova.local;

// pass the server to the configuration and define some options
~satieConfiguration = SatieConfiguration.new(s, [~listeningFormat],~auxBusCount, [~outBusIndex]);
~satieConfiguration.serverOptions.blockSize = 512;
~satieConfiguration.serverOptions.memSize = (2**21).asInt;        // probably should just leave this the same for everyting
~satieConfiguration.serverOptions.threads = 8;    // set this to core count

// for use with ambi1
// choose custom location for HRTF data
// ~satieConfiguration.hrtfPath = "/Users/zack/Library/Application Support/SuperCollider/downloaded-quarks/SATIE-quark/satie-assets/ATK";



~satie = Satie.new(~satieConfiguration);
~satie.boot();


~satie.satieConfiguration.server.waitForBoot{

	~satie.satieConfiguration.server.sync;

	~satie.makeSynthDef(\pink, \PinkSin, [], [],  [~listeningFormat], [~satie.satieConfiguration.outBusIndex[0]]);
	~satie.makeSynthDef(\dust, \DustDust,  [~satie.aux[0]], [], [~listeningFormat], [~satie.satieConfiguration.outBusIndex[0]]);
	~satie.makeSynthDef(\default, \default,  [], [], [~listeningFormat], [~satie.satieConfiguration.outBusIndex[0]]);
	~satie.makeSynthDef(\test, \testtone,   [], [], [~listeningFormat], [~satie.satieConfiguration.outBusIndex[0]]);
	~satie.makeSynthDef(\busgverb, \gverb,  [], [], [~listeningFormat], [~satie.satieConfiguration.outBusIndex[0]]);
	~satie.makeSynthDef(\zkarpluck1, \zkarpluck1, [~satie.aux[0]], [], [~listeningFormat], [~satie.satieConfiguration.outBusIndex[0]] );   // sends to effects bus, pre-spatializer

		~satie.makeSynthDef(\nearTest, \default,   [~satie.aux[0]],  [],[~listeningFormat],  [~satie.satieConfiguration.outBusIndex[0]], \nearField1);  // for mapping distances
		~satie.makeSynthDef(\farTest, \default,   [~satie.aux[0]],  [],[~listeningFormat],  [~satie.satieConfiguration.outBusIndex[0]], \farField1);  // for mapping distances


	~satie.satieConfiguration.server.sync;

	s.meter;
	s.makeGui;
	s.plotTree;

};  // end of  waitforboot


b = NetAddr.new("127.0.0.1", 18032);    // connect to satie's RX port


)


// THEN Evaluate the different sections below

b.sendMsg("/satie/scene/debugFlag", 1);    // activate  debugging printing to console
b.sendMsg("/satie/scene/debugFlag", 0);    // deactivate debugging printing to console

//  1. single node example  -----------------------------------
b.sendMsg("/satie/scene/createSource",  "sheefa", "default", "default");    // create source
b.sendMsg("/satie/source/update", "sheefa", 0,0,-3,0,15000,20);   //update spatialiser args:  azimuthRad elevationRad gainDB delayMS  lpHZ  distanceMETERS
// OR  use the set method to update the same spatialization parameters using several key value pairs
b.sendMsg("/satie/source/set", "sheefa", "aziDeg", 360.rand, "eleDeg", 0, "gainDB", -6, "delayMs", 0, "lpHz", 15000);
b.sendMsg("/satie/source/set", "sheefa", "lfoHz", 20.1.rand);    // set a key value pair of the synth

b.sendMsg("/satie/source/state", "sheefa", 0);    // set node state to 0  (pauses synth)
b.sendMsg("/satie/source/state", "sheefa", 1);    // set node state to 1


b.sendMsg("/satie/scene/deleteNode",  "sheefa");  // delete node

b.sendMsg("/satie/scene/clear");    // clear scene


// 1.bis  effects node example  -----------------------------------
b.sendMsg("/satie/scene/createSource",  "sheefaDust", "dust", "default");    // create source node
b.sendMsg("/satie/source/update", "sheefaDust", 360.rand,0, -3,0,15000,20);   // update spatialiser
b.sendMsg("/satie/source/set", "sheefaDust", "density2", 10);    // set param

b.sendMsg("/satie/scene/createEffect",  "sheefaFx", "busgverb", 0 );    // create effects node in defaultFx group, with input from satie's AuxBus 0
b.sendMsg("/satie/source/update", "sheefaFx", 0,0, -12,0,15000,20);   //update spatialiser
b.sendMsg("/satie/source/set", "sheefaFx", "revtime",  10);    // set param
b.sendMsg("/satie/source/set", "sheefaFx", "revtime", 1);    // set param


b.sendMsg("/satie/scene/deleteNode",  "sheefaFx");  // delete node

b.sendMsg("/satie/scene/clear");    // clear scene


//  2. group node example  -----------------------------------
b.sendMsg("/satie/scene/createSourceGroup",  "sheefaGroup");    // create group node
b.sendMsg("/satie/scene/createEffectGroup",  "sheefaFXgroup");    // create group node

b.sendMsg("/satie/scene/createEffect",  "sheefaFx", "busgverb" , "sheefaFXgroup");    // create effects node in sheefaFXgroup, with input from satie's AuxBus 0
b.sendMsg("/satie/source/update", "sheefaFx", 0,0, -20,0,15000,20);   //update spatialiser


// create member nodes in group
(
20.do( {|item|
	var nodename=("testNode"++"_"++item);
	b.sendMsg("/satie/scene/createSource",  "sheefa"++item, "dust", "sheefaGroup");    // create source
	b.sendMsg("/satie/source/update", "sheefa"++item, 360.rand,360.rand,-20,0,15000,20);   // create source

});
)

// set member node parems using group node
b.sendMsg("/satie/group/set", "sheefaGroup","density2", 0.1);    // set param
b.sendMsg("/satie/group/set", "sheefaGroup","density2", 10);    // set param


// set member node parems using group node
b.sendMsg("/satie/group/set", "sheefaFXgroup", "outputDB",  -30);    // set param
b.sendMsg("/satie/group/set", "sheefaFXgroup", "outputDB",  0);    // set param

b.sendMsg("/satie/group/set", "sheefaFXgroup", "revtime",  5);    // set param
b.sendMsg("/satie/group/set", "sheefaFXgroup", "revtime", 0.5);    // set param



// destroy group members
(
20.do( {|item|
	var nodename=("testNode"++"_"++item);
	b.sendMsg("/satie/scene/deleteNode",  "sheefa"++item);
});
)

b.sendMsg("/satie/scene/deleteNode",  "sheefaFx");  // delete node

b.sendMsg("/satie/scene/clear");    // clear scene



//  3. process node examples -----------------------------------

// Hello World
b.sendMsg("/satie/scene/createProcess",  "myProcess", "helloWorld  a 1 b 2 c 3" );    // create process node - unique group will be automatically generated for each created.  Note the use of creation key value argument pairs

b.sendMsg("/satie/process/property", "myProcess", "debugFlag", 1);    // set existing process environment variable
b.sendMsg("/satie/process/property", "myProcess", "debugFlag", 0);    // set existing process environment variable

b.sendMsg("/satie/process/property", "myProcess", "someProperty", 1);    // can set arbitrary key value pairs to the processes's environment


b.sendMsg("/satie/process/set", "myProcess", "someParam", 2);    // set a synth param

b.sendMsg("/satie/process/eval", "myProcess", "doit", 2, 3,4);    // call a function defined in the processes's environment
b.sendMsg("/satie/process/eval", "myProcess", "nonexistant", 2, 3,4);    // call a function defined in the processes's environment


b.sendMsg("/satie/process/state", "myProcess", 0);    // set state
b.sendMsg("/satie/process/state", "myProcess", 1);    // set state


b.sendMsg("/satie/scene/deleteNode", "myProcess");


// Custom Process
(
b.sendMsg("/satie/scene", "createProcess",  "sheefaProcess", "process://sheefa cloneCount 20" );    // create process node - unique group will be automatically generated for each created node
b.sendMsg("/satie/process/update", "sheefaProcess", 0,0, -6,0,15000,20);   // update spatialiser
b.sendMsg("/satie/process/set", "sheefaProcess", "spread", 30);    // calls custom handler 'spread', defined in process's environment
)

b.sendMsg("/satie/process/property", "sheefaProcess", "debugFlag", 0);    // set process environment variable
b.sendMsg("/satie/process/property", "sheefaProcess", "debugFlag", 1);    // set process environment variable

b.sendMsg("/satie/process/setvec" , "sheefaProcess", "trigger", 60, 1,1);     // for processes, 'setvec' will call custom handler 'trigger', if defined in process's environment

b.sendMsg("/satie/process/set", "sheefaProcess", "player", 1);    // calls custom handler 'player', defined in process's environment
b.sendMsg("/satie/process/set", "sheefaProcess", "player", 0);    // calls custom handler 'player', defined in process's environment

b.sendMsg("/satie/process/property", "sheefaProcess", "triggerIntervalMs", 100);    // set process environment variable
b.sendMsg("/satie/process/property", "sheefaProcess", "triggerIntervalMs", 500);    // set process environment variable
b.sendMsg("/satie/process/property", "sheefaProcess", "triggerIntervalMs", 2000);    // set process environment variable

b.sendMsg("/satie/process/property", "sheefaProcess", "cloneCount", 1);    // set process environment variable
b.sendMsg("/satie/process/property", "sheefaProcess", "cloneCount", 50);    // set process environment variable


b.sendMsg("/satie/scene", "deleteNode", "sheefaProcess");

b.sendMsg("/satie/scene", "clear");    // clear scene


//  4. using mappers example  -----------------------------------

// CREATE NEAR FIELD SOURCE
b.sendMsg("/satie/scene/createSource",  "mappie", "nearTest", "default");    // create nearField source

// OR CREATE FAR FIELD SOURCE
b.sendMsg("/satie/scene/createSource",  "mappie", "farTest", "default");    // create farField source

b.sendMsg("/satie/source/update", "mappie", 0,0,-0,0,15000,1);   //update spatialiser args:  azimuthRad elevationRad gainDB delayMS  lpHZ  distanceMETERS


b.sendMsg("/satie/source/set", "mappie", "radius", 1);
b.sendMsg("/satie/source/set", "mappie", "distance", 0);
b.sendMsg("/satie/source/set", "mappie", "distance", 0.5);
b.sendMsg("/satie/source/set", "mappie", "distance", 1);

b.sendMsg("/satie/source/set", "mappie", "radius", 6);
b.sendMsg("/satie/source/set", "mappie", "distance", 0);
b.sendMsg("/satie/source/set", "mappie", "distance", 3);
b.sendMsg("/satie/source/set", "mappie", "distance", 6);


b.sendMsg("/satie/source/set", "mappie", "exp", 1);
b.sendMsg("/satie/source/set", "mappie", "exp", 4);
b.sendMsg("/satie/source/set", "mappie", "exp", 0.25);



b.sendMsg("/satie/scene/deleteNode",  "mappie");  // delete node

b.sendMsg("/satie/scene/clear");    // clear scene

//   annex example:  setting a key with more than one value  -----------------------------------

b.sendMsg("/satie/scene", "createSource",  "ball_1000", "plugin://zkarpluck1", "default");    // create source
b.sendMsg("/satie/source/update", "ball_1000", 0,0, -3,0,15000,20);   //update spatialiser
b.sendMsg("/satie/source/set", "ball_1000", "trimDB", -10, "c1", 0.9, "c3", 5);    // set key value pairs to synth parameters
b.sendMsg("/satie/source/set", "ball_1000", "c1", 0.9, "c3", 5);    // set key value pairs to synth parameters

b.sendMsg("/satie/source/set", "ball_1000", "fb", 100.rand);    // update fb param

b.sendMsg("/satie/scene", "createEffect",  "resonance_SC", "busgverb", 0 );    // create effects node
b.sendMsg("/satie/source/update", "resonance_SC", 0,0, -115,0,15000,20);   //update spatialiser









/*
s.latency=0.01
(
~speed=0.4;
~speed=0.2;
~speed=0.1;
~speed=0.05;
~speed=0.01;

~index=0;

t = Task({ {

	var nodename="ball_"++~index.mod(150);
	~index = ~index+1;

	//b.sendMsg("/satie/source/setvec", "ball_1000", "note", (55+20.rand), (0.5+0.5.rand), (0.5+0.5.rand));    // set param

	~satie.groupInstances[\default][nodename.asSymbol].set("t_trig", 1);    // set param

	//b.sendMsg("/satie/source/set", nodename, "t_trig", 1);    // set param

	//b.sendMsg("/satie/source/update", "ball_1000", 360.rand,0, -16,0,15000,20);   //update spatialiser
//nodename.postln;
	~speed.wait; }.loop });
t.start;

)

(
t.stop;
b.sendMsg("/satie/scene", "deleteNode",  "ball_1000");  // delete node
b.sendMsg("/satie/scene", "deleteNode",  "resonance_SC");  // delete node

)


b.sendMsg("/satie/source/set", "ball_1", "t_trig", 1);    // set param

b.sendMsg("/satie/group/set", "default", "c1", 2, "c3", 5);    // set key value pairs to synth parameters

b.sendMsg("/satie/group/set", "default", "t_trig", 1);    // set param


b.sendMsg("/satie/group/update", "default", 0,0, -3,0,15000,20);   //update spatialiser



(
 b.sendMsg("/satie/source/set", "ball_1", "c1", 0.9, "c3", 1);    // set key value pairs to synth
	b.sendMsg("/satie/source/setvec", "ball_1", "t_trig", 1);    // set param
)



*/
