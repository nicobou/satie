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

~name = \emptySpat;


// spat input args:
// aziDeg degrees (-180 to 180)
// elevDeg   degrees (-180 to 180)
// gainDB  decibels
// delaySec  seconds
// lpHz    hertz
// spread  units  (0 == directional, ....,  100 == omni)




~function = {|in = 0, aziDeg = 0, eleDeg = 0, gainDB = 0, delayMs = 1, lpHz = 15000, spread = 1 |  // note:  sholuld we provide an additional arg: customArray for additional params ???

	DC.ar(0);
};
