// USES GLOBAL VARIABLES:   ~procMan and  ~thisProjectResourcePath

// this file defines  a process class, which is ONLY used by source nodes that have that have a URI of type:   "process" , e.g:      uri://process  "particule1"
// you can define any number of these process clases, each one, corresponding to a particular type of processing  behavoir you define

// this class is for updated resonant klones

// required:  set up class struct

~particule1 = Environment[
	// required fields
	'nodeName' -> \nil,
	'nodeGroupName' -> \nil,
	'nodeGroup' -> \nil,

	// connection state
	'aziDeg' -> -10,
	'elevDeg' -> 10,
	'gainDB' -> -99,
	'delayMs' -> 0,
	'lpHz' -> 0.5,
	'hpHz' -> 22040,
	// project specific
	'synth' -> \zkarpluck1P,  // \zparticle1P,
	'cloneCount' -> 0,
	'cloudRadius' -> 5, // NOT IMPLEMENTED
	'cloudExp'-> 2,    // increase this value to make cloud more "narrow"  (narrows more quickly as with distance)
	'triggerIntervalMs' -> 500,   // time interval, during which the clones will randomly trigger
	// other state
	'transposition' -> 0,
	'pitchSeqGlobalMode' -> 0,
	'pitchSeqSym' -> \default,
	'pitchSeqLen' -> 1,   // not used
	'pitchSeqIncr' -> 1,   // used, but only to set global sequencer state
	'pitchSeqPos' -> 0,     // not used
	'debugFlag' -> 0,

];

// required: set these variables to the process name;
~processName = \particule1;
~process = ~particule1;
~process.know=true;
~procMan.registerProcessEnv(~processName, ~process);  // regester this process with satie


// set up class instance dictionary

~particule1_instances = Dictionary.new();



// define any custom "class"  variables, referenced by all "instants"  of "particule1" class
if (~particule1_pitchSequences == nil,
	{
		~particule1_pitchSequences = Dictionary.new();
		~particule1_pitchSequences.put(\default, Dictionary.new());
		~particule1_pitchSequences.at(\default).put(\pitches, [60]);
		~particule1_pitchSequences.at(\default).put(\pos, 0);
		~particule1_pitchSequences.at(\default).put(\incr,1);
		~particule1_pitchSequences.at(\default).put(\size,1);

});

// required functions


// required function but adaptable to project specifics
// generates N synths
~particule1.setup = { | self, nodeName, nodeGroupName, argsList  |
	var thisGroup = ~procMan.satie.satieGroups[nodeGroupName.asSymbol] ;

	self.nodeName = nodeName;
	self.nodeGroupName = nodeGroupName;
	self.nodeGroup = thisGroup;
	~particule1_instances.put(self.nodeName.asSymbol, self);

	// IF there are args, try to parse them and set corresponding environment key value pairs
	if (  argsList.size > 1,
		{
			if (  (argsList.size&1)==1,    // odd length,  bad key value format
				{
					warn("particule1.setup:  node: %   ignoring args:  expecting key value pair(s)  % \n",  self.nodeName, argsList);
				},
				// else arg list good to parse
				{
					argsList.pairsDo({ | key, val |
						self[key.asSymbol] = val;
						if (self.debugFlag != 0, { postf("••particule1.setup: setting key value pair:  % : %  \n", key, val); });
					});
			});
	});

	// add project-specific code below

	self.put(\cloneCount, self.cloneCount.asInt.clip(0,1000));  // safety

	if (self.debugFlag != 0, { postf("••particule1.setup:  generating % synthVoices for group %\n",  self.cloneCount, self.nodeGroupName);});

	// generate N  self.cloneCount  synths
	(self.cloneCount - 1).do( { arg item;
		var nodename=(self.nodeName++"_"++item).asSymbol;
		var synth;

		synth = ~procMan.satie.makeInstance(nodename.asSymbol, self.synth.asSymbol, self.nodeGroupName);
		// synth now created, so we can set its state
		synth.set(\aziDeg, self.aziDeg, \eleDeg, self.elevDeg, \gainDB, self.gainDB , \delayMs, self.delayMs, \lpHz, self.lpHz, \hpHz, self.hpHz);
		synth.set(\randTrigMaxMs, self.triggerIntervalMs);
	});
};


