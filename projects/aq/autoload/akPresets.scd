

if (w != nil, {w.close});

w=Window.new("AQ_bell_Preset voicing", Rect(500, 30, 400, 140)).front;
w.view.decorator=FlowLayout(w.view.bounds);
w.view.decorator.gap=8@2;


// g = EZSlider(w, 380@20, "pitch ", ControlSpec(40, 110, \lin, 1, 60));
// g.action_({ |ez| (  ~bellSet.value(\note, [ ez.value, 1, 0.5 ] );  ~bellSet.value(\t_trig, 1);)});


// h = EZSlider(w, 380@20, "amp", ControlSpec(0, 1, \lin, 0.01, 0.5));
// h.action_({ |ez| (  ~globalSet.value(\amp, (ez.value)))});
//


g = EZSlider(w, 380@20, "decay", ControlSpec(0.0, 1, \lin, 0.01, 0.14));
g.action_({ |ez| (  ~ballSet.value(\decay, (ez.value)))});

/*
j = EZSlider(w, 380@20, "c1", ControlSpec(0.05, 5, \lin, 0.01, 1));
j.action_({ |ez| (  ~ballSet.value(\c1, (ez.value)))});


k = EZSlider(w, 380@20, "c3", ControlSpec(0.05, 20, \lin, 0.01, 1));
k.action_({ |ez| (  ~ballSet.value(\c3, (ez.value)))});

l = EZSlider(w, 380@20, "fb", ControlSpec(0.0, 100, \lin, 0.1, 20));
l.action_({ |ez| (  ~ballSet.value(\fb, (ez.value)))});

m = EZSlider(w, 380@20, "PRESET", ControlSpec(0.0, 6, \lin, 1, 0));
m.action_({ |ez| (  ~setPreset.value( (ez.value)))});*/


// proxyspace delay problem:

// 250 ms delay with this
 //   ~scbr.satieGroups[\default][\ball_0].set(\t_trig, 1);

// 0 ms delay with this
//	~scbr.satieGroups[\default].group.set(\t_trig, 1);




OSCdef(\presetCallback ).clear.free;

OSCdef(\presetCallback, ~presetCallback, "/a.renderer/preset", recvPort: 18032);


	~bellSet = { | param, value |
		~scbr.satieGroups[\default].set(param.asSymbol, value);
	};


~setPreset = {
	arg presetNo;
	if (presetNo < 0, {presetNo=0});
	if (presetNo > 6, {presetNo=6});



	postf("~setPreset no: %\n", presetNo.asInt);
	switch (presetNo.asInt,
		0,
		{

						postf("~setPreset no: %\n", presetNo);

			// harp 0
			~bellSet.value(\decay, 0.1);
		},
		1,
		{
			// harp 1
			~bellSet.value(\decay, 0.3);
		},
		2,
		{
			// bell 2 (longer dur)
			~bellSet.value(\decay, 0.5);
		},
		3,
		{
			// bell 2 (longer dur)
			~bellSet.value(\decay, 0.7);
		},
		4,
		{
			// bell 2 (longer dur)
			~bellSet.value(\decay, 0.8);
		},
		5,
		{
				// bell 2 (longer dur)
			~bellSet.value(\decay, 0.9);
		},
		6,
		{
				// bell 6 (longer dur)
			~bellSet.value(\decay, 0.95);
		}
	);
};


~presetCallback = {
	arg msg;
	var presetNo = msg[1];

	postf("~basicRendererCallback: command: %, msg: %, \n", presetNo, msg);

	if (msg.size < 2,
		{
			"~presetCallback: empty message".warn;
			postf("~presetCallback MESS LEN: %", msg.size);

		},
		// else
		{
			~setPreset.value(presetNo);
	});
};


//~scbr.satieGroups[\default].set(\decay, 0.0, \t_trig, 1)

