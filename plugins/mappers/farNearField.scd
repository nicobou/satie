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


// this example mapper preprocesses the standard spatializer input arguments by scaling the gain as a function of distance

(
~name = \farNearField;
~function = {
	// arguments,  corresponding to required spatializer parameters:
	| aziDeg = 0, eleDeg = 0, gainDB = 0, delayMs = 1, lpHz = 15000, hpHz = 0.5, spread = 1, distance = 0.01, radius = 6, exp = 1 |

	var newGainDBFar;
	var dbOffsetFar;
	var nfScalerFar = distance.clip(0.01, radius) / radius;

	var newGainDBNear;
	var dbOffsetNear;
	var nfScalerNear = 1 - (distance.clip(0.01, radius) / radius);

	nfScalerFar = nfScalerFar**exp;
	dbOffsetFar = nfScalerFar.ampdb;
	newGainDBFar = gainDB + dbOffsetFar;

	nfScalerNear = nfScalerNear**exp;
	dbOffsetNear = nfScalerNear.ampdb;
	newGainDBNear = gainDB + dbOffsetNear;

	// output modified spatializer parameters
	[[aziDeg, eleDeg, newGainDBFar, delayMs, lpHz, hpHz, spread], // far field
	[aziDeg, eleDeg, newGainDBNear, delayMs, lpHz, hpHz, spread]]; // near field
};

~function.value;
)