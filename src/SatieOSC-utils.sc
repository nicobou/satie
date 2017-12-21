// some helper functions

+ SatieOSC {
	// get a node from a dict
	// this method is good for sources and processes
	getSourceNode {
		| nodeName |
		var ret;
		satie.groupInstances.values.do({|dico, i|
			if (dico.includesKey(nodeName.asSymbol),
				{
					^ret = dico.at(nodeName.asSymbol);
				},
				{
					ret = nil;
				}
			);
		});
		^ret;
	}

	// get a group node
	getGroupNode {
		| groupName, key |
		var ret;
		ret = satie.groups[groupName.asSymbol];
		if (ret == nil,
			{
				"→    %: % not found at %".format(
					this.class.getBackTrace, groupName, key
				);
			},
			{
				^ret;
			}
		)
	}

	// check if inBus specified:
	// uriPath eg: effect://reverb inBus 2
	getFxInBus { | uriPath |
		var auxBus = 0;  //default bus

		var argList = this.getUriArgs(uriPath);

		// if there are two args, and the first arg is the keyword "inBus"then try to set the effect's \in param to the second arg
		if (argList.size > 1,
			{
				if (argList[0].asString == "inBus",
					{
						auxBus = argList[1].asInt.clip(0, satie.aux.size - 1);
					});
			});
		^auxBus;  // returns auxBus for effects node
	}

	getUriArgs { | uriPath |
		var temp,charIndex, processName;
		var argsString = "";
		var stringArray;
		var rawArgVec = nil;
		var argList = List[];
		var argsArray;

		stringArray = uriPath.asString.split($ );

		if (stringArray.size < 2,
			{
				[];
			},
			{
				argsArray = uriPath.asString.split($ );
				argsArray.removeAt(0);
				// make list of items in argString
				argsArray.do( { arg item;
					if ( item != "",
						{
							argList.add(item);
						});
				}
				)
			}
		);
	}
}