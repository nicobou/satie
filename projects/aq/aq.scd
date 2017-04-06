//~satie4unity=nil;

// called from project's  main.scd file

//WAS ~aqSoundDir="~/".standardizePath ++"Dropbox/Unity3D/projects_unity5/aquaKhoriaShow/Assets/StreamingAssets/sound";


// this is hardwired since it must be defined at init itme, prior to receiving messages from any OSC clients
~thisProjectResourcePath = "~/".standardizePath ++"src/aquakhoria/AquaKhoria_UnityProject/Assets/StreamingAssets";
~thisProjectSoundDir=~thisProjectResourcePath++"/sound";

s.waitForBoot{

	~num_aux_bus = 5;  // THIS MUST BE DEFINED FOR PROJECTS, with a value of 1 or greater


	// based on the value of ~num_aux_bus,  the following can be defined
	~inBus0 = 0;  // relative aux bus number that satie will use for this project's synthdef sends to fx synthdefs
	~inBus1 = 1;  // relative aux bus number that satie will use for this project's synthdef sends to fx synthdefs
	~inBus2 = 2;  // relative aux bus number that satie will use for this project's synthdef sends to fx synthdefs
	~inBus3 = 3;  // relative aux bus number that satie will use for this project's synthdef sends to fx synthdefs
	~inBus4 = 4;  // relative aux bus number that satie will use for this project's synthdef sends to fx synthdefs


	// create and initialize an instance of SATIE, and set environment variable
	if (~satie == nil,{
		postln("loading SATIE kernal...");
		~satie = ~satieMaker.value(numAudioAux: ~num_aux_bus, satieSrcPath: ~rootSrcPath);
	});

	// instantiate the OSC interface, and set environment variable
	if (~osc == nil,{
		~osc = ~spatOSCMaker.value();   // create an OSC RX message mapper object receiveing on port 18032 by default
	});


	// instantiate a renderer control object, and set environment variable
		if (~srCtl == nil,{
		~srCtl = ~satieRendererCtlMaker.value(~satie);
	});

	// instiante the satie4Unity protocol, and set environment variable
	if (~satie4unity == nil,{
		~satie4unity = ~satie4unityprotocol.value(~osc, ~satie);
		~satie4unity.projectDirectory = ~thisProjectResourcePath;
	});




	s.sync;

	// define the phasorSync Generator, used by the syncSamp1 synthdef
	if (~phasorSync == nil,
			{
		"creating phasorSync generator".inform;
			~phasorSync = Synth.before(s,\globalPhasor);
	});

		// required
	~satie.makeSynthDef(\dummyPlugin, \emptySource, [], [], [\emptySpat], [0]);    // dummy synthdef, used for new nodes - required for all projects

/*		~satie.makeSynthDef(\string_with_effects, \zkarpluck1, [~satie.aux[0]], [~satie.aux[1]], [\stereoPanner], [0], \defaultMapper);
	// spatilized reverb effect (input will be set at creation):
	~satie.makeSynthDef(\busreverb, \freeverb, [], [], [\stereoPanner], [0]);*/


	//  declare all the project's needed synthDefs here
	postf("generating example project synthdefs for % format \n", ~listeningFormat);
	~satie.makeSynthDef(\zparticle1, \zparticle1, [], [], [~listeningFormat], [0]);
	~satie.makeSynthDef(\pink, \PinkSin, [], [], [~listeningFormat], [0]);
	~satie.makeSynthDef(\dust, \DustDust, [], [], [~listeningFormat], [0]);
	~satie.makeSynthDef(\default, \default, [~satie.aux[~inBus0]], [], [~listeningFormat], [0]);
	~satie.makeSynthDef(\zkarpluck0, \zkarpluck0, [], [], [~listeningFormat], [0]);
	//~satie.makeSynthDef(\zkarpluck1, \zkarpluck1, [], [], [~listeningFormat], [0]);
	~satie.makeSynthDef(\test, \testtone,  [], [], [~listeningFormat], [0]);
	//~satie.makeSynthDef(\zbell1, \zbell1, [], [], [~listeningFormat], [0]);

	~satie.makeSynthDef(\pbell1, \pbell1, [], [], [~listeningFormat], [0]);
	// same thing but with with reverb send
	~satie.makeSynthDef(\pbell1++'\:rev', \pbell1, [~satie.aux[~inBus0]], [], [~listeningFormat], [0]);

	~satie.makeSynthDef(\zkarpluck1, \zkarpluck1, [], [], [~listeningFormat], [0]);
	// same thing but with with reverb send
	~satie.makeSynthDef(\zkarpluck1++'\:rev', \zkarpluck1, [~satie.aux[~inBus0]], [], [~listeningFormat], [0]);

	// effects node
	~satie.makeSynthDef(\busreverb, \freeverb, [], [], [~listeningFormat], [0]);
	~satie.makeSynthDef(\busgverb, \gverb, [], [], [~listeningFormat], [0]);

	// note order:   name, synthName, fxBusPre, fxBisPost, listenerName, outBusNo, mapName, optArgs
	~satie.makeSynthDef(\zkarpluck1P, \zkarpluck1P,   [~satie.aux[~inBus0]], [], [~listeningFormat],  [0], \randOffsets1, []);   // for kamikazis
	~satie.makeSynthDef(\zkarpluck2P, \zkarpluck2P,   [~satie.aux[~inBus0]],  [],[~listeningFormat],  [0], \randOffsets1, []);  // for resonant updated klones
    ~satie.makeSynthDef(\zkarpluck3P, \zkarpluck2P,   [],  [], [~listeningFormat],  [0], \defaultMapper, []);  //  for kamakazis with no clones
    ~satie.makeSynthDef(\zkarpluck3P++'\:rev', \zkarpluck2P,   [~satie.aux[~inBus0]],  [],[~listeningFormat],  [0], \defaultMapper, []);  //  for kamakazis with no clones
    ~satie.makeSynthDef(\zkarpluck3P++'\:rev1', \zkarpluck2P,   [~satie.aux[~inBus1]],  [],[~listeningFormat],  [0], \defaultMapper, []);  //  for kamakazis with no clones




	~satie.makeSynthDef(\particule1, \particule1,   [~satie.aux[~inBus0]],  [],[~listeningFormat],  [0], \defaultMapper, []);  //  for kamakazis

	~satie.makeSynthDef(\particule1dyn, \particule1dyn,   [~satie.aux[~inBus0]],  [],[~listeningFormat],  [0], \defaultMapper, []);  //  for allocated staticlly spatialized particles*/


// - load soundfiles done automatically in the loadSamps file




	// be sure the synthDef is compiled on the server

	s.sync;

	// now connect OSC RX message callbacks for rendererControl object
	// to be safe,  remove any previous OSC  callbacks  (if any)
	~osc.removeRendererCtlOSC.value();

	// create OSC callbacks to control audio renderer
	// e.g.  /satie/rendererCtl/setOutputDB -12
	~osc.makeRendererCtlOSC( ~srCtl['satieRendererCallback'] );
	s.sync;

	// PROJECT SPECIFIC OSC MESSAGES

~aquakhoriaCallback = {
	arg msg;
	var command = msg[1];
	postf("~aquakhoriaCallback: command: %, msg: %, \n", command, msg);

	if (msg.size < 2,
		{"~aquakhoriaCallback: empty message".warn;
			postf("~basicRendererCallback MESS LEN: %", msg.size);

		},
		// else
		{

			switch (command,
				'resetSync',
				{
					if (~phasorSync != nil,
						{
							"resetting phasorSync generator".inform;
							~phasorSync.set(\t_trig, 1);
					});

				},
						'setProjectDir',
						{
							if ( (msg.size != 3 ) ,
								{"~aquakhoriaCallback: setProjectDir bad arg count: expecting 'setProjectDir projectDirPath' ".warn;},
								// else
								{
									~satie4unity.projectDirectory = msg[2];

									//e.projectDirectory.postln;
									postf("~basicRendererCallback: setProjectDir: % \n", ~satie4unity.projectDirectory);

								}
							)
						},

			)
	});
};


// CONNECT TO OSC USING BASIC RENDERER SETTINGS (PORT ETC.)
~osc.deleteOSC(\aquakhoria);

~osc.newOSC(\aquakhoria, ~aquakhoriaCallback, "/satie/aquakhoria");
};  // end of  waitforboot






/*
testing

~myFile =  "/Users/zack/Dropbox/Unity3D/projects_unity5/balljamDemoSATIE_2015_unity5/Assets/StreamingAssets/midi/pitchSequences/bjGroove.mid.mid.txt";
~sheefa.readPitches(~myFile);
~sheefa.pitchSeqLen;
~sheefa.pitchSeqName;

*/
