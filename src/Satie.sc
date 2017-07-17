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
 * SATIE for SuperCollider3
 *
 */
Satie {
	var <>satieConfiguration;
	var <server;
	var options;
	var <>spat;
	var <>debug = true;
	var <satieRoot;

	// Plugins needed by the renderer
	var <>audioPlugins;
	var <>fxPlugins;
	var <>spatPlugins;
	var <>mapperPlugins;

	/*    RENDERER     */
	// buses
	var <auxbus;
	var <aux;
	// compiled definitions
	var generators, effects, <processes;
	// instantiated
	var <groups, <groupInstances;

	*new {|satieConfiguration|
		^super.newCopyArgs(satieConfiguration).initRenderer;
	}
	// Private method
	initRenderer {
		options = satieConfiguration.serverOptions;
		satieRoot = satieConfiguration.satieRoot;
		debug = satieConfiguration.debug;
		audioPlugins = satieConfiguration.audioPlugins;
		fxPlugins = satieConfiguration.fxPlugins;
		spatPlugins = satieConfiguration.spatPlugins;
		mapperPlugins = satieConfiguration.mapperPlugins;
		groups = Dictionary.new();
		groupInstances = Dictionary.new();
		generators = IdentityDictionary.new();
		effects = IdentityDictionary.new();
		processes = Dictionary.new();
		auxbus = Bus.audio(satieConfiguration.server, satieConfiguration.numAudioAux);
		aux = Array.fill(satieConfiguration.numAudioAux, {arg i; auxbus.index + i});
		// TODO:
		// for some reason, we need to create the default group explicitly elsewhere, probably some timing or synchronicity
		// needs to be figured out.
		// satieConfiguration.server.doWhenBooted(this.makeSatieGroup(\default), onFailure: {"server did not boot".warning;});
		// this.makeSatieGroup(\default);
	}
}