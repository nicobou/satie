// USES GLOBAL VARIABLES:   ~procMan and  ~thisProjectResourcePath

// this file defines  a process class, which is ONLY used by source nodes that have that have a URI of type:   "process" , e.g:      uri://process  "particule2"
// you can define any number of these process clases, each one, corresponding to a particular type of processing  behavoir you define

// this class is for preallocated klones with no spatializer updates (except for the one at trigger time)

// required:  set up class struct

~particule2 = Environment[
	// required fields
	'nodeName' -> \nil,
	'nodeGroupName' -> \nil,
	'nodeGroup' -> \nil,


	// project specific
	//'cloneVector' -> [],  // vector to store allocated synths
	'synth' -> \zkarpluck2P,  // \zparticle2P,
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
	'debugFlag' -> 1,
];


// required: set these variables to the process name;
~processName = \particule2;
~process = ~particule2;
~process.know=true;

// regester this process with satie
~procMan.registerProcessEnv(~processName, ~process);


// set up class instance dictionary

~particule2_instances = Dictionary.new();

// define any custom "class"  variables, referenced by all "instants"  of "particule2" class
if (~particule2_pitchSequences == nil,
	{
		~particule2_pitchSequences = Dictionary.new();
		~particule2_pitchSequences.put(\default, Dictionary.new());
		~particule2_pitchSequences.at(\default).put(\pitches, [60]);
		~particule2_pitchSequences.at(\default).put(\pos, 0);
		~particule2_pitchSequences.at(\default).put(\incr,1);
		~particule2_pitchSequences.at(\default).put(\size,1);

});

// required functions

~particule2.cleanup = { | self |

	var synth;

	// add code here to manage project-specific stuff
	postf("~particule2.clearSynths: clearing synths in node: % group \n", self.nodeName);
	(self.cloneCount).do( { arg item;
		var nodename=(self.nodeName++"_"++item).asSymbol;
		~procMan.satie.cleanInstance(nodename.asSymbol, self.nodeGroupName);
	});
	~particule2_instances.removeAt(self.nodeName);
};


// required function but adaptable to project specifics
// generates N synths
~particule2.setup = { | self, nodeName, nodeGroupName, argsList  |
	var thisGroup = ~procMan.satie.satieGroups[nodeGroupName.asSymbol] ;

	self.nodeName = nodeName;
	self.nodeGroupName = nodeGroupName;
	self.nodeGroup = thisGroup;
	//'particule2,setup'.postln;

	// IF there are args, try to parse them and set corresponding environment key value pairs
	if (  argsList.size > 1,
		{
			if (  (argsList.size&1)==1,    // odd length,  bad key value format
				{
					warn("particule2.setup:  node: %   ignoring args:  expecting key value pair(s)  % \n",  self.nodeName, argsList);
				},
				// else arg list good to parse
				{
					argsList.pairsDo({ | key, val |
						self[key.asSymbol] = val;
						if (self.debugFlag != 0, { postf("••particule2.setup: setting key value pair:  % : %  \n", key, val); });
					});
			});
	});

	// add project-specific code below

	self.cloneCount = self.cloneCount.asInt.clip(0,1000);  // safety

	if (self.debugFlag != 0, { postf("••particule2.setup:  generating % synthVoices for group %\n",  self.cloneCount, self.nodeGroupName);});

	// generate N  self.cloneCount  synths
	(self.cloneCount ).do( { arg item;
		var nodename=(self.nodeName++"_"++item).asSymbol;
		var synth;

		synth = ~procMan.satie.makeInstance(nodename.asSymbol, self.synth.asSymbol, self.nodeGroupName);
		// synth now created, so we can set its state
		// synth.set(\aziDeg, self.aziDeg, \eleDeg, self.elevDeg, \gainDB, self.gainDB , \delayMs, self.delayMs, \lpHz, self.lpHz, \hpHz, self.hpHz);
		synth.set(\randTrigMaxMs, self.triggerIntervalMs);
	});


	~particule2_instances.put(self.nodeName.asSymbol, self);
};


// overwrite this method here, and do nothing, since the updates are handled by the trigger method
~particule1.setUpdate = { | self, aziDeg, eleDeg, gainDB, delayMs, lpHz, distance |
};

// overwrite satie4Unity's 'property' handler
~particule2.property =  {| self, key, value |
	// add conditional processing of key value pairs here
	if (self.debugFlag != 0, {  postf("••particule2.setProperty:  processing key vaue pair:  %:%   to process node's environment \n", key, value,  self.nodeName);});

	switch (key.asSymbol,
		\triggerIntervalMs,
		{
			value = value.clip(100, 100000);
			self.triggerIntervalMs = value;
		},
		\cloneCount,     // need to do some conditional processing for this particular key
		{
			value = value.clip(0, 1000);  // safety
			if (self.cloneCount != value,
				{
					self.setCloneCount(value);   // this call updates property as well
			});
		},
		\increment,     // need to do some conditional processing for this particular key
		{
			self.setIncrement(value.asFloat);   // updates property as well
			postf("***********SET INCREMENT: %\n",  value.asFloat);

		},		// else just write key value pair to process instance's environment
		{
			self.put(key.asSymbol, value);
	});

};


