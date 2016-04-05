//~satie4unity=nil;

// called from project's  main.scd file

~aqSoundDir="~/".standardizePath ++"Dropbox/Unity3D/projects_unity5/aquaKhoriaShow/Assets/StreamingAssets/sound";

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
	//~scbr.makeSynthDef(\zkarpluck1, \zkarpluck1, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\test, \testtone,  [~listeningFormat], [0]);
	//~scbr.makeSynthDef(\zbell1, \zbell1, [~listeningFormat], [0]);
	~scbr.makeSynthDef(\pbell1, \pbell1, [~listeningFormat], [0], [~scbr.aux[~fxInputBus]]);
	~scbr.makeSynthDef(\zkarpluck1, \zkarpluck1, [~listeningFormat], [0], [~scbr.aux[~fxInputBus]]);

	// note order:   name, synthName, fxBus, listenerName, outBusNo, mapName, optArgs
	~scbr.makeSynthDef2(\zkarpluck1P, \zkarpluck1P,   [~scbr.aux[~fxInputBus]], [~listeningFormat],  [0], \randOffsets1, []);   // for kamikazis
	~scbr.makeSynthDef2(\zkarpluck2P, \zkarpluck2P,   [~scbr.aux[~fxInputBus]], [~listeningFormat],  [0], \randOffsets1, []);  // for resonant updated klones
    //~scbr.makeSynthDef2(\particule1, \particule1,   [~scbr.aux[~fxInputBus]], [~listeningFormat],  [0], \defaultMapper, []);  //  for kamakazis
	~scbr.makeSynthDef2(\particule1, \particule1,   [~scbr.aux[~fxInputBus]], [~listeningFormat],  [0], \defaultMapper, []);  //  for kamakazis
	// ~scbr.makeSynthDef2(\particule1, \particule1,   [~scbr.aux[~fxInputBus]], [\labodomeVBAP],  [0], \defaultMapper, []);  //  for kamakazis
	~scbr.makeSynthDef2(\particule1dyn, \particule1dyn,   [~scbr.aux[~fxInputBus]], [~listeningFormat],  [0], \defaultMapper, []);  //  for allocated staticlly spatialized particles


	/*// - load soundfiles
 	~aqPlayBuffers = Dictionary();


	~aqPlayBuffers.add(\underWaterBuff0 -> Buffer.cueSoundFile(s, ~aqSoundDir +/+ "myNoise_Underwater_track01.0.M.wav", 0, 1));
	~aqPlayBuffers.add(\underWaterBuff1 -> Buffer.cueSoundFile(s, ~aqSoundDir +/+ "myNoise_Underwater_track01.1.M.wav", 0, 1));
	~aqPlayBuffers.add(\underWaterBuff2 -> Buffer.cueSoundFile(s, ~aqSoundDir +/+ "myNoise_Underwater_track01.2.M.wav", 0, 1));
	~aqPlayBuffers.add(\underWaterBuff3 -> Buffer.cueSoundFile(s, ~aqSoundDir +/+ "myNoise_Underwater_track01.3.M.wav", 0, 1));
	~aqPlayBuffers.add(\underWaterBuff4 -> Buffer.cueSoundFile(s, ~aqSoundDir +/+ "myNoise_Underwater_track01.4.M.wav", 0, 1));
	~aqPlayBuffers.add(\underWaterBuff5 -> Buffer.cueSoundFile(s, ~aqSoundDir +/+ "myNoise_Underwater_track01.5.M.wav", 0, 1));
	~aqPlayBuffers.add(\underWaterBuff6 -> Buffer.cueSoundFile(s, ~aqSoundDir +/+ "myNoise_Underwater_track01.6.M.wav", 0, 1));
	~aqPlayBuffers.add(\underWaterBuff7 -> Buffer.cueSoundFile(s, ~aqSoundDir +/+ "myNoise_Underwater_track01.7.M.wav", 0, 1));
	~aqPlayBuffers.add(\underWaterBuff8 -> Buffer.cueSoundFile(s, ~aqSoundDir +/+ "myNoise_Underwater_track01.8.M.wav", 0, 1));
	~aqPlayBuffers.add(\underWaterBuff9 -> Buffer.cueSoundFile(s, ~aqSoundDir +/+ "myNoise_Underwater_track01.9.M.wav", 0, 1));


	~aqPlayBuffers.add(\caveWaterBuff0 -> Buffer.cueSoundFile(s, ~aqSoundDir +/+ "myNoise_CaveWater_track01.0.M.wav", 0, 1));
	~aqPlayBuffers.add(\caveWaterBuff1 -> Buffer.cueSoundFile(s, ~aqSoundDir +/+ "myNoise_CaveWater_track01.1.M.wav", 0, 1));
	~aqPlayBuffers.add(\caveWaterBuff2 -> Buffer.cueSoundFile(s, ~aqSoundDir +/+ "myNoise_CaveWater_track01.2.M.wav", 0, 1));
	~aqPlayBuffers.add(\caveWaterBuff3 -> Buffer.cueSoundFile(s, ~aqSoundDir +/+ "myNoise_CaveWater_track01.3.M.wav", 0, 1));
	~aqPlayBuffers.add(\caveWaterBuff4 -> Buffer.cueSoundFile(s, ~aqSoundDir +/+ "myNoise_CaveWater_track01.4.M.wav", 0, 1));
	~aqPlayBuffers.add(\caveWaterBuff5 -> Buffer.cueSoundFile(s, ~aqSoundDir +/+ "myNoise_CaveWater_track01.5.M.wav", 0, 1));
	~aqPlayBuffers.add(\caveWaterBuff6 -> Buffer.cueSoundFile(s, ~aqSoundDir +/+ "myNoise_CaveWater_track01.6.M.wav", 0, 1));
	~aqPlayBuffers.add(\caveWaterBuff7 -> Buffer.cueSoundFile(s, ~aqSoundDir +/+ "myNoise_CaveWater_track01.7.M.wav", 0, 1));
	~aqPlayBuffers.add(\caveWaterBuff8 -> Buffer.cueSoundFile(s, ~aqSoundDir +/+ "myNoise_CaveWater_track01.8.M.wav", 0, 1));
	~aqPlayBuffers.add(\caveWaterBuff9 -> Buffer.cueSoundFile(s, ~aqSoundDir +/+ "myNoise_CaveWater_track01.9.M.wav", 0, 1));






 // create soundfile players
	~scbr.makeSynthDef(\uwSound0, \sndFile, [~listeningFormat], [0], [], [~aqPlayBuffers[\underWaterBuff0].bufnum]);
	~scbr.makeSynthDef(\uwSound1, \sndFile, [~listeningFormat], [0], [], [~aqPlayBuffers[\underWaterBuff1].bufnum]);
	~scbr.makeSynthDef(\uwSound2, \sndFile, [~listeningFormat], [0], [], [~aqPlayBuffers[\underWaterBuff2].bufnum]);
	~scbr.makeSynthDef(\uwSound3, \sndFile, [~listeningFormat], [0], [], [~aqPlayBuffers[\underWaterBuff3].bufnum]);
	~scbr.makeSynthDef(\uwSound4, \sndFile, [~listeningFormat], [0], [], [~aqPlayBuffers[\underWaterBuff4].bufnum]);
	~scbr.makeSynthDef(\uwSound5, \sndFile, [~listeningFormat], [0], [], [~aqPlayBuffers[\underWaterBuff5].bufnum]);
	~scbr.makeSynthDef(\uwSound6, \sndFile, [~listeningFormat], [0], [], [~aqPlayBuffers[\underWaterBuff6].bufnum]);
	~scbr.makeSynthDef(\uwSound7, \sndFile, [~listeningFormat], [0], [], [~aqPlayBuffers[\underWaterBuff7].bufnum]);
	~scbr.makeSynthDef(\uwSound8, \sndFile, [~listeningFormat], [0], [], [~aqPlayBuffers[\underWaterBuff8].bufnum]);
	~scbr.makeSynthDef(\uwSound9, \sndFile, [~listeningFormat], [0], [], [~aqPlayBuffers[\underWaterBuff9].bufnum]);

	~scbr.makeSynthDef(\caveSound0, \sndFile, [~listeningFormat], [0], [], [~aqPlayBuffers[\caveWaterBuff0].bufnum]);
	~scbr.makeSynthDef(\caveSound1, \sndFile, [~listeningFormat], [0], [], [~aqPlayBuffers[\caveWaterBuff1].bufnum]);
	~scbr.makeSynthDef(\caveSound2, \sndFile, [~listeningFormat], [0], [], [~aqPlayBuffers[\caveWaterBuff2].bufnum]);
	~scbr.makeSynthDef(\caveSound3, \sndFile, [~listeningFormat], [0], [], [~aqPlayBuffers[\caveWaterBuff3].bufnum]);
	~scbr.makeSynthDef(\caveSound4, \sndFile, [~listeningFormat], [0], [], [~aqPlayBuffers[\caveWaterBuff4].bufnum]);
	~scbr.makeSynthDef(\caveSound5, \sndFile, [~listeningFormat], [0], [], [~aqPlayBuffers[\caveWaterBuff5].bufnum]);
	~scbr.makeSynthDef(\caveSound6, \sndFile, [~listeningFormat], [0], [], [~aqPlayBuffers[\caveWaterBuff6].bufnum]);
	~scbr.makeSynthDef(\caveSound7, \sndFile, [~listeningFormat], [0], [], [~aqPlayBuffers[\caveWaterBuff7].bufnum]);
	~scbr.makeSynthDef(\caveSound8, \sndFile, [~listeningFormat], [0], [], [~aqPlayBuffers[\caveWaterBuff8].bufnum]);
	~scbr.makeSynthDef(\caveSound9, \sndFile, [~listeningFormat], [0], [], [~aqPlayBuffers[\caveWaterBuff9].bufnum]);

*/





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

/*
testing

~myFile =  "/Users/zack/Dropbox/Unity3D/projects_unity5/balljamDemoSATIE_2015_unity5/Assets/StreamingAssets/midi/pitchSequences/bjGroove.mid.mid.txt";
~sheefa.readPitches(~myFile);
~sheefa.pitchSeqLen;
~sheefa.pitchSeqName;

*/
