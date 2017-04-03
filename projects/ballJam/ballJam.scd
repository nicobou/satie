// called from project's  main.scd file

s.waitForBoot{

	~num_aux_bus = 5;
	~fxInputBus = 0;  // relative aux bus number that satie will use for this project's synthdef sends to fx synthdefs


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

	// instiante the satieOSC protocol, and set environment variable
	if (~satieOsc == nil,{
		~satieOsc = ~satieOSCProtocol.value(~osc, ~scbr, ~procMan);
		//~satieOsc.debugFlag = true;
	});

	s.sync;

	//  declare all the project's needed synthDefs here
   // makeSynthDef args:    name, synthName, fxBusPre, fxBisPost, listenerName, outBusNo, mapName, optArgs


	postf("generating example project synthdefs for % format \n", ~listeningFormat);
	~scbr.makeSynthDef(\zparticle1, \zparticle1, [], [], [~listeningFormat], [0]);
	~scbr.makeSynthDef(\pink, \PinkSin, [], [],  [~listeningFormat], [0]);
	~scbr.makeSynthDef(\dust, \DustDust,  [], [], [~listeningFormat], [0]);
	~scbr.makeSynthDef(\default, \default,  [], [], [~listeningFormat], [0]);
	~scbr.makeSynthDef(\zkarpluck0, \zkarpluck0,  [], [], [~listeningFormat], [0]);
	~scbr.makeSynthDef(\test, \testtone,   [], [], [~listeningFormat], [0]);
	~scbr.makeSynthDef(\pbell1, \pbell1, [], [],  [~listeningFormat], [0]);
	~scbr.makeSynthDef(\zkarpluck1P, \zkarpluck1P,   [~scbr.aux[~fxInputBus]], [], [~listeningFormat], [0] );   // sends to effects bus, pre-spatializer
	~scbr.makeSynthDef(\zkarpluck1, \zkarpluck1, [~scbr.aux[~fxInputBus]], [], [~listeningFormat], [0] );   // sends to effects bus, pre-spatializer
	~scbr.makeSynthDef(\busreverb, \freeverb,  [], [], [~listeningFormat], [0]);
	~scbr.makeSynthDef(\busgverb, \gverb,  [], [], [~listeningFormat], [0]);
	//	~scbr.makeSynthDef(\zparticle1, \zparticle1, [~listeningFormat], [0]);
	// ~scbr.makeSynthDef(\pink, \PinkSin, [~listeningFormat], [0]);
	// ~scbr.makeSynthDef(\dust, \DustDust, [~listeningFormat], [0]);
	// ~scbr.makeSynthDef(\default, \default, [~listeningFormat], [0]);
	// ~scbr.makeSynthDef(\zkarpluck0, \zkarpluck0, [~listeningFormat], [0]);
	// ~scbr.makeSynthDef(\test, \testtone,  [~listeningFormat], [0]);
	// ~scbr.makeSynthDef(\pbell1, \pbell1, [~listeningFormat], [0]);
	// ~scbr.makeSynthDef(\zkarpluck1, \zkarpluck1, [~listeningFormat], [0], [~scbr.aux[~fxInputBus]]);
	// ~scbr.makeSynthDef(\busreverb, \freeverb, [~listeningFormat], [0]);
	// ~scbr.makeSynthDef(\busgverb, \gverb, [~listeningFormat], [0]);

	// dummy
	~scbr.makeSynthDef(\dummyPlugin, \emptySource,  [], [], [\emptySpat], [0]);    // dummy synthdef, used for new nodes
	// be sure the synthDef is compiled on the server




	s.sync;
};  // end of  waitforboot


/*
testing

~myFile =  "/Users/zack/Dropbox/Unity3D/projects_unity5/balljamDemoSATIE_2015_unity5/Assets/StreamingAssets/midi/pitchSequences/bjGroove.mid.mid.txt";
~sheefa.readPitches(~myFile);
~sheefa.pitchSeqLen;
~sheefa.pitchSeqName;

*/
