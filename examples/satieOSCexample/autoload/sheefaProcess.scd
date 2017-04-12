// USES GLOBAL VARIABLES:   ~satie <required> and  ~thisProjectResourcePath <optional>

// this file defines  a process class, which is ONLY used by source nodes that have that have a URI of type:   "process" , e.g:      uri://process  "sheefa"
// you can define any number of these process clases, each one, corresponding to a particular type of processing  behavoir you define
// any number of instances of a given process class can be created

// About this example
// This process generates N cloned synthes, that differ only  spatialization, pitch, and delay-until-tiggered-time
// The clones are triggered via this message:     /satie/process/setvec  processNodeName 'trigger'  pitch,  unitAmp, unitVel
// There is also a "player" function, that periodically triggers the clones.
// The player function is accessed by this message:      /satie/process/set processNodeName 'player' value
//  The cloneCount can be changed by this message:  /satie/process/property  processNodeName 'cloneCount' value
//  The player function speed can be changed by this message:  /satie/process/property  processNodeName 'triggerIntervalMs'  value


// required:  set up class struct
~sheefa = Environment[
	// required fields
	'nodeName' -> \nil,
	'nodeGroupName' -> \nil,
	'nodeGroup' -> \nil,

	// project specific below

	// connection state register for this project
	'g' -> -10,
	'elevDeg' -> 10,
	'gainDB' -> -99,
	'delayMs' -> 0,
	'lpHz' -> 15000,
	'hpHz' -> 5,
	'dist' -> 10,

	// other stuff
	'synth' -> \zparticle1,    // used for clones
	'cloneCount' -> 20,
	'triggerIntervalMs' -> 500,   // time interval, during which the clones will randomly trigger
	'debugFlag' -> 0,
];

// required: set these variables to the process name, and register process
~processName = \sheefa;
~process = ~sheefa;
~process.know=true;
~satie.makeProcess(~processName, ~process);

// optional custom global variables, that can be referenced by all "instants"  of "sheefa" class
~sheefa_pitchRoot = 60;


// required functions

// required  setup function,  can be extended to suit particular needs of process
~sheefa.setup = { | self, nodeName, nodeGroupName, args |
	var thisGroup = ~satie.satieGroups[nodeGroupName.asSymbol] ;

	// required
	self.nodeName = nodeName;
	self.nodeGroupName = nodeGroupName;
	self.nodeGroup = thisGroup;

	// IF there are args, try to parse them and set corresponding environment key value pairs
	if (  args.size > 1,
		{
			if (  (args.size&1)==1,    // odd length,  bad key value format
				{
					warn("sheefa.setup:  node: %   ignoring args:  expecting key value pair(s)  % \n",  self.nodeName, args);
				},
				// else arg list good to parse
				{
					args.pairsDo({ | key, val |
						self[key.asSymbol] = val;
						postf("••sheefa.setup: setting key value pair:  % : %  \n", key, val);
					});
			});
	});

	// add project-specific code below

	self.cloneCount = self.cloneCount.asInt.clip(0,200);  // safety  - note that type forcing is needed

	if (self.debugFlag != 0, { postf("••sheefa.setup:  node: %  group: %    args % \n",  self.nodeName, self.nodeGroupName, args);});

	if (self.debugFlag != 0, { postf("•• \t generating % synthVoices for group %\n",  self.cloneCount, self.nodeGroupName);});

	// generate N  self.cloneCount  synths
	self.cloneCount.do( { arg item;
		var nodename=(self.nodeName++"_"++item).asSymbol;
		var synth;

		synth = ~satie.makeInstance(nodename.asSymbol, self.synth.asSymbol, self.nodeGroupName);
		// synth now created, so we can set its state
		synth.set(\aziDeg, self.aziDeg, \eleDeg, self.elevDeg, \gainDB, self.gainDB , \delayMs, self.delayMs, \lpHz, self.lpHz, \hpHz, self.hpHz);
		synth.set(\randTrigMaxMs, self.triggerIntervalMs);
	});
};

