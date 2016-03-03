




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
	'clonePool' -> 0,   // will be = to cloneCount * 10
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
	'clonePtr' -> 0,    // modulus voice playing pointer
];


// required: set these variables to the process name;
~processName = \particule2;
~process = ~particule2;
~process.know=true;

if (~satie4unity == nil, {
	error(~processName ++ ": ~satie4unity protocol undefined, can't register this process");
}, // else
{
	// if already registered, re-register
	if (  ~satie4unity.allProcesses.includesKey(~processName) == true,
		{
			inform("un-registering process: "++~processName);
			~satie4unity.allProcesses.removeAt(~processName);
	});

	inform("registering process: "++~processName);
	~satie4unity.allProcesses.put(~processName, ~process);
});



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
	self.clonePool.do( { arg item;
		var nodename=(self.nodeName++"_"++item).asSymbol;
		~scbr.cleanInstance(nodename.asSymbol, self.nodeGroupName);
	});
	~particule2_instances.removeAt(self.nodeName);
};


// required function but adaptable to project specifics
// generates N synths
~particule2.setup = { | self, nodeName, nodeGroupName, argsList  |
	var thisGroup = ~scbr.satieGroups[nodeGroupName.asSymbol] ;

	self.nodeName = nodeName;
	self.nodeGroupName = nodeGroupName;
	self.nodeGroup = thisGroup;
	//'particule2,setup'.postln;

	// project-specific parsing of args string (coming from setUri OSC message string)
	if ( argsList.size >= 2,
		{
			//~sheefaVec = argvec;

			//postf(" particule2.setup: node: %    args:   %    size:  %\n", nodeName, argsList, argsList.size);
			if ( argsList[0].asString == "cloneCount",
				{
					self.cloneCount = argsList[1].asInt.clip(1, 1000);   // clip to 1000 to avoid meltdown caused by error
					postf(" particule2.setup: node: %   setting up for % kamakazi clones \n", nodeName, self.cloneCount);
				},
				// else bad arg
				{
					error("particule2.setup: unrecognized key, expecting 'cloneCount' ");
			});
	});

	self.clonePool = self.cloneCount * 20;

	self.cloneVector =  Array.new(self.clonePool);
	self.cloneVector.postln;

	// now generate   self.cloneCount  synths in advance
	//  when the state problem is fixed, this can be done in the context of trigger, and synths can destroy  themselves after sounding
	self.clonePool.do( { arg item;
		var nodename=(self.nodeName++"_"++item).asSymbol;
		var synth;

		synth = ~scbr.makeInstance(nodename.asSymbol, self.synth.asSymbol, self.nodeGroupName);
		self.cloneVector.add(synth);
		synth.set(\gainDB, -99);  // instantiate full attenuated
	});
	postf("~particule2.setup:  generating % synthVoice clones for group %\n",  self.clonePool, self.nodeGroupName);

	~particule2_instances.put(self.nodeName.asSymbol, self);
};


// end of required class functions


// the functions below are not requied
// however if defined, they will be called by satie4unity


// if defined, will be called when node's "prop" message is received
// otherwise satie4unity will send the  "prop" message to the node's group
~particule2.prop =  {| self, property, value |
	self.put(property.asSymbol, value);
};



// if defined, will be called when node's "update" message is received
// otherwise satie4unity will send the  "update" message to the node's group
~particule2.updateConnection = { | self, aziDeg, eleDeg, gainDB, delayMs, lpHz, distance |

	// do nothing for this node, since spatialization is done using the trigger method
};


// if defined, will be called when node's "spread" message is received
// otherwise the "spread" message will be applided to the node's group
~particule2.spread = { | self, spreadVal |

	// do nothing for this node, since spatialization is only done using the trigger method

};


// totally custom functions.  Calls to these functions result from OSC events received by satie4unity from Unity, and then applied to these functions,  if they exist