~particule1.cleanup = { | self |

	// add project-specific code below
	if (self.debugFlag != 0, {  postf("••particule1.cleanup: clearing synths in node: % group \n", self.nodeName);});

	(self.cloneCount - 1).do( { arg item;
		var nodename=(self.nodeName++"_"++item).asSymbol;
		~procMan.satie.cleanInstance(nodename.asSymbol, self.nodeGroupName);
	});

	~particule1_instances.removeAt(self.nodeName);
};


// overrides satie4Unity's 'set' message handler

~particule1.set =  {| self, key, value |
	if (self.debugFlag != 0, { postf("••particle1.set: key %  value % \n", key, value);});
	// add conditional processing of key value pairs here
	// write key value pair to synth
	(self.cloneCount - 1).do( { arg item;
		var nodename=(self.nodeName++"_"++item).asSymbol;

		// this is where we can calculate clone-specific parameters
		// value = value *  item;

		~procMan.satie.satieGroupInstances[ self.nodeGroupName.asSymbol ][ nodename.asSymbol ].set(key.asSymbol,value);
	});


};


// overrides satie4Unity's 'state' message handler

~particule1.state =  {| self, value |
	if (self.debugFlag != 0, {  postf("••particle1.state: setting state of process node %  clones to % \n", self.nodeName, value);});

	(self.cloneCount - 1).do( { arg item;
		var nodename=(self.nodeName++"_"++item).asSymbol;

		// this is where we can calculate clone-specific actions before changing state
	});
	self.nodeGroup.run(value);   // change state for all synths in process's group
};


~particule1.property =  {| self, key, value |
	// add conditional processing of key value pairs here
	if (self.debugFlag != 0, {  postf("••particule1.setProperty:  processing key vaue pair:  %:%   to process node's environment \n", key, value,  self.nodeName);});

	switch (key.asSymbol,
		\triggerIntervalMs,
		{
			value = value.asFloat.clip(100, 100000);
			self.put(key.asSymbol, value);
		},
		\cloneCount,     // need to do some conditional processing for this particular key
		{
			value = value.asInt.clip(0, 500);  // safety
			if (self.cloneCount != value,
				{
					self.setCloneCount(value);   // updates property as well
			});
		},
		\increment,     // need to do some conditional processing for this particular key
		{
			self.setIncrement(value.asFloat);   // updates property as well

		},		// else just write key value pair to process instance's environment
		{
			self.put(key.asSymbol, value);
	});

};


// overrides satie4Unity's update function
// if defined, will be called when node's "update" message is received
// otherwise satie4unity will send the  "update" message to the node's group
~particule1.setUpdate = { | self, aziDeg, eleDeg, gainDB, delayMs, lpHz, distance |

	var 	thisGroup = self.nodeGroup; // ~allSourceNodes[self.nodeName.asSymbol].at(\proxy);
	var xzDist = distance * eleDeg.degrad.cos;  // get (horizontal) distance of node to listener on XZ plane
	var yDist = distance * eleDeg.degrad.sin;  // get (vertical) distance of node to listener projected on Y axis
	var aziScaler;
	var elevScaler;


	xzDist = xzDist.clip(0, 100)*0.01;   // anything over 100 meters away will generate no azimuth offset its clones. Normalize

	yDist = yDist.clip(0, 100)*0.01;   // anything over 100 meters away will generate no azimuth offset its clones. Normalize

	aziScaler = (1 - xzDist)**self.cloudExp;   // increase this exponent to fall off more quickly
	elevScaler = (1 - yDist)**self.cloudExp;   // increase this exponent to fall off more quickly

	//aziScaler.postln;

	//postf(" distance: %    xzDist:  %\n", distance, xzDist);

	// saving the connection state in case its needed
	self.aziDeg = aziDeg;
	self.elevDeg = eleDeg;
	self.gainDB = gainDB;
	self.delayMs = delayMs;
	self.lpHz = lpHz;
	self.hpHz = 0.5;  // to be added


	// updating the connection of all this node's clones (via group message)
	thisGroup.set(\aziDeg, self.aziDeg, \eleDeg, self.elevDeg, \gainDB, self.gainDB , \delayMs, self.delayMs, \lpHz, self.lpHz,  \cloudAziScale, aziScaler, \cloudElevScale, elevScaler ); //  \hpHz, self.hpHz);
};


