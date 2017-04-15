// USES GLOBAL VARIABLES:   ~satie <required> and  ~thisProjectResourcePath <optional>

// this file defines  a process class, which is ONLY used by source nodes that have that have a URI of type:   "process" , e.g:      uri://process  "nearField"
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
~nearField = Environment[
	// required fields
	'nodeName' -> \nil,
	'nodeGroupName' -> \nil,
	'nodeGroup' -> \nil,
	'synth'  -> \zkarpluck1,
	'synthPtr' -> \nil,
	'nearFieldToggle'  -> 1,   // default to nearField Processing - set to 0 for farField Processing
	'nearFieldRadius'  -> 8,   // defaults to 8 meter near field radius
	'nearFieldExp'  -> 2,  // defaults to nonlinear attenuation using  x squared

	// project specific below

	'debugFlag' -> 1,
];

// required: set these variables to the process name, and register process
~processName = \nearField;
~process = ~nearField;
~process.know=true;
~satie.makeProcess(~processName, ~process);


// required functions
// required  setup function,  can be extended to suit particular needs of process
~nearField.setup = { | self, nodeName, nodeGroupName, args |
	var thisGroup = ~satie.satieGroups[nodeGroupName.asSymbol] ;

	// required
	self.nodeName = nodeName;
	self.nodeGroupName = nodeGroupName;
	self.nodeGroup = thisGroup;

	//x = args.copy;

	// IF there are args, try to parse them and set corresponding environment key value pairs
	if (args != nil,
		{
			if (  args.size > 1,
				{
					if (  (args.size&1)==1,    // odd length,  bad key value format
						{
							warn("nearField.setup:  node: %   ignoring args:  expecting key value pair(s)  % \n",  self.nodeName, args);
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

	self.put(\synthPtr, ~satie.makeInstance(nodeName.asSymbol, self.synth.asSymbol, self.nodeGroupName));


	if (self.debugFlag != 0, {postf("••nearField.setup:  node: %  group: %    args % \n", self.nodeName, self.nodeGroupName, args);});
};

// required  cleanup function,
~nearField.cleanup = { | self |

	// add project-specific code below
	if (self.debugFlag != 0, {  postf("••nearField.cleanup: clearing synths in node: % group \n", self.nodeName);});
	~satie.cleanInstance(self.nodeName.asSymbol, self.nodeGroupName);

};

// end of required class functions


// Optional Override handlers

// Below are optionally defined message handlers that, if defined, will be called by satieOSC.
// They override satieOSC's corresponding generic handlers, that apply these messages to the processNodes group (or environment, in the case of the  'property' message
// satieOSC provides an override mechanism for the following  messages, which are handled by the corresponding process functions as shown:

//   /satie/process/update   processName   azi ele gdb del lpf dst    -->  handled by process[\update]
//   /satie/process/property processName  key value  -->  handled by process[\property]
//   /satie/process/state      processName  state      -->   hadled by  process[\state]
//   /satie/process/set         processName  key value  -->  handled by process[key]
//   /satie/process/set         processName  key value  -->  handled by process[\set]   (unless process[key] is defined)
//  /satie/process/setvec     processName  key  [ val1 .... valN ]     -->   handled by process[key]
//  /satie/process/setvec         processName  key [ val1 .... valN ]  -->  handled by process[\setVec]   (unless process[key] is defined)


// overrides satieOSC's 'set' handler
// called on the reception of the message:  'set' key value
// NOTE:  if this process defines a handler for a particular key (e.g.  process[key] ), satieOSC will instead call that particular handler with the value arg. - see  spread handler example  below

~nearField.set =  {| self, key, value |
	if (self.debugFlag != 0, { postf("••nearField.set: key %  value % \n", key, value);});
	self.synthPtr.set(key.asSymbol, value);
};


// overrides satieOSC's 'setVec' handler
// called on the reception of the message:  'setVec' key vector
// NOTE:  if this process defines a handler for a particular key (e.g.  process[key] ), satieOSC will instead call that particular handler with the vec

~nearField.setVec =  {| self, key, vector |
	if (self.debugFlag != 0, { postf("••nearField.setVec: key %  value % \n", key, vector);});
	self.synthPtr.set(key.asSymbol, vector);
};



// overrides satieOSC's property handler
// called on the reception of the message:  'property' key value
// otherwise, satieOSC  will write the key value to this process's environment

~nearField.property =  {| self, key, value |
	if (self.debugFlag != 0, {  postf("••nearField.setProperty:  setting key vaue pair:  %:%   to process node's environment \n", key, value,  self.nodeName);});

	// project specific code below
	self.put(key.asSymbol, value);
};



// overrides satieOSC's update handler
// called on the reception of the message:  'update' azi ele gain del lp dist
// otherwise satieOSC will send the   'update'  message to the node's group

~nearField.setUpdate = { | self, aziDeg, eleDeg, gainDB, delayMs, lpHz, distance |
	var dbOffset;
	var newGainDB;
	var nfScaler = distance.clip(0.1, self.nearFieldRadius) / self.nearFieldRadius;


	if (self.nearFieldToggle == 1,
		{
			nfScaler = 1 - nfScaler;
	});

	nfScaler = nfScaler**self.nearFieldExp;
	dbOffset = nfScaler.ampdb;
	newGainDB = gainDB + dbOffset;

	if (self.debugFlag != 0, {  postf("••nearField.setUpdate: for process node  %   dbOffset: %  nfScaler % \n", self.nodeName, dbOffset, nfScaler  );});

	self.synthPtr.set(\aziDeg, aziDeg, \eleDeg, eleDeg, \gainDB, newGainDB , \delayMs, delayMs, \lpHz, lpHz);

};


// overrides satieOSC's state function
// called on the reception of the message:  'state'  value
// otherwise satieOSC will send the  'state' message to the node's group
/*
~nearField.state =  {| self, value |
	if (self.debugFlag != 0, {  postf("••nearField.state: setting state of process node %   to % \n", self.nodeName, value);});
};*/




