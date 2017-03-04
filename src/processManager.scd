(
// process manager maker
~pmMaker = { | satieContext |

	var env = Environment.make( {
		~allProcesses = ();    // initialize list for processes to register themselves;
		~satie = satieContext;
		~debugFlag=false;

		~registerProcessEnv = { | self, processName, processEnv |
			if (  self.allProcesses.includesKey(processName.asSymbol) == true,
				{
					warn("un-registering process environment: "++processName);
					self.allProcesses.removeAt(processName.asSymbol);
			});
			inform("satieProcessManager: registering process environment: "++processName);
			self.allProcesses.put(processName.asSymbol, processEnv);
		};

		// returns a clone of the named process, or NIL if processEnv is not defined
		~cloneProcess = { | self, processName |
			var processClone = nil;

			if (self.allProcesses.includesKey(processName.asSymbol),
				{
					var temp = self.allProcesses.at(processName.asSymbol);
					processClone = temp.copy;
				},
				{
					error("undefined process environment: "++processName);
					processClone = nil;
			});
			processClone;
		};

	}); // Environment.make

	"satieProcessManager loaded".inform;
	env.know = true;
	env;  // return environment
};

)


/*~pm = ~pmMaker.value("weewee");

~pm.satie;

~pm.satie



~pm.registerProcessEnv(~processName, ~process);

// a = ~pm.cloneProcess(~processName);

~pm.cloneProcess(\sheefa);*/

