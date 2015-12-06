s.makeGui;
s.meter;
s.sampleRate


~nodeName= "bell_0";
~listenerName = "listener";
~pluginName = "pbell1";
~groupSym = \default;


~connectionName = ~nodeName++ "->"++~listenerName;
~pluginPath = "plugin://"++~pluginName;


~createSource.value(~nodeName, ~pluginPath, ~groupSym);
~createConnection.value(~nodeName,~listenerName);





~connectionCallback.value( ["/spatosc/core/connection/"++ ~connectionName++"/update", 0,0,-1,1,22050]);

~connectionCallback.value( ["/spatosc/core/connection/"++ ~connectionName++"/submerse", 1]);
~setEvent.value(~nodeName, \t_trig, 1);

~connectionCallback.value( ["/spatosc/core/connection/"++ ~connectionName++"/submerse", 0]);
~setEvent.value(~nodeName, \t_trig, 1);


~setEvent.value(~nodeName, \note, [80,1,1]);
~setEvent.value(~nodeName, \t_trig, 1);


~setEvent.value(~nodeName, \t_trig, 1);
~setEvent.value(~nodeName, \hpHz, 0);
~setEvent.value(~nodeName, \gainDB, 6);


~allSourceNodes[\bell_0].at(\proxy).set(\hpHz ,  10000 );
~setEvent.value(~nodeName, \t_trig, 1)


~allSourceNodes[\bell_0].at(\proxy).set(\hpHz ,   );




~scbr.satieGroups[\default].group.set(\hpHz ,  800 );

~scbr.satieGroups[\default].group.set(\hpHz ,  1 );

~scbr.satieGroups[\default].group.set(\t_trig, 1)



~setEvent.value(~nodeName, \t_trig, 1)



~allSourceNodes[\bell_0].at(\proxy).set(\gainDB ,  0 );

gainDB




// proxyspace delay problem:

// 250 ms delay with this
~scbr.satieGroups[\default][~nodeName.asSymbol].set(\t_trig, 1);

// 0 ms delay with this
	~scbr.satieGroups[\default].group.set(\t_trig, 1);


~scbr.satieGroups[\default][~nodeName.asSymbol].set(\t_trig, 1);
~scbr.satieGroups[\default].group.set(\t_trig, 1);













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


~nodeCount=3;


// "ball_142:spatOSCsource_143"


~nodeCount=3;


// CREATE SOURCES

~nodeCount.do({ arg item;
	var nodename=("ball_"++item++":spatOSCsource_"++(item+1)).asSymbol;
	var connectionName = nodename++item++ "->listener:spatOSClistener_0";
	postln("creating: "++nodename++" and connection:  "++ connectionName);
	~createSource.value(nodename, "plugin://zkarpluck1", \default);
	~createConnection.value(nodename, "listener:spatOSClistener_0");
	 // ~setUri.value(nodename, "plugin://zkarpluck1");
	//~connectionCallback.value( ["/spatosc/core/connection/"++ connectionName ++"/spread", 5]);
	//~connectionCallback.value( ["/spatosc/core/connection/"++ connectionName++"/update", 45,0,-80,1,14000]);

});
~allSourceNodes.size;


	~connectionName = ~reverbName++"->listener:spatOSClistener_0";
~connectionCallback.value( ["/spatosc/core/connection/"++ "ball_0:spatOSCsource_1->listener:spatOSClistener_0" ++"/update", 45,0,-30,1,14000]);


~sourceCallback.value( ["/spatosc/core/source/"++~reverbName++"/prop", "outputDB", -30] );

 ["/spatosc/core/connection/"++ "ball_1:spatOSCsource_21->listener:spatOSClistener_0" ++"/update", 45,0,-30,1,14000].postln


// SET CONNECTION

~nodeCount.do({ arg item;
	var nodename=("ball_"++item++":spatOSCsource_"++(item+1)).asSymbol;
	var connectionName = nodename++"->listener:spatOSClistener_0";
	//postf("creating: "++nodename++"\n");
	 //~setUri.value(nodename, "plugin://zkarpluck1");
	~connectionCallback.value( ["/spatosc/core/connection/"++ connectionName ++"/spread", 5]);
	~connectionCallback.value( ["/spatosc/core/connection/"++ connectionName++"/update", 45,0,-10,1,14000]);

});