// custom methods



// called with args:  // list: force, impactIncidence, aziDeg, eleDeg, gainDB, delayMs, lpHz, hpHz , distance, spread
~particule2.trigger = { arg self, args = #[1,2,3,4,5,6,7,8,9,10] ;
	var thisGroup = self.nodeGroup;
	var seqName, position, incr, size, vel, incidence;
	var aziDeg, eleDeg, gainDB, delayMs, lpHz, hpHz, distance, spread;
	var xzDist, yDist, aziScaler, elevScaler;


	if (self.debugFlag != 0, {  postf("••particule2.trigger: triggering % clones of node: %   argVec: %  \n", self.cloneCount, self.nodeName, args);});

	~particule2_pitchSequences.at(self.pitchSeqSym).at(\pos).postln;


	if ( args.size != 10,
		{
			error("~particule2.trigger:  bad item count, expecing '[ pitch vel incidence]' , received: % args\n",args.size);
		},
		{ // else

				// args.postln;

			seqName = self.pitchSeqSym;
			vel =  args[0].asFloat;
			incidence = args[1].asFloat.abs;   // not using negative values
			aziDeg = args[2].asFloat;     // rad2deg conversion no longer needed
			eleDeg = args[3].asFloat;    // rad2deg conversion no longer needed
			gainDB = args[4].asFloat;
			delayMs = args[5].asFloat;
			lpHz = args[6].asFloat;
			hpHz = args[7].asFloat;
			distance = args[8].asFloat;
			spread = args[9].asFloat;


			// NOTE:  aziScaler and elevScaler are calculated as a function of fistance, and added as args to the synth using a corresponding  MAPPER
			xzDist = distance * eleDeg.degrad.cos;  // get (horizontal) distance of node to listener on XZ plane
			yDist = distance * eleDeg.degrad.sin;  // get (vertical) distance of node to listener projected on Y axis

			xzDist = xzDist.clip(0, 100)*0.01;   // anything over 100 meters away will generate no azimuth offset its clones. Normalize

			yDist = yDist.clip(0, 100)*0.01;   // anything over 100 meters away will generate no azimuth offset its clones. Normalize

			aziScaler = (1 - xzDist)**self.cloudExp;   // increase this exponent to fall off more quickly
			elevScaler = (1 - yDist)**self.cloudExp;   // increase this exponent to fall off more quickly


			// update all clones with these values
			thisGroup.set(\randTrigMaxMs, self.triggerIntervalMs);
			thisGroup.set(\aziDeg, aziDeg, \eleDeg, eleDeg, \gainDB, gainDB,\delayMs, delayMs, \lpHz , lpHz, \hpHz, hpHz, \spread, spread, \cloudAziScale,  aziScaler, \cloudElevScale, elevScaler);


			// assign pitches  for each particle and trigger
			(self.cloneCount).do( { arg item;
			//0.do( { arg item;
				var nodename=(self.nodeName++"_"++item).asSymbol;
				var pitch;

				//var nodename=(self.nodeName++"_"++item).asSymbol;

				// this is where we could calculate the exact position of each clone, with respect to this node
				// but its expensive

				/* instance specific look up not used
				pitch = ~particule2_pitchSequences[self.pitchSeqSym][self.pitchSeqPos];
				self.pitchSeqPos = (self.pitchSeqPos + self.pitchSeqIncr) % self.pitchSeqLen;
				*/

				size = ~particule2_pitchSequences.at(seqName.asSymbol).at(\size);


				if (self.pitchSeqGlobalMode != 0,
					{

						position = ~particule2_pitchSequences.at(seqName.asSymbol).at(\pos);
						incr = ~particule2_pitchSequences.at(seqName.asSymbol).at(\incr);
						pitch =  self.transposition + ~particule2_pitchSequences.at(seqName.asSymbol).at(\pitches)[position];
						~particule2_pitchSequences.at(seqName.asSymbol).put(\pos,  ((position + incr) % size) );
					},
					// else   instance specific read
					{
						position = self.pitchSeqPos;
						incr = self.pitchSeqIncr;
						pitch =  self.transposition + ~particule2_pitchSequences.at(seqName.asSymbol).at(\pitches)[position];

						self.pitchSeqPos = ((position + incr) % size);
				});

				//(self.transposition + ~particule2_pitchSequences.at(seqName.asSymbol).at(\pitches)  ).postln;
				~procMan.satie.satieGroupInstances[ self.nodeGroupName.asSymbol ][ nodename.asSymbol ].set(\note, [ pitch, vel, incidence ] );
				~procMan.satie.satieGroupInstances[ self.nodeGroupName.asSymbol ][ nodename.asSymbol ].set(\t_trig, 1);

			});
	});
};

