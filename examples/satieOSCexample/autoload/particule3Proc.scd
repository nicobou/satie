// USES GLOBAL VARIABLES:   ~procMan and  ~thisProjectResourcePath

// this file defines  a process class, which is ONLY used by source nodes that have that have a URI of type:   "process" , e.g:      uri://process  "particule3"
// you can define any number of these process clases, each one, corresponding to a particular type of processing  behavoir you define

// this class is for KAMAKAZI synths,  klones.   Thus, there are  is no spatializer updates (except for the one at trigger time) once the synth has been created
//  FOR USE WITH SYNTHDEFS that generate delayed random offsets for clones

// required:  set up class struct

~particule3= Environment[
	// required fields
	'nodeName' -> \nil,
	'nodeGroupName' -> \nil,
	'nodeGroup' -> \nil,


	// project specific
	//'cloneVector' -> [],  // vector to store allocated synths
	'debugFlag' -> 0,
	'synth' -> \zkarpluck2P,  // \zparticle2P,
	'cloneCount' -> 0,
	'cloudRadius' -> 5, // NOT IMPLEMENTED
	'cloudExp'-> 2,    // increase this value to make cloud more "narrow"  (narrows more quickly as with distance)
	'triggerIntervalMs' -> 500,   // time interval, during which the clones will randomly trigger
	// other state
	'pitchSeqGlobalMode' -> 0,
	'pitchSeqSym' -> \default,
	'pitchSeqLen' -> 1,   // not used
	'pitchSeqIncr' -> 1,   // used, but only to set global sequencer state
	'pitchSeqPos' -> 0,     // not used
	// playback state
	'polyCounter' -> 0,  // polyphony thinning register
	'debug_thinnerState' -> 0,  // polyphony thinning register
	'clonePtr' -> 0,    // modulus voice playing pointer
	'transposition' -> 0,
	'synthCountMax' ->  150,    //to be safe,  this value should be half of the number that breaks the server
	'synthCountLimitThresh' ->  0.9,   // 90 %  of maxium -  the factor when limiting of  synth triggering (instance generation) begins. A variable threshold is used to thin out triggers (see below)
	'debugFlag' -> 0 ;

];

// required: set these variables to the process name;
~processName = \particule3;
~process = ~particule3;
~process.know=true;
~procMan.registerProcessEnv(~processName, ~process); // regester this process with satie


// set up class instance dictionary

~particule3_instances = Dictionary.new();

// define any custom "class"  variables, referenced by all "instants"  of "particule3" class
if (~particule3_pitchSequences == nil,
	{
		~particule3_pitchSequences = Dictionary.new();
		~particule3_pitchSequences.put(\default, Dictionary.new());
		~particule3_pitchSequences.at(\default).put(\pitches, [60]);
		~particule3_pitchSequences.at(\default).put(\pos, 0);
		~particule3_pitchSequences.at(\default).put(\incr,1);
		~particule3_pitchSequences.at(\default).put(\size,1);

});

// required functions

// required function but adaptable to project specifics
// generates N synths
~particule3.setup = { | self, nodeName, nodeGroupName, argsList  |
	var thisGroup = ~procMan.satie.satieGroups[nodeGroupName.asSymbol] ;

	self.nodeName = nodeName;
	self.nodeGroupName = nodeGroupName;
	self.nodeGroup = thisGroup;
	//'particule3,setup'.postln;

	// IF there are args, try to parse them and set corresponding environment key value pairs
	if (  argsList.size > 1,
		{
			if (  (argsList.size&1)==1,    // odd length,  bad key value format
				{
					warn("particule3.setup:  node: %   ignoring args:  expecting key value pair(s)  % \n",  self.nodeName, argsList);
				},
				// else arg list good to parse
				{
					argsList.pairsDo({ | key, val |
						self[key.asSymbol] = val;
						if (self.debugFlag != 0, { postf("••particule3.setup: setting key value pair:  % : %  \n", key, val); });
					});
			});
	});

		postf("••particule3.setup:   self.cloneCount: %  \n", self.cloneCount );

	self.cloneCount  = self.cloneCount.asInt.clip(0, 1000);



	self[\synthParams] =  Dictionary.new();  // set up state register for synthfef properties

	~particule3_instances.put(self.nodeName.asSymbol, self);
};

