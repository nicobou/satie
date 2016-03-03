// called from project's  main.scd file

//~satie4unity=nil;

s.waitForBoot{

	~num_aux_bus = 5;
	~fxInputBus = 0;  // relative aux bus number that satie will use for this project's synthdef sends to fx synthdefs

	// create and initialize a sc-basic-renderer, and set environment variable
	if (~scbr == nil,{
		postln("loading SATIE kernal...");
		~scbr = ~scbrMaker.value(numAudioAux: ~num_aux_bus, satieSrcPath: ~rootSrcPath);
	});

	s.sync;

	//  declare all the project's needed synthDefs here
	postf("generating example project synthdefs for % format \n", ~listeningFormat);
	~scbr.makeSynthDef(\zparticle1, \zparticle1, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\pink, \PinkSin, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\dust, \DustDust, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\default, \default, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\zkarpluck0, \zkarpluck0, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\test, \testtone,  [~listeningFormat], [0]);
	~scbr.makeSynthDef(\pbell1, \pbell1, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\zkarpluck1, \zkarpluck1, [~listeningFormat], [0], [~scbr.aux[~fxInputBus]]);
	~scbr.makeSynthDef(\zkarpluck1P, \zkarpluck1P, [~listeningFormat], [0], [~scbr.aux[~fxInputBus]]);
	~scbr.makeSynthDef(\busreverb, \freeverb, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\busgverb, \gverb, [~listeningFormat], [0]);

	// dummy
	~scbr.makeSynthDef(\dummyPlugin, \emptySource, [\emptySpat], [0]);    // dummy synthdef, used for new nodes
	// be sure the synthDef is compiled on the server
	s.sync;

	// instantiate the OSC interface
	if (~oscInterface == nil,{
		~oscInterface = ~spatOSCMaker.value();
	});
	// instiante the satie4Unity protocol
	if (~satie4unity == nil,{
		~satie4unity = ~satie4unityprotocol.value(~oscInterface, ~scbr);
	});
	s.sync;

};  // end of  waitforboot
