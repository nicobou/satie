SatieIntrospection {
	var context;
	var allPlugins;
	var spatList;

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
		var tempPlugs;
		tempPlugs = context.audioPlugins.merge(context.fxPlugins).merge(context.postprocessorPlugins);
		allPlugins = tempPlugs;
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

	getSynthDefList {

	}

	// @plugin
	getPluginArguments { | plugin |
		var argnames, plugs;
		this.updatePluginsList;
 		allPlugins.do({|coll|
			if(coll.keys.includes(plugin.asSymbol),
				{

					^argnames = coll[plugin].function.def.keyValuePairsFromArgs;
				},
				{
					if(context.satieConfiguration.debug,
						{"% tried % in % and found none...\n".format(this.class.getBackTrace, plugin, allPlugins).warn}
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
		allPlugins.do({|coll|
			if(coll.keys.includes(plugin.asSymbol),
				{
					^description = coll[plugin].description;
				},
				{
					if(context.satieConfiguration.debug,
						{"% tried % in % and found none...".format(this.class.getBackTrace, plugin, allPlugins).warn}
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

	// we will probably want to get other available fields of a plugin, we can list them here
	getPluginFields { | plugin |
		var fields, plugClass, plugInstance, ret;
		fields = Dictionary.new();
		ret = Dictionary.new();
		this.updatePluginsList;
		allPlugins.do {| coll |
			if(coll.keys.includes(plugin.asSymbol),
				{
					plugInstance = coll[plugin.asSymbol];
					plugClass = plugInstance.class;
					plugClass.instVarNames.do({|item, i|
						fields.add(item.asSymbol -> plugInstance.instVarAt(i).asCompileString);
					});
				},
				{
					if(context.satieConfiguration.debug,
						{"% tried % in % and found none...".format(this.class.getBackTrace, plugin, allPlugins).warn}
					);
				}
			)
		};
		ret.add(plugin.asSymbol -> fields);
		^ret;
	}

	getPluginFieldsJSON {|spatPlug|
		^ToJSON.stringify(this.getPluginFields(spatPlug.asSymbol));
	}

	getSpatializerArguments {| spatPlug |
		var argnames;
		this.updateSpatList();
		if(spatList.keys.includes(spatPlug.asSymbol),
			{
				^argnames = spatList[spatPlug.asSymbol].function.def.keyValuePairsFromArgs;
			},
			{
				if(context.satieConfiguration.debug,
					{"% tried % in % and found none...\n".format(this.class.getBackTrace, spatPlug, spatList).warn}
				);
				argnames = "null";
			}
		);
		^argnames;
	}

	updateSpatList {
		spatList = context.spatPlugins;
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
		^context.mastering;
	}

	// grouped by generators and effects
	getInstances {
		var instances = Dictionary.new();
		instances.add(\generators -> this.getGenerators());
		instances.add(\effects -> this.getEffects());
		instances.add(\mastering -> this.getPostProcessors());
		^instances;
	}

	getInstancesJSON {
		^ToJSON.stringify(this.getInstances);
	}

	getCompiledPlugins {
		var infos, synthdefs;
		infos = Dictionary.new();
		synthdefs = this.getInstances();
		this.updatePluginsList();
		synthdefs.keysDo({|key|
			var temp = Dictionary.new();
			infos[key.asSymbol] = Dictionary.new();
			synthdefs[key].do({|item|
				temp[item.asSymbol] = Dictionary.newFrom(List[
					\name, allPlugins[item.asSymbol].name, \description, allPlugins[item.asSymbol].description
				]);
			});
			infos[key.asSymbol] = temp;
		});
		^infos;
	}

	getCompiledPluginsJSON{
		^ToJSON.stringify(this.getCompiledPlugins());
	}

	getInstanceInfo { | id |
		var srcName, description, arguments, ret;
		description = Dictionary.new();
		arguments = Dictionary.new();

		this.getInstances.keysValuesDo({| category, instances |
			instances.keysValuesDo({| name, srcName |
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