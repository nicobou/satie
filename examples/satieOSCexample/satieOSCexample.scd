// BASIC PROJECT FORMAT

//  ~listeningFormat SHOULD BE A GLOBAL SATIE ITEM, DEFINED AS SOON AS THE SERVER IS BOOTED
//  ~satieRootPath    SHOULD BE A GLOBAL SATIE ITEM ,DEFINED AS SOON AS THE SERVER IS BOOTED
//  ~outBusIndex  SHOULD BE A GLOBAL SATIE ITEM, DEFINED AS SOON AS THE SERVER IS BOOTED

// Optional Definition:   value of this variable can be overwritten via OSC messages from Project
~thisProjectResourcePath = thisProcess.nowExecutingPath.dirname++"/satieOSCunity/Assets/StreamingAssets";



~num_aux_bus = 2;   // one bus for reverb, and 8 busses for object audio
~fxBus0 = 0;  // relative aux bus number that satie will use for this project's synthdef sends to fx synthdefs
~fxBus1 = 0;  // relative aux bus number that satie will use for this project's synthdef sends to fx synthdefs



// used only for debug printing
~thisProjectName = thisProcess.nowExecutingPath.split($/).last.splitext[0];
~thisProjectDir = thisProcess.nowExecutingPath.dirname;

postf("***"++~thisProjectName++" :  loading project,  using listenerFormat: %  with %  FX busses  \n", ~listeningFormat, ~num_aux_bus);



//   REMOVE THIS TEST ONCE THE GLOBALS HAVE BEEN SORTED OUT
if (~listeningFormat == nil,
	{
		error(~thisProjectName++" : BUG FOUND:  listening format not defined, setting to stereo");
		~listeningFormat = \stereoListener;
});

if (~satieRootPath == nil,
	{
		error(~thisProjectName++" : BUG FOUND:  ~satieRootPath  not defined, GUESSING.... ");
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
	~satie.makeSynthDef(\zparticle1, \zparticle1, [], [], [~listeningFormat], [~outBusIndex]);
	~satie.makeSynthDef(\pink, \PinkSin, [], [],  [~listeningFormat], [~outBusIndex]);
	~satie.makeSynthDef(\dust, \DustDust,   [], [~satie.aux[~fxBus0]], [~listeningFormat], [~outBusIndex]);  // post-spatializer send
	~satie.makeSynthDef(\default, \default,  [], [], [~listeningFormat], [~outBusIndex]);
	~satie.makeSynthDef(\zkarpluck0, \zkarpluck0,  [], [], [~listeningFormat], [~outBusIndex]);
	~satie.makeSynthDef(\test, \testtone,   [], [], [~listeningFormat], [~outBusIndex]);
	~satie.makeSynthDef(\pbell1, \pbell1, [], [],  [~listeningFormat], [~outBusIndex]);
	~satie.makeSynthDef(\zkarpluck1P, \zkarpluck1P,   [~satie.aux[~fxBus0]], [], [~listeningFormat], [~outBusIndex]);   // sends to effects bus, pre-spatializer
   ~satie.makeSynthDef(\zkarpluck1, \zkarpluck1,  [], [~satie.aux[~fxBus0]], [~listeningFormat], [~outBusIndex]);   // sends to effects bus, post-spatializer
	~satie.makeSynthDef(\busreverb, \freeverb,  [], [], [~listeningFormat], [~outBusIndex]);
	~satie.makeSynthDef(\busgverb, \gverb,  [], [], [~listeningFormat], [~outBusIndex]);

	~satie.makeSynthDef(\zkarpluck2P, \zkarpluck2P,   [~satie.aux[~fxBus0]],  [],[~listeningFormat],  [~outBusIndex], \randOffsets1);  // for resonant updated klones


	// dummy
	~satie.makeSynthDef(\dummyPlugin, \emptySource,  [], [], [\emptySpat], [~outBusIndex]);    // dummy synthdef, used for new nodes
	// be sure the synthDef is compiled on the server
	s.sync;

	// load project file, and any  utility files
	if ( ~utilityFIles.size > 0, { postf(~thisProjectName++" :  loading utility files \n")});
	~utilityFiles.do { |f|  f.postln;  f.load ; s.sync;};

	s.sync;

	// load additional project-specific files from the "autoload" subdir.
	postf(~thisProjectName++" :  loading % items in %/autoload subdirectory\n", ~files.size, ~thisProjectDir);
	~files.do { |f|  f.split.last.postln;  f.load; s.sync;};
	s.sync;

};  // end of  waitforboot


	// set up PROJECT SPECIFIC OSC MESSAGE RX
	~myProjectCallback = {   	// receives OSC messages that look like:   /satie/project/myProjectname data1 .... dataN
		arg msg;
		var command = msg[1];
		//postf(~thisProjectName++" Project:  command: %, msg: %, \n", command, msg);

		if (msg.size < 2,
			{~thisProjectName++" : myProjectCallback:  empty message".warn;
				postf(~thisProjectName++" : myProjectCallback:  Project:  MESS LEN: %", msg.size);

			},
			// else
			{
				// parse out project messages here
				switch (command,
					'setProjectDir',
					{
						if ( (msg.size != 3 ) ,
							{~thisProjectName++" : myProjectCallback: Project: setProjectDir bad arg count: expecting 'setProjectDir projectDirPath' ".warn;},
							// else
							{
								~thisProjectResourcePath = msg[2];     // optionally referenced by certain processes

								//e.projectDirectory.postln;
								postf(~thisProjectName++" : myProjectCallback: setting project directory to: % \n", ~thisProjectResourcePath);
							}
						)
				})
		});
	};


	// set up to receive OSC project messages: e.g.  /satie/project/myProjectname data1 .... dataN
	~osc.removeProjectOSC(~thisProjectName.asSymbol);   // just in case
	~osc.makeProjectOSC(~thisProjectName.asSymbol, ~myProjectCallback);   // now create osc callback for project


/*
testing

~myFile =  "/Users/zack/Dropbox/Unity3D/projects_unity5/balljamDemoSATIE_2015_unity5/Assets/StreamingAssets/midi/pitchSequences/bjGroove.mid.mid.txt";
~sheefa.readPitches(~myFile);
~sheefa.pitchSeqLen;
~sheefa.pitchSeqName;

*/