// custom method
~particule2.readPitches = { arg self, items = #["/tmp"] ;

	var pitchList, seqName, file, csvmidifilePath;

	//postf("readPitches:   arg 0: % \n",  items[0] );

	if ( items.size != 1,
		{
			warn("~particule2.readPitches:  bad item count, expecting one filePath arg, received: % items\n",items.size);
		},
		//else
		{
			csvmidifilePath = items[0].asString;

			if (csvmidifilePath[0] != $/,
				{
					csvmidifilePath = ~thisProjectResourcePath++"/"++csvmidifilePath;
			});

			csvmidifilePath.postln;

			pitchList = List.new();
			seqName = csvmidifilePath.split.last;
			file = File(csvmidifilePath.standardizePath,"rb");

			// process only if pitch sequence has not yet been loaded
			if ( ~particule2_pitchSequences.includesKey(seqName.asSymbol),
				{

					//  file already loaded, just set instance  specific state
					postf("particule2.readPitches:  sequence % already loaded, skipping file load\n", seqName);
					self.pitchSeqSym = seqName.asSymbol;
					self.pitchSeqLen = ~particule2_pitchSequences.at(seqName.asSymbol).at(\size);
					// self.pitchSeqPos = 0;    DONT RESET READ HEAD

					// and reset sequence's global state  BUT DO NOT RESET READ HEAD
					// ~particule2_pitchSequences.at(seqName.asSymbol).put(\pos, 0);
					~particule2_pitchSequences.at(seqName.asSymbol).put(\incr, self.pitchSeqIncr);   // using instance specific state.. may overwrite
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

							~particule2_pitchSequences.removeAt(seqName.asSymbol);   // overwrite previous

							~particule2_pitchSequences.put(seqName.asSymbol, Dictionary.new());
							~particule2_pitchSequences.at(seqName.asSymbol).put(\pitches, pitchList);
							~particule2_pitchSequences.at(seqName.asSymbol).put(\size, pitchList.size);
							~particule2_pitchSequences.at(seqName.asSymbol).put(\pos, 0);
							~particule2_pitchSequences.at(seqName.asSymbol).put(\incr, 1);


							//~particule2_pitchSequences.removeAt(seqName.asSymbol);
							//~particule2_pitchSequences.put(seqName.asSymbol, pitchList);
							//~particule2_pitchSequences.put(seqName.asSymbol,

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
};

// utility function to change pitch increment
~particule2.setIncrement = { | self, value |

	if (self.debugFlag != 0, { postf("particule2.setIncrement:  increment = % \n", value);});

	if (self.pitchSeqGlobalMode != 0,
		{
			~particule2_pitchSequences.at(self.pitchSeqSym).put(\incr, value);
		},
		// else
		{
			self.pitchSeqIncr = value;
	});
};


// Utility function that changes instance's  clone count
~particule2.setCloneCount = { | self, newCount |

		if (self.debugFlag != 0, { postf("••particle2.setCloneCount: coneCount: %   *  voiceCount: % \n", newCount, self.voiceCount);});

		(self.cloneCount ).do( { arg item;
		var nodename=(self.nodeName++"_"++item).asSymbol;
		var synth =  ~procMan.satie.satieGroupInstances[ self.nodeGroupName.asSymbol ][ nodename.asSymbol ];
		~procMan.satie.cleanInstance(nodename, self.nodeGroupName );
		synth.free;    // KLUGE:  to make sure it gets cleaned from the node tree
	});

	self.cloneCount = newCount;

	// generate N  self.cloneCount  synths
	(self.cloneCount ).do( { arg item;
		var nodename=(self.nodeName++"_"++item).asSymbol;
		var synth;

		synth = ~procMan.satie.makeInstance(nodename.asSymbol, self.synth.asSymbol, self.nodeGroupName);
		// synth now created, so we can set its state
		synth.set(\gainDB, -99);
		synth.set(\randTrigMaxMs, self.triggerIntervalMs);
	});
};


/*
testing

~myFile =  "/Users/zack/Dropbox/Unity3D/projects_unity5/balljamDemoSATIE_2015_unity5/Assets/StreamingAssets/midi/pitchSequences/bjGroove.mid.mid.txt";
~particule2.readPitches(~myFile);
~particule2.pitchSeqLen;
~particule2.pitchSeqName;

*/
