SatiePlugin {
	var <name, <description, <function;

	*new{|name, description="This should describe the plugin", function|
		description = description ? "Description missing"
		^super.newCopyArgs(name, description, function);
	}

	getName {
		^name;
	}

	getDescription {
		^description;
	}

	getSrc {
		^function;
	}
}