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
					out.put(i, env * SynthDef.wrap(item, prependArgs: [in] ++ mapped.at(i.mod(mapped.size))));
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
					out.put(i, env * SynthDef.wrap(item, prependArgs: [in] ++ mapped.at(i.mod(mapped.size))));
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

	*makeAmbiFromMono{|
		name,
		src,
		preBusArray,
		postBusArray,
		ambiOrder,
		ambiEffectPipeline,
		ambiBusIndex,
		paramsMapper,
		synthArgs |

		SynthDef(name,
			{| synth_gate = 1, preBus_gainDB = 0, postBus_gainDB = 0  |
				var in, env, out, mapped, encoder;
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
				// encoder part
				encoder = { |in, order = 1, aziDeg = 0, eleDeg = 45, gainDB = -90, delayMs = 1,
					lpHz = 15000, hpHz = 1, spread = 1, plane_spherical = 0, radius = 2, speaker_radius = 1.07 |
					var gain = gainDB.dbamp;   // convert gainDB to gainAMP
					var delay = delayMs * 0.001;    // convert to seconds
					var slewDelay = 0.3; //  note: this needs to be improved ... smoother
					var slewGain = 0.1;
					var slewFilter = 0.6;
					var slewPanning = 0.030;
					var panWeights;
					var outsig;

					outsig =  LPF.ar(DelayC.ar(
						Lag.kr(gain, slewGain) * in,
						maxdelaytime: 0.5,
					delaytime: delay.lag(slewDelay)), lpHz.lag(slewFilter) );

					outsig = BHiPass.ar(outsig, VarLag.kr(hpHz, slewFilter ) );
					HOAEncoder.ar(order, outsig,
						Ramp.kr(aziDeg * 0.017453292519943, slewPanning),
						Ramp.kr(eleDeg * 0.017453292519943, slewPanning),
					gainDB, plane_spherical, radius, speaker_radius);
				};

				out = env * SynthDef.wrap(encoder, prependArgs: [in, ambiOrder] ++ mapped);
				postBusArray.do { arg item;
					Out.ar(item, postBus_gainDB.dbamp * env * NumChannels.ar(out,numChannels: 1, mixdown: false));
				};
				// sending to out
				Out.ar(ambiBusIndex, out);
		}).add;

		SynthDef(name ++ "_kamikaze",
			{| synth_gate = 1, preBus_gainDB = 0, postBus_gainDB = 0  |
				var in, env, out, mapped, encoder;
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
				// encoder part
				encoder = { |in, order = 1, aziDeg = 0, eleDeg = 45, gainDB = -90, delayMs = 1,
					lpHz = 15000, hpHz = 1, spread = 1, plane_spherical = 0, radius = 2, speaker_radius = 1.07 |
					var gain = gainDB.dbamp;   // convert gainDB to gainAMP
					var delay = delayMs * 0.001;    // convert to seconds
					var slewDelay = 0.3; //  note: this needs to be improved ... smoother
					var slewGain = 0.1;
					var slewFilter = 0.6;
					var slewPanning = 0.030;
					var panWeights;
					var outsig;

					outsig =  LPF.ar(DelayC.ar(
						Lag.kr(gain, slewGain) * in,
						maxdelaytime: 0.5,
					delaytime: delay.lag(slewDelay)), lpHz.lag(slewFilter) );

					outsig = BHiPass.ar(outsig, VarLag.kr(hpHz, slewFilter ) );
					HOAEncoder.ar(order, outsig,
						Ramp.kr(aziDeg * 0.017453292519943, slewPanning),
						Ramp.kr(eleDeg * 0.017453292519943, slewPanning),
					gainDB, plane_spherical, radius, speaker_radius);
				};

				out = env * SynthDef.wrap(encoder, prependArgs: [in, ambiOrder] ++ mapped);
				postBusArray.do { arg item;
					Out.ar(item, postBus_gainDB.dbamp * env * NumChannels.ar(out,numChannels: 1, mixdown: false));
				};
				// sending to out
				Out.ar(ambiBusIndex, out);
		}).add;

	}
}