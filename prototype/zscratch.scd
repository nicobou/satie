// s.makeGui;
// s.meter;
// s.sampleRate;

//~dumpNodes.value();


n=ParGroup.new(1, \addToTail);

e=~satie.satieGroups[\defalutFx];



g = ~satie.satieGroups[\default];

d.moveToTail

d.moveToTail(n)

d=~satie.satieGroups[\defaultFx]

	g = ~satie.createGroup(\defaultFx, \addToTail);

ParGroup(1002)


~satie.createGroup(\default);



[(50+30.rand), (0.5+0.5.rand), (0.5+0.5.rand)]


x = ~satieOsc.allSourceNodes.at(\srcNodeSP).at(\process);
x.debugFlag


x[\synthParams]

b = x.cloneCount.asFloat

if  ( b > 1000,  { "wewewe".postln });

x.nodeGroupName

x.trigger( [(50+30.rand), (0.5+0.5.rand), (0.5+0.5.rand)]);

x.routine.reset;
x.routine.value(x);
x.routine.play;
x.routine.stop;
x.routine.next
x.routine.class.dumpMethodList


~particule2_pitchSequences.at("bjGroove.mid.mid.txt".asSymbol).put(\incr, 1.0);


~particule2_pitchSequences.at("bjGroove.mid.mid.txt".asSymbol).put(\pos, 1.0);

~particule2_pitchSequences.at("bjGroove.mid.mid.txt".asSymbol).at(\pos);
~particule2_pitchSequences.at("bjGroove.mid.mid.txt".asSymbol).at(\incr);

~particule2_pitchSequences.at("bjGroove.mid.mid.txt".asSymbol).at(\pitches)

((0 + 1) % 55)




10.do( {|item|
	var nodename=("srcNodeSP"++"_"++item);
~synth = ~satie.satieGroupInstances[\srcNodeSP_group][nodename];
	~synth.set(\note, [ 60, 1, 1 ] );
});

~synth = ~satie.satieGroupInstances[\default][\ball_69]


~synth.set(\note, [ 60, 0.9, 0.9 ] );
~synth.set(\t_trig, 1);





~myNodeName = \srcNode_0;
~myNode = ~satieOsc.allSourceNodes[~myNodeName.asSymbol];


~myProcess = ~myNode.at(\process);

~myProcess[\setProperty].class == Function

~myProcess.at(\sheefa);

~setFn = ~myProcess[\set];

~myProcess.at(\hpHz).class

~myProcess.at(\spread).class == Function

~myProcess.at(\set).class == Function

~mySetFunction = ~myProcess.at(\set);

~setFn == ~mySetFunction


~myProcess.at(\spread).value(~myProcess, \spread, 0);


~myProcess.at(\nodeGroupName)






f.value(p, \spread, 0)
x.dump

x = p.at(\set)
y = p[\set]

x == y

x.value(p, \spread, 0)

f == y


p == ~myProcess

p[\hpHz].class

//gainDB = -90, delayMs = 1, lpHz = 15000, hpHz = 1, spread = 1

~bell = ~satie.satieGroupInstances[\oceanScene][\bellSnd_6];




