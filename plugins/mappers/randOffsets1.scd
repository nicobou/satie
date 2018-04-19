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

~name = \randOffsets1;
~function = {
	// arguments, starting with required spatializer parameters:
	| aziDeg = 0, eleDeg = 0, gainDB = -90, delayMs = 1, lpHz = 15000, hpHz = 0.5, spread = 1,

	// and can get new trailing parameters:

	cloudAziScale = 1,  cloudElevScale = 0 |   // cloud...Scale range from 0 to one

	// computing value to be sent to the spatializer:
		// extra state for random particle variation
	var randOffsetAzi = Rand(-180, 180);  // random offset for azimuth
	var randOffsetElev = Rand(-90, 90);  // random offset for elevation
	var newAzi, newEle;


	newAzi = aziDeg + (randOffsetAzi * cloudAziScale);
	newEle =  eleDeg + (randOffsetElev * cloudElevScale);
	// forwarding required spatializer parameters only,
	// here aziDeg and eleDeg has been replaced by the computed values:
	[[newAzi, newEle, gainDB, delayMs, lpHz, hpHz, spread]];
};
