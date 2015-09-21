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




/*
s.makeGui;
s.meter

s.dump
s.reboot;

*/


// set these flags depending on your environment

~outAudioDev = nil;
~superNovaFlag = true;

//~listeningFormat = \stereoListener;

//~listeningFormat = \octoVBAP;       // octo
~listeningFormat = \domeVBAP;       // for sato
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


if ( ~outAudioDev != nil ,
	{
		o.device = ~outAudioDev;
});


// open up GUIs for monitoring
if (~plotTree == nil,  { ~plotTree=s.plotTree;});
if (~makeGui == nil,  { ~plotTree=s.makeGui;});
if (~meter == nil,  { ~plotTree=s.meter;});



// LOAD FILES FOR PROJECT

(
~files = #["spatOSCexample.scd", "spatOSCrx.scd","spatOSCrx.scd"];

s.waitForBoot {
	var dir = thisProcess.nowExecutingPath.dirname;
	~files.do { |f| f.loadRelative ; s.sync;};
	s.sync;
	"All spatOSCexample files loaded".postln;
}; // waitForBoot
)