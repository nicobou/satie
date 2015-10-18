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


// NOTE:  this file optionally uses the BASH environment variable SATIE_LISTENING_FORMAT
// which is set to:
//   export SATIE_LISTENING_FORMAT="sato"
// or
// export SATIE_LISTENING_FORMAT="labodome"

/*
s.makeGui;
s.meter

s.dump
s.reboot;

*/


// set these flags depending on your environment

~outAudioDev = nil;
~superNovaFlag = true;

~defaultListeningFormat = \stereoListener;

~listeningFormat = ~defaultListeningFormat;    // will remain unless overwritten below


//~listeningFormat = \octoVBAP;       // octo
//~listeningFormat = \domeVBAP;       // for sato
//~listeningFormat = \labodomeVBAP;      // for labodome

//~outAudioDev = "Soundflower (64ch)";   //  for multi-channel testing without hardware on OSX
//~outAudioDev = "MADIface USB (23635751)";     // for labodome or SATO


if ( ~superNovaFlag != nil,
	{
		Server.supernova;
});

o = Server.local.options;   // default set up options
o.memSize = 2**20;        // probably should just leave this the same for everyting
o.device = nil;  // default
o.blockSize = 2048;



// check to see if the BASH environment variable is set to either "sato" or "labodome"
(
//p = Pipe.new("ls -l", "r");            // list directory contents in long format
p = Pipe.new("echo $SATIE_LISTENING_FORMAT", "r");            // list directory contents in long format

l = p.getLine;                    // get the first line

if ( l != nil,
	{

		// l.postln;
		switch (l,
			"sato",
			{
				"SETTING LISTENING FORMAT TO: domeVBAP".postln;
				~listeningFormat = \domeVBAP;       // for sato

			},
			"labodome",
			{
				"SETTING LISTENING FORMAT TO: labodomeVBAP".postln;
				~listeningFormat = \labodomeVBAP;      // for labodome

			}
		);
});

p.close;                    // close the pipe to avoid that nasty buildup
);



// o.device = "MADIface USB (23635751)";     // set for dome or labodome

if ( ~listeningFormat == \domeVBAP,
	{
		o.numOutputBusChannels = 32;
		~outAudioDev = "MADIface USB (23635751)";
		// o.dump;
});

if ( ~listeningFormat == \labodomeVBAP,
	{
		o.numOutputBusChannels = 24;
		~outAudioDev = "MADIface USB (23635751)";
		// o.dump;
});

if ( ~listeningFormat == \octoVBAP,
	{
		o.numOutputBusChannels = 8;
		//~outAudioDev = "MADIface USB (23635751)";
		// o.dump;
});




if ( ~listeningFormat == \stereoListener,
	{
		o.numOutputBusChannels = 2;
		~outAudioDev = "Built-in Output";
		// o.dump;
});


if ( ~outAudioDev != nil ,
	{
		o.device = ~outAudioDev;
});


postf("AUDIO CONFIGURATION: \n");
postf("\t LISTENING FORMAT:  %  \n", ~listeningFormat);
postf("\t OUTPUT DEVICE:  %\n", o.outDevice);
postf("\t OUTPUT CHANNELS:  %\n", o.numOutputBusChannels);
//o.dump


// open up GUIs for monitoring
if (~plotTree == nil,  { ~plotTree=s.plotTree;});
if (~makeGui == nil,  { ~plotTree=s.makeGui;});
if (~meter == nil,  { ~plotTree=s.meter;});



// LOAD FILES FOR PROJECT

(
// note: files that define OSCcallbacks seem to need to be evaluated twice
~files = #["../../utils/dacTest.scd", "spatOSCexample.scd", "spatOSCrx.scd","spatOSCrx.scd", "spatOSCexamplePresets.scd", "spatOSCexamplePresets.scd"];

s.waitForBoot {
	var dir = thisProcess.nowExecutingPath.dirname;
	~files.do { |f| f.loadRelative ; s.sync;};
	s.sync;
	"All spatOSCexample files loaded".postln;
}; // waitForBoot
)