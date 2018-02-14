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


// this example mapper preprocesses the standard spatializer input arguments by scaling the gain as a function of the ndIndex parameter
// outputs arguments for a  [ nearField, farField ]  pair of spatializers

(
~name = \nearFarField1;
~function = {
	// arguments,  corresponding to required spatializer parameters:
	| aziDeg = 0, eleDeg = 0, gainDB = 0, delayMs = 1, lpHz = 15000, hpHz = 0.5, spread = 1, distance = 0.01, nfIndex = 0|

	var nfGain, ffGain, nfGainDB, ffGainDB;

	nfGain = gainDB.dbamp * nfIndex;
	ffGain = gainDB.dbamp * (1 - nfIndex);

	nfGainDB = nfGain.clip(0.00001, 1).ampdb; // make sure this is constrained, while avoiding -inf for 0.ampdb case
	ffGainDB = ffGain.clip(0.00001, 1).ampdb;  // make sure this is constrained, while avoiding -inf for 0.ampdb case

	// output modified spatializer parameters
	[[aziDeg, eleDeg, nfGainDB, delayMs, lpHz, hpHz, spread, nfIndex], // near field
	[aziDeg, eleDeg, ffGainDB, delayMs, lpHz, hpHz, spread, nfIndex]]; // far field
};

~function.value;
)