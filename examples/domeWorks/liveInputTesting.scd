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

(

Exception.debug = true;
Server.supernova;
o = Server.local.options;
o.numInputBusChannels = 8;
o.numOutputBusChannels = 4;
o.memSize = 2**20;
o.blockSize = 1024;
// s.reboot;

s.waitForBoot {
	~rootSrcPath = thisProcess.nowExecutingPath.dirname ++ "/../..";
	(~rootSrcPath ++ "/src/*.scd").pathMatch.do({arg item; item.loadPaths});

	~num_aux_bus = 5;
	// creating a sc-basic-renderer
	~scbr = ~scbrMaker.value(numAudioAux: ~num_aux_bus, satieSrcPath: ~rootSrcPath);
	// printing internal aux array with bus indexes
	// ~scbr.aux;
	// ~scbr.auxbus.scope;

	// generating SynthDef that are going to be used,
	// here a PinkSin source spatialized by
	//   - a stereo panner (starting channel 0)
	//   - a monoSpat (starting channel 2)
	// mono input
	~scbr.makeSynthDef(\monoIn, \MonoIn, [], [], [\quadVBAP, \stereoPanner], [0], \defaultMapper, []);
    // drone
	~scbr.makeSynthDef(\tastee, \testee, [], [], [\quadVBAP], [0], \defaultMapper, []);
	// be sure the synthDef is compiled on the server

	// instantiate a renderer control object
	~srCtl = ~satieRendererCtlMaker.value(~scbr);

	~osc = ~satieOSCMaker.value();   // create an OSC RX message mapper object receiveing on port 18032 by default


	// now connect OSC RX message callbacks for rendererControl object

	// to be safe,  remove any previous OSC  callbacks  (if any)
	~osc.removeRendererCtlOSC.value();

	// create OSC callbacks to control audio renderer
	// e.g.  /satie/rendererCtl/setOutputDB -12
	~osc.makeRendererCtlOSC( ~srCtl['satieRendererCallback'] );


	s.sync;
	(~rootSrcPath ++ "/protocols/satieOSC.scd").load;
	s.sync;
    s.makeGui;
    s.meter;
    s.plotTree;
};
)

