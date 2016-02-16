




// this file defines  a process class, which is ONLY used by source nodes that have that have a URI of type:   "process" , e.g:      uri://process  "particule4"
	// you can define any number of these process clases, each one, corresponding to a particular type of processing  behavoir you define

// this class is for preallocated klones with no spatializer updates (except for the one at trigger time)

// required:  set up class struct

	~particule4= Environment[
		// required fields
		'nodeName' -> \nil,
		'nodeGroupName' -> \nil,
		'nodeGroup' -> \nil,


		// project specific
	//'cloneVector' -> [],  // vector to store allocated synths
		'synth' -> \particule1,  // \particle1,
		'cloneCount' -> 0,
	   'cloudExp'-> 2,    // increase this value to make cloud more "narrow"  (narrows more quickly as with distance)
		'triggerIntervalMs' -> 500,   // time interval, during which the clones will randomly trigger
	    'decaySecs' -> 0.5,  // ringtime for synth
		// other state
		'pitchSeqGlobalMode' -> 0,
		'pitchSeqSym' -> \default,
		'pitchSeqLen' -> 1,   // not used
		'pitchSeqIncr' -> 1,   // used, but only to set global sequencer state
		'pitchSeqPos' -> 0,     // not used
	 // playback state
	    'clonePtr' -> 0,    // modulus voice playing pointer
	// timbre state
	     'pitch' -> 55

	];


// set up class instance dictionary

~particule4_instances = Dictionary.new();



	// define any custom "class"  variables, referenced by all "instants"  of "particule4" class
if (~particule4_pitchSequences == nil,
		{
			~particule4_pitchSequences = Dictionary.new();
			~particule4_pitchSequences.put(\default, Dictionary.new());
			~particule4_pitchSequences.at(\default).put(\pitches, [60]);
			~particule4_pitchSequences.at(\default).put(\pos, 0);
			~particule4_pitchSequences.at(\default).put(\incr,1);
			~particule4_pitchSequences.at(\default).put(\size,1);

	});


	// required functions and state

	~particule4.know=true;
	~particule4.property =  {| self, property, value |
		self.put(property.asSymbol, value);
	};

	// register process to environment
	if (~allProcesses == nil, {
		~allProcesses = ();         // environment namespace for project functions
	});

	// if already registered, re-register
	if (  ~allProcesses.includesKey(\particule4) == true,
		{
			'un-registering process: particule4'.postln;
			~allProcesses.removeAt(\particule4);
	});

	'registering process: particule4'.postln;
	~allProcesses.put(\particule4, ~particule4);


	// required


	~particule4.cleanup = { | self |

	var synth;

		// add code here to manage project-specific stuff
		postf("~particule4.clearSynths: clearing synths in node: % group \n", self.nodeName);
	// var nodename=(self.nodeName++"_"++item).asSymbol;
	// ~scbr.cleanInstance(nodename.asSymbol, self.nodeGroupName);
	// });
		~particule4_instances.removeAt(self.nodeName);
	};


// required function but adaptable to project specifics
// generates N synths
~particule4.setup = { | self, nodeName, nodeGroupName, argsString  |
	var argvec = argsString.split($ );
	var thisGroup = ~scbr.satieGroups[nodeGroupName.asSymbol] ;

	self.nodeName = nodeName;
	self.nodeGroupName = nodeGroupName;
	self.nodeGroup = thisGroup;
	//'particule4,setup'.postln;

	// project-specific parsing of args string (coming from setUri OSC message string)
	if ( argvec.size >= 2,
		{

			if ( argvec[0].asString == "cloneCount",
				{
					self.cloneCount = argvec[1].asInt.clip(1, 1000);   // clip to 1000 to avoid meltdown caused by error
					postf(" particule4.setup: node: %   setting up for % kamakazi clones \n", nodeName, self.cloneCount);
				},
				// else bad arg
				{
					error("particule4.setup: unrecognized key, expecting 'cloneCount' ");
			});
	});
	~particule4_instances.put(self.nodeName.asSymbol, self);
};


