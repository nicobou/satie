s.makeGui;
s.meter;

Server.default.options.dump;



~superNovaFlag = true;



OSCdef(\createBasicRendererListener).clear.free;  // just in case newOSC will be re-evaluated.
	~scbr.oscInterface.newOSC(\createBasicRendererListener, ~basicRendererCallback, "/a.renderer");



~basicRendererCallback = {
	arg msg;
	var command;
	command = msg[1];
	postf("~basicRendererCallback: command: %, msg: %, \n", command, msg);

	switch (command,
		'createSource',
		{
			if ( (msg.size < 3 ) ,
				{"~basicRendererCallback: OSCrx createSource message missing values".warn;
					postf("CREATESOURCE MESS LEN: %", msg.size);

				},
				// else
				{
					var sourceName = msg[2];
					var uriName;

					if (msg.size == 3,
						{
							uriName = "";
						},
						// else
						{
							uriName = msg[3];
					});

					~createSource.value(sourceName, uriName);
				}
			)
		}
	);
};






//~domePlaybackFormat = \domeVBAP;       // for sato
~domePlaybackFormat = \labodomeVBAP;      // for labodome


//~outAudioDev = "Soundflower (64ch)";   //  for multi-channel testing without hardware on OSX

~outAudioDev = "MADIface USB (23635751)";     // for labodome or SATO


if ( ~superNovaFlag != nil,
	{
	Server.supernova;
});

	o = Server.local.options;   // set up options
    o.memSize = 2**19;        // probably should just leave this the same for everyting
	//o.blockSize = 2048;


if ( ~outAudioDev != nil ,
{
	o.device = ~outAudioDev;
});

   // o.device = "MADIface USB (23635751)";     // set for dome or labodome

if ( ~domePlaybackFormat != nil,
	{
		o.memSize = 2**19;
		o.blockSize = 2048;
		o.numOutputBusChannels = 32;
		// o.dump;
});


~allNodes.size;
~allNodes.clear;

~allNodes;

~dumpNodes.value();


~clearScene.value();


~createSource.value(\testNode0);
~setUri.value(\testNode0, "plugin://pink");



~deleteSource.value(\testNode2);


~clearNode.value(\testNode0);

~clearScene.value();


~setUri.value(\testNode0, "plugin://zkarpluck1");
~setUri.value(\testNode0, "plugin://pink");


~group.set(\t_trig, 1);



~setState.value(\testNode0, 1);



~allNodes[\testNode0];

~allNodes.removeAt(\testNode0);


~cleaninstance.value(\testNode0, ~prox);

~clearNode.value(\testNode0);
~dumpNodes.value();




~clearScene.value();

// generate N instances

// "ball_142:spatOSCsource_143"

150.do({ arg item;
	var nodename=("ball_"++item++":spatOSCsource_"++(item+1)).asSymbol;
	var connectionName = "testNode"++item++"->ear";
	//postf("creating: "++nodename++"\n");
	~createSource.value(nodename);
	~createConnection.value(nodename, "listener:spatOSClistener_0");
	~setUri.value(nodename, "plugin://zkarpluck1");
	//~connectionCallback.value( ["/spatosc/core/connection/"++ connectionName ++"/spread", 5]);
	//~connectionCallback.value( ["/spatosc/core/connection/"++ connectionName++"/update", 45,0,-80,1,14000]);

});
~allNodes.size;


	~connectionName = ~reverbName++"->listener:spatOSClistener_0";
~connectionCallback.value( ["/spatosc/core/connection/"++ ~connectionName++"/update", 45,0,-30,1,14000]);

~sourceCallback.value( ["/spatosc/core/source/"++~reverbName++"/prop", "outputDB", -30] );





// delete instances
100.do({ arg item;
	var nodename=("testNode"++item).asSymbol;
	~deleteSource.value( nodename );
});
~allNodes.size;



t = Task({ {

	149.do( { arg item;
		var pitch = 55 + rand(50);
		var nodename=("ball_"++item++":spatOSCsource_"++(item+1)).asSymbol;
		~setEvent.value(nodename, \note, [pitch,1,1]);
		~setEvent.value(nodename, \t_trig, 1);
		item.postln;
		0.1.wait;
	});
	//~globalSet.value(\t_trig, 1);

	0.wait; }.loop });
t.start;
t.stop;



~allNodes.size;
~allNodes.dump;


//mix=1.0, room=0.5, damp=0.5

//~setUri.value(~reverbName.asSymbol, "plugin://busreverb");



~setProperty.value(~reverbName, \in, ~scbr.aux[0]);
~setProperty.value(~reverbName, \outputDB, 10);
~setProperty.value(~reverbName, \mix, 1);  //wet only
~setProperty.value(~reverbName, \room, 0.8);
~setProperty.value(~reverbName, \damp, 0.1);
~setProperty.value(~reverbName, \aziDeg, -180);
~setProperty.value(~reverbName, \gainDB, -0);


	~globalSet.value(\gainDB, -80);




~globalSet.value(\fb, 0);
~globalSet.value(\pos, 0.5);






// harp 1
~globalSet.value(\c1, 0.4);
~globalSet.value(\c3, 5);
~globalSet.value(\fb, 0);

// harp 2
~globalSet.value(\c1, 0.38);
~globalSet.value(\c3, 6.11);
~globalSet.value(\fb, 0);

