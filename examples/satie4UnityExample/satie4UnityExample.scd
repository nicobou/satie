// called from project's  main.scd file

//~satie4unity=nil;     // uncomment for debug

// Optional Definition:   value of this variable can be overwritten via OSC messages from Project
~thisProjectResourcePath = "~/".standardizePath ++"Dropbox/REMOTE_projects/unityProjects/satie4UnityProject_REVISED/Assets/StreamingAssets";

//Note:  the Project Name is generated  using the name of  the Project FIle (defined in main.scd)
~myProjectName = ~myProjectFIleName.splitext(".scd")[0];


s.waitForBoot{

	// we define the following busses,  and set the falue of ~num_aux_bus accordingly
	~inBus0 = 0;  // relative aux bus number that satie will use for this project's synthdef sends to fx synthdefs
	~inBus1 = 1;  // relative aux bus number that satie will use for this project's synthdef sends to fx synthdefs

	~num_aux_bus = 2;



	// create and initialize an instance of SATIE, and set environment variable
	if (~scbr == nil,{
		postln("loading SATIE kernal...");
		~scbr = ~scbrMaker.value(numAudioAux: ~num_aux_bus, satieSrcPath: ~rootSrcPath);
	});

	// instantiate the OSC interface, and set environment variable
	if (~osc == nil,{
		~osc = ~satieOSCMaker.value();   // create an OSC RX message mapper object receiveing on port 18032 by default
	});

	// instantiate a renderer OSC control object, and set environment variable
	if (~srCtl == nil,{
		~srCtl = ~satieRendererCtlMaker.value(~scbr);
		~osc.removeRendererCtlOSC.value();  // to be safe,  remove any previous OSC  callbacks  (if any)

		// create OSC callbacks to control audio renderer
		~osc.makeRendererCtlOSC( ~srCtl['satieRendererCallback'] );  // e.g.  /satie/rendererCtl/setOutputDB -12
	});

	// instantiate a process manager , and set environment variable
	if (~procMan == nil,{
		~procMan = ~pmMaker.value(~scbr);
	});

	// instiante the satie4Unity protocol, and set environment variable
	if (~satie4unity == nil,{
		~satie4unity = ~satie4unityprotocol.value(~osc, ~scbr, ~procMan);
		~satie4unity.debugFlag = true;
	});


	s.sync;

	//  declare all the project's needed synthDefs here
	// makeSynthDef args:    name, synthName, fxBusPre, fxBisPost, spatializerName, outBusNo, mapName, optArgs


	postf("generating example project synthdefs for % format \n", ~listeningFormat);
	~scbr.makeSynthDef(\zparticle1, \zparticle1, [], [], [~listeningFormat], [0]);
	~scbr.makeSynthDef(\pink, \PinkSin, [], [],  [~listeningFormat], [0]);
	~scbr.makeSynthDef(\dust, \DustDust,  [], [], [~listeningFormat], [0]);
	~scbr.makeSynthDef(\default, \default,  [], [], [~listeningFormat], [0]);
	~scbr.makeSynthDef(\zkarpluck0, \zkarpluck0,  [], [], [~listeningFormat], [0]);
	~scbr.makeSynthDef(\test, \testtone,   [], [], [~listeningFormat], [0]);
	~scbr.makeSynthDef(\pbell1, \pbell1, [], [],  [~listeningFormat], [0]);
	~scbr.makeSynthDef(\zkarpluck1P, \zkarpluck1P,   [~scbr.aux[~inBus0]], [], [~listeningFormat], [0] );   // sends to effects bus, pre-spatializer
	~scbr.makeSynthDef(\zkarpluck1, \zkarpluck1,  [], [~scbr.aux[~inBus0]], [~listeningFormat], [0] );   // sends to effects bus, post-spatializer
	~scbr.makeSynthDef(\busreverb, \freeverb,  [], [], [~listeningFormat], [0]);
	~scbr.makeSynthDef(\busgverb, \gverb,  [], [], [~listeningFormat], [0]);

	~scbr.makeSynthDef(\zkarpluck2P, \zkarpluck2P,   [~scbr.aux[~inBus0]],  [],[~listeningFormat],  [0], \randOffsets1);  // for resonant updated klones

	// dummy
	~scbr.makeSynthDef(\dummyPlugin, \emptySource,  [], [], [\emptySpat], [0]);    // dummy synthdef, used for new nodes
	// be sure the synthDef is compiled on the server
	s.sync;



	// set up PROJECT SPECIFIC OSC MESSAGE RX
	~myProjectCallback = {   	// receives OSC messages that look like:   /satie/project/myProjectname data1 .... dataN
		arg msg;
		var command = msg[1];
		//postf(~myProjectName++" Project:  command: %, msg: %, \n", command, msg);

		if (msg.size < 2,
			{~myProjectName++" Project:  empty message".warn;
				postf(~myProjectName++" Project:  MESS LEN: %", msg.size);

			},
			// else
			{
				// parse out project messages here
				switch (command,
					'setProjectDir',
					{
						if ( (msg.size != 3 ) ,
							{~myProjectName++" Project: setProjectDir bad arg count: expecting 'setProjectDir projectDirPath' ".warn;},
							// else
							{
								~thisProjectResourcePath = msg[2];     // optionally referenced by certain processes

								//e.projectDirectory.postln;
								postf(~myProjectName++" Project: setting project directory to: % \n", ~thisProjectResourcePath);
							}
						)
				})
		});
	};


	// set up to receive OSC project messages: e.g.  /satie/project/myProjectname data1 .... dataN
	~osc.removeProjectOSC(~myProjectName.asSymbol);   // just in case
	~osc.makeProjectOSC(~myProjectName.asSymbol, ~myProjectCallback);   // now create osc callback for project

	s.sync;    // maks sure satue4Unity is fully instantiated before moving on

};  // end of  waitforboot
