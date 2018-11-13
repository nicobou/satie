+ Satie {

	// exMake provides a convience function for simple projects to facilitate listening format switching between VBAP and Ambisonics.
	// if ambisonics listening is definted in the satieConfiguration, the arugments will be applyed to makeAmbi, otherwise to makeSynthDef
	// note that the argument order is taken from makeSynthDef, with one (required) or more additional arguments that will be applied for the makeAmbi case.
	// Limitation: for use only with projects that do not make simultaneous use of Ambisonic and VBAP Listening formats.

	ezMake {|
		id,
		srcName,
		preBusArray,
		postBusArray,
		srcPreMonitorFuncsArray,
		spatSymbolArray,
		firstOutputIndexes = #[0],
		paramsMapper = \defaultMapper,
		synthArgs = #[]
		ambiOrder,
		ambiEffectPipeline = #[],
		ambiBusIndex = 0 |

		if (satieConfiguration.ambiOrders.size == 0,
		{
				// no ambisonics  defined, using VBAP
				"ezMake: making VBAP synth".debug;
			this.makeSynthDef(id, srcName,preBusArray,postBusArray,srcPreMonitorFuncsArray,spatSymbolArray,firstOutputIndexes,paramsMapper,synthArgs);
		},
			// else ambisonics defined
		{
			"ezMake: making ambisonic synth".debug;
			this.makeAmbi(id, srcName, preBusArray, postBusArray, srcPreMonitorFuncsArray, ambiOrder, ambiEffectPipeline, ambiBusIndex, paramsMapper, synthArgs);
		});
	}
}