// DELETE INSTANCE
~nodeCount.do({ arg item;
		var nodename=("ball_"++item++":spatOSCsource_"++(item+1)).asSymbol;

	~deleteSource.value( nodename );
});


~incidenceVal = 0;

~incidenceIndex=0;
t = Task({ {
	~nodeCount.do( { arg item;
		var pitch = 55 + rand(10);
		var nodename=("ball_"++item++":spatOSCsource_"++(item+1)).asSymbol;
		var connectionName = nodename++"->listener:spatOSClistener_0";
		// var incidence =  ~incidenceIndex.mod(100) * 0.01;

		// var pitch = 55 + rand(10);

		~incidenceIndex = (~incidenceIndex + 1) ;


		//incidence.postln;

		~setEvent.value(nodename, \note, [pitch,1,~incidenceVal]);
		~setEvent.value(nodename, \t_trig, 1);
		item.postln;
		0.2.wait;
	});
	//~globalSet.value(\t_trig, 1);
	0.wait; }.loop });

t.start;
t.stop;



~allSourceNodes.size;
~allSourceNodes.dump;


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





Server.default = s = Server.internal;
// 2D
a = VBAPSpeakerArray.new(2, [-60, 60, 0]); // 8 channel ring

a.speakers[1].dump;

b = a.loadToBuffer;

(
x = { |azi = 0, ele = 0, spr = 0|
VBAP.ar(2, PinkNoise.ar(0.2), b.bufnum, azi, ele, spr);
}.scope;
)



o = OSCresponderNode(s.addr, '/tr', { |time, resp, msg| msg.postln }).add;


o.remove;  // when done, you need to clean up the OSCresponderNode



w=Window.new("voicing", Rect(30, 30, 400, 140)).front;
w.view.decorator=FlowLayout(w.view.bounds);
w.view.decorator.gap=8@2;


l = EZSlider(w, 380@20, "azi", ControlSpec(-360, 360, \lin, 1, 0));
l.action_({ |ez| (  v.set(\aziDeg, (ez.value)))});

j = EZSlider(w, 380@20, "spread", ControlSpec(0, 100, \lin, 1, 0));
j.action_({ |ez| (  v.set(\spread, (ez.value)))});




// spread  units  (0 == directional, ....,  100 == omni)
(
v = {|in = 0, aziDeg = 0, eleDeg = 0, gainDB = 0, delayMs = 1, lpHz = 15000, spread = 10 |
	var gain= gainDB.dbamp;   // convert gainDB to gainAMP
	var delay = delayMs * 0.001;    // convert to seconds
	var slewDelay = 0.3; //  note: this needs to be improved ... smoother
	var slewGain = 0.03;
	var slewLp = 0.3;

	var insig;
	var aziScale = 0.01 * (100 - spread);


	var theta = aziScale * aziDeg *  0.01745329251994;  // radians

	var index = SinOsc.kr(0, theta);


	insig = LPF.ar(DelayC.ar(
		gain.lag(slewGain) *  PinkNoise.ar(0.2),
		maxdelaytime: 0.5,
		delaytime: delay.lag(slewDelay)), lpHz.lag(slewLp));

		//SendTrig.kr(Impulse.kr(4), 0, index);

	   Out.ar(0,Pan2.ar( insig, index ));
//}
}.scope;
)


(
v = {|in = 0, aziDeg = 0, eleDeg = 0, gainDB = 0, delayMs = 1, lpHz = 15000, spread = 1 |
PinkNoise.ar(0.2) * Math.
}.scope;
)




// test them out
{[45, 90, 135, 180, -135, -90, -45, 0].do({|ang| v.set(\azi, ang); 1.wait; }) }.fork;

// try the spread
x.set(\spr, .4);
x.set(\spr, 100); // all speakers


v.set(\azi,1); // all speakers


x.free; b.free;


// test them out
{[0, 45, 90, 135, 180, -135, -90, -45, 0].do({|ang| v.set(\aziDeg, ang); 1.wait; }) }.fork;

// try the spread
x.set(\spr, 1);
x.set(\spr, 100); // all speakers


x.set(\azi,-90); // all speakers


x.free; b.free;


