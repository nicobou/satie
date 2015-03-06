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
		~makeSynthDef = {| self, name, srcfunc, destFunArray, busShiftArray = #[0] |
			SynthDef(name,
				{| gate = 1, update = #[0,0,0,1,22000 ], spread = 1 |
					var in, env;
					in = SynthDef.wrap(srcfunc);
					env = Linen.kr(gate, 2, 1, 2, 2); // fade in/out the signal  FIXME change parameters
					destFunArray.do{ arg item, i;
						var out = SynthDef.wrap(item, prependArgs: [in, update, spread]);
						//var out = SynthDef.wrap(item, prependArgs: [in, vol, delay, azi, ele]);
						Out.ar(busShiftArray.wrapAt(i), env * out);
					};
			}).add;
		};

		// example test function, see test/test.scd
		~test = {
			var y;
			// first generate the SynthDef
			~make.value(\NSinNSin,
				srcfunc: {|srcfreq = 4| Dust.ar(srcfreq)},
				destFunArray: [
					{|in = 0, vol, delay, azi, ele, room = 1| vol * FreeVerb.ar(in, room)},
					{|in = 0, vol, delay, azi, ele, room2 = 0| vol * FreeVerb.ar(in, room2)}],
				busShiftArray: [0,1]);
			y = Synth.tail(s, \NSinNSin);
			y;  // returning the synth
			// control example
			// y.set(\srcfreq, 8);
			// y.set(\room, 0);
			// y.set(\room, 1);
			// y.set(\room2, 0);
			// y.set(\room2, 20);
			// y.set(\vol, 1);
			// y.release;
			// y.set(\gate, 0);
		};
	});
	e.know = true;
	e;
};
)  // end of file
