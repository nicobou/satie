+ Satie {

	// switchMake provides a convience function for simple projects to facilitate listening format switching between non-ambisonic and ambisonic spatializers.
	// if ambisonics listening is definted in the SatieConfiguration, the corresponding arugments will be applyed to makeAmbi, otherwise to makeSynthDef
	// note that the argument order is the same as makeSynthDef, with one (required) or more additional arguments that can be applied for the makeAmbi case.
	// Limitation: for use only with projects that do not make simultaneous use of Ambisonic and VBAP Listening formats.

	switchMake {|
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

		if (config.ambiOrders.size == 0,
		{
				// no ambisonics  defined, using standard spatializer(s)
			this.makeSynthDef(id, srcName,preBusArray,postBusArray,srcPreMonitorFuncsArray,spatSymbolArray,firstOutputIndexes,paramsMapper,synthArgs);
		},
			// else ambisonics defined, using ambisonic spatializer
		{
			this.makeAmbi(id, srcName, preBusArray, postBusArray, srcPreMonitorFuncsArray, ambiOrder, ambiEffectPipeline, ambiBusIndex, paramsMapper, synthArgs);
		});
	}
}