// end of required class functions

// the functions below are not requied
// however if defined, they will be called by satie4unity when node's "update" message is received
// otherwise satie4unity will send the  "update" message to the node's group

~particule4.updateConnection = { | self, aziDeg, eleDeg, gainDB, delayMs, lpHz, distance |

	// do nothing for this node, since spatialization is done using the trigger method
    };


	// if defined, will be called when node's "spread" message is received
	// otherwise the "spread" message will be applided to the node's group
	~particule4.spread = { | self, spreadVal |

	// do nothing for this node, since spatialization is only done using the trigger method

	};


	// totally custom functions.  Calls to these functions result from OSC events received by satie4unity from Unity, and then applied to these functions,  if they exist

	~particule4.setIncrement = { arg self, items = #[1] ;

		if ( items.size != 1,
			{
				warn("~particule4.setIncrement:  bad item count,  takes one float arg, received: % items\n",items.size);
			},
			//else
			{
					postf("particule4.setIncrement:  increment = % \n", items[0].asFloat);

			   if (self.pitchSeqGlobalMode != 0,
				{
				~particule4_pitchSequences.at(self.pitchSeqSym).put(\incr, items[0].asFloat);
				},
				// else
				{
					self.pitchSeqIncr = items[0].asFloat;
			});
		});
	};