~particule2.setIncrement = { arg self, items = #[1] ;

	if ( items.size != 1,
		{
			warn("~particule2.setIncrement:  bad item count,  takes one float arg, received: % items\n",items.size);
		},
		//else
		{
			postf("particule2.setIncrement:  increment = % \n", items[0].asFloat);

			if (self.pitchSeqGlobalMode != 0,
				{
					~particule2_pitchSequences.at(self.pitchSeqSym).put(\incr, items[0].asFloat);
				},
				// else
				{
					self.pitchSeqIncr = items[0].asFloat;
			});
	});
};


// custom method
// called with args:  // list: force, impactIncidence, aziDeg, eleDeg, gainDB, delayMs, lpHz, hpHz , distance
~particule2.trigger = { arg self, items = #[1,2,3,4,5,6,7,8,9] ;
	var thisGroup = self.nodeGroup;
	var seqName, pitch, position, incr, size, vel, incidence;
	var aziDeg, eleDeg, gainDB, delayMs, lpHz, hpHz, distance;
	var xzDist, yDist, aziScaler, elevScaler;




	if ( items.size != 9,
		{
			postf("~particule2.trigger:  bad item count, expecing '[ pitch vel incidence]' , received: % items\n",items.size);
		},
		{ // else

			// kind of stupid ti assert thus value t wat
			thisGroup.set(\randTrigMaxMs, self.triggerIntervalMs);

			// items.postln;

			seqName = self.pitchSeqSym;
			vel =  items[0].asFloat;
			incidence = items[1].asFloat.abs;   // not using negative values
			aziDeg = items[2].asFloat.raddeg;
			eleDeg = items[3].asFloat.raddeg;
			gainDB = items[4].asFloat;
			delayMs = items[5].asFloat;
			lpHz = items[6].asFloat;
			hpHz = items[7].asFloat;
			distance = items[8].asFloat;

			xzDist = distance * eleDeg.degrad.cos;  // get (horizontal) distance of node to listener on XZ plane
			yDist = distance * eleDeg.degrad.sin;  // get (vertical) distance of node to listener projected on Y axis

			xzDist = xzDist.clip(0, 100)*0.01;   // anything over 100 meters away will generate no azimuth offset its clones. Normalize

			yDist = yDist.clip(0, 100)*0.01;   // anything over 100 meters away will generate no azimuth offset its clones. Normalize

			aziScaler = (1 - xzDist)**self.cloudExp;   // increase this exponent to fall off more quickly
			elevScaler = (1 - yDist)**self.cloudExp;   // increase this exponent to fall off more quickly

			//[incidence, vel].postln;

			// assign pitches  for each particle
			self.cloneCount.do( { arg item;
				var synth;

				synth = self.cloneVector[self.clonePtr];
				self.clonePtr = (self.clonePtr + 1).mod(self.clonePool);

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
						pitch = ~particule2_pitchSequences.at(seqName.asSymbol).at(\pitches)[position];
						~particule2_pitchSequences.at(seqName.asSymbol).put(\pos,  ((position + incr) % size) );
					},
					// else   instance specific read
					{
						position = self.pitchSeqPos;
						incr = self.pitchSeqIncr;
						pitch = ~particule2_pitchSequences.at(seqName.asSymbol).at(\pitches)[position];
						self.pitchSeqPos = ((position + incr) % size);
				});

				synth.set(\aziDeg, aziDeg, \eleDeg, eleDeg, \gainDB, gainDB,\delayMs, delayMs, \lpHz , lpHz, \hpHz, hpHz, \cloudAziScale,  aziScaler, \cloudElevScale, elevScaler);
				synth.set(\note, [ pitch, vel, incidence ] );
				synth.set(\t_trig, 1);
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
					csvmidifilePath = ~satie4unity.projectDirectory++"/"++csvmidifilePath;
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
							postf("% pitches read from file %\n", pitchList.size,  csvmidifilePath);
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

/*
testing

~myFile =  "/Users/zack/Dropbox/Unity3D/projects_unity5/balljamDemoSATIE_2015_unity5/Assets/StreamingAssets/midi/pitchSequences/bjGroove.mid.mid.txt";
~particule2.readPitches(~myFile);
~particule2.pitchSeqLen;
~particule2.pitchSeqName;

*/
