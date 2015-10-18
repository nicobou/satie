

if (w != nil, {w.close});

w=Window.new("spatOSCexamplePreset voicing", Rect(500, 30, 400, 140)).front;
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

m = EZSlider(w, 380@20, "PRESET", ControlSpec(0.0, 6, \lin, 1, 0));
m.action_({ |ez| (  ~setPreset.value( (ez.value)))});




OSCdef(\presetCallback ).clear.free;

OSCdef(\presetCallback, ~presetCallback, "/a.renderer/preset", recvPort: 18032);



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
			~globalSet.value(\c1, 0.4);
			~globalSet.value(\c3, 5);
			~globalSet.value(\fb, 0);

		},
		1,
		{
			// harp 1
			~globalSet.value(\c1, 0.38);
			~globalSet.value(\c3, 6.11);
			~globalSet.value(\fb, 0);

		},
		2,
		{
			// harp 2 (longer dur)
			~globalSet.value(\c1, 0.15);
			~globalSet.value(\c3, 4.51);
			~globalSet.value(\fb, 0);

		},
		3,
		{
			// harp 3 (feather)
			~globalSet.value(\c1, 0.15);
			~globalSet.value(\c3, 9.51);
			~globalSet.value(\fb, 0);


		},
		4,
		{
			// lantern zoner
			~globalSet.value(\c1, 0.11);
			~globalSet.value(\c3, 3);
			~globalSet.value(\fb, 100);

		},
		5,
		{
			// lantern zoner (shorter)
			~globalSet.value(\c1, 0.7);
			~globalSet.value(\c3, 3);
			~globalSet.value(\fb, 100);

		},
		6,
		{
			// Unused
			~globalSet.value(\c1, 0.2);
			~globalSet.value(\c3, 6);
			~globalSet.value(\fb, 60);
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




