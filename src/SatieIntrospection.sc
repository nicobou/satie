SatieIntrospection {
	var context;

	*new {|satieContext|
		if (satieContext.class == Satie,
			{
				^super.newCopyArgs(satieContext);
			},
			{
				"ERROR: Wrong argument, should be Satie".error;
				^"null";
			}
		)
	}

	// return a dictionary audio plugins. Key is the type of plugin, value a set of names.
	getPluginList {
		var ret = Dictionary.new();
		ret.add(\generators -> context.audioPlugins.keys);
		ret.add(\effects -> context.fxPlugins.keys);
		^ret;
	}

	getPluginListAsJSON {
		^ToJSON.stringify(this.getPluginList);
	}
}