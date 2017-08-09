+ SatieOSC {
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
}