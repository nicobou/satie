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

];

// required: set these variables to the process name;
~processName = \particule1;
~process = ~particule1;
~process.know=true;

// regester this process with satie
~procMan.registerProcessEnv(~processName, ~process);


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

~particule1.cleanup = { | self |

	// add code here to manage project-specific stuff
	postf("~particule1.clearSynths: clearing synths in node: % group \n", self.nodeName);

	self.cloneCount.do( { arg item;
		var nodename=(self.nodeName++"_"++item).asSymbol;
		~procMan.satie.cleanInstance(nodename.asSymbol, self.nodeGroupName);
	});
	~particule1_instances.removeAt(self.nodeName);

};


// required function but adaptable to project specifics
// generates N synths
~particule1.setup = { | self, nodeName, nodeGroupName, argsList  |
	var thisGroup = ~procMan.satie.satieGroups[nodeGroupName.asSymbol] ;

	self.nodeName = nodeName;
	self.nodeGroupName = nodeGroupName;
	self.nodeGroup = thisGroup;
	//'particule1,setup'.postln;

	// project-specific parsing of args string (coming from setUri OSC message string)
	if ( argsList.size >= 2,
		{
			//~sheefaVec = argvec;

			//postf(" particule1.setup: node: %    args:   %    size:  %\n", nodeName, argsList, argsList.size);
			if ( argsList[0].asString == "cloneCount",
				{
					self.cloneCount = argsList[1].asInt.clip(1, 1000);   // clip to 1000 to avoid meltdown caused by error
					postf(" particule1.setup: node: %   setting up for % kamakazi clones \n", nodeName, self.cloneCount);
				},
				// else bad arg
				{
					error("particule1.setup: unrecognized key, expecting 'cloneCount' ");
			});
	});

	// now generate   self.cloneCount  synths in advance
	//  when the state problem is fixed, this can be done in the context of trigger, and synths can destroy  themselves after sounding
	self.cloneCount.do( { arg item;
		var nodename=(self.nodeName++"_"++item).asSymbol;
		var synth;

		synth = ~procMan.satie.makeInstance(nodename.asSymbol, self.synth.asSymbol, self.nodeGroupName);
		synth.set(\gainDB, -99);  // instantiate full attenuated
	});
	postf("~particule1.setup:  generating % synthVoices for group %\n",  self.cloneCount, self.nodeGroupName);

	~particule1_instances.put(self.nodeName.asSymbol, self);

};


// end of required class functions

// the functions below are not requied, since satie4Unity, by default, forwards most received messages to the process's synth group.
// However if a given function IS defined,  that function will be called when satie4Unity receives a corresponding message


// for example, on the reception of the message:  "set" key value
// if the  process[key] is defined as a function,  that particular function will be called with the arguments:  key, value

~particule1.set =  {| self, property, value |
	// add conditional processing of key value pairs here
	// write key value pair to synth

	postf("~particule1.set:  node:%  key:%  val:%\n", self.nodeName, property, value);
			self.cloneCount.do( { arg item;
				var nodename=(self.nodeName++"_"++item).asSymbol;

				// this is where we can calculate clone-specific parameters
				// e.g:  value = value *  item;

				~procMan.satie.satieGroupInstances[ self.nodeGroupName.asSymbol ][ nodename.asSymbol ].set(property.asSymbol,value);
	});
};




// if the function below is defined,  satie4Unity will call it when redeiving the message:  property key value,  passing the key and value args
// otherwise, satie4Unity  will write the key value to this process's environment

~particule1.setProperty =  {| self, property, value |
	// add conditional processing of key value pairs here
	// write key value pair to process instance's environment
	self.put(property.asSymbol, value);
};




// if defined, will be called when node's "update" message is received
// otherwise satie4unity will send the  "update" message to the node's group
~particule1.updateConnection = { | self, aziDeg, eleDeg, gainDB, delayMs, lpHz, distance |

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



// The following functions can be defined to handle setting the synthDef's Keyword Pairs via the "set" message
// if defined,  "spread" will be called when node's "spread" message is received
// otherwise the "spread" message will be applided to the node's group
~particule1.spread = { | self, key, value |

	var 	thisGroup = self.nodeGroup;
	// updating the spread param of all this node's clones (via group message)
	postf("~particule1.spread:  node:%  key:%  val:%\n", self.nodeName, key, value);

	thisGroup.set(\spread, value);
};


// totally custom functions.  Calls to these functions result from OSC events received by satie4unity from Unity, and then applied to these functions,  if they exist

~particule1.setIncrement = { arg self, items = #[1] ;

	if ( items.size != 1,
		{
			warn("~particule1.setIncrement:  bad item count,  takes one float arg, received: % items\n",items.size);
		},
		//else
		{
			postf("particule1.setIncrement:  increment = % \n", items[0].asFloat);

			if (self.pitchSeqGlobalMode != 0,
				{
					~particule1_pitchSequences.at(self.pitchSeqSym).put(\incr, items[0].asFloat);
				},
				// else
				{
					self.pitchSeqIncr = items[0].asFloat;
			});
	});
};


// custom method
~particule1.trigger = { arg self, items = #[1,2,3] ;
	var thisGroup = self.nodeGroup;
	var gain = self.gainDB;
	var seqName, pitch, position, incr, size, vel, incidence;

	if ( items.size != 3,
		{
			postf("~particule1.trigger:  bad item count, expecing '[ pitch vel incidence]' , received: % items\n",items.size);
		},
		{ // else

			seqName = self.pitchSeqSym;
			vel =  items[1].asFloat;

			// find out why incidence fucks the dog
			// incidence = 1; items[2].asFloat;

			incidence = items[2].asFloat.abs;   // not using negative values

			//("incidence"++incidence).postln;

			// update all nodes in group

			// thisGroup.set(\gainDB, gain);  not necessary, since this is handled in the update connection

			thisGroup.set(\randTrigMaxMs, self.triggerIntervalMs);

			// assign pitches  for each particle
			self.cloneCount.do( { arg item;
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

			// calculate azimuths for each particle
			// finally  update and trigger all cloned synths (particles)
			/*				thisGroup.set(\gainDB, gain);
			thisGroup.set(\randTrigMaxMs, self.triggerIntervalMs);*/
			//thisGroup.set(\t_trig, 1);
			//postf("~particule1.trigger: triggering synths in node: % group \n",self.nodeName);
			//~particule1_pitchSequences.at(seqName.asSymbol).at(\pos).postln;
	});
};

// custom method
~particule1.readPitches = { arg self, items = #["/tmp"] ;

	var pitchList, seqName, file, csvmidifilePath;

	//postf("readPitches:   arg 0: % \n",  items[0] );

	if ( items.size != 1,
		{
			warn("~particule1.readPitches:  bad item count, expecting one filePath arg, received: % items\n",items.size);
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
			if ( ~particule1_pitchSequences.includesKey(seqName.asSymbol),
				{

					//  file already loaded, just set instance  specific state
					postf("particule1.readPitches:  sequence % already loaded, skipping file load\n", seqName);
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
							postf("% pitches read from file %\n", pitchList.size,  csvmidifilePath);
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
};

/*
testing

~myFile =  "/Users/zack/Dropbox/Unity3D/projects_unity5/balljamDemoSATIE_2015_unity5/Assets/StreamingAssets/midi/pitchSequences/bjGroove.mid.mid.txt";
~particule1.readPitches(~myFile);
~particule1.pitchSeqLen;
~particule1.pitchSeqName;

*/
