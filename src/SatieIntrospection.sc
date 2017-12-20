SatieIntrospection {
	var context;
	var pluginsList;

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

	/* *****
	*	queries about uninstantiated plugin sources
	*
	*/
	updatePluginsList{
		pluginsList = [context.audioPlugins, context.fxPlugins, context.postprocessorPlugins];
	}

	// return a dictionary audio plugins. Key is the type of plugin, value a Set of names.
	getPluginList {
		var ret = Dictionary.new();
		ret.add(\generators -> context.audioPlugins.keys);
		ret.add(\effects -> context.fxPlugins.keys);
		ret.add(\mastering -> context.postprocessorPlugins);
		^ret;
	}

	pluginListJSON {
		^ToJSON.stringify(this.getPluginList);
	}
	// @plugin
	getPluginArguments { | plugin |
		var argnames, plugs;
		this.updatePluginsList;
 		pluginsList.do({|coll|
			"    ***** looking for key: % in: %\n".format(plugin, coll[plugin]).asCompileString.postln;
			if(coll.keys.includes(plugin.asSymbol),
				{

					^argnames = coll[plugin].function.def.keyValuePairsFromArgs;
				},
				{
					if(context.satieConfiguration.debug,
						{"% tried % in % and found none...\n".format(this.class.getBackTrace, plugin, pluginsList).warn}
					);
					argnames = "null";
				}
			);
		});
		^argnames;
	}

	getPluginDescription { | plugin |
		var description;
		this.updatePluginsList;
		pluginsList.do({|coll|
			if(coll.keys.includes(plugin.asSymbol),
				{
					^description = coll[plugin].description;
				},
				{
					if(context.satieConfiguration.debug,
						{"% tried % in % and found none...".format(this.class.getBackTrace, plugin, pluginsList).warn}
					);
					^description = "null";
				}
			);
		});
	}

	getPluginInfo { | plugin |
		var description, arguments, dico;
		dico = Dictionary.new();
		description = this.getPluginDescription(plugin);
		arguments = this.getPluginArguments(plugin);
		dico.add(\description -> description);
		dico.add(\arguments -> arguments.as(Dictionary));
		^dico;
	}

	getPluginInfoJSON { | plugin |
		var dico = Dictionary.new();
		dico.add(plugin.asSymbol -> this.getPluginInfo(plugin));
		^ToJSON.stringify(dico);
	}


	/* *****
	*	queries about compiled synths & effects
	*
	*/

	/*
		Return a dictionary of instances of generators
		key: ID (given name)
		value: source name
	*/
	getGenerators {
		^context.generators;
	}

	getEffects {
		^context.effects;
	}

	getPostProcessors {
		// var
		^context.postprocessorPlugins;
	}

	// grouped by generators and effects
	getInstances {
		var instances = Dictionary.new();
		instances.add(\synths -> this.getGenerators());
		instances.add(\effects -> this.getEffects());
		instances.add(\mastering -> this.getPostProcessors());
		^instances;
	}

	getInstancesJSON {
		^ToJSON.stringify(this.getInstances);
	}

	getInstanceInfo { | id |
		var srcName, description, arguments, ret;
		description = Dictionary.new();
		arguments = Dictionary.new();

		this.getInstances.keysValuesDo({| category, instances |
			"  ** category: % instances: %".format(category, instances.asCompileString).postln;
			instances.keysValuesDo({| name, srcName |
				"    ****  getInstanceInfo: %".format(name).postln;
				if (id.asSymbol == name.asSymbol,
					{
						var plug = this.getPluginInfo(srcName.asSymbol);
						ret = Dictionary.new();
						description = plug[\description];
						arguments = plug[\arguments];
						srcName = srcName.asSymbol;
						ret.add(id.asSymbol -> Dictionary.with(*[
							\srcName -> srcName,
							\description -> description,
							\arguments -> arguments])
						);
						^ret;
					},
					{
						if (context.satieConfiguration.debug,
							{"% did not find % in %".format(this.class.getBackTrace, id, instances).postln});
						ret = "null";
					}
				);
			});
		});
		^ret;
	}

	getInstanceInfoJSON { | id |
		^ToJSON.stringify(this.getInstanceInfo(id));
	}
}