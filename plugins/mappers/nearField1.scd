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

~name = \farField1;
~function = {
	// arguments,  corresponding to required spatializer parameters:
	| aziDeg = 0, eleDeg = 0, gainDB = -90, delayMs = 1, lpHz = 15000, hpHz = 0.5, spread = 1, distance = 1, radius = 1, exp = 1 |

	var newGainDB;
	var dbOffset;
	var nfScaler = distance.clip(0.01, radius) / radius;


	nfScaler = nfScaler**exp;
	dbOffset = nfScaler.ampdb;
	newGainDB = gainDB + dbOffset;



	// output modified spatializer parameters

	[aziDeg, eleDeg, newGainDB, delayMs, lpHz, hpHz, spread];
};


//~function.value()
