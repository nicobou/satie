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



		Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");



		// generate soundfile buffer
		//~aqPlayBuffers.add(sfName.asSymbol -> Buffer.cueSoundFile(s, f, 0, 1));


	    // generate sample  buffer
		~aqPlayBuffers.add(sfName.asSymbol -> Buffer.read(s, f));



		//s.sync;     // enable this line if needed

		// create soundfile players
		//~scbr.makeSynthDef(sfName.asSymbol, \sndFile, [~listeningFormat], [0], [], [~aqPlayBuffers[sfName.asSymbol].bufnum]);

		// create sample buffer playback
	    ~scbr.makeSynthDef(sfName.asSymbol, \sndBuffer, [~listeningFormat], [0], [], [~aqPlayBuffers[sfName.asSymbol].bufnum]);

	};

}


/*  test
g = "myNoise_CaveWater_track01.0.M.wav".asSymbol
~scbr.makeInstance(\sheefa, g, \default);
~scbr.satieGroupInstances[\default][\sheefa].set(\gainDB, -30, \loop, 1);
~scbr.satieGroupInstances[\default][\sheefa].set(\gainDB, -99, \loop, 0);
*/



