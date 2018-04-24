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

/*       Monitoring/analysis plugin definition

	Each monitoring/analyser plugin should define the following global variables:
    ~name: (symbol) name of the spatializer
	~description: (string) a short description
	~function: the actual definition of the plugin
	~setup: optional function that will set up the plugin before server boots

	It should not return any audio
*/

~name = \envTrigger;
~description = "Send a trigger based on envelope threshold";

~function = { arg in, envTrigger_triggerLevel=0.2, envTrigger_debounce=1 ;
	var mic = in,
	amplitude = Amplitude.kr(mic),
	env = EnvFollow.kr(mic, 0.999),
	trig = amplitude > envTrigger_triggerLevel,
	timer = Timer.kr(trig),
	filteredTrig = (timer > envTrigger_debounce);
	SendTrig.kr(filteredTrig, 0, env);
    };

~setup = nil;