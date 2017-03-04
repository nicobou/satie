// USES GLOBAL VARIABLE:   ~procMan

// this file defines  a process class, which is ONLY used by source nodes that have that have a URI of type:   "process" , e.g:      uri://process  "sheefa"
// you can define any number of these process clases, each one, corresponding to a particular type of processing  behavoir you define



// required:  set up class struct

~sheefa = Environment[
	// required fields
	'nodeName' -> \nil,
	'nodeGroupName' -> \nil,
	'nodeGroup' -> \nil,

	// project specific

	// connection state register for this project
	'g' -> -10,
	'elevDeg' -> 10,
	'gainDB' -> -99,
	'delayMs' -> 0,
	'lpHz' -> 0.5,
	'hpHz' -> 22040,

	// other stuff
	// this project
	'synth' -> \zparticle1,    // used for clones
	'cloneCount' -> 20,
	'triggerIntervalMs' -> 500,   // time interval, during which the clones will randomly trigger
];

// required: set these variables to the process name;
~processName = \sheefa;
~process = ~sheefa;

// regester this process with satie
~procMan.registerProcessEnv(~processName, ~process);


// define any custom "class"  variables, referenced by all "instants"  of "sheefa" class
~sheefa_pitchRoot = 60;




// required
~process.know=true;

// required functions and state

~sheefa.property =  {| self, property, value |
	self.put(property.asSymbol, value);
};

// frees all clone synths
~sheefa.freeClones = { | self |
	//self.nodeGroup = nodeGroup;
	//thisGroup = self.nodeGroup.group;

	//postf("~sheefa.free:  freeing % synthVoices for group %\n",  self.cloneCount, self.nodeGroupName);

	self.cloneCount.do( { arg item;
		var nodename=(self.nodeName++"_"++item).asSymbol;
		~procMan.satie.cleanInstance(nodename, self.nodeGroupName );
	});
};


// required function,  but modified to suit project needs
// generates N synths
~sheefa.setup = { | self, nodeName, nodeGroupName |
	var thisGroup = ~procMan.satie.satieGroups[nodeGroupName.asSymbol] ;

	// generic
	self.nodeName = nodeName;
	self.nodeGroupName = nodeGroupName;
	self.nodeGroup = thisGroup;


	// project-specific code after here
	postf("~sheefa.setup:  generating % synthVoices for group %\n",  self.cloneCount, self.nodeGroupName);

	// generate N  self.cloneCount  synths
	self.cloneCount.do( { arg item;
		var nodename=(self.nodeName++"_"++item).asSymbol;
		var synth;

		synth = ~procMan.satie.makeInstance(nodename.asSymbol, self.synth.asSymbol, self.nodeGroupName);
		// synth now created, so we can set its state
		synth.set(\gainDB, -99);  // initialise to full attenuatuion
		synth.set(\randTrigMaxMs, self.triggerIntervalMs);
	});
};


~sheefa.cleanup = { | self |

	// add code here to manage project-specific stuff
	postf("~sheefa.clearSynths: clearing synths in node: % group \n", self.nodeName);

	self.cloneCount.do( { arg item;
		var nodename=(self.nodeName++"_"++item).asSymbol;
		~procMan.satie.cleanInstance(nodename.asSymbol, self.nodeGroupName);
	});
};

// end of required class functions

// the functions below are not requied
// however if defined, they will be called by satie4unity, otherwise the messages will get forwarded to the node's group



// if defined, will be called when node's "prop" message is received
// otherwise satie4unity will send the  "prop" message to the node's group
~sheefa.prop =  {| self, property, value |
	self.put(property.asSymbol, value);
};


// If defined, the funciton below will be called when the node's "udate" message is received
// otherwise satie4unity will send the  "update" message to the node's group
~sheefa.updateConnection = { | self, aziDeg, eleDeg, gainDB, delayMs, lpHz |

	var 	thisGroup = self.nodeGroup; // ~allSourceNodes[self.nodeName.asSymbol].at(\proxy);

	// saving the connection state in case its needed
	self.aziDeg = aziDeg;
	self.elevDeg = eleDeg;
	self.gainDB = gainDB;
	self.delayMs = delayMs;
	self.lpHz = lpHz;
	self.hpHz = 0.5;  // to be added

	//postf("sheefa.updateConnection: called for node: %    azi: %  \n", self.nodeName, aziDeg);

	// updating the connection of all this node's clones (via group message)
	thisGroup.set(\aziDeg, self.aziDeg, \eleDeg, self.elevDeg, \gainDB, self.gainDB , \delayMs, self.delayMs, \lpHz, self.lpHz, \hpHz, self.hpHz);
};


// if defined, will be called when node's "spread" message is received
// otherwise the "spread" message will be applided to the node's group
~sheefa.spread = { | self, spreadVal |

	var 	thisGroup = self.nodeGroup;
	// updating the spread param of all this node's clones (via group message)

	thisGroup.set(\spread, spreadVal);
};

// totally custom functions.  Calls to these functions result from OSC events received by satie4unity from Unity, and then applied to these functions,  if they exist
// this message is called via the following osc message:   /satie/process/event processName trigger pitch  vel incidence


~sheefa.trigger = { arg self, items = #[1,2,3] ;
	var thisGroup = self.nodeGroup;
	var gain = self.gainDB;
	var pitch,  vel, incidence;


	if ( items.size != 3,
		{
			postf("~sheefa.trigger:  bad item count, expecing '[ pitch vel incidence]' , received: % items\n",items.size);
		},
		{ // else

			pitch = items[0].asFloat;
			vel =  items[1].asFloat;
			incidence = items[2].asFloat;

			thisGroup.set(\randTrigMaxMs, self.triggerIntervalMs);  // update clones in case value has changed

			// assign pitches  for each particle
			self.cloneCount.do( { arg item;
				var nodename=(self.nodeName++"_"++item).asSymbol;

				// this is where we cn calculate clone-specific parameters
				var clone_pitch = pitch + item;

				~procMan.satie.satieGroupInstances[ self.nodeGroupName.asSymbol ][ nodename.asSymbol ].set(\note, [ pitch, vel, incidence ] );

				~procMan.satie.satieGroupInstances[ self.nodeGroupName.asSymbol ][ nodename.asSymbol ].set(\t_trig, 1);
			});
	});
};


