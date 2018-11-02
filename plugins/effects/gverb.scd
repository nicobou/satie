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

~name = \gverb;
~description = "A simple reverb based on the GVerb UGen";
~channelLayout = \mono;
~function = { arg in, roomsize=50, revtime=3, damping=0.5, inputbw=0.5, spreadEffect=15, drylevel=1, earlylevel=0.7, taillevel=0.5, maxroomsize=300, outputDB=0;
 outputDB.dbamp  * Mix.fill(1,GVerb.ar(
		        In.ar(in),
		        roomsize,
		        revtime,
		        damping,
		        inputbw,
		        spreadEffect,
		        drylevel.dbamp,
		        earlylevel.dbamp,
		        taillevel.dbamp,
		roomsize ));
	//outputDB.dbamp  *  Mix.new([revsig]);


	};
