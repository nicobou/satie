// some helper functions

+ SatieOSC {
	// get a node from a dict
	// this method is good for sources and processes
	getSourceNode {
		| nodeName, key |
		var ret;
		ret = allSourceNodes[nodeName.asSymbol].at(key.asSymbol);
		if (ret == nil,
			{
				"→    %: % not found at %".format(
					this.class.getBackTrace, nodeName, key
				);
			},
			{
				^ret;
			}
		)
	}

	// get a group node
	getGroupNode {
		| groupName, key |
		var ret;
		ret = allGroupNodes[groupName.asSymbol].at(key.asSymbol).group;
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

}