// required  cleanup function,
~sheefa.cleanup = { | self |

	// add project-specific code below
	if (self.debugFlag != 0, {  postf("••sheefa.cleanup: clearing synths in node: % group \n", self.nodeName);});

	self.routine.stop;

	self.cloneCount.do( { arg item;
		var nodename=(self.nodeName++"_"++item).asSymbol;
		~satie.cleanInstance(nodename.asSymbol, self.nodeGroupName);
	});
};

// end of required class functions


// Optional Override handlers

// Below are optionally defined message handlers that, if defined, will be called by satie4Unity.
// They override satie4Unity's corresponding generic handlers, that apply these messages to the processNodes group (or environment, in the case of the  'property' message
// Satie4Unity provides an override mechanism for the following  messages, which are handled by the corresponding process functions as shown:

//   /satie/process/update   processName   azi ele gdb del lpf dst    -->  handled by process[\update]
//   /satie/process/property processName  key value  -->  handled by process[\property]
//   /satie/process/state      processName  state      -->   hadled by  process[\state]
//   /satie/process/set         processName  key value  -->  handled by process[key]
//   /satie/process/set         processName  key value  -->  handled by process[\set]   (unless process[key] is defined)
//  /satie/process/setvec     processName  key  val1 .... valN      -->   handled by process[key]


// overrides satie4Unity's 'set' handler
// called on the reception of the message:  'set' key value
// NOTE:  if this process defines a handler for a particular key (e.g.  process[key] ), satie4Unity will instead call that particular handler with the value arg. - see  spread handler example  below

~sheefa.set =  {| self, key, value |
	if (self.debugFlag != 0, { postf("••sheefa.set: key %  value % \n", key, value);});
	// add conditional processing of key value pairs here
	// write key value pair to synth
	self.cloneCount.do( { arg item;
		var nodename=(self.nodeName++"_"++item).asSymbol;

		// this is where we can calculate clone-specific parameters
		// value = value *  item;

		~satie.satieGroupInstances[ self.nodeGroupName.asSymbol ][ nodename.asSymbol ].set(key.asSymbol,value);
	});
};

// overrides satie4Unity's property handler
// called on the reception of the message:  'property' key value
// otherwise, satie4Unity  will write the key value to this process's environment

