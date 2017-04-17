//  listen to effects bus 1 and write to last output channel
// used for listening Format:   \dodecNF
//  flutter synth def writes to ~fxBus1, which is copied to put
//





// evaluate this file to connect the named aux busses to the named channel outs
// used for object audio streams to near-field renderer


if (~listeningFormat == \dodecNF,
	{


s.waitForBoot {

~nearFieldObjBusCount = 8;
~nearFieldObjBusses = Array.new(~nearFieldObjBusCount);
~nearFieldObjBusCount.do( {|item| ~nearFieldObjBusses.add(item);});


	// synthDef  outputs named auxBus on named outputChannel
SynthDef(\nfObjSend, { arg inChan=1,  outChan=1;
		var input;
		input = In.ar(inChan, 1);
		Out.ar(outChan, input);
 }).add;

	s.sync;

// make sure to free before filling
~nearFieldObjBusCount.do( {|item|

	~nearFieldObjBusses[item].free;

	});

~nearFieldObjBusCount.do( {|item|
		var x;
	    var auxNo = ~satie.aux[0]+1+item;
	    var outChanNo = o.numOutputBusChannels- ~nearFieldObjBusCount +item;

		x = Synth.tail(s, "nfObjSend",  [ \inChan , auxNo,  \outChan , outChanNo ] );

		//x.moveToTail;
		postf("creating Bus to Ouptut Map: :  auxBus %   -->  OutBus % \n", auxNo, outChanNo);
	   ~nearFieldObjBusses[item] = x;
	});

};
});







	//
	// x = {
	// 	~input = In.ar(~satie.aux[~objBus1], 1);
	// 	Out.ar(o.numOutputBusChannels - ~nearFieldObjBusCount,  ~input);
	// }.play;
	//
	// x = Synth.tail(s, "nfObjSend",  [ \inChan , ~satie.aux[0]+1, \outChan , o.numOutputBusChannels- ~nearFieldObjBusCount ] );
	// x.free;
	// }


// x.free;	// free just x

