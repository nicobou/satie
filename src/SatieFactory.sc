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

SatieFactory {

	*makeSynthDef{|
		name,
		src,
		preBusArray,
		postBusArray,
		spatializerArray,
		firstOutputIndexArray,
		paramsMapper,
		synthArgs |

		SynthDef(name,
			{| synth_gate = 1, preBus_gainDB = 0, postBus_gainDB = 0  |
				var in, env, out, mapped;
				// install first the mapper with spatialization parameters, allowing it to take control
				// over all defined parameter
				mapped = SynthDef.wrap(paramsMapper);
				// in
				in = SynthDef.wrap(src, prependArgs:  synthArgs);
				// fade in set to as short as possible for percussive cases
				env = EnvGen.kr(Env.cutoff(0.01, 1, 2),  synth_gate, doneAction: 2);
				// in -> busses (busses are taking raw input)
				preBusArray.do {arg item;
					Out.ar(item, preBus_gainDB.dbamp * env * in);
				};
				// in -> dest
				// collecting spatializers
				out = Array.newClear(spatializerArray.size());
				spatializerArray.do { arg item, i;
					out.put(i, env * SynthDef.wrap(item, prependArgs: [in] ++ mapped));
				};
				// sending sum of first spatializer to the post busses
				postBusArray.do { arg item;
					Out.ar(item, postBus_gainDB.dbamp * env * Mix.new(out.at(0)));
				};
				// sending to out
				spatializerArray.do { arg item, i;
					Out.ar(firstOutputIndexArray.wrapAt(i), out.at(i));
				}
		}).add;
	}

	*makeDummySynth{|name|
		SynthDef(name, {| sfreq = 200 |
			PinkNoise.ar() + FSinOsc.ar(sfreq)
		}).add;
	}

	*makeSD{|name, src, synthArgs|
		SynthDef(name, {|out = 0|
			Out.ar(out, SynthDef.wrap(src, prependArgs: synthArgs));
		}).add;
	}
}