// satieOSC, audio rendering support for Unity
// Copyright (C) 2016  Zack Settel

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
// -----------------------------------------------------------



// DEFINE  GLOBAL VARIABLES  -- used from elsewhere in the environment--
// it would be good if  listeningFormat could also be a GLOBAL defined before evaluating this file, from say, an example file.
~satieRootPath = thisProcess.nowExecutingPath.dirname++ "/..";   //  needed when calling ~satieMaker
~outBusIndex=0;  // used in makeSynthDefs, usually 0, but set to some allocated bus number when using ambisonics listening Format
~ambiBus;  // multi-channel ambisonic encoded signal bus to decoder


// allow listeningFormat to be defined prior to evaluation
if (~listeningFormat == nil,
	{
		~listeningFormat = \stereoListener;    // default listening format
		//~listeningFormat = \ambi3;
		//~listeningFormat = \ambi1;

});




//~satie.pluginLoader.spatPlugins;




// you can also overwrite the ~listeningFormat with:   \domeVBAP  ,  \labodomeVBAP  ,  \octoVBAP,  \cubeVBAP, \ambi3  , \ambi1  etc.
// or specify the listening format via command line args
//          possible arg values:   "sato", "labo", "octo",  "stereo", "mono", "5one", "dodec" , "ambi3",  "ambi1"


// set this flags depending on your environment
~superNovaFlag = true;


// Evaluate this file to
// 1)  load the items in /src
// 2) create a satieOSCmaker instance
// 3) create an audioRenderer control instance
// 4) create an OSC messageHandler to load files    /satie/load fileName

// using the messageHandler, additional satie state can be instantiated, like the basic-renderer or saiteOSC



if  (thisProcess.argv.size >= 1,
	{

		switch (thisProcess.argv[0].asString ,
			"cube",
			{
				~listeningFormat = \cubeVBAP
			},
			"ambi1",
			{
				~listeningFormat = \ambi1;   //  uses bus 100-104 to bus ambi1stOrder sigs to binaural decoder on same bus
			},
			"ambi3",
			{
				~listeningFormat = \ambi3;   //  uses bus 100-116 to bus ambi3rdOrder sigs to binaural decoder on same bus
			},
			"dodec",
			{
				~listeningFormat = \dodecVBAP;   // vbap to near field... outputs 20 chanels to soundFlower
			},
			"sato",
			{
				~listeningFormat = \domeVBAP;
			},
			"labo",
			{
				~listeningFormat = \labodomeVBAP;
			},
			"octo",
			{
				~listeningFormat = \octoVBAP;
			},
			"mono",
			{
				~listeningFormat = \mono;
			},
			"5one",
			{
				~listeningFormat = \five1VBAP;
			},
			"quad",
			{
				~listeningFormat = \quadVBAP;
			},
			"stereo",
			{
				~listeningFormat = \stereoListener;  	}
		);
		postf(" %: main.scd : parsing comand line arg:  setting listening format to %\n", thisProcess, ~listeningFormat);

});


~thisFile = thisProcess.nowExecutingPath.split($/).last;

~thisDir = thisProcess.nowExecutingPath.dirname;

// Only edit this path to point to the sate root if you have moved location of this example project directory to a different level of the satie distribution directory tree
// by default it is: ~rootSrcPath = ~thisDir++ "/../..";

~satieRootPath = ~thisDir++ "/../";



// set these flags depending on your environment
~outAudioDev = nil;



// PROBABLY NO NEED TO MODIFY ANYTHING ELSE BELOW  HERE


if ( ~superNovaFlag != nil,
	{
		Server.supernova;
});

o = Server.local.options;   // default set up options
o.memSize = (2**21).asInt;        // probably should just leave this the same for everyting
o.device = nil;  // default
o.threads = 8;    // set this to core count
o.blockSize = 2048;

// adjust blockSize if need be
if ( ~listeningFormat == \ambi1,
	{
		o.blockSize = 64;    // ATK -  needs small buffer sizes or it complains
});

if ( ~listeningFormat == \ambi3,
	{
		o.blockSize = 128;    // ATK -  needs small buffer sizes or it complains
});




// ~listeningFormat = \five1VBAP;    for debugging testing

Platform.case (
	\osx, {
		if (  ( ( ~listeningFormat == \domeVBAP)  ||   ( ~listeningFormat == \labodomeVBAP)  || ( ~listeningFormat == \octoVBAP)  ),
			{

				if (  ServerOptions.outDevices.indexOfEqual("HDSPe MADI (23453676)") != nil,
					{
						postln("AudioOutDev: HDSPe MADI");
						~outAudioDev = "HDSPe MADI (23453676)";
				});

				if (  ServerOptions.outDevices.indexOfEqual("MADIface USB (23635751)") != nil,
					{
						postln("AudioOutDev:  MADIface USB");
						~outAudioDev = "MADIface USB (23635751)";
				});

		});
		//  OR iF
		if (   ~listeningFormat == \dodecVBAP ,        // special case for near-field demo for IX    (this case should removed eventually)
			{
				~outAudioDev = "Dante Virtual Soundcard";    // this may require updating
				postf("AudioOutDev: %\n", ~outAudioDev);
		});
		//  OR iF
		if ( ( ( ~listeningFormat == \quadVBAP)  ||   ( ~listeningFormat == \five1VBAP)  ),
			{

				if (  ServerOptions.outDevices.indexOfEqual("MOTU UltraLite mk3 Hybrid") != nil,
					{
						postln("AudioOutDev: MOTU UltraLite mk3 Hybrid");
						~outAudioDev = "MOTU UltraLite mk3 Hybrid";
				});
			}, // else
			{
				if ( ~listeningFormat == \stereoListener,
					{
						// better letting the system set the default device
						//postln("AudioOutDev: Built-in Output");
						//~outAudioDev = "Built-in Output";
						// o.dump;
				});
		});
	}
);

