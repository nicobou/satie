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


~name = \BeamDirac;
~description = "Filters along a specifed direction (truncated Dirac). Az from -180 to 180, ele from -90 to 90";

~function = {|in = 0, order = 1, beamDiracAziDeg = 0, beamDiracEleDeg = 0, beamDiracLevelDeg = 0 |
HOABeamDirac2Hoa.ar(order, in,  beamDiracAziDeg * pi / 180.0, beamDiracEleDeg * pi / 180.0, beamDiracLevelDeg * pi / 180.0);
};
