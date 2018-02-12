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


// example mapper is adding a two parameters, aziDegShift and eleDegShift, that affect
// aziDeg and eleDeg sent to the spatializer

~name = \exampleMapper;
~function = {
	// arguments, starting with required spatializer parameters:
	| aziDeg = 0, eleDeg = 0, gainDB = -90, delayMs = 1, lpHz = 15000, hpHz = 0.5, spread = 1,
	// and can get new trailing parameters:
	aziDegShift = 0, eleDegShift = 0  |
	// computing value to be sent to the spatializer:
	var newAzi, newEle;
	newAzi = aziDeg + aziDegShift;
	newEle = eleDeg + eleDegShift;
	// forwarding required spatializer parameters only,
	// here aziDeg and eleDeg has been replaced by the computed values
	// Note that mapper must return an array of array(s), allowing specific mapping for
	// specific spatializer, see the nearFarField.scd file for an example
	[[newAzi, newEle, gainDB, delayMs, lpHz, hpHz, spread]];
};