switch (~listeningFormat,
	\ambi1,
	{
		o.numOutputBusChannels = 2;   // 2 outputs for the binaural rendering
	},
	\ambi3,
	{
		o.numOutputBusChannels = 2;   // 2 outputs for the binaural rendering
	},
	\dodec,
	{
		o.numOutputBusChannels = 28;   // twenty channels for dodecahedron output plus 8 out busses for object audio
	},
	\domeVBAP,
	{
		o.numOutputBusChannels = 32;
	},
	\labodomeVBAP,
	{
		o.numOutputBusChannels = 24;
	},
	\cubeVBAP,
	{
		o.numOutputBusChannels = 8;
	},
	\octoVBAP,
	{
		o.numOutputBusChannels = 8;
	},
	\five1VBAP,
	{
		o.numOutputBusChannels = 5+1;
	},
	\quadVBAP,
	{
		o.numOutputBusChannels = 4;
	},
	\stereoListener,
	{
		o.numOutputBusChannels = 2;
	}
);

Platform.case(
	\osx, {
		if ( ~outAudioDev != nil ,
			{
				o.device = ~outAudioDev;
		});
	},
	\linux, {
		postln("We're in linux, o.device nil means default: " ++ o.device);
	},
	\windows, {"We're on windows... good luck"}
);





// Initialize and load  section   ----------------------------------
(
// Load SATIE kernel
(~satieRootPath ++ "/src/*.scd").pathMatch.do({arg item; item.loadPaths});


// specify any other files to be loaded:

~startupfiles = [~satieRootPath ++ "prototype/ambi1Listener.scd"];

~startupfiles = List.new();

if ( ~listeningFormat == \ambi1,
	{
		~startupfiles.add(~satieRootPath ++ "prototype/ambi1Listener.scd");
});

if ( ~listeningFormat == \ambi3,
	{
		~startupfiles.add(~satieRootPath ++ "prototype/ambi3Listener.scd");
});


// add additional files here
//~startupfiles.add(~rootSrcPath++"/utils/dacTest.scd");


// load the additional files
s.waitForBoot {

	//  now that the server is booted, create any needed buses
switch (~listeningFormat,
	\ambi1,
	{
		~outBusIndex  = Bus.audio(s, 1).index; //  makeSynthDef spatializer outpus are assigned to this dummy bus;  used only for post spatializer fx sending
		~ambiBus = Bus.audio(s, 4);  // define 4 channel signal bus to accumulate and send the ambisonic encoded  source nodes output to decoder
	},
	\ambi3,
	{
		~outBusIndex=Bus.audio(s, 1).index; //  makeSynthDef spatializer outpus are assigned to this dummy bus;  used only for post spatializer fx sending
		~ambiBus = Bus.audio(s, 16); 		// define 16 channel signal bus to accumulate and send the ambisonic encoded  source nodes output to decoder
});

	s.sync;

	~startupfiles.do { |f|  f.postln;  f.load ; s.sync;};

	s.sync;

	// open up GUIs for monitoring
	if (~plotTree == nil,  { ~plotTree=s.plotTree;});
	if (~makeGui == nil,  { ~makeGui=s.makeGui;});
	if (~meter == nil,  { ~meter=s.meter;});

	s.sync;



postf("\n\nAudio Configuration: \n");
postf("\t listening format:  % \n ", ~listeningFormat);
postf("\t output device (nil = default):  % \n", o.outDevice);
postf("\t blockSize:  % \n", o.blockSize);
postf("\t threadCount:  % \n", o.threads);
postf("\t memory:  %K \n", (o.memSize*0.001).asInt);
postf("\t output channels:  %\n", o.numOutputBusChannels);
if (~ambiBus != nil, { postf("\t creating %-channel ambisonics signal on bus(%) \n\n", ~ambiBus.numChannels,  ~ambiBus.index    ); });

	s.sync;

};   // end of waitForBoot





// Now set up satie's  osc message handler for file loading
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

~satieFileLoader= {   	// receives OSC messages that look like:   /satie/load filename
	arg msg;

	if ( (msg.size < 2 ) ,
		{~thisFile++" : satieFileLoader:  message missing filepath".warn;},
		// else
		{
			var filepath = msg[1].asString.standardizePath;   // can handle '~'

			if ( File.exists(filepath) == false,
				{
					error(~thisFile++" : satieFileLoader:   "++filepath++" not found, aborting");
				},
				// else  file exists, process
				{

					if (filepath.splitext.last != "scd",
						{
							error(~thisFile++" : satieFileLoader: "++filepath++" must be a file of type  '.scd'  ");
						},
						// else file type is good. Try to load
						{
							s.waitForBoot {

								filepath.load;
								s.sync;
							}; // waitForBoot
					});
			});
	});
};

~osc.deleteOSC(\satieFileLoader);  // disconnect any previous handlers
~osc.newOSC(\satieFileLoader, ~satieFileLoader, "/satie/load");   // connect handler

)