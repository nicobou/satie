// reads soundfiles into sound buffers using same names


~aqSoundDir="~/".standardizePath ++"Dropbox/Unity3D/projects_unity5/aquaKhoriaShow/Assets/StreamingAssets/sound";

~autoLoadDirCmd = "ls "++~aqSoundDir++"/*.wav "++~aqSoundDir++"/*.aiff "++~aqSoundDir++"/*.aif 2>/dev/null";



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



//  list of  sound buffers
~aqPlayBuffers = Dictionary();


s.waitForBoot {


	~files.do { |f|
		var sfName =  f.split.last;

		inform("buffering: "++sfName);



		//Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");



		// generate soundfile buffer
		//~aqPlayBuffers.add(sfName.asSymbol -> Buffer.cueSoundFile(s, f, 0, 1));


		// generate sample  buffer
		~aqPlayBuffers.add(sfName.asSymbol -> Buffer.read(s, f));

		// special treatment for samples with the rootName:  "drop"
		if (sfName.containsi("drop"),
			{
				~scbr.makeSynthDef2(sfName.asSymbol++'\:k:rev', \zPsamp1,  [~scbr.aux[~fxInputBus]], [~listeningFormat],  [0], \defaultMapper, [~aqPlayBuffers[sfName.asSymbol].bufnum]);  //  for kamakazis with no clones
			},
			// else  regular sample playback, no kamikazies, for all other samples found
			{
					//postf("FX buffer at: %", ~scbr.aux[~fxInputBus]);

				// create sample buffer playback with no rev send
				~scbr.makeSynthDef(sfName.asSymbol, \sndBuffer, [~listeningFormat], [0],  [], [~aqPlayBuffers[sfName.asSymbol].bufnum]);

				// create sample buffer playback with  rev send, referenced by   pluginName:rev
				~scbr.makeSynthDef(sfName.asSymbol++'\:rev', \sndBuffer, [~listeningFormat], [0],  [~scbr.aux[~fxInputBus]], [~aqPlayBuffers[sfName.asSymbol].bufnum]);


		});
		//postf("CREATING SYNTHDEF: : %\n", sfName.asSymbol++'\:rev');

	};

}


/*  test
g = "myNoise_CaveWater_track01.0.M.wav".asSymbol
~scbr.makeInstance(\sheefa, g, \default);
~scbr.satieGroupInstances[\default][\sheefa].set(\gainDB, -30, \loop, 1);
~scbr.satieGroupInstances[\default][\sheefa].set(\gainDB, -99, \loop, 0);
*/



