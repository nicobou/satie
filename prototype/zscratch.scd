	// s.boot; s.makeGui;

	~deleteSource.value(\testNode0);

	~dumpNodes.value();

	~allNodes.size;

	~clearScene.value();


// generate N instances

	100.do({ arg item;
	var nodename=("testNode"++item).asSymbol;
	var connectionName = "testNode"++item++"->ear";

	~createSource.value(nodename);
	~createConnection.value(nodename, "ear");
	~setUri.value(nodename, "plugin://zkarpluck1");
	~connectionCallback.value( ["/spatosc/core/connection/"++ connectionName ++"/spread", 10]);
		       });




~globalParGroup.set(\gainDB, -10);

~globalSet.value(\c1, 0.1);
~globalSet.value(\c3, 10);
~globalSet.value(\fb, 100);
~globalSet.value(\pos, 0.5);

~globalSet.value(\gain, 3);

~globalSet.value(\t_trig, 1);

~globalSet.value(\spread, 10);





~globalParGroup.set(\t_trig, 1);
	~clearScene.value();



	~createSource.value(\testNode0);

       ~setUri.value(\testNode0, "plugin://zkarpluck1");
       ~setUri.value(\testNode0, "plugin://pink");
~setPlugin.value("ball_0:spatOSCsource_1", \pink);
~setPlugin.value("ball_0:spatOSCsource_1", \test);
~setPlugin.value("ball_0:spatOSCsource_1", \zkarpluck1);

      ~setState.value(\testNode0, 1);




w=Window.new("sheefa", Rect(30, 30, 400, 200)).front;
w.view.decorator=FlowLayout(w.view.bounds);
w.view.decorator.gap=8@2;



h = EZSlider(w, 380@20, "azi", ControlSpec(-180, 180, \lin, 0.1, 0));
h.action_({ |ez| ( ~globalSet.value(\aziDeg, (ez.value)))});

i = EZSlider(w, 380@20, "elev", ControlSpec(-180, 180, \lin, 0.1, 0));
i.action_({ |ez| ( ~globalSet.value(\eleDeg, (ez.value)))});

j = EZSlider(w, 380@20, "spread", ControlSpec(0, 100, \lin, 0.1, 5));
j.action_({ |ez| ( ~globalSet.value(\spread, (ez.value)))});








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


p = ~allNodes[\testNode0].at(\proxy);

	p[\gainDB] = 0;

	p[\out].source = \fool;
    p[\out].set(\gainDB, -20);

	p[\out].pause;
p.release;


~globalParGroup.set(\gainDB, -20);




	~dumpNodes.value();

	~allNodes.size;

	~clearScene.value();




 SynthDef(\test, { arg freq = 440, amp = 1;
	//var freqLag = Lag.kr(freq, 10);
	Out.ar(0, SinOsc.ar(freq.lag(3), 0, amp));
 }).add;



>
a = Synth(\test);
a.set(\freq, 440, \amp, 0.8);

a.set(\freq, 440);
a.set(\freq, 240);





				~allNodes[\testNode0] = Dictionary();   // create node  -- create node-specific dict.

				~allNodes[\testNode0].put(\groupName, ~zgroup);  // create node-specific group and add to node dict.
				p = ProxySpace(s);
				p.fadeTime = 0.02;
				p[\out].ar(0);  //    this prevents an extra bus being allocated. this must be the first reference of ~out
				p[\out].group = ~globalParGroup;  //~zgroup;
				~allNodes[\testNode0].put(\pluginName, \nil);
				~allNodes[\testNode0].put(\proxy, p);




p = ~allNodes[\testNode0].at(\proxy);

	p[\outDB] = -3;

	p[\out].source = \fool;
	p[\out].source = \nil;

~allNodes[\testNode0].at(\proxy).[\out].source = \foo1;

		~zgroup.set(\gainDB, -0);

		~zgroup.freeAll;



