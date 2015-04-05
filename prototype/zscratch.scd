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
~globalParGroup.set(\c1, 0.1);
~globalParGroup.set(\c3, 2);
~globalParGroup.set(\t_trig, 1);
	~clearScene.value();



	~createSource.value(\testNode0);

       ~setUri.value(\testNode0, "plugin://zkarpluck1");
       ~setUri.value(\testNode0, "plugin://pink");
      ~setPlugin.value(\testNode0, \default);

      ~setState.value(\testNode0, 1);




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