// called on /satie/process/setvec nodeName 'trigger' midiPitch unitAmp unitVel
// custom method
~particule1.trigger = { arg self, args = #[1,2,3] ;
	var thisGroup = self.nodeGroup;
	var gain = self.gainDB;
	var seqName, pitch, position, incr, size, vel, incidence;

	if (self.debugFlag != 0, {  postf("••particule1.trigger: triggering % clones of node: %   argVec: %  \n", self.cloneCount, self.nodeName, args);});

	if ( args.size != 3,
		{
			warn("~particule1.trigger:  bad item count, expecing '[ pitch vel incidence]' , received: "++args++" \n");
		},
		{ // else

			seqName = self.pitchSeqSym;
			vel =  args[1].asFloat;

			// find out why incidence fucks the dog
			// incidence = 1; args[2].asFloat;

			incidence = args[2].asFloat.abs;   // not using negative values

			//("incidence"++incidence).postln;

			// update all nodes in group

			// thisGroup.set(\gainDB, gain);  not necessary, since this is handled in the update connection

			thisGroup.set(\randTrigMaxMs, self.triggerIntervalMs);

			// assign pitches  for each particle
			(self.cloneCount - 1).do( { arg item;
				var nodename=(self.nodeName++"_"++item).asSymbol;

				// this is where we could calculate the exact position of each clone, with respect to this node
				// but its expensive

				/* instance specific look up not used
				pitch = ~particule1_pitchSequences[self.pitchSeqSym][self.pitchSeqPos];
				self.pitchSeqPos = (self.pitchSeqPos + self.pitchSeqIncr) % self.pitchSeqLen;
				*/

				size = ~particule1_pitchSequences.at(seqName.asSymbol).at(\size);

				if (self.pitchSeqGlobalMode != 0,
					{

						position = ~particule1_pitchSequences.at(seqName.asSymbol).at(\pos);
						incr = ~particule1_pitchSequences.at(seqName.asSymbol).at(\incr);
						pitch =  self.transposition + ~particule1_pitchSequences.at(seqName.asSymbol).at(\pitches)[position];
						~particule1_pitchSequences.at(seqName.asSymbol).put(\pos,  ((position + incr) % size) );
					},
					// else   instance specific read
					{
						position = self.pitchSeqPos;
						incr = self.pitchSeqIncr;
						pitch =  self.transposition + ~particule1_pitchSequences.at(seqName.asSymbol).at(\pitches)[position];
						self.pitchSeqPos = ((position + incr) % size);
				});
				~procMan.satie.satieGroupInstances[ self.nodeGroupName.asSymbol ][ nodename.asSymbol ].set(\note, [ pitch, vel, incidence ] );
				~procMan.satie.satieGroupInstances[ self.nodeGroupName.asSymbol ][ nodename.asSymbol ].set(\t_trig, 1);
			});
	});
};

