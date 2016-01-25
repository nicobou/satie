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
		//         /--> listener 1
		//     src ---> ...
		//         \--> listener n
		// a call to function ~make will create a SynthDef and add it to the server
		//
		// @name            the generated SynthDef name
		// @srcfunc         a function the will output a mono signal
		// @destfunArray    an array of function reading the mono signal
		//                  from the source and write computed signals to outbus
		// @busShiftArray   position of the first bus to write
		// @toBusArray      send src to busses which indexes are in the array
		~makeSynthDef = {| self,
			name,
			srcfunc,
			destFunArray,
			busShiftArray = #[0],
			toBusArray = #[],
			synthArgs = #[] |
			SynthDef(name,
				// can the "gate" arg name be changed to avoid conflicts with plugin-synthDefs that use it
				{| gate = 1,  aziDeg = 0, eleDeg = 0, gainDB = -90, delayMs = 1, lpHz = 15000, hpHz = 0.5 , spread = 1 |
					var in, env;
					in = SynthDef.wrap(srcfunc, prependArgs:  synthArgs);
					// fade in set to as short as possible for percussive cases
					env = Linen.kr(gate, 0.005, 1, 0.01, 2);
					//in -> busses
					toBusArray.do {arg item;
						Out.ar(item, env * in);
					};
					// in -> dest
					destFunArray.do{ arg item, i;
						var out = SynthDef.wrap(item, prependArgs: [in, aziDeg, eleDeg, gainDB, delayMs, lpHz, hpHz, spread]);
						//var out = SynthDef.wrap(item, prependArgs: [in, vol, delay, azi, ele]);
						Out.ar(busShiftArray.wrapAt(i), env * out);
					}
			}).add;
		};
		~makeSynthDef2 = {| self,
			name,
			src,
			srcToBusses = #[],
			spatializers,
			firstOutputIndexes = #[0],
            paramsMapper,
			synthArgs = #[] |
			SynthDef(name,
				// can the "gate" arg name be changed to avoid conflicts with plugin-synthDefs that use it
				{ | gate = 1 |
					var in, env, out, mapped;
					// install first the mapper with spatialization parameters, allowing it to take control
					// over all defined parameter
					mapped = SynthDef.wrap(paramsMapper, prependArgs:  synthArgs);
					// in
					in = SynthDef.wrap(src);
					// fade in set to as short as possible for percussive cases
					env = Linen.kr(gate, 0.005, 1, 0.01, 2);
					// in -> busses (busses are taking raw input)
					srcToBusses.do {arg item;
						Out.ar(item, env * in);
					};
					// in -> dest
					spatializers.do{ arg item, i;
						var out = SynthDef.wrap(item, prependArgs: [in] ++ mapped);
						Out.ar(firstOutputIndexes.wrapAt(i), env * out);
					}
			}).add;
		};
	});
	e.know = true;
	e;
};
)  // end of file
