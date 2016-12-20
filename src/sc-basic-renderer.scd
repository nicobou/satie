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
~scbrMaker = { | numAudioAux = 0, satieSrcPath |
	var e = Environment.make({
		// TODO use try catch with this
		~pluginLoader;
		~synthDefFactory;
		//~spatOSCMaker;
		~defaultSatieGroup;
		~satieGroups = Dictionary.new;
		~satieGroupInstances = Dictionary.new;
		~effectSynthDef = Set.new;
		~auxbus;
		~aux;
		~satieSrcPath;

		~makeSynthDef = {
			| self,
			name,
			srcSymbol, srcPreToBusses = #[], srcPostToBusses = #[],
			spatSymbolArray, firstOutputIndexes = #[0],
			paramsMapper = \defaultMapper,
			synthArgs = #[] |
			// selecting audio source or effect dictionay because
			// make instance require effects to be added to tail
			// and audio source to head
			var dictionary;
			if (nil != self.pluginLoader.audioPlugins.at(srcSymbol),
				{
					dictionary = self.pluginLoader.audioPlugins;
				},
				{
					dictionary = self.pluginLoader.effectPlugins;
					self.effectSynthDef.add(name.asSymbol);  // ? this needs to be figured out
				}
			); //  endif
			// Factory
			self.synthDefFactory.makeSynthDef(
				/*name:*/ name,
				/*src:*/ dictionary.at(srcSymbol),
				/*srcPreToBusses:*/ srcPreToBusses,
				/*srcPostToBusses:*/ srcPostToBusses,
				/*spatializers:*/ spatSymbolArray.collect({ arg item, i;
					self.pluginLoader.spatPlugins.at(item)}),
				/*firstOutputIndexes:*/ firstOutputIndexes,
				/*paramsMapper:*/ self.pluginLoader.mapperPlugins.at(paramsMapper),
				/*synthArgs:*/ synthArgs);
			nil;  // return
		};

		~makeSatieGroup = { | self, name, addAction = \addToHead |
			var group = ParGroup.new(addAction: addAction);
			self.satieGroups.put(name.asSymbol, group);
			self.satieGroupInstances.put(name.asSymbol, Dictionary.new);
			group;
		};

		~killSatieGroup = { | self, name |
			// self.satieGroups[name].end;
			self.satieGroups[name].free;
			self.satieGroupInstances[name].free;
			self.satieGroups.removeAt(name);
			self.satieGroupInstances.removeAt(name);
			nil;
		};

		~makeInstance = { | self, name, synthDefName, group = \default, synthArgs = #[] |
			var synth = Synth(synthDefName, args: synthArgs, target: self.satieGroups[group], addAction: \addToHead );
			self.satieGroupInstances[group].put(name, synth);
			synth;
		};

		~makeKamikaze = { | self, name, synthDefName, group = \default, synthArgs = #[] |
			var synth = Synth(synthDefName ++ "_kamikaze", args: synthArgs, target: self.satieGroups[group], addAction: \addToHead );
			synth;
		};

		~cleanInstance = { | self, name, group = \default |
			self.satieGroupInstances[group][name].release();
			// fadeTime must be higher than SATIE internal fadeTime:
			self.satieGroupInstances[group][name].clear(0.03);
			self.satieGroupInstances[group].removeAt(name);
			nil;
		};

		~pauseInstance = { | self, name, group = \default |
			self.satieGroupInstances[group][name].release();
			nil;
		};
	});  // Environment.make

	e.know = true;
	e.auxbus = Bus.audio(s, numAudioAux);
	e.aux = Array.fill(numAudioAux, {arg i; e.auxbus.index + i });
	e.pluginLoader = ~scbrPlugins.value();
	e.synthDefFactory = ~scbrFactory.value();
	e.defaultSatieGroup = e.makeSatieGroup();
	e.satieGroups.put(\default, e.defaultSatieGroup);
	e.satieGroupInstances.put(\default, Dictionary.new);
	e.satieSrcPath = satieSrcPath;
	// loading plugins
	e.pluginLoader.loadAudioPlugins(e.satieSrcPath ++ "/audiosources/*.scd");
	e.pluginLoader.loadSpatPlugins(e.satieSrcPath ++ "/spatializers/*.scd");
	e.pluginLoader.loadEffectPlugins(e.satieSrcPath ++ "/effects/*.scd");
	e.pluginLoader.loadMapperPlugins(e.satieSrcPath ++ "/mappers/*.scd");
	~scbrCtl.value(~scbr);    // create renderer control object
	e;  // return
};  // scbrMaker