// custom method
~particule1.readPitches = { arg self, items = #["/tmp"] ;

	var pitchList, seqName, file, csvmidifilePath;

	//postf("readPitches:   arg 0: % \n",  items[0] );

	if ( items.size != 1,
		{
			error("particule1.readPitches:  bad item count, expecting one filePath arg, received: "++items++" \n");
		},
		//else
		{
			csvmidifilePath = items[0].asString;

			if (csvmidifilePath[0] != $/,
				{
					csvmidifilePath = ~thisProjectResourcePath++"/"++csvmidifilePath;
			});

			if (self.debugFlag != 0, { "••process1.readPitches file path"++csvmidifilePath.postln; });

			pitchList = List.new();
			seqName = csvmidifilePath.split.last;


			if ( File.exists(csvmidifilePath.standardizePath) == false,
				{
					error("particule1.readPitches: file "++csvmidifilePath.standardizePath++" not found, aborting");
				},
				// else  file exists, process
				{


			file = File(csvmidifilePath.standardizePath,"rb");



			// process only if pitch sequence has not yet been loaded
			if ( ~particule1_pitchSequences.includesKey(seqName.asSymbol),
				{

					//  file already loaded, just set instance  specific state
					if (self.debugFlag != 0, { postf("particule1.readPitches:  sequence % already loaded, skipping file load\n", seqName);});
					self.pitchSeqSym = seqName.asSymbol;
					self.pitchSeqLen = ~particule1_pitchSequences.at(seqName.asSymbol).at(\size);
					self.pitchSeqPos = 0;

					// and reset sequence's global state
					~particule1_pitchSequences.at(seqName.asSymbol).put(\pos, 0);
					~particule1_pitchSequences.at(seqName.asSymbol).put(\incr, self.pitchSeqIncr);   // using instance specific state.. may overwrite


				},
				// else  read file and create pitch sequence
				{
					//postf("file % length:  %\n", csvmidifilePath, file.length);

					file.do({
						var value, event;

						value = file.getLine();

						if (value.contains("Note_on_c"),
							{
								event = value.split($,);
								pitchList.add(event[4].asInt);
						});
					});

					file.close;

					if (pitchList.size > 0,
						{
							if (self.debugFlag != 0, { postf("••process1.readPitches:  % pitches read from file %\n", pitchList.size,  csvmidifilePath);});
							// add sequence to dictionary

							~particule1_pitchSequences.removeAt(seqName.asSymbol);   // overwrite previous

							~particule1_pitchSequences.put(seqName.asSymbol, Dictionary.new());
							~particule1_pitchSequences.at(seqName.asSymbol).put(\pitches, pitchList);
							~particule1_pitchSequences.at(seqName.asSymbol).put(\size, pitchList.size);
							~particule1_pitchSequences.at(seqName.asSymbol).put(\pos, 0);
							~particule1_pitchSequences.at(seqName.asSymbol).put(\incr, 1);


							//~particule1_pitchSequences.removeAt(seqName.asSymbol);
							//~particule1_pitchSequences.put(seqName.asSymbol, pitchList);
							//~particule1_pitchSequences.put(seqName.asSymbol,

							// set instance local state -- currently not used, but available for future deployment
							self.pitchSeqSym = seqName.asSymbol;
							self.pitchSeqLen = pitchList.size;
							self.pitchSeqPos = 0;
						},
						//else
						{
							warn("no pitches found in file: "++csvmidifilePath);
					});
			});
			});
	});
};

// utility function to change pitch increment
~particule1.setIncrement = { | self, value |

	if (self.debugFlag != 0, { postf("particule1.setIncrement:  increment = % \n", value);});

	if (self.pitchSeqGlobalMode != 0,
		{
			~particule1_pitchSequences.at(self.pitchSeqSym).put(\incr, value);
		},
		// else
		{
			self.pitchSeqIncr = value;
	});
};


// Utility function that changes instance's  clone count
~particule1.setCloneCount = { | self, newCount |

	(self.cloneCount - 1).do( { arg item;
		var nodename=(self.nodeName++"_"++item).asSymbol;
		var synth =  ~procMan.satie.satieGroupInstances[ self.nodeGroupName.asSymbol ][ nodename.asSymbol ];
		~procMan.satie.cleanInstance(nodename, self.nodeGroupName );
		//synth.free;    // KLUGE:  to make sure it gets cleaned from the node tree
	});

	self.cloneCount = newCount.asInt;

	// generate N  self.cloneCount  synths
	(self.cloneCount - 1).do( { arg item;
		var nodename=(self.nodeName++"_"++item).asSymbol;
		var synth;

		synth = ~procMan.satie.makeInstance(nodename.asSymbol, self.synth.asSymbol, self.nodeGroupName);
		// synth now created, so we can set its state
		synth.set(\aziDeg, self.aziDeg, \eleDeg, self.elevDeg, \gainDB, self.gainDB , \delayMs, self.delayMs, \lpHz, self.lpHz, \hpHz, self.hpHz);
		synth.set(\randTrigMaxMs, self.triggerIntervalMs);
	});
};


/*
testing

~myFile =  "/Users/zack/Dropbox/Unity3D/projects_unity5/balljamDemoSATIE_2015_unity5/Assets/StreamingAssets/midi/pitchSequences/bjGroove.mid.mid.txt";
~particule1.readPitches(~myFile);
~particule1.pitchSeqLen;
~particule1.pitchSeqName;

*/
