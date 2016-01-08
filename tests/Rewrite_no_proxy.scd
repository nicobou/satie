Server.supernova;
o = Server.local.options;
o.numOutputBusChannels = 2;
o.memSize = 2**20;
o.blockSize = 256;
s.reboot;
s.makeGui;
s.meter;

// synthdef

SynthDef(\sin, { | mul = 0.2|
	Out.ar(0, SinOsc.ar(rrand(400, 800), 0, mul);)
}).add;

// create some dictionaries

~groupsDico = Dictionary.new; // dictionary for ParGroups
~group = ParGroup.new; // the pargroup
~groupInstances = Dictionary.new; // a separate dictionary for instances.

~groupsDico.put(\synths, ~group);
~groupInstances.put(\synths, Dictionary.new);

// instantiate some synths

20.do( { arg item;
    var nodename=("testNode"++"_"++item).asSymbol;
    var synth;
    nodename.asSymbol.postln;
	synth = Synth(\sin, target: ~groupsDico[\synths], addAction: \addToHead);
	// set some paramter immediately
    synth.set(\mul, 0.01);
	// add to instances disctionary
	~groupInstances[\synths].put(nodename.asSymbol, synth);
});

// show what's in the dictionaries
~groupsDico
~group
~groupInstances

// set some properties to group or individual synth
~groupsDico[\synths].set(\mul, 0.01)
~groupInstances[\synths][\testNode_10].set(\mul, 0.01)


// some other tests
d[\synths][\testNode_619].set(\mul, 0.01)
d[\synths][\testNode_14].get(\mul).postln
d[\synths].set(\mul, 0.01)
g.set(\mul, 0.01)
g.get(\mul)
d[\synths]
x.set(\mul, 0.02)
