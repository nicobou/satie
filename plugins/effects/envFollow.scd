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

~name = \envFollow;
~description = "Send a trigger based on envelope threshold";
~channelLayout = \mono;

~function = { arg in, triggerLevel=0.2, debounce=1 ;
	var mic = In.ar(in),
	amplitude = Amplitude.kr(mic),
	env = EnvFollow.kr(mic, 0.999),
	trig = amplitude > triggerLevel,
	timer = Timer.kr(trig),
	filteredTrig = (timer > debounce); //* trig;
	SendTrig.kr(filteredTrig, 0, env);
    };