~sheefa.property =  {| self, key, value |
	// add conditional processing of key value pairs here
	if (self.debugFlag != 0, {  postf("••sheefa.setProperty:  processing key vaue pair:  %:%   to process node's environment \n", key, value,  self.nodeName);});

	switch (key.asSymbol,
		\triggerIntervalMs,
		{
			value = value.asFloat.clip(100, 100000);   	// note that type forcing is necessary
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
 		// else just write key value pair to process instance's environment
		{
			self.put(key.asSymbol, value);
	});
};


// overrides satie4Unity's update handler
// called on the reception of the message:  'update' azi ele gain del lp dist
// otherwise satie4unity will send the   'update'  message to the node's group

~sheefa.setUpdate = { | self, aziDeg, eleDeg, gainDB, delayMs, lpHz, dist |
	var 	thisGroup = self.nodeGroup; // ~allSourceNodes[self.nodeName.asSymbol].at(\proxy);
	if (self.debugFlag != 0, {  postf("••sheefa.setUpdate: for process node \n", self.nodeName);});

	// saving the connection state in case its needed
	self.aziDeg = aziDeg;
	self.elevDeg = eleDeg;
	self.gainDB = gainDB;
	self.delayMs = delayMs;
	self.lpHz = lpHz;
	self.hpHz = 0.5;  // to be added
	self.dist = 0.5;  // to be added

	//postf("sheefa.update: called for node: %    azi: %  \n", self.nodeName, aziDeg);

	// updating the connection of all this node's clones (via group message)
	thisGroup.set(\aziDeg, self.aziDeg, \eleDeg, self.elevDeg, \gainDB, self.gainDB , \delayMs, self.delayMs, \lpHz, self.lpHz, \hpHz, self.hpHz);
};

// overrides satie4Unity's state function
// called on the reception of the message:  'state'  value
// otherwise satie4unity will send the  'state' message to the node's group

~sheefa.state =  {| self, value |
	if (self.debugFlag != 0, {  postf("••sheefa.state: setting state of process node %  clones to % \n", self.nodeName, value);});

	self.cloneCount.do( { arg item;
		var nodename=(self.nodeName++"_"++item).asSymbol;

		// this is where we can calculate clone-specific actions before changing state
	});
	self.nodeGroup.run(value);   // change state for all synths in process's group
};


// Custom key-specific message handlers  can be defiend for  'set'  and 'setvec'  OSC messages
//   If defined, satie4unity will call these handlers according to the 'key'  with corresponding arguments as shown:
//   /satie/process/set nodeName key val    -->  hadled by  process[\key]   val
//  /satie/process/setvec  nodeName key  val1 ... valN    -->   -->  hadled by  process[\key]  val1 ... valN
//  for example:

// called when the  'set' message is received with the key:  'spread'
~sheefa.spread = { | self, spreadVal |

	var 	thisGroup = self.nodeGroup;

	if (self.debugFlag != 0, {  postf("••sheefa.spread:  setting spread for each synth in node: % group \n", self.nodeName);});

	// updating the spread param of all this node's clones (via group message)

	thisGroup.set(\spread, spreadVal);
};


// handler that is called when the node's 'setvec' message is received with the key:  'trigger'
~sheefa.trigger = { arg self, items = #[1,2,3] ;
	var thisGroup = self.nodeGroup;
	var gain = self.gainDB;
	var pitch,  vel, incidence;

	if (self.debugFlag != 0, {  postf("••sheefa.trigger: triggering % clones of node: %  \n", self.cloneCount, self.nodeName);});

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
				var synth =  ~satie.satieGroupInstances[ self.nodeGroupName.asSymbol ][ nodename.asSymbol ];
				synth.set(\aziDeg, 360.rand, \eleDeg, 360.rand);
				synth.set(\note, [ pitch, vel, incidence ] );
				synth.set(\t_trig, 1);
			});
	});
};

// this routine
~sheefa.routine = Routine { arg self;
	loop {
		if (self.debugFlag != 0, {   postf("••sheefa.routine triggering %  clones \n",  self.cloneCount ); });
		self.trigger( [(50+30.rand), (0.5+0.5.rand), (0.5+0.5.rand)]);
		( self.triggerIntervalMs * 0.001 ).yield;  // loop time
	}
};

// called by  /satie/process/set nodeName 'player' value
~sheefa.player = { | self, state |
	if (state == 0,
		{
			self.routine.stop;
		},
		// else
		{
			self.routine.reset;
			self.routine.value(self);
			self.routine.play;
	});
};


// Utility function that changes instance's  clone count
~sheefa.setCloneCount = { | self, newCount |

	self.cloneCount.do( { arg item;
		var nodename=(self.nodeName++"_"++item).asSymbol;
		var synth =  ~satie.satieGroupInstances[ self.nodeGroupName.asSymbol ][ nodename.asSymbol ];
		~satie.cleanInstance(nodename, self.nodeGroupName );
		//synth.free;    // KLUGE:  to make sure it gets cleaned from the node tree
	});

	self.cloneCount = newCount;

	// generate N  self.cloneCount  synths
	self.cloneCount.do( { arg item;
		var nodename=(self.nodeName++"_"++item).asSymbol;
		var synth;

		synth = ~satie.makeInstance(nodename.asSymbol, self.synth.asSymbol, self.nodeGroupName);
		// synth now created, so we can set its state
		synth.set(\aziDeg, self.aziDeg, \eleDeg, self.elevDeg, \gainDB, self.gainDB , \delayMs, self.delayMs, \lpHz, self.lpHz, \hpHz, self.hpHz);
		synth.set(\randTrigMaxMs, self.triggerIntervalMs);
	});
};