~particule3.cleanup = { | self |

	var synth;

	// add code here to manage project-specific stuff
	postf("~particule3.clearSynths: clearing synths in node: % group \n", self.nodeName);
	// var nodename=(self.nodeName++"_"++item).asSymbol;
	// ~procMan.satie.cleanInstance(nodename.asSymbol, self.nodeGroupName);
	// });
	~particule3_instances.removeAt(self.nodeName);
};




// end of required class functions

// overrides satie4Unity's 'state' message handler
~particule3.state =  {| self, value |

	// kamikazes only ,  do nothing here

};

// this is defined so the 'update' message will not be applied to the processes' group by satie4Unity
~particule3.setUpdate = { | self, aziDeg, eleDeg, gainDB, delayMs, lpHz, distance |

	// kamikazes only.  do nothing for this node, since spatialization is done using the trigger method
};

// this is defined so the 'set processName spread' message will not be applied to the processes' group by satie4Unity
~particule3.spread = { | self, spreadVal |

	//  kamikazes only. do nothing for this node, since spatialization is only done using the trigger method
};


// overrides satie4Unity's 'set' message handler
~particule3.set =  {| self, key, value |
	if (self.debugFlag != 0, { postf("••particle3.set: key %  value % \n", key, value);});

	self[\synthParams].put(key.asSymbol, value);

};


~particule3.property =  {| self, key, value |
	// add conditional processing of key value pairs here
	if (self.debugFlag != 0, {  postf("••particule3.setProperty:  processing key vaue pair:  %:%   to process node's environment \n", key, value,  self.nodeName);});

	switch (key.asSymbol,
		\cloneCount,     // need to do some conditional processing for this particular key
		{
			self.cloneCount = value.asInt.clip(0, 1000);  // safety
		},
		\increment,     // need to do some conditional processing for this particular key
		{
			self.setIncrement(value.asFloat);   // updates property as well

		},		// else just write key value pair to process instance's environment
		{
			self.put(key.asSymbol, value);
	});

};


