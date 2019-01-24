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

/*       Audio plugin definition

	Each audio plugin should define the following global variables:
    ~name: (symbol) name of the spatializer
	~description: (string) a short description
	~function: the actual definition of the plugin

*/

~name = \Limiter;
~description = "A simple limiter";
~channelLayout = \mono;

~function = { arg in, level=0.7, dur=0.01, outputDB=0;
	outputDB.dbamp * Limiter.ar(In.ar(in), level, dur);
};