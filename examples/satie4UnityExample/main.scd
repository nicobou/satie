// Satie4Unity, audio rendering support for Unity
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


//  REQUIRED project file name declaration
~myProjectFIleName = "satie4UnityExample.scd";


~thisDir = thisProcess.nowExecutingPath.dirname ;

// Only edit this path to point to the sate root if you have moved location of this example project directory to a different level of the satie distribution directory tree
// by default it is: ~rootSrcPath = ~thisDir++ "/../..";

~rootSrcPath = ~thisDir++ "/../..";


// set these flags depending on your environment
~outAudioDev = nil;
~superNovaFlag = true;


~defaultListeningFormat = \stereoListener;    // can also be set to \domeVBAP  or  \labodomeVBAP  or   \octoVBAP


// PROBABLY NO NEED TO MODIFY ANYTHING ELSE BELOW
~listeningFormat = ~defaultListeningFormat;    // will remain unless overwritten below


if ( ~superNovaFlag != nil,
	{
		Server.supernova;
});

o = Server.local.options;   // default set up options
o.memSize = 2**21;        // probably should just leave this the same for everyting
o.device = nil;  // default
o.blockSize = 2048;
o.threads = 8;

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

	},  // else
	{
		if ( ~listeningFormat == \stereoListener,
		{
				// better letting the system set the default device
				//postln("AudioOutDev: Built-in Output");
				//~outAudioDev = "Built-in Output";
		// o.dump;
		});
});


switch (~listeningFormat,
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
	\stereoListener,
	{
	o.numOutputBusChannels = 2;
	}
);



if ( ~outAudioDev != nil ,
	{
		o.device = ~outAudioDev;
});


postf("AUDIO CONFIGURATION: ");
postf("\t LISTENING FORMAT:  %   ,    ", ~listeningFormat);
postf("\t OUTPUT DEVICE:  %    ,     ", o.outDevice);
postf("\t OUTPUT CHANNELS:  %\n", o.numOutputBusChannels);
//o.dump


// open up GUIs for monitoring
if (~plotTree == nil,  { ~plotTree=s.plotTree;});
if (~makeGui == nil,  { ~plotTree=s.makeGui;});
if (~meter == nil,  { ~plotTree=s.meter;});



// LOAD ENVIRONMENT AND PROJECT FILES

(
// note: files that define OSCcallbacks seem to need to be evaluated twice
~startupfiles = [~rootSrcPath++"/utils/dacTest.scd", ~thisDir++"/"++~myProjectFIleName, ~rootSrcPath++"/src/satie4unity.scd", ~rootSrcPath++"/src/satie4unity.scd"];


// next:  load any .scd files in the project's autoload subdir
~autoLoadDirCmd = "ls "++thisProcess.nowExecutingPath.dirname++"/autoload/*.scd";
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

// load everything
s.waitForBoot {
	var dir = thisProcess.nowExecutingPath.dirname;
	postf("main.scd:  loading needed files for % project \n", ~myProjectFIleName.splitext[0]);
	~startupfiles.do { |f|  f.postln;  f.load ; s.sync;};
	s.sync;

	postf("main.scd: loading % items from %/autoload subdirectory\n", ~files.size, ~myProjectFIleName.splitext[0]);
	~files.do { |f|  f.split.last.postln;  f.load; s.sync;};
	s.sync;
}; // waitForBoot
);