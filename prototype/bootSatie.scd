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



// REQUIRED  GLOBAL VARIABLES  -- used from elsewhere in the environment--
~satieRootPath = thisProcess.nowExecutingPath.dirname++ "/..";   //  needed when calling ~satieMaker

~listeningFormat = \stereoListener;    // defaults to stereo    - needed when calling makeSynthDef

//~listeningFormat = \dodecNF;    // defaults to stereo    - needed when calling makeSynthDef


// Evaluate this file to
// 1)  load the items in /src
// 2) create a satieOSCmaker instance
// 3) create an audioRenderer control instance
// 4) create an OSC messageHandler to load files    /satie/load fileName

// using the messageHandler, additional satie state can be instantiated, like the basic-renderer or saiteOSC


// set this flags depending on your environment

~superNovaFlag = true;



// or specify the listening format via command line args
// possible arg values:   "sato", "labo", "octo",  "stereo", "mono"


if  (thisProcess.argv.size >= 1,
	{

		switch (thisProcess.argv[0].asString ,
			"dodecNF",
			{
				~listeningFormat = \dodecNF;   // vbap to near field... outputs 20 chanels to soundFlower
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

~thisFile = thisProcess.nowExecutingPath.split($/).last;  // used for debug printing


if ( ~superNovaFlag != nil,
	{
		Server.supernova;
});

o = Server.local.options;   // default set up options
o.memSize = (2**21).asInt;        // probably should just leave this the same for everyting
o.device = nil;  // default
o.blockSize = 2048;
o.threads = 8;    // set this to core count

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
		if (  ( ~listeningFormat == \dodecNF ),
			{

				if (  ServerOptions.outDevices.indexOfEqual("Soundflower (64ch)") != nil,
					{
						postln("AudioOutDev: Dante Virtual Soundcard");
						~outAudioDev = "Dante Virtual Soundcard";
				});


		});		// OR IF
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
	\dodecNF,
	{
		o.numOutputBusChannels = 28;   // 20 channels for vbap output  and 8 for object audio streams
	},
	\domeVBAP,
	{
		o.numOutputBusChannels = 32;
	},
	\labodomeVBAP,
	{
		o.numOutputBusChannels = 24;
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

postf("AUDIO CONFIGURATION: ");
postf("\t LISTENING FORMAT:  %   ,    ", ~listeningFormat);
postf("\t OUTPUT DEVICE:  %    ,     ", o.outDevice);
postf("\t OUTPUT CHANNELS:  %\n", o.numOutputBusChannels);
//o.dump


// open up GUIs for monitoring
if (~plotTree == nil,  { ~plotTree=s.plotTree;});
if (~makeGui == nil,  { ~plotTree=s.makeGui;});
if (~meter == nil,  { ~plotTree=s.meter;});


// Initialize and load  section   ----------------------------------
(
// Load SATIE kernel
(~satieRootPath ++ "/src/*.scd").pathMatch.do({arg item; item.loadPaths});


// specify any other files to be loaded:

~startupfiles = [];

// add additional files here
//~startupfiles.add(~rootSrcPath++"/utils/dacTest.scd");


// load the additional files
s.waitForBoot {

	~startupfiles.do { |f|  f.postln;  f.load ; s.sync;};
	s.sync;
};


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