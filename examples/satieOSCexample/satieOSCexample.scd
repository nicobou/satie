// BASIC PROJECT FORMAT

//  ~listeningFormat SHOULD BE A GLOBAL SATIE ITEM, DEFINED AS SOON AS THE SERVER IS BOOTED
//  ~satieRootPath    SHOULD BE A GLOBAL SATIE ITEM ,DEFINED AS SOON AS THE SERVER IS BOOTED

// Optional Definition:   value of this variable can be overwritten via OSC messages from Project
~thisProjectResourcePath = thisProcess.nowExecutingPath.dirname++"/satieOSCunity/Assets/StreamingAssets";



~num_aux_bus = 9;   // one bus for reverb, and 8 busses for object audio
//~num_aux_bus = 5;
~fxBus0 = 0;  // relative aux bus number that satie will use for this project's synthdef sends to fx synthdefs
~objBus1 = 1;  //  ""
~objBus2 = 2;  //  ""
~objBus3 = 3;  //  ""
~objBus4 = 4;  //  ""
~objBus5 = 5;  //  ""
~objBus6 = 6;  //  ""
~objBus7 = 7;  //  ""
~objBus8 = 8;  //  ""


// used only for debug printing
~thisProjectFile = thisProcess.nowExecutingPath.split($/).last;
~thisProjectDir = thisProcess.nowExecutingPath.dirname;

postf("***"++~thisProjectFile++" :  loading project,  using listenerFormat: %  with %  FX busses  \n", ~listeningFormat, ~num_aux_bus);



//   REMOVE THIS TEST ONCE THE GLOBALS HAVE BEEN SORTED OUT
if (~listeningFormat == nil,
	{
		error(~thisProjectFile++" : BUG FOUND:  listening format not defined, setting to stereo");
		~listeningFormat = \stereoListener;
});

if (~satieRootPath == nil,
	{
		error(~thisProjectFile++" : BUG FOUND:  ~satieRootPath  not defined, GUESSING.... ");
		~satieRootPath = ~thisProjectDir++"/../..";
});



// THE FOLLOWING SETS UP SATIE, SINCE ONLY NOW DO WO KNOW THE AUX BUS COUNT


// create and initialize an instance of SATIE, and set environment variable
//  THERE IS A CHOICE TO MAKE:  DO WE KILL AN EXISTING SATIE FIRST ??
if (~satie == nil,{
	postln("loading SATIE kernal...");
	~satie = ~satieMaker.value(numAudioAux: ~num_aux_bus, satieSrcPath:  ~satieRootPath );
});

// THIS SHOULD BE A GLOBAL SATIE ITEM, DEFINED AS SOON AS THE SATIE /src folder has been loaded
// instantiate the OSC interface, and set environment variable
if (~osc == nil,{
	~osc = ~satieOSCMaker.value();   // create an OSC RX message mapper object receiveing on port 18032 by default
});


// instiante the satieOSC protocol, and set environment variable
if (~satieOsc == nil,{
	~satieOsc = ~satieOSCProtocol.value(~osc, ~satie);
	//~satieOsc.debugFlag = true;
});


// add additional files here
~utilityFiles = [];
~utilityFiles.add(~satieRootPath++"/utils/dacTest.scd");


// Locate any .scd files in the project's autoload subdir
~autoLoadDirCmd = "ls "++thisProcess.nowExecutingPath.dirname++"/autoload/*.scd";
~pipe = Pipe.new(~autoLoadDirCmd, "r");            // list directory contents in long format

~files =List.new();
~done = nil;
while (  { ~done != true} ,
	{
		var filePath;
		filePath = ~pipe.getLine;

		if ( filePath != nil,
			{
				~files.add( filePath);
			},
			// else
			{
				~done = true;
		});
});
~pipe.close;