SynthDef(\prayer_bell,  ~function  ).add;
(

~bell.free;

~bell =Synth.new("prayer_bell",  [ \i_doneAction, 0, \decayscale , 0.7,  \muteSecs, 0, \gainDB, 0]);

~bell.set(\note, #[61, 1, 1]);
)

~bell.set(\t_trig, 1);



~bell.set(\gainDB, 0);



// ~bell.set(\note, #[61, 0.9, -1]);


~bell.set(\note, #[61, 1, 1]);
~bell.set(\t_trig, 1);

~bell.set(\note, #[61, 0.0, 0.3]);
~bell.set(\t_trig, 1);




~bell.set(\amp, 1);


~bell.set(\decayscale , 0.7,   \muteSecs, 0)

~bell.set(\t_trig, 1);
~bell.set(\decayscale, 0.6);









(

~bell.set(\note, #[61, 0.9, 0.9], \t_trig, 1);

~bell.set(\t_trig, 1);
~bell.set(\decayscale, 0.1);
~bell.set(\gainDB, 0);

)






~nodeName = \coreLoopBuff;
~nodeName2= \accLoopBuff;
~noteName3 = \accentsLoopBuff;



~satie.satieGroups[\whaleBellyScene].set(\note, #[60,0,0]);

~node = ~satie.satieGroupInstances[\whaleBellyScene][\coreLoopBuff];


~node.set(\note, #[60,1,1]);
~node.set(\amp, 6);

~node.set(\transp, -0);

~node.set(\transp, -2);





~satie4unity.deleteSource(\bellSnd_1);

~satie.satieGroups[\oceanScene]


~satie4unity.satieAuxBusCount;



~satie4unity.clearScene()

~satie4unity.allSourceNodes.size()



~satie.satieGroups[\oceanScene].freeAll;

~satie.killSatieGroup(\oceanScene)


~satie.satieGroupInstances[\oceanScene].size()

~satie.satieGroupInstances[\default][\vStem_61].dump


bad values:  15, 26, 29,51, 56,84, 95,


~satie.cleanInstance("bellSnd_3".asSymbol ,\oceanScene );



~satie.cleanInstance("bellSnd_5".asSymbol ,\oceanScene );




~bell.free

~satie.satieGroupInstances[\default]


~satie.satieGroupInstances[\default][vStem_63].free

~satie.satieGroupInstances[\default][\vStem_18].set(\curve, 6, \warp, 5, \glide, 0, \note, #[60, 1, 1] );

~satie.satieGroupInstances[\default][\vStem_18].set(\glide, 0, \transp, 0, \startLoop, 0, \endLoop, 999999, \bufnum, b.bufnum, \note, #[60, 1, 1] );

~satie.satieGroupInstances[\default][\vStem_18].set(\bufnum, b.bufnum);


~aqPlayBuffers["vortexDrone.aif".asSymbol]

b



~satie.satieGroupInstances[\oceanScene][\bellSnd_2].free



~satie.makeInstance(\sheefa, \busgverb, \effect);

~satie.makeInstance(\sheefa, \busgverb, \default);

		if ( ~satie.satieGroups[\effect] == nil,
			{~effectProx = ~satie.makeSatieGroup(~satieFXgroupSym, \addToTail);}
		);


~satie4unity.allGroupNodes.size()


~satie.aux.size
"sheefa".size


(

~cloneParams =[ \note, [ 60, 1, 1 ], \t_trig, 1 ];

~synthName="drops-95.wav:k:rev".asSymbol;
x = ~satie.makeKamikaze(\sheefa, ~synthName, \default, ~cloneParams);
// x = ~satie.makeInstance(\sheefa, ~synthName, \default);
x.set(\gainDB, 0);
x.set(\t_trig, 1);
)


(

~cloneParams =[ \gainDB, 0, \note, [ 60, 1, 1 ], \t_trig, 1 ];

~synthName="drops-95.wav:k:rev".asSymbol;
x = ~satie.makeKamikaze(\sheefa, ~synthName, \default, ~cloneParams);

)


	~zombieTrig1_instances.keysDo{ arg key;

		if ( key == ~processName,
			{
				key.postln;
				~satie4unity.allProcesses.at(~processName).at(\synthCountMax).postln;
		});
	};





(
~cloneParams =[ \gainDB, 0, \note, [ 60, 1, 1 ], \t_trig, 1 ];

~synthName="drops-95.wav:k:rev".asSymbol;

~incr= 0;

{100.do{ arg item;
var n = item + ~incr;

	~cloneParams =[ \gainDB, 0, \note, [ 60, (0.3 + (0.7*item)/100),  item/100 ], \t_trig, 1 ];

// ~synthName="drops-"++ n++".wav:k:rev".asString;
x = ~satie.makeKamikaze(\sheefa, ~synthName, \default, ~cloneParams);






	//n.postln;
			0.1.wait;
};}.fork


)


"_______"




~satie.satieGroupInstances[\default][\digestion].set(\gainDB, -10);



~satie.satieGroupInstances[\default][\digestion].run(0);


~satie.satieGroupInstances[\default][\sound].set(\loop, 1);

~satie.satieGroupInstances[\default][\sound].set(\gainDB, -60.1);

TempoClock.default.sched(0.05,
									{
~satie.satieGroupInstances[\default][\sound].set(\gainDB, -60.1);

~satie.satieGroups[\default].set(\gainDB,  -30);

										nil });




~satie.satieGroupInstances[\default][\sound].set(\gainDB, -30);



~satie4unity.allSourceNodes[\srcNodeSP].at(\groupNameSym);


~satie4unity.allSourceNodes[\srcNodeSP];

~myGroupName = \srcNodeSP_group;

g = ~satie.satieGroups[~myGroupName].set(\delayMs, 200, \attackDB, -44);


g = ~satie.satieGroups[~myGroupName].run(true);

~nodeName= \bellSnd_8;


~satie4unity.setEvent(~nodeName, \note, [80,1,1]);
~satie4unity.setEvent(~nodeName, \t_trig, 1);







~groupSym = \default;

~nodeName= \bellSnd_8;
~nodeName = \setNodeSP;

~nodeGroupName = ~satie4unity.allSourceNodes[~nodeName.asSymbol].at(\groupNameSym);

~listenerName = "listener";

~allGroupNodes.includesKey(~nodeGroupName);

~cloneName = ~nodeName++"_0";


// process node testing
~myProcess = ~allSourceNodes[~nodeName.asSymbol].at(\process);
~myGroupName = ~myProcess.nodeGroupName.asSymbol;
~myGroup = ~myProcess.nodeGroup.group;



// for normal source Node
//~pluginName = "pbell1";
//~pluginPath = "plugin://"++~pluginName;

// for process node
~pluginName = "sheefa";
//~pluginPath = "process://"++~pluginName;


/*
~createSource.value(~nodeName, ~pluginPath, ~groupSym);
~createConnection.value(~nodeName,~listenerName);

*/

// inspect values
~myProcess.at(\cloneCount);
~myProcess.at(\triggerIntervalMs);
~myProcess.at(\nodeGroup);

//~someKey = "cloneCount";
//~myProcess.put(~someKey.asSymbol, 33);


	~satie.satieGroups[~nodeGroupName].set(\c1, 0.7,  \c3, 3, \fb,  100);


~particule1_instances.do{ |item |
	var groupName = item.nodeGroupName;

	~satie.satieGroups[groupName].set(\c1, 2,  \c3, 4, \fb,  100);

};

	~satie.satieGroups[groupName].set(\c1, 0.7,  \c3, 3, \fb,  100);

// 0.7, 3, 100



// srcNode_0_group, srcNode_0_6

~satie.satieGroupInstances[~myGroupName][~cloneName].set(\note, [75,1,1], \t_trig, 1);
~myProcess.put(triggerIntervalMs, 0);

~satie.satieGroupInstances[~myGroupName][~cloneName].set(\t_trig, 1);

~satie.satieGroupInstances[~myGroupName][~cloneName].set(\cloudSpread, 2);


~myGroup.set(\randTrigMaxMs, 0);
//~myGroup.set(\t_trig, 1).free

\srcNode_0
~satie.satieGroups[~myGroupName].set(\aziDeg,  -89, \eleiDeg,  0, \gainDB, -30, \note, [75,1,1], \t_trig, 1);

~satie.satieGroups[~myGroupName].set(\cloudAziScale,  1, \cloudElevScale,  0, \t_trig, 1);
~satie.satieGroups[~myGroupName].set(\cloudAziScale,  0, \cloudElevScale,  0, \t_trig, 1);


~satie.satieGroups[~myGroupName].group.set(\t_trig, 1);

{~satie.satieGroupInstances[~myGroupName].keysDo{ |key |
	var nodeSym = key;
	// var synthName = "srcNode_"++item++"_group";


	~satie.satieGroupInstances[~myGroupName][key].set(\randTrigMaxMs, 0);
	~satie.satieGroupInstances[~myGroupName][key].set(\note, [89,1,1]);

	~satie.satieGroupInstances[~myGroupName][key].set(\t_trig, 1);
	key.postln;
			0.2.wait;
};}.fork



~connectionName = ~nodeName++ "->"++~listenerName;




~myGroupName;

// clear
//~myProcess[\clearSynths].value(~myProcess);

//~myProcess.freeClones();


//~satie.cleanInstance(~cloneName,~myGroupName );


~allSourceNodes[\ball_5].at(\groupNameSym);


\srcNode_0

~satie.satieGroups[\srcNode_group];
~satie.satieGroups[\srcNode_1_group].set(\randTrigMaxMs, 0);



~satie.satieGroups[\srcNode_0_group].set(\aziDeg,  90);
~satie.satieGroups[\srcNode_0_group].set(\t_trig, 1);

~satie.satieGroups[\srcNode_1_group].set(\aziDeg,  -90);
~satie.satieGroups[~myGroupName].set(\t_trig, 1);



~srcNode_0process = ~allSourceNodes[\srcNode_0].at(\process);
~srcNode_1process = ~allSourceNodes[\srcNode_1].at(\process);


~srcNode_0process.at(\nodeGroup).set(\aziDeg,  -90);
~srcNode_1process.at(\nodeGroup).set(\aziDeg,  -90);

~srcNode_0process.at(\nodeGroup).set(\t_trig, 1);
~srcNode_1process.at(\nodeGroup).set(\t_trig, 1);




~allSourceNodes[\srcNode_0].at(\process) == ~allSourceNodes[\srcNode_1].at(\process);

~satie.satieGroupInstances[~myGroupName.asSymbol][~cloneName.asSymbol].set(\note, [89,1,1]);   // broken

// should be

~satie.satieGroupInstances[~myGroupName.asSymbol][~cloneName.asSymbol].set(\note, [89,1,1]);     // new style



~satie.satieGroupInstances[~myGroupName.asSymbol][~cloneName.asSymbol].set(\t_trig, 1);



~satie.satieGroups.keysDo{ |key |
	var nodeSym = key;

	if (key != \default,
		{
			~satie.killSatieGroup(key);
	});
};


~satie.satieGroups


( { arg key;

	key.postln;

	~satie.killSatieGroup(nil);

});





~myProcess.at(\nodeGroupProxy).group.set(\note, [85,0.5,0.5]);
~myProcess.at(\nodeGroupProxy).group.set(\t_trig, 1);
~myProcess.at(\nodeGroupProxy).group.set(\randTrigMaxMs, 0);

~myProcess.at(\nodeGroupProxy).group.set(\t_trig, 1);
~myProcess.at(\nodeGroupProxy).group.set(\aziDeg, -90);

~allSourceNodes[~nodeName].at(\proxy);



~connectionProcessCallback.value( ["/spatosc/core/connection/"++ ~connectionName++"/update", 0,0,-3,1,12345]);

~sourceProcessCallback.value( ["/spatosc/core/source/"++ ~nodeName ++"/event", \trigger, 1]);

// this is the way to access the process's params
~sourceProcessCallback.value( ["/spatosc/core/source/"++ ~nodeName ++"/event", \setParam, \gainDB, -40]);


// adjust group
~myProcess.at(\nodeGroupProxy).group.set(\gainDB, -30);
~myProcess.at(\nodeGroupProxy).group.set(\gainDB, -20);
~myProcess.dump;






//~nodeName="shitfuck";

~myProcess.at(\cloneCount).do( { arg item;
	var nodeName=(~nodeName++"_"++item).asSymbol;
	var groupName = ~myProcess.at(\nodeGroupName);
	var synth;
	synth = ~satie.satieGroups[ groupName ][nodeName];
	synth.set(\gainDB, -10);
	synth.set(\t_trig, 1);
});







	10.do( { arg item;
			var nodename=(~nodeName++"_"++item).asSymbol;
	var synth;
	{
			synth = ~satie.makeInstance(nodename.asSymbol, \default, ~myGroupName);
		     s.sync;
			synth.set(\gainDB, -3);
	}.fork
			//synth.at(\gainDB).postln;
			//self.gainDB.postln;

		});



	20.do( { arg item;
			var nodename=(~nodeName++"_"++item).asSymbol;
	var synth;
	{
		nodename.asSymbol.postln;
			synth = ~satie.cleanInstance(nodename.asSymbol, ~myGroupName);
		     s.sync;
			synth.set(\gainDB, -3);
	}.fork
			//synth.at(\gainDB).postln;
			//self.gainDB.postln;

		});



{
        SynthDef(.....).add;
        s.sync;
        Synth(\newSDef, ...);
}.fork;





~synthName=~nodeName++"_12";

~satie.satieGroups[~myGroupName][~synthName.asSymbol ].set(\gainDB, -30);

~synth  = ~satie.satieGroups[~myGroupName][~synthName.asSymbol ];

~synth.set(\gainDB, -90);


~synth = ~satie.makeInstance(~nodeName.asSymbol ,  \default, ~myGroupName);
~synth.dump

~synth.set(\gainDB, ~myProcess.at(\gainDB))


~myProcess.at(\gainDB);
~myProcess.at(\triggerIntervalMs)


~connectionCallback.value( ["/spatosc/core/connection/"++ ~connectionName++"/update", 0,0,-30,1,13456]);

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




~satie.satieGroups[\default].group.set(\hpHz ,  800 );

~satie.satieGroups[\default].group.set(\hpHz ,  1 );

~satie.satieGroups[\default].group.set(\t_trig, 1)

~satie.satieGroups[\default].group.set(\decayscale, 0.6)


~setEvent.value(~nodeName, \t_trig, 1)



~allSourceNodes[\bell_0].at(\proxy).set(\gainDB ,  0 );




~satie.satieGroups[\effect].set(\aux, 0);

~satie.satieGroups[\default].set(\t_trig, 1);


~satie.satieGroups[\default].group.set(\gainDB, 4);

~satie.satieGroups[\default].set(\gainDB, -200);

~satie.satieGroupInstances[\effect][\resonance_SC].set(\outputDB, -30);


~effectProx[\effect]



~allSourceNodes[\resonance_SC].at(\auxBus);

~allSourceNodes[\resonance_SC].at(\aux);


~allSourceNodes[\resonance_SC].put(\aux, 0);

~allSourceNodes[\resonance_SC].at(\auxbus);

~allSourceNodes[\resonance_SC].at(\proxy).set(\in, ~allSourceNodes[\resonance_SC].at(\auxBus));
~allSourceNodes[\resonance_SC].at(\proxy).set(\outputDB, -30);


 ~allSourceNodes[\srcNode_0]

ScIDE.open








gainDB




// proxyspace delay problem:

// 250 ms delay with this
~satie.satieGroups[\default][~nodeName.asSymbol].set(\t_trig, 1);

// 0 ms delay with this
	~satie.satieGroups[\default].group.set(\t_trig, 1);


~satie.satieGroups[\default][~nodeName.asSymbol].set(\t_trig, 1);
~satie.satieGroups[\default].group.set(\t_trig, 1);



		~cleanInstance = { | self, name, group = \default |


	~satie.satieGroupInstances[\default][name].release();
			// fadeTime must be higher than SATIE internal fadeTime:
			~satie.satieGroupInstances[group][name].clear(0.03);
			~satie.satieGroupInstances[group].removeAt(name);
			nil;
		};









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


~connectionName = ~reverbName++"->listener:spatOSClistener_0";
~connectionCallback.value( ["/spatosc/core/connection/"++ "ball_0:spatOSCsource_1->listener:spatOSClistener_0" ++"/update", 45,0,-30,1,14000]);


~sourceCallback.value( ["/spatosc/core/source/"++~reverbName++"/prop", "outputDB", -30] );

 ["/spatosc/core/connection/"++ "ball_1:spatOSCsource_21->listener:spatOSClistener_0" ++"/update", 45,0,-30,1,14000].postln


~nodeCount=10;

// CREATE SOURCES

~nodeCount.do({ arg item;
	var nodename=("ball_"++item).asSymbol;
	var connectionName = nodename++ "->listener";
	postln("creating: "++nodename++" and connection:  "++ connectionName);
	~createSource.value(nodename, "plugin://zkarpluck1", \default);
	~createConnection.value(nodename, "listener");
	 // ~setUri.value(nodename, "plugin://zkarpluck1");
	//~connectionCallback.value( ["/spatosc/core/connection/"++ connectionName ++"/spread", 5]);
	//~connectionCallback.value( ["/spatosc/core/connection/"++ connectionName++"/update", 45,0,-80,1,14000]);

});
~allSourceNodes.size;



// SET CONNECTION

~nodeCount.do({ arg item;
	var nodename=("ball_"++item).asSymbol;
	var connectionName = nodename++"->listener";
	//postf("creating: "++nodename++"\n");
	 //~setUri.value(nodename, "plugin://zkarpluck1");
	~connectionCallback.value( ["/spatosc/core/connection/"++ connectionName ++"/spread", 5]);
	~connectionCallback.value( ["/spatosc/core/connection/"++ connectionName++"/update", 45,0,-10,1,14000]);

});





// DELETE INSTANCE
~nodeCount.do({ arg item;
		var nodename=("ball_"++item).asSymbol;

	~deleteSource.value( nodename );
});


~incidenceVal = 0;

~incidenceIndex=0;
t = Task({ {
	~nodeCount.do( { arg item;
		var pitch = 55 + rand(10);
		var nodename=("ball_"++item).asSymbol;
		var connectionName = nodename++"->listener";
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



~setProperty.value(~reverbName, \in, ~satie.aux[0]);
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

~uriPath= "process://sheefa  cloneCount 20";
~stringArray = ~uriPath.asString.split($ );
~charIndex = ~stringArray[0].asString.find("://");
~processName = ~stringArray[0].asString.subStr(~charIndex+3);
~thisargsString = ~uriPath.asString.subStr(~stringArray[0].size+1);

~thisargsString.postln;
~argsString.postln;


~uriPath= "process://sheefa 444 shit arg2 2.2 arg3";




// ~argvec = ~valueString.split($ );
//
// ~argvec.size;
//
// if ( ~argvec.size >= 2,
// 	{
// 		if ( ~argvec[0].asString == "cloneCount",
// 			{
// 				'yes'.postln;
// 				~argvec[1].asFloat.postln;
//
// 			},
// 			// else bad arg
// 			{
// 				error("sheefa.setup: unrecognized key, expecting 'cloneCount' ");
// 		});
//
//
// 		~argvec[1].asFloat.postln;
// });
//
//
// ~argvec[1].asInt.clip(1, 10000);


//type = ~uriPath.asString.subStr(0, ~charIndex-1);




// ~stringArray[0].asString.find("://");
//
// ~temp.asString.find(" ");
//
//
// ~charIndex = ~uriPath.asString.find(~processName);
//
//
// ~temp = ~uriPath.asString.subStr(~charIndex);
//

*******************************************************   AMBUZIBBUCS



p = ProxySpace.push;
~test = { EnvGen.kr(Env.adsr, Impulse.kr(3)) * PinkNoise.ar(0.8); };
~elev = {|e=0| e};
~enc = { PanAmbi3O.ar(~test.ar, MouseX.kr(-pi, pi), ~elev.kr) };
~dec = { DecodeAmbi3O.ar(~enc.ar, '1_4_7_4') };

~enc.scope












		BinAmbi3O.kemarPath_(~satieRootPath++"/utils/hrtf/full");
		BinAmbi3O.init('1_4_7_4');   // spearker configuration:  1 top,  4 high, 7 ear level, and 4 low

(
// synthDef  outputs named auxBus on named outputChannel
SynthDef(\sheefa, { arg inBus,  outChan=0;
	var ambiVec;
	var outsig;
	var sound;

	sound = PinkNoise.ar(0.01);

	ambiVec =    PanAmbi3O.ar(sound, -90.degrad,0,'1_4_7_4');



	outsig =  BinAmbi3O.ar(ambiVec);   // decodes for HRTF


	Out.ar( 0, outsig );
}).add;

)


(
// start the decoder, reading bus ~ambiBus at the \tail of Group(1)
if (q != nil, {  q.free; });
q = Synth(\sheefa, [\inBus, ~outBusIndex], 1, \addToTail);   // adding to the tail of Group(1)


)




// a ProxySpace example
p = ProxySpace.push;


q="/Users/zack/Dropbox/Unity3D/audioRendering/satie/prototype/.."++"/utils/hrtf/full";


BinAmbi3O.kemarPath_(q);
BinAmbi3O.init('1_4_7_4');

(
~azi = 45.degrad;
~ele = 0.degrad;

~px = 0;
~py = 0;
~pz = 0;
)
~test = { EnvGen.kr(Env.adsr, Impulse.kr(3)) * PinkNoise.ar(0.8); };


~enc = { PanAmbi3O.ar(~test.ar, ~azi.kr, ~azi.kr ) };

~rot = { RotateAmbi.ar(~enc.ar, ~px.kr, ~py.kr, ~pz.kr )} ;

~bin = { BinAmbi3O.ar(~enc.ar) };
~bin.play;


~bin.free;


p.pop

(
Server.supernova;
o = Server.local.options;   // default set up options

		o.blockSize = 512;    // ATK -  needs small buffer sizes or it complains

s.boot;

	// open up GUIs for monitoring
	if (~plotTree == nil,  { ~plotTree=s.plotTree;});
	if (~makeGui == nil,  { ~makeGui=s.makeGui;});
	if (~meter == nil,  { ~meter=s.meter;});


)




// a ProxySpace example

(
p = ProxySpace.push;

// The speaker positions [eleveation],[azimuth]
e = [90,40,40,40,40,0,0,0,0,0,0,0,-40,-40,-40,-40];
a = [0,45,135,225,315,25,75,130,180,230,285,335,0,90,180,270];

// adjust your path to the Kemar data
// this is relative to the SC3 folder
Kemar.path = "/Users/zack/Dropbox/Unity3D/audioRendering/satie/prototype/.."++"/utils/hrtf/full";



)

Kemar.initBuffers(a, e, s);









(
{
    var sound;
    sound = EnvGen.kr(Env.adsr, Impulse.kr(3)) * PinkNoise.ar(0.8);
    Kemar.ar(
        DecodeAmbi3O.ar(
            PanAmbi3O.ar(sound,
                MouseX.kr(-pi, pi),
                MouseY.kr(-pi, pi)),
            '1_4_7_4'
        )
    );
}.play;
)


p.pop




// a ProxySpace example
p = ProxySpace.push;

v = VBAPSpeakerArray.new(3, [[-22.5, 14.97], [22.5, 14.97], [-67.5, 14.97], [67.5, 14.97], [-112.5, 14.97], [112.5, 14.97], [-157.5, 14.97], [157.5, 14.97], [-45, 0], [45, 0], [-90, 0], [90, 0], [-135, 0], [135, 0], [0, 0], [180, 0]]); // zig zag partial dome
b = Buffer.loadCollection(s, v.getSetsAndMatrices);



~test = { EnvGen.kr(Env.adsr, Impulse.kr(3)) * PinkNoise.ar(0.8); };

~enc = { PanAmbi3O.ar(~test.ar, MouseX.kr(-pi, pi), MouseY.kr(-pi, pi)) };
~dec = { DecodeAmbi3O.ar(~enc.ar, '1_4_7_4') };



//~pink = { NumChannels.ar( PinkNoise.ar(0.8), 16); };

~pink = {  PinkNoise.ar(0.8); };

~vsig = { VBAP.ar(16, ~pink, b.bufnum, LFSaw.kr(0.5, 0).range(-180, 180) * -1, SinOsc.kr(3, 0).range(0, 14.97), 0); };



~sines = { SinOsc.ar([100,200,300,400,500,600,700,800,900, 1000, 10,20,30,40,50,60],0,0.2); };

~bin = { Kemar.ar(  ~vsig.ar )    };
~bin.stop;

p.pop


*******************

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

// spat input args:
// aziDeg degrees (-180 to 180)
// elevDeg   degrees (-180 to 180)
// gainDB  decibels
// delaySec  seconds
// lpHz    hertz
// spread  units  (0 == directional, ....,  100 == omni)

// dome speaker layout



/* speaker positions used by ambIEM
https://github.com/supercollider-quarks/AmbIEM/blob/master/Classes/DecodeAmbi.sc

azi: [0,45,135,225,315,25,75,130,180,230,285,335,0,90,180,270]
elev: [90,40,40,40,40,0,0,0,0,0,0,0,-40,-40,-40,-40],

*/


~speakerConfig1474 = [
[0 , 90 ],  // top
[45 , 40 ], // upper
[135 , 40 ],
[-135 , 40 ],
[-45 , 40 ],
[25 , 0 ],   // middle
[75 , 0  ],
[130 , 0  ],
[180 , 0  ],
[-130 , 0 ],
[-75 , 0 ],
[-25 , 0 ],
[0 , -40  ],  // lower
[90 , -40  ],
[180 , -40  ],
[-90 , -40 ]];




~spk16 = VBAPSpeakerArray.new(3, ~speakerConfig1474);



~vbuf16 = Buffer.loadCollection(s, ~spk16.getSetsAndMatrices);

~name = \_1474_VBAP;

(

~function = {|  aziDeg = 25, eleDeg = 0, gainDB = -90, delayMs = 1, lpHz = 15000, hpHz = 1, spread = 1, rotAzi=0 |
	var gain= gainDB.dbamp;   // convert gainDB to gainAMP
	var delay = delayMs * 0.001;    // convert to seconds
	var slewDelay = 0.3; //  note: this needs to be improved ... smoother
	var slewGain = 0.1;
	var slewFilter = 0.6;
	var slewPanning = 0.030;
	var panWeights;
	var outsig, sigvec, rotVec;




	panWeights = VBAP.kr(numChans: ~spk16.numSpeakers,
		in: 1.0,
		bufnum: ~vbuf16.bufnum,
		azimuth: aziDeg,
		elevation: eleDeg,
		spread: spread );

	   sigvec = PinkNoise.ar(1)  * Lag.kr(panWeights, 0.030);

	Out.ar(~outBusIndex,sigvec);

	//sigvec.scope;

	// rotVec = VBAP.ar(16, sigvec[0], ~vbuf16.bufnum, ~speakerConfig1474[ 0][0]  + rotAzi,   ~speakerConfig1474[ 0][1] );
	// rotVec =  rotVec + VBAP.ar(16, sigvec[1], ~vbuf16.bufnum, ~speakerConfig1474[ 1][0]  + rotAzi,   ~speakerConfig1474[ 1][1] );
	// rotVec =  rotVec + VBAP.ar(16, sigvec[2], ~vbuf16.bufnum, ~speakerConfig1474[ 2][0]  + rotAzi,   ~speakerConfig1474[ 2][1] );
	// rotVec =  rotVec + VBAP.ar(16, sigvec[3], ~vbuf16.bufnum, ~speakerConfig1474[ 3][0]  + rotAzi,   ~speakerConfig1474[ 3][1] );
	// rotVec =  rotVec + VBAP.ar(16, sigvec[4], ~vbuf16.bufnum, ~speakerConfig1474[ 4][0]  + rotAzi,   ~speakerConfig1474[ 4][1] );
	// rotVec =  rotVec + VBAP.ar(16, sigvec[5], ~vbuf16.bufnum, ~speakerConfig1474[ 5][0]  + rotAzi,   ~speakerConfig1474[ 5][1] );
	// rotVec = rotVec + VBAP.ar(16, sigvec[6], ~vbuf16.bufnum, ~speakerConfig1474[ 6 ][0]  + rotAzi,   ~speakerConfig1474[ 6][1] );
	// rotVec = rotVec + VBAP.ar(16, sigvec[7], ~vbuf16.bufnum, ~speakerConfig1474[ 7 ][0]  + rotAzi,   ~speakerConfig1474[ 7][1] );
	// rotVec = rotVec + VBAP.ar(16, sigvec[8], ~vbuf16.bufnum, ~speakerConfig1474[ 8 ][0]  + rotAzi,   ~speakerConfig1474[ 8][1] );
	// rotVec = rotVec + VBAP.ar(16, sigvec[9], ~vbuf16.bufnum, ~speakerConfig1474[ 9 ][0]  + rotAzi,   ~speakerConfig1474[ 8][1] );
	// rotVec = rotVec + VBAP.ar(16, sigvec[10], ~vbuf16.bufnum, ~speakerConfig1474[ 10 ][0]  + rotAzi,   ~speakerConfig1474[ 10][1] );
	// rotVec = rotVec + VBAP.ar(16, sigvec[11], ~vbuf16.bufnum, ~speakerConfig1474[ 11 ][0]  + rotAzi,   ~speakerConfig1474[ 11][1] );
	// rotVec = rotVec + VBAP.ar(16, sigvec[12], ~vbuf16.bufnum, ~speakerConfig1474[ 12 ][0]  + rotAzi,  ~speakerConfig1474[ 12][1] );
	// rotVec = rotVec + VBAP.ar(16, sigvec[13], ~vbuf16.bufnum, ~speakerConfig1474[ 13 ][0]  + rotAzi,  ~speakerConfig1474[13][1] );
	// rotVec = rotVec + VBAP.ar(16, sigvec[14], ~vbuf16.bufnum, ~speakerConfig1474[ 14 ][0]  + rotAzi,   ~speakerConfig1474[ 14][1] );
	// rotVec = rotVec + VBAP.ar(16, sigvec[15], ~vbuf16.bufnum, ~speakerConfig1474[ 15 ][0]  + rotAzi,   ~speakerConfig1474[ 15][1] );
	//
	// Out.ar(0,rotVec);
};


SynthDef(\sheefa, ~function ).add;
)

x = Synth.new( \sheefa ); // create the synth

x.set(\aziDeg,  180);
x.set(\aziDeg,  25);
x.set(\eleDeg, 0);

x.set(\rotAzi,  180);
x.free;


)


