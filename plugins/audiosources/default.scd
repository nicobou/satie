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

~name = \default;
~description = "...";
~channelLayout = \mono;

~function = { arg amp=1, lfoHz=10, trimDB = 0, t_gate=0, note=#[60,1];
	var signal, env;
	env = EnvGen.ar(Env.perc(0.01, 0.3, 0.5), gate: t_gate, doneAction:0);
	//amp*(PinkNoise.ar(1)* LFPulse.ar(lfoHz) + (env*FSinOsc.ar((note[0]).midicps)));
	trimDB.dbamp*amp*(PinkNoise.ar(1)* LFPulse.ar(lfoHz));
};

/*  for test of "prop" and "event" messages
a=~function.play;
a.set(\tremelo, 20);   // accessed via the "prop" message
a.set(\amp, 2.reciprocal);   // accessed via the "prop" message
a.set(\note, #[1,60]);   // accessed via the "event" message
a.set(\t_trigger, 1);
*/
