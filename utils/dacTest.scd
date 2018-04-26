(
// DAC tester
//    to stop without gui
//		~task.stop;
//		~dacTestSyn.release;

~panDur=0.4;
~usingServer = "Built-in Output"; // OSX only

~channelCount= Server.local.options.numOutputBusChannels;

if  ( ~channelCount == 32,
	{
		~channelCount= ~channelCount-1;
});


SynthDef(\speakerMapTest, { |out, gate=1|
    Out.ar(out, WhiteNoise.ar(1) * EnvGen.kr(Env.asr(0.03, 0.3, 0.01), gate, doneAction:2));
}).store; // use store for compatibility with pattern example below

~task= Task({
    loop {
		~channelCount .do({ arg item;
			~dacTestSyn = Synth(\speakerMapTest, [\out, item,]); // play out through hardware output bus 0 (see Out.help)
            ~panDur.wait;
			~dacTestSyn.release;
        });
    }
});

~rebootServerUsing = {
	Platform.case(
		\osx, {
			var deviceName = ~usingServer;
			deviceName.postln;
			Server.local.options.device = deviceName;
			("booting with: "++deviceName).postln;
		});
	s.reboot;
    ("THE SERVER IS :  "++s).postln;
    Server.allRunningServers.postln;
};


// UI
~dacTestWindow=Window.new("dac testing", Rect(30, 30, 400, 130)).front;
~dacTestWindow.view.decorator=FlowLayout(~dacTestWindow.view.bounds);
~dacTestWindow.view.decorator.gap=8@2;


~stateButton = Button(~dacTestWindow, 75 @ 30);
~stateButton.states = [
    ["Start", Color.black, Color.green(0.7)],
    ["Stop", Color.white, Color.red(0.7)]
];

~stateButton.action = { |view|
	view.value.postln;

	if (view.value == 1, {
		~task.play;
	},
	//else stop
	{
		~task.stop;
		~dacTestSyn.release;
	});

};

~testWindButton = Button(~dacTestWindow, 120 @ 30);
~testWindButton.states = [
	["view checkboxes", Color.white, Color.gray],
	["view checkboxes", Color.white, Color.gray]
];

~testWindButton.action = { |view|
	view.value.postln;

	if (view.value == 1, {
		 ~genSpeakerTestWindow.value(~channelCount);
	},
	//else stop
	{
		 ~genSpeakerTestWindow.value(~channelCount);

	});

};

~chanCountSlider = EZSlider(~dacTestWindow, 380@20, "channels", ControlSpec(0, 31, \lin, 1, ~channelCount));
~chanCountSlider.action_({ |ez| (  ~channelCount = ez.value;   )});

~panDurSlider = EZSlider(~dacTestWindow, 380@20, "panDuration", ControlSpec(0.05, 2, \lin, 0.02, 0.4));
~panDurSlider.action_({ |ez| (  ~panDur = ez.value;   )});

g = EZPopUpMenu.new(~dacTestWindow,250@30 ,"Device : ");

Button.new(~dacTestWindow,Rect(10,10,120,30)).states_([["reboot server"]]).action_(~rebootServerUsing);

Platform.case (
	\osx, {
		z=0;
		ServerOptions.outDevices.do({ arg key ;
			var index = z;
			//postf("dev: "++z++"  "++key.asSymbol++"\n");
			g.addItem(key.asSymbol, { |a| ( ~usingServer= ServerOptions.outDevices[index] ) });
			z=z+1;
		});
	}
);

// speaker test window

~speakerTestWindow=nil;
~genSpeakerTestWindow = { | speakerCount |
	var w, b;

	if ( ~speakerTestWindow == nil,
		{
			~speakerTestArray = Array.fill(speakerCount,'');
			w = GUI.window.new( "Test Outputs", Rect( 128, 64, 380, 108 ));

			w.view.decorator = FlowLayout( w.view.bounds );
			w.view.background = Color.black;

			w.onClose_({ ~killSynths.value() }); //close the window and the synth plays

			speakerCount.do({ arg i;
				b = GUI.button.new( w, Rect( rrand( 20, 300 ), rrand( 20, 300 ), 30, 30 ));
				b.states = [[ i.asSymbol, Color.white, Color.gray ],
					[ i.asSymbol, Color.white, Color.red ]];

				b.action = { |view|
					var index = i;
					if (view.value == 1, {
						~speakerTestArray.put(index, Synth(\speakerMapTest, [\out, index]));
					},
					//else stop
					{
						~speakerTestArray.at(index) .free
					});
				};
			});
			~speakerTestWindow = w;
	});
	~speakerTestWindow.front;
};

~killSynths = {
	"KILLING ALL SYNTHS".postln;

	~speakerTestArray.do({arg item;
		if ( item!=nil, { item.free});
		~speakerTestWindow = nil;
	});

};
)