// psudo class to control  basic-renderer above
// Creates instance to receive control messages via OSC on the rxPort
// note: any OSC bindings of previous instances are destoyed before creation of a new instance
// so it is safe to call repeatedly

~scbrCtl = { | satieContext, rxPort=18032 |
	var satie = satieContext;
	var oscAddress = "/satie/rendererCtl";

	var e = Environment.make({


		// used for audio renderer control
		~volume = s.volume;     // create hook to global audio engine volume / mute control
		~volume.setVolumeRange(-99, 18);
		~outputDB = 0;    // current state of the supercollider's output
		~outputTrimDB = 0;
		~debugFlag=false;
		~basicRendererCallbackID = \basicRendererCallback;



		// ~basicRendererCallback = { "basicRendererCallback called".inform };
		~basicRendererCallback = {
			arg msg;
			var command = msg[1];

			if (~debugFlag == true,
				{
					postf("~basicRendererCallback: command: %, msg: %, \n", command, msg);
			});

			if (msg.size < 2,
				{"~basicRendererCallback: empty message".warn;
					postf("~basicRendererCallback MESS LEN: %", msg.size);

				},
				// else
				{

					switch (command,
						'setProjectDir',
						{
							if ( (msg.size != 3 ) ,
								{"~basicRendererCallback: setProjectDir bad arg count: expecting 'setProjectDir projectDirPath' ".warn;},
								// else
								{
									e.projectDirectory = msg[2];

									//e.projectDirectory.postln;
									postf("~basicRendererCallback: setProjectDir: % \n", e.projectDirectory);

								}
							)
						},
						'setOutputTrimDB',
						{
							if ( (msg.size < 3 ) ,
								{"~basicRendererCallback: setOutputTrimDB missing value".warn;},
								// else
								{
									e.outputTrimDB = msg[2];
									e.volume.volume = e.outputTrimDB + e.outputDB;
								}
							)
						},
						'setOutputDB',
						{
							if ( (msg.size < 3 ) ,
								{"~basicRendererCallback: setOutputDB missing value".warn;},
								// else
								{
									e.outputDB = msg[2];
									e.volume.volume = e.outputTrimDB + e.outputDB;
								}
							)
						},
						'setOutputDIM',
						{
							if ( (msg.size < 3 ) ,
								{"~basicRendererCallback: setOutputMute missing value".warn;
									// postf("CREATESOURCE MESS LEN: %", msg.size);

								},
								// else
								{
									if (msg [2] > 0,
										{  e.volume.volume = -30;  },
										// else
										{  e.volume.volume =  e.outputDB + e.outputTrimDB;   });
								}
							)
						},
						'freeSynths',
						{
							if ( (msg.size < 3 ) ,
								{"~basicRendererCallback: freeSynths missing group name".warn;
									// postf("freeSynths MESS LEN: %", msg.size);

								},
								// else
								{
									var groupSym = msg [2] .asSymbol;

									satie.satieGroups[groupSym].freeAll;
									postf("basicRendererCallback: freeing all synths in % group", groupSym);
								}
							)
						},
						'setOutputMute',
						{
							//postf("~basicRendererCallback setMute: %\n", msg[2]);
							if ( (msg.size < 3 ) ,
								{"~basicRendererCallback: setOutputDIM missing value".warn;  },
								// else
								{
									if (msg [2] > 0,
										{e.volume.mute;},
										// else
										{e.volume.unmute;} );  // full muting implmentation
								}
							);
						}
					)
			});
		};

		// now connect the OSC callback to this instance
	    OSCdef(~basicRendererCallbackID).clear.free;   // disconnect older instance,  if it exists
		OSCdef(~basicRendererCallbackID, ~basicRendererCallback, oscAddress, recvPort: rxPort);  // set up OSC callback

	}); // Environment.make
	"basicRendererCtl loaded".inform;
	e.know = true;
	e;
};



)