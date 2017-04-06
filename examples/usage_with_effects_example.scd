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
Server.supernova;
o = Server.local.options;
o.numOutputBusChannels = 8;
o.memSize = 2**20;
o.blockSize = 2048;
//s.reboot;
s.waitForBoot {
	~rootSrcPath = thisProcess.nowExecutingPath.dirname ++ "/..";
	(~rootSrcPath ++ "/src/*.scd").pathMatch.do({arg item; item.loadPaths});

	// creating 2 busses in order to route pre and post source audio
	~num_aux_bus = 2;
	// creating a sc-basic-renderer
	~satie = ~satieMaker.value(numAudioAux: ~num_aux_bus, satieSrcPath: ~rootSrcPath);
	// printing internal aux array with bus indexes
	// ~satie.aux;
	// monitoring pre and post busses
	~satie.auxbus.scope;

	// writing to only to the third audio bus
	~satie.makeSynthDef(\string_with_effects, \zkarpluck1, [~satie.aux[0]], [~satie.aux[1]], [\stereoPanner], [0], \defaultMapper);
	// spatilized reverb effect (input will be set at creation):
	~satie.makeSynthDef(\busreverb, \freeverb, [], [], [\stereoPanner], [0]);
	s.sync;
	s.makeGui;
	s.meter;
	s.plotTree;
};
)

// ******* spatialized effects  (read audio from a bus) ***

// making two trigered sound source
(
~satie.makeInstance(\test_src, \string_with_effects);
~satie.satieGroups[\default].set(\gainDB, -20);
~satie.satieGroupInstances[\default][\test_src].set(\t_trig, 1, \note, rrand(42,72), 1, 0.5);
// making a group for effects. We need them to be added to tail for being computed after the source sound.
~satie.makeSatieGroup(\effect, \addToTail);
)

// Adding reverb to the pre bus (left).
(
~satie.makeInstance(\rev_pre, \busreverb, \effect);
~satie.satieGroupInstances[\effect][\rev_pre].set(\in, ~satie.aux[0]);  // attached to source Pre bus
// Note the volume of the effect is reduced since it is reading the
// "raw" audio from the pre bus, where sound source volume control has no effect:
~satie.satieGroupInstances[\effect][\rev_pre].set(\mix, 1 /*wet only*/, \room, 0.3, \damp, 1, \aziDeg, -180/*left*/, \gainDB, -20);
// listen: string is centered and rev_pre is located on the left
~satie.satieGroupInstances[\default][\test_src].set(\t_trig, 1, \note, rrand(42,72), 1, 0.5);
)

// Adding reverd to the post bus (right).
(
~satie.makeInstance(\rev_post, \busreverb, \effect);
~satie.satieGroupInstances[\effect][\rev_post].set(\in, ~satie.aux[1]);  // attached to source Post bus
~satie.satieGroupInstances[\effect][\rev_post].set(
	\mix, 1 /*wet only*/, \room, 0.9, \damp, 1, \aziDeg, 180/*right*/, \gainDB, 0);
// listen: post reverb is on the right
~satie.satieGroupInstances[\default][\test_src].set(\t_trig, 1, \note, rrand(42,72), 1, 0.5);
)