// custom method
// called with args:  // list: force, impactIncidence, aziDeg, eleDeg, gainDB, delayMs, lpHz, hpHz , distance, spread
~particule3.trigger = { arg self, items = #[1,2,3,4,5,6,7,8,9,10] ;
	var thisGroup = self.nodeGroup;
	var seqName, pitch, position, incr, size, force, incidence;
	var aziDeg, eleDeg, gainDB, delayMs, lpHz, hpHz, distance, spread;
	var xzDist, yDist, aziScaler, elevScaler;


	if ( items.size != 10,
		{
			postf("~particule3.trigger:  bad item count, expecing '[ pitch force incidence]' , received: % items\n",items.size);
		},
		{ // else

			var thinner = 999999;  // used for polyphony thinnning.  Initialized to no-thinning value;
			var params;
			var synthParams;

			// kind of stupid ti assert thus value t wat
			// NO GROUP TX  IN THIS CASE:   thisGroup.set(\randTrigMaxMs, self.triggerIntervalMs);
			// kamakazi must be fully parameterized at creation

			// items.postln;

			seqName = self.pitchSeqSym;
			force =  items[0].asFloat;
			incidence = items[1].asFloat.abs;   // not using negative values
			aziDeg = items[2].asFloat.raddeg;
			eleDeg = items[3].asFloat.raddeg;
			gainDB = items[4].asFloat;
			delayMs = items[5].asFloat;
			lpHz = items[6].asFloat;
			hpHz = items[7].asFloat;
			distance = items[8].asFloat;
			spread = items[9];

			// particle generation limiting, based on current server load
			// note:  this seems to work best when configured for fewer clones  (like 2)
			if (s.numSynths > (self.synthCountMax * self.synthCountLimitThresh),
				{
					var overThreshRange = self.synthCountMax * self.synthCountLimitThresh;  // amount of synths between threshold and syntchCountMax limit
					var overThresCount = s.numSynths - overThreshRange;   // syntchCountMax - 250 * .8
					var muteFactor =  (overThresCount  / overThreshRange).clip(0,1);

					// "THRESHOLD \n".postln;
					// NOTE:  11 is a good all around value to use, based on emperical observations
					thinner = (11 *  (1 - muteFactor )).asInt;    // when just over threshold, starts skipping 1 synth note in 10 (1/10),   midway:  1/5,   and at maximum:  1/1

					/*  not used
					if (force < (muteFactor * 0.3),
					{
					muteFlag = 1;
					postf("MUTING:  FORCE UNDER = % \n", muteFactor * 0.3);
					});

					// not used
					if (gainDB < ( -60 * (1 - muteFactor)),
					{
					muteFlag = 1;
					postf("MUTING:  DB UNDER = % \n", -60 * (1 - muteFactor));
					});*/
				},
				// else
				{
					self.polyCounter = 1;  // reset poly counter

					if ( self.debugFlag != 0 ,
						{
							if  ( self.debug_thinnerState != thinner,
								{
									self.debug_thinnerState = thinner;
									postf("% process: no skipping \n",  self.nodeName);
							});
					});
			});



			size = ~particule3_pitchSequences.at(seqName.asSymbol).at(\size);

			xzDist = distance * eleDeg.degrad.cos;  // get (horizontal) distance of node to listener on XZ plane
			yDist = distance * eleDeg.degrad.sin;  // get (vertical) distance of node to listener projected on Y axis

			xzDist = xzDist.clip(0, 100)*0.01;   // anything over 100 meters away will generate no azimuth offset its clones. Normalize

			yDist = yDist.clip(0, 100)*0.01;   // anything over 100 meters away will generate no azimuth offset its clones. Normalize

			aziScaler = (1 - xzDist)**self.cloudExp;   // increase this exponent to fall off more quickly
			elevScaler = (1 - yDist)**self.cloudExp;   // increase this exponent to fall off more quickly

			params = [
				\randTrigMaxMs, self.triggerIntervalMs, \aziDeg, aziDeg, \eleDeg, eleDeg, \gainDB, gainDB,
				\delayMs, delayMs, \lpHz , lpHz, \hpHz, hpHz, \cloudAziScale,  aziScaler, \cloudElevScale, elevScaler, \spread, spread
			];

			if ( self[\synthParams] != nil, { synthParams = params++ self[\synthParams].getPairs;}); // combine param arrays

			// assign pitches  for each particle
			self.cloneCount.do( { arg item;
				var nodename=(self.nodeName++"_"++item).asSymbol;
				var synth, skipFlag;

				skipFlag = self.polyCounter.mod(thinner);

				if (  (skipFlag == 0) &&  ( self.debugFlag != 0) ,
					{
						if  ( self.debug_thinnerState != thinner,
							{
								self.debug_thinnerState = thinner;
								postf("% process: skiping 1 / % ,  polyCount: % \n",  self.nodeName, thinner, self.polyCounter);
						});
				});

				// postf("polyCounter: % , mod: %", self.polyCounter, thinner);

				if (skipFlag != 0,    // controls synth spawning density  by skipping:  from  1/10  (1 note out of 10)   to  4/5   to 1 / 1, when the system is loaded
					{
						var cloneParams;

						if (self.pitchSeqGlobalMode != 0,
							{

								position = ~particule3_pitchSequences.at(seqName.asSymbol).at(\pos);
								incr = ~particule3_pitchSequences.at(seqName.asSymbol).at(\incr);
								pitch = ~particule3_pitchSequences.at(seqName.asSymbol).at(\pitches)[position];
								~particule3_pitchSequences.at(seqName.asSymbol).put(\pos,  ((position + incr) % size) );
							},
							// else   instance specific read
							{
								position = self.pitchSeqPos;
								incr = self.pitchSeqIncr;
								pitch = ~particule3_pitchSequences.at(seqName.asSymbol).at(\pitches)[position];
								self.pitchSeqPos = ((position + incr) % size);
						});

						cloneParams = synthParams++ [ \note, [ pitch+self.transposition, force, incidence ], \t_trig, 1 ];

						//[ \note, [ pitch+self.transposition, force, incidence ]].postln;

						synth = ~procMan.satie.makeKamikaze(nodename, self.synth.asSymbol, self.nodeGroupName, cloneParams);
						// synth.set(\note, [ pitch+self.transposition, force, incidence ], \t_trig, 1);
				});
				self.polyCounter = self.polyCounter + 1;
			});

	});
};

