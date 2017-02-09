// called from project's  main.scd file

//~satie4unity=nil;     // uncomment for debug

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
		~osc = ~spatOSCMaker.value();   // create an OSC RX message mapper object receiveing on port 18032 by default
	});


	// instantiate a renderer control object, and set environment variable
		if (~srCtl == nil,{
		~srCtl = ~satieRendererCtlMaker.value(~scbr);
	});

	// instiante the satie4Unity protocol, and set environment variable
	if (~satie4unity == nil,{
		~satie4unity = ~satie4unityprotocol.value(~osc, ~scbr);
		~satie4unity.debugFlag = true;

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
	~scbr.makeSynthDef(\zkarpluck1, \zkarpluck1,  [], [~scbr.aux[~fxInputBus]], [~listeningFormat], [0] );   // sends to effects bus, post-spatializer
	~scbr.makeSynthDef(\busreverb, \freeverb,  [], [], [~listeningFormat], [0]);
	~scbr.makeSynthDef(\busgverb, \gverb,  [], [], [~listeningFormat], [0]);

	// dummy
	~scbr.makeSynthDef(\dummyPlugin, \emptySource,  [], [], [\emptySpat], [0]);    // dummy synthdef, used for new nodes
	// be sure the synthDef is compiled on the server
	s.sync;


	// now connect OSC RX message callbacks for rendererControl object
	// to be safe,  remove any previous OSC  callbacks  (if any)
	~osc.removeRendererCtlOSC.value();

	// create OSC callbacks to control audio renderer
	// e.g.  /satie/rendererCtl/setOutputDB -12
	~osc.makeRendererCtlOSC( ~srCtl['satieRendererCallback'] );


	s.sync;    // maks sure satue4Unity is fully instantiated before moving on

};  // end of  waitforboot