// custom method
// called with args:  // list: force, impactIncidence, aziDeg, eleDeg, gainDB, delayMs, lpHz, hpHz , distance
~particule4.trigger = { arg self, items = #[1,2,3,4,5,6,7,8,9] ;
	var thisGroup = self.nodeGroup;
	var seqName, pitch, position, incr, size, force, incidence;
	var aziDeg, eleDeg, gainDB, delayMs, lpHz, hpHz, distance;
	var xzDist, yDist, aziScaler, elevScaler;

	if ( items.size != 9,
		{
			postf("~particule4.trigger:  bad item count, expecing '[ pitch vel incidence]' , received: % items\n",items.size);
		},
		{ // else

			// kind of stupid ti assert thus value t wat
			// NO GROUP TX  IN THIS CASE:   thisGroup.set(\randTrigMaxMs, self.triggerIntervalMs);
			// kamakazi must be fully parameterized at creation


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
			size = ~particule4_pitchSequences.at(seqName.asSymbol).at(\size);

			xzDist = distance * eleDeg.degrad.cos;  // get (horizontal) distance of node to listener on XZ plane
			yDist = distance * eleDeg.degrad.sin;  // get (vertical) distance of node to listener projected on Y axis

			xzDist = xzDist.clip(0, 100)*0.01;   // anything over 100 meters away will generate no azimuth offset its clones. Normalize

			yDist = yDist.clip(0, 100)*0.01;   // anything over 100 meters away will generate no azimuth offset its clones. Normalize

			aziScaler = (1 - xzDist)**self.cloudExp;   // increase this exponent to fall off more quickly
			elevScaler = (1 - yDist)**self.cloudExp;   // increase this exponent to fall off more quickly


			// assign pitches  for each particle
			self.cloneCount.do( { arg item;
				var nodename=(self.nodeName++"_"++item).asSymbol;
				var synth;


				if (self.pitchSeqGlobalMode != 0,
					{

						position = ~particule4_pitchSequences.at(seqName.asSymbol).at(\pos);
						incr = ~particule4_pitchSequences.at(seqName.asSymbol).at(\incr);
						pitch = ~particule4_pitchSequences.at(seqName.asSymbol).at(\pitches)[position];
						~particule4_pitchSequences.at(seqName.asSymbol).put(\pos,  ((position + incr) % size) );
					},
					// else   instance specific read
					{
						position = self.pitchSeqPos;
						incr = self.pitchSeqIncr;
						pitch = ~particule4_pitchSequences.at(seqName.asSymbol).at(\pitches)[position];
						self.pitchSeqPos = ((position + incr) % size);
				});

				//name, synthDefName, group , synthArgs[]
/*				synth = ~scbr.makeKamikaze(nodename, self.synth.asSymbol, self.nodeGroupName, []);
					synth.set(\aziDeg, aziDeg, \eleDeg, eleDeg, \gainDB, gainDB,\delayMs, delayMs, \lpHz , lpHz, \hpHz, hpHz,
					\decaySecs, self.decaySecs, \pitch, self.pitch, \force, force, \incidence, incidence);   // \t_trig,  1

				"eep".postln;*/


 		synth = ~scbr.makeKamikaze(nodename, self.synth.asSymbol, self.nodeGroupName, [
					\aziDeg, aziDeg, \eleDeg, eleDeg, \gainDB, gainDB,\delayMs, delayMs, \lpHz , lpHz, \hpHz, hpHz,
					\decaySecs, self.decaySecs, \pitch, self.pitch, \force, 1, \incidence, 1, // \t_trig,  1
				]);



/*				TempoClock.default.sched(1,
	{ Synth("zp1", [
            \freqs, {12000.0.linrand+80}.dup(12),
           \amps, {0.05.rrand(2)}.dup(12),
		\rings, {0.01.rrand(0.5)}.dup(12) ] ); nil });*/

			});
	});
};

	// custom method
	~particule4.readPitches = { arg self, items = #["/tmp"] ;

		var pitchList, seqName, file, csvmidifilePath;

		//postf("readPitches:   arg 0: % \n",  items[0] );

		if ( items.size != 1,
			{
				warn("~particule4.readPitches:  bad item count, expecting one filePath arg, received: % items\n",items.size);
			},
			//else
			{
				csvmidifilePath = items[0].asString;

				if (csvmidifilePath[0] != $/,
					{
						csvmidifilePath = ~projectDirectory++"/"++csvmidifilePath;
				});

				csvmidifilePath.postln;

				pitchList = List.new();
				seqName = csvmidifilePath.split.last;
				file = File(csvmidifilePath.standardizePath,"rb");

				// process only if pitch sequence has not yet been loaded
				if ( ~particule4_pitchSequences.includesKey(seqName.asSymbol),
					{

						//  file already loaded, just set instance  specific state
						postf("particule4.readPitches:  sequence % already loaded, skipping file load\n", seqName);
						self.pitchSeqSym = seqName.asSymbol;
						self.pitchSeqLen = ~particule4_pitchSequences.at(seqName.asSymbol).at(\size);
						// self.pitchSeqPos = 0;    DONT RESET READ HEAD

						// and reset sequence's global state  BUT DO NOT RESET READ HEAD
						// ~particule4_pitchSequences.at(seqName.asSymbol).put(\pos, 0);
						~particule4_pitchSequences.at(seqName.asSymbol).put(\incr, self.pitchSeqIncr);   // using instance specific state.. may overwrite


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

								~particule4_pitchSequences.removeAt(seqName.asSymbol);   // overwrite previous

								~particule4_pitchSequences.put(seqName.asSymbol, Dictionary.new());
								~particule4_pitchSequences.at(seqName.asSymbol).put(\pitches, pitchList);
								~particule4_pitchSequences.at(seqName.asSymbol).put(\size, pitchList.size);
								~particule4_pitchSequences.at(seqName.asSymbol).put(\pos, 0);
								~particule4_pitchSequences.at(seqName.asSymbol).put(\incr, 1);


								//~particule4_pitchSequences.removeAt(seqName.asSymbol);
								//~particule4_pitchSequences.put(seqName.asSymbol, pitchList);
								//~particule4_pitchSequences.put(seqName.asSymbol,

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

/*
testing

~myFile =  "/Users/zack/Dropbox/Unity3D/projects_unity5/balljamDemoSATIE_2015_unity5/Assets/StreamingAssets/midi/pitchSequences/bjGroove.mid.mid.txt";
~particule4.readPitches(~myFile);
~particule4.pitchSeqLen;
~particule4.pitchSeqName;

*/
