SatiePlugins : Dictionary {
	var srcpath;

	*new {|path|
		^super.new.init(path);
	}

	init {arg path;
		this.appendPath(path);
	}

	/*
	*  Append plugins from path
	*/
	appendPath { arg path;

		path.pathMatch.do{arg item;
			item.loadPaths;
			this.add(~name.asSymbol -> SatiePlugin.new(~name, ~description, ~function));
		};
	}
}