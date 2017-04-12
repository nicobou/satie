// USES GLOBAL VARIABLES:   ~satie <required> and  ~thisProjectResourcePath <optional>

// this file defines  a process class, which is ONLY used by source nodes that have that have a URI of type:   "process" , e.g:      uri://process  "helloWorld"
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
~helloWorld = Environment[
	// required fields
	'nodeName' -> \nil,
	'nodeGroupName' -> \nil,
	'nodeGroup' -> \nil,

	// project specific below

	'debugFlag' -> 1,
];

// required: set these variables to the process name, and register process
~processName = \helloWorld;
~process = ~helloWorld;
~process.know=true;
~satie.makeProcess(~processName, ~process);


// required functions
// required  setup function,  can be extended to suit particular needs of process
~helloWorld.setup = { | self, nodeName, nodeGroupName, args |
	var thisGroup = ~satie.satieGroups[nodeGroupName.asSymbol] ;

	// required
	self.nodeName = nodeName;
	self.nodeGroupName = nodeGroupName;
	self.nodeGroup = thisGroup;

	x = args.copy;

	// IF there are args, try to parse them and set corresponding environment key value pairs
	if (args != nil,
		{
			if (  args.size > 1,
				{
					if (  (args.size&1)==1,    // odd length,  bad key value format
						{
							warn("helloWorld.setup:  node: %   ignoring args:  expecting key value pair(s)  % \n",  self.nodeName, args);
						},
						// else arg list good to parse
						{
							args.pairsDo({ | key, val |
								self[key.asSymbol] = val;
							});
					});
			});
	});

	// add project-specific code below

	if (self.debugFlag != 0, {postf("••helloWorld.setup:  node: %  group: %    args % \n", self.nodeName, self.nodeGroupName, args);});
};

// required  cleanup function,
~helloWorld.cleanup = { | self |

	// add project-specific code below
	if (self.debugFlag != 0, {  postf("••helloWorld.cleanup: clearing synths in node: % group \n", self.nodeName);});
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

~helloWorld.set =  {| self, key, value |
	if (self.debugFlag != 0, { postf("••helloWorld.set: key %  value % \n", key, value);});
};

// overrides satie4Unity's property handler
// called on the reception of the message:  'property' key value
// otherwise, satie4Unity  will write the key value to this process's environment

~helloWorld.property =  {| self, key, value |
	if (self.debugFlag != 0, {  postf("••helloWorld.setProperty:  setting key vaue pair:  %:%   to process node's environment \n", key, value,  self.nodeName);});

	// project specific code below
	self.put(key.asSymbol, value);
};


// overrides satie4Unity's update handler
// called on the reception of the message:  'update' azi ele gain del lp dist
// otherwise satie4unity will send the   'update'  message to the node's group

~helloWorld.setUpdate = { | self, aziDeg, eleDeg, gainDB, delayMs, lpHz, dist |
	if (self.debugFlag != 0, {  postf("••helloWorld.setUpdate: for process node \n", self.nodeName);});
};


// overrides satie4Unity's state function
// called on the reception of the message:  'state'  value
// otherwise satie4unity will send the  'state' message to the node's group

~helloWorld.state =  {| self, value |
	if (self.debugFlag != 0, {  postf("••helloWorld.state: setting state of process node %   to % \n", self.nodeName, value);});
};




