SatieIntrospection {
	var satie;

	*new {|satieContext|
		^super.newCopyArgs(satieContext);
	}
	
	getGenerators {
		^satie.generators;
	}

	getEffects {
		^satie.effects;
	}
}