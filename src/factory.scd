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

(
~scbrFactory = {
	var e = Environment.make({  // scbrFactory namespace
		// function ~make
		// make a source, n listeners and link them as as follows:
		//         /--> spatilizer 1
		//     src ---> ...
		//         \--> spatializer n
		// a call to function ~make will create a SynthDef and add it to the server
		//
		// @name            the generated SynthDef name
		// @src             a function the will output a mono signal
		// @preBusArray    send raw src to busses which indexes are in the array
		// @destfunArray    an array of function reading the mono signal
		//                  from the source and write computed signals to outbus
		// @outBusArray   position of the first bus to write
		~makeSynthDef = {| self,
			name,
			src,
			preBusArray = #[],
			spatializerArray,
			firstOutputIndexArray = #[0],
            paramsMapper,
			synthArgs = #[] |
			SynthDef(name,
				{ | synth_gate = 1, preBus_gainDB = 0 |
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
					spatializerArray.do{ arg item, i;
						var out = SynthDef.wrap(item, prependArgs: [in] ++ mapped);
						Out.ar(firstOutputIndexArray.wrapAt(i), env * out);
					}
			}).add;
			// create a kamikaze shadow
			SynthDef(name ++ "_kamikaze",
				{ | synth_gate = 1, preBus_gainDB = 0  |
					var in, env, out, mapped;
					// install first the mapper with spatialization parameters, allowing it to take control
					// over all defined parameter
					mapped = SynthDef.wrap(paramsMapper);
					// in
					in = SynthDef.wrap(src, prependArgs:  synthArgs);
					DetectSilence.ar(in, doneAction: 2);
					// fade in set to as short as possible for percussive cases
					env = EnvGen.kr(Env.cutoff(0.01, 1, 2),  synth_gate, doneAction: 2);
					// in -> busses (busses are taking raw input)
					preBusArray.do {arg item;
						Out.ar(item, preBus_gainDB.dbamp * env * in);
					};
					// in -> dest
					spatializerArray.do{ arg item, i;
						var out = SynthDef.wrap(item, prependArgs: [in] ++ mapped);
						Out.ar(firstOutputIndexArray.wrapAt(i), env * out);
					}
			}).add;
		};
	});
	e.know = true;
	e;
};
)  // end of file
