//  listen to effects bus 1 and write to last output channel
// used for listening Format:   \dodecNF
//  flutter synth def writes to ~fxBus1, which is copied to put
//
if (x != nil, {x.free});


s.waitForBoot {

x = {
	~input = In.ar(~satie.aux[~fxBus1], 1);
	Out.ar(o.numOutputBusChannels-1, ~input);
}.play;
	s.sync;
	x.moveToTail;
}


// x.free;	// free just x

