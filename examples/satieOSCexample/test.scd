// Tester for satieOSC protocol


(

// EVALUATE THIS BLOCK FIRST

(thisProcess.nowExecutingPath.dirname++"/main.scd").load;   // load the satieOSC and example project resources, such as processes, synthdefs, etc
b = NetAddr.new("127.0.0.1", 18032);    // connect to satie's RX port
b.sendMsg("/satie/scene", "debugFlag", 1);    // activate  debugging printing to console

)

b.sendMsg("/satie/scene", "debugFlag", 1);    // optionally deactivate debugging printing to console



//  1. single node example  -----------------------------------
b.sendMsg("/satie/scene", "createSource",  "sheefa", "plugin://default", "default");    // create source
b.sendMsg("/satie/source/update", "sheefa", 0,0,-3,0,15000,20);   //update spatialiser args:  azimuthRad elevationRad gainDB delayMS  lpHZ  distanceMETERS
// OR  use the set method to update the same spatialization parameters using several key value pairs
b.sendMsg("/satie/source/set", "sheefa", "aziDeg", 0, "eleDeg", 0, "gainDB", -6, "delayMs", 0, "lpHz", 15000);
b.sendMsg("/satie/source/set", "sheefa", "lfoHz", 20.1.rand);    // set a key value pair of the synth

b.sendMsg("/satie/source/state", "sheefa", 0);    // set node state to 0  (pauses synth)
b.sendMsg("/satie/source/state", "sheefa", 1);    // set node state to 1


b.sendMsg("/satie/scene", "deleteNode",  "sheefa");  // delete node

b.sendMsg("/satie/scene", "clear");    // clear scene


// 1.bis  effects node example  -----------------------------------
b.sendMsg("/satie/scene", "createSource",  "sheefaDust", "plugin://dust", "default");    // create source node
b.sendMsg("/satie/source/update", "sheefaDust", 0,0, 10,0,15000,20);   // update spatialiser
b.sendMsg("/satie/source/set", "sheefaDust", "density2", 30);    // set param

b.sendMsg("/satie/scene", "createSource",  "sheefaFx", "effect://busgverb inbus 0" );    // create effects node
b.sendMsg("/satie/source/update", "sheefaFx", 0,0, -10,0,15000,20);   //update spatialiser

b.sendMsg("/satie/scene", "clear");    // clear scene


//  2. group node example  -----------------------------------
b.sendMsg("/satie/scene", "createGroup",  "sheefaGroup");    // create group node

// create member nodes in group
(
20.do( {|item|
	var nodename=("testNode"++"_"++item);
	b.sendMsg("/satie/scene", "createSource",  "sheefa"++item, "plugin://default", "sheefaGroup");    // create source
	b.sendMsg("/satie/source/update", "sheefa"++item, 360.rand,360.rand,-20,0,15000,20);   // create source
	b.sendMsg("/satie/source/set", "sheefa"++item, "lfoHz", 2);

});
)

// set member node parems using group node
b.sendMsg("/satie/group/set", "sheefaGroup", "gainDB", -30);

// set member node parems using group node
b.sendMsg("/satie/group/set", "sheefaGroup", "lfoHz", 10.1.rand);

 // destroy group members
(
20.do( {|item|
	var nodename=("testNode"++"_"++item);
	b.sendMsg("/satie/scene", "deleteNode",  "sheefa"++item);
});
)

b.sendMsg("/satie/scene", "clear");    // clear scene



//  3. process node examples -----------------------------------

// Hello World
b.sendMsg("/satie/scene", "createProcess",  "myProcess", "process://helloWorld" );    // create process node - unique group will be automatically generated for each created
b.sendMsg("/satie/process/set", "myProcess", "someParam", 1);    //

b.sendMsg("/satie/process/property", "myProcess", "debugFlag", 0);    // set process environment variable
b.sendMsg("/satie/process/set", "myProcess", "someParam", 2);    // set synth param

b.sendMsg("/satie/scene", "deleteNode", "myProcess");


// Custom Process
(
b.sendMsg("/satie/scene", "createProcess",  "sheefaProcess", "process://sheefa cloneCount 10" );    // create process node - unique group will be automatically generated for each created node
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




//   annex example:  setting a key with more than one value  -----------------------------------
(
b.sendMsg("/satie/scene", "createSource",  "sheefaPluck", "plugin://zkarpluck1", "default");    // create source
b.sendMsg("/satie/source/update", "sheefaPluck", 0,0, -3,0,15000,20);   //update spatialiser
b.sendMsg("/satie/source/set", "sheefaPluck", "trimDB", -10, "c1", 0.9, "c3", 5);    // set key value pairs to synth parameters
b.sendMsg("/satie/source/set", "sheefaPluck", "c1", 0.9, "c3", 5);    // set key value pairs to synth parameters

b.sendMsg("/satie/source/set", "sheefaPluck", "fb", 100.rand);    // update fb param

t = Task({ {

	b.sendMsg("/satie/source/setvec", "sheefaPluck", "note", (55+20.rand), (0.5+0.5.rand), (0.5+0.5.rand));    // set param
	b.sendMsg("/satie/source/set", "sheefaPluck", "t_trig", 1);    // set param

	0.4.wait; }.loop });
t.start;

)

(
t.stop;
b.sendMsg("/satie/scene", "deleteNode",  "sheefaPluck");  // delete node
)