// custom method
~particule3.readPitches = { arg self, items = #["/tmp"] ;

	var pitchList, seqName, file, csvmidifilePath;

	//postf("readPitches:   arg 0: % \n",  items[0] );

	if ( items.size != 1,
		{
			warn("~particule3.readPitches:  bad item count, expecting one filePath arg, received: % items\n",items.size);
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
			if ( ~particule3_pitchSequences.includesKey(seqName.asSymbol),
				{

					//  file already loaded, just set instance  specific state
					postf("particule3.readPitches:  sequence % already loaded, skipping file load\n", seqName);
					self.pitchSeqSym = seqName.asSymbol;
					self.pitchSeqLen = ~particule3_pitchSequences.at(seqName.asSymbol).at(\size);
					// self.pitchSeqPos = 0;    DONT RESET READ HEAD

					// and reset sequence's global state  BUT DO NOT RESET READ HEAD
					// ~particule3_pitchSequences.at(seqName.asSymbol).put(\pos, 0);
					~particule3_pitchSequences.at(seqName.asSymbol).put(\incr, self.pitchSeqIncr);   // using instance specific state.. may overwrite


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
							postf("% pitches read from file %\n", pitchList.size,  csvmidifilePath);
							// add sequence to dictionary

							~particule3_pitchSequences.removeAt(seqName.asSymbol);   // overwrite previous

							~particule3_pitchSequences.put(seqName.asSymbol, Dictionary.new());
							~particule3_pitchSequences.at(seqName.asSymbol).put(\pitches, pitchList);
							~particule3_pitchSequences.at(seqName.asSymbol).put(\size, pitchList.size);
							~particule3_pitchSequences.at(seqName.asSymbol).put(\pos, 0);
							~particule3_pitchSequences.at(seqName.asSymbol).put(\incr, 1);


							//~particule3_pitchSequences.removeAt(seqName.asSymbol);
							//~particule3_pitchSequences.put(seqName.asSymbol, pitchList);
							//~particule3_pitchSequences.put(seqName.asSymbol,

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
~particule3.setIncrement = { | self, value |

	if (self.debugFlag != 0, { postf("particule3.setIncrement:  increment = % \n", value);});

	if (self.pitchSeqGlobalMode != 0,
		{
			~particule3_pitchSequences.at(self.pitchSeqSym).put(\incr, value);
		},
		// else
		{
			self.pitchSeqIncr = value;
	});
};




/*
testing

~myFile =  "/Users/zack/Dropbox/Unity3D/projects_unity5/balljamDemoSATIE_2015_unity5/Assets/StreamingAssets/midi/pitchSequences/bjGroove.mid.mid.txt";
~particule3.readPitches(~myFile);
~particule3.pitchSeqLen;
~particule3.pitchSeqName;

*/