// now load stuff on the server
s.waitForBoot{

	s.sync;

	postf("generating example project synthdefs for % format \n", ~listeningFormat);
	~satie.makeSynthDef(\zparticle1, \zparticle1, [], [], [~listeningFormat], [0]);
	~satie.makeSynthDef(\pink, \PinkSin, [], [],  [~listeningFormat], [0]);
	~satie.makeSynthDef(\dust, \DustDust,   [], [~satie.aux[~fxBus0]], [~listeningFormat], [0]);
	~satie.makeSynthDef(\default, \default,  [], [], [~listeningFormat], [0]);
	~satie.makeSynthDef(\zkarpluck0, \zkarpluck0,  [], [], [~listeningFormat], [0]);
	~satie.makeSynthDef(\test, \testtone,   [], [], [~listeningFormat], [0]);
	~satie.makeSynthDef(\pbell1, \pbell1, [], [],  [~listeningFormat], [0]);
	~satie.makeSynthDef(\zkarpluck1P, \zkarpluck1P,   [~satie.aux[~fxBus0]], [], [~listeningFormat], [0] );   // sends to effects bus, pre-spatializer
   ~satie.makeSynthDef(\zkarpluck1, \zkarpluck1,  [], [~satie.aux[~fxBus0]], [~listeningFormat], [0] );   // sends to effects bus, post-spatializer
	~satie.makeSynthDef(\busreverb, \freeverb,  [], [], [~listeningFormat], [0]);
	~satie.makeSynthDef(\busgverb, \gverb,  [], [], [~listeningFormat], [0]);

	~satie.makeSynthDef(\zkarpluck2P, \zkarpluck2P,   [~satie.aux[~fxBus0]],  [],[~listeningFormat],  [0], \randOffsets1);  // for resonant updated klones
	~satie.makeSynthDef(\flutter1, \default,  [], [ ~satie.aux[~fxBus0], ~satie.aux[~objBus1]], [~listeningFormat], [0]);     // sound source that writes to an object bus out
	~satie.makeSynthDef(\flutter2, \default,  [], [ ~satie.aux[~fxBus0], ~satie.aux[~objBus2]], [~listeningFormat], [0]);     // sound source that writes to an object bus out
	~satie.makeSynthDef(\flutter3, \default,  [], [ ~satie.aux[~fxBus0], ~satie.aux[~objBus3]], [~listeningFormat], [0]);     // sound source that writes to an object bus out
	~satie.makeSynthDef(\flutter4, \default,  [], [ ~satie.aux[~fxBus0], ~satie.aux[~objBus4]], [~listeningFormat], [0]);     // sound source that writes to an object bus out
	~satie.makeSynthDef(\flutter5, \default,  [], [ ~satie.aux[~fxBus0], ~satie.aux[~objBus5]], [~listeningFormat], [0]);     // sound source that writes to an object bus out
	~satie.makeSynthDef(\flutter6, \default,  [], [ ~satie.aux[~fxBus0], ~satie.aux[~objBus6]], [~listeningFormat], [0]);     // sound source that writes to an object bus out
	~satie.makeSynthDef(\flutter7, \default,  [], [ ~satie.aux[~fxBus0], ~satie.aux[~objBus7]], [~listeningFormat], [0]);     // sound source that writes to an object bus out
	~satie.makeSynthDef(\flutter8, \default,  [], [ ~satie.aux[~fxBus0], ~satie.aux[~objBus8]], [~listeningFormat], [0]);     // sound source that writes to an object bus out




	// dummy
	~satie.makeSynthDef(\dummyPlugin, \emptySource,  [], [], [\emptySpat], [0]);    // dummy synthdef, used for new nodes
	// be sure the synthDef is compiled on the server
	s.sync;

	// load project file, and any  utility files
	if ( ~utilityFIles.size > 0, { postf(~thisProjectFile++" :  loading utility files \n")});
	~utilityFiles.do { |f|  f.postln;  f.load ; s.sync;};

	s.sync;

	// load additional project-specific files from the "autoload" subdir.
	postf(~thisProjectFile++" :  loading % items in %/autoload subdirectory\n", ~files.size, ~thisProjectDir);
	~files.do { |f|  f.split.last.postln;  f.load; s.sync;};
	s.sync;

};  // end of  waitforboot


	// set up PROJECT SPECIFIC OSC MESSAGE RX
	~myProjectCallback = {   	// receives OSC messages that look like:   /satie/project/myProjectname data1 .... dataN
		arg msg;
		var command = msg[1];
		//postf(~myProjectName++" Project:  command: %, msg: %, \n", command, msg);

		if (msg.size < 2,
			{~thisProjectFile++" : myProjectCallback:  empty message".warn;
				postf(~thisProjectFile++" : myProjectCallback:  Project:  MESS LEN: %", msg.size);

			},
			// else
			{
				// parse out project messages here
				switch (command,
					'setProjectDir',
					{
						if ( (msg.size != 3 ) ,
							{~thisProjectFile++" : myProjectCallback: Project: setProjectDir bad arg count: expecting 'setProjectDir projectDirPath' ".warn;},
							// else
							{
								~thisProjectResourcePath = msg[2];     // optionally referenced by certain processes

								//e.projectDirectory.postln;
								postf(~thisProjectFile++" : myProjectCallback: setting project directory to: % \n", ~thisProjectResourcePath);
							}
						)
				})
		});
	};


	// set up to receive OSC project messages: e.g.  /satie/project/myProjectname data1 .... dataN
	~osc.removeProjectOSC(~thisProjectFile.asSymbol);   // just in case
	~osc.makeProjectOSC(~thisProjectFile.asSymbol, ~myProjectCallback);   // now create osc callback for project


/*
testing

~myFile =  "/Users/zack/Dropbox/Unity3D/projects_unity5/balljamDemoSATIE_2015_unity5/Assets/StreamingAssets/midi/pitchSequences/bjGroove.mid.mid.txt";
~sheefa.readPitches(~myFile);
~sheefa.pitchSeqLen;
~sheefa.pitchSeqName;

*/
