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

	envAndPitch: track envelope and pitch. Sends a message with:
	- hasFreq: bool
	- env: float
	- freq: float
*/

~name = \envAndPitch;
~description = "Send amplitude envelope stream";

~function = { arg in, envAndPitch_rate=10, envAndPitch_Thresh = 0.02, envAndPitch_median = 7;
	var mic, env, freq, hasFreq, trig;
	mic = in;
	env = EnvFollow.kr(mic, 0.999);
	# freq, hasFreq = Pitch.kr(mic, ampThreshold: envAndPitch_Thresh,  median: envAndPitch_median);
	trig = Impulse.kr(envAndPitch_rate);

	SendReply.kr(trig, "/analysis", [hasFreq, env, freq]);
    };

~setup = nil;