// harp 3 (longer dur)
~globalSet.value(\c1, 0.15);
~globalSet.value(\c3, 4.51);
~globalSet.value(\fb, 0);

// harp 3 (feather)
~globalSet.value(\c1, 0.15);
~globalSet.value(\c3, 9.51);
~globalSet.value(\fb, 0);


~globalSet.value(\c1, 0.2);
~globalSet.value(\c3, 6);

~globalSet.value(\c1, 0.2);
~globalSet.value(\c3, 3);

~globalSet.value(\c1, 0.2);
~globalSet.value(\c3, 3);


// lantern zoner
~globalSet.value(\c1, 0.11);
~globalSet.value(\c3, 3);
~globalSet.value(\fb, 100);

// lantern zoner (shorter)
~globalSet.value(\c1, 0.7);
~globalSet.value(\c3, 3);
~globalSet.value(\fb, 100);





v=Window.new("location", Rect(30, 30, 400, 100)).front;
v.view.decorator=FlowLayout(v.view.bounds);
v.view.decorator.gap=8@2;



h = EZSlider(v, 380@20, "azi", ControlSpec(-180, 180, \lin, 0.1, 0));
h.action_({ |ez| ( ~globalSet.value(\aziDeg, (ez.value)))});

i = EZSlider(v, 380@20, "elev", ControlSpec(-90, 90, \lin, 0.1, 0));
i.action_({ |ez| ( ~globalSet.value(\eleDeg, (ez.value)))});

j = EZSlider(v, 380@20, "spread", ControlSpec(0, 100, \lin, 0.1, 5));
j.action_({ |ez| ( ~globalSet.value(\spread, (ez.value)))});









w=Window.new("voicing", Rect(30, 30, 400, 140)).front;
w.view.decorator=FlowLayout(w.view.bounds);
w.view.decorator.gap=8@2;


g = EZSlider(w, 380@20, "pitch ", ControlSpec(40, 110, \lin, 1, 60));
g.action_({ |ez| (  ~globalSet.value(\note, [ ez.value, 1, 0.5 ] );  ~globalSet.value(\t_trig, 1);)});


// h = EZSlider(w, 380@20, "amp", ControlSpec(0, 1, \lin, 0.01, 0.5));
// h.action_({ |ez| (  ~globalSet.value(\amp, (ez.value)))});
//


i = EZSlider(w, 380@20, "pos", ControlSpec(0.0, 1, \lin, 0.01, 0.14));
i.action_({ |ez| (  ~globalSet.value(\pos, (ez.value)))});


j = EZSlider(w, 380@20, "c1", ControlSpec(0.05, 5, \lin, 0.01, 1));
j.action_({ |ez| (  ~globalSet.value(\c1, (ez.value)))});


k = EZSlider(w, 380@20, "c3", ControlSpec(0.05, 20, \lin, 0.01, 1));
k.action_({ |ez| (  ~globalSet.value(\c3, (ez.value)))});

l = EZSlider(w, 380@20, "fb", ControlSpec(0.0, 100, \lin, 0.1, 20));
l.action_({ |ez| (  ~globalSet.value(\fb, (ez.value)))});







~globalSet.value(\gain, 3);

~globalSet.value(\t_trig, 1);

~globalSet.value(\spread, 10);

~globalSet.set(\gainDB, -40);



	200.do( { arg item;
	var pitch = 55 + rand(50);
	var nodename=("testNode"++item).asSymbol;
	~setEvent.value(nodename, \note, [pitch,1,1]);
});








~sourceCallback.value( ["/spatosc/core/source/"++ "testNode0" ++"/event", \t_trig, 1]);

~sourceCallback.value( ["/spatosc/core/source/"++ "ball_17:spatOSCsource_18" ++"/event", \t_trig, 1]);
~sourceCallback.value( ["/spatosc/core/source/"++ "ball_17:spatOSCsource_18" ++"/event", \note, 70,1,1]);

~sourceCallback.value( ["/spatosc/core/source/"++ "ball_18:spatOSCsource_19" ++"/event", \note, 90,1,1]);
~sourceCallback.value( ["/spatosc/core/source/"++ "ball_18:spatOSCsource_19" ++"/event", \t_trig, 1]);


~createConnection.value(\testNode0, "ear");
~connectionCallback.value( ["/spatosc/core/connection/"++ "testNode0->ear" ++"/spread", 10]);
~connectionCallback.value( ["/spatosc/core/connection/"++ "testNode0->ear" ++"/update", 90,0,-0,1,14000]);

~globalParGroup.freeAll;


	~globalSet.value(\gainDB, -10);
	~globalSet.value(\c3, 2);

~globalSetState.value(0);


	~dumpNodes.value();

	~allNodes.size;

	~clearScene.value();


0.001.degrad


		~allNodes.keysDo { |key |
			var nodeSym = key;
			//postf("node: %  \n", key);
			~allNodes[nodeSym].keysDo { | key |
			if ( key == \connectionState,
				{
					postf(" %:   %  =  % \n",nodeSym,  key, ~allNodes[nodeSym].at(key));
			});
			};
		};



 SynthDef(\test, { arg freq = 440, amp = 1;
	//var freqLag = Lag.kr(freq, 10);
	Out.ar(0, SinOsc.ar(freq.lag(3), 0, amp));
 }).add;



>
a = Synth(\test);
a.set(\freq, 440, \amp, 0.8);

a.set(\freq, 440);
a.set(\freq, 240);






