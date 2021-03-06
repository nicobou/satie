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
~satieFactory = {
	var e = Environment.make({

		// Method ~makeSynthDef makes a source, n listeners and link them as follow:
		//         /--> spatilizer 1
		//     src ---> ...
		//         \--> spatializer n
		// a call will create a SynthDef and add it to the server.
		//
		// Method parameters:
		// @name                  the generated SynthDef name
		// @src                   a function the will output a mono signal
		// @preBusArray           send raw src to busses which indexes are in the array
		// @ppostBusArray         send mixed-to-mono sound source to busses which indexes are in the array
		// @spatializerArray      an array of function reading the mono signal
		//                        from the source and write computed signals to outbus
		// @firstOutputIndexArray position of the first bus to write
		// @paramsMapper          a mapper function that handle and map spatialiser parameters
		// @synthArgs             set different default values for parameters

		~makeSynthDef = {| self,
			name,
			src,
			preBusArray = #[],
			postBusArray = #[],
			spatializerArray,
			firstOutputIndexArray = #[0],
            paramsMapper,
			synthArgs = #[] |
			SynthDef(name,
				{ | synth_gate = 1, preBus_gainDB = 0, postBus_gainDB = 0  |
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

			// create a kamikaze shadow
			SynthDef(name ++ "_kamikaze",
				{ | synth_gate = 1, preBus_gainDB = 0, postBus_gainDB = 0  |
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
		};
	});
	e.know = true;
	e;
};
)  // end of file
