

// called from project's  main.scd file

s.waitForBoot{

	~listeningFormatP = (~listeningFormat++"_P").asSymbol;

	~num_aux_bus = 5;
	~fxInputBus = 0;  // relative aux bus number that satie will use for this project's synthdef sends to fx synthdefs

	// create and initialize a sc-basic-renderer, and set environment variable
	~scbr = ~scbrMaker.value(numAudioAux: ~num_aux_bus, satieSrcPath: ~rootSrcPath);   // satie plugins (re)loaded

	s.sync;

	//  declare all the project's needed synthDefs here
	postf("generating example project synthdefs for % format \n", ~listeningFormat);
	~scbr.makeSynthDef(\zparticle1, \zparticle1, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\pink, \PinkSin, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\dust, \DustDust, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\default, \default, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\zkarpluck0, \zkarpluck0, [~listeningFormat], [0]);
	//~scbr.makeSynthDef(\zkarpluck1, \zkarpluck1, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\test, \testtone,  [~listeningFormat], [0]);
	//~scbr.makeSynthDef(\zbell1, \zbell1, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\pbell1, \pbell1, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\zkarpluck1, \zkarpluck1, [~listeningFormat], [0], [~scbr.aux[~fxInputBus]]);
//	~scbr.makeSynthDef(\zkarpluck1P, \zkarpluck1P, [~listeningFormatP], [0], [~scbr.aux[~fxInputBus]]);

	// note order:   name, synthName, fxBus, listenerName, outBusNo, mapName, optArgs
	~scbr.makeSynthDef2(\zkarpluck1P, \zkarpluck1P,   [~scbr.aux[~fxInputBus]], [~listeningFormat],  [0], \randOffsets1, []);   // for kamikazis
	~scbr.makeSynthDef2(\zkarpluck2P, \zkarpluck2P,   [~scbr.aux[~fxInputBus]], [~listeningFormat],  [0], \randOffsets1, []);  // for resonant updated klones


	~scbr.makeSynthDef(\busreverb, \freeverb, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\busgverb, \gverb, [~listeningFormat], [0]);


	s.sync;

};  // end of  waitforboot

/*
testing

~myFile =  "/Users/zack/Dropbox/Unity3D/projects_unity5/balljamDemoSATIE_2015_unity5/Assets/StreamingAssets/midi/pitchSequences/bjGroove.mid.mid.txt";
~sheefa.readPitches(~myFile);
~sheefa.pitchSeqLen;
~sheefa.pitchSeqName;

*/
