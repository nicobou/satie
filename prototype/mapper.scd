s.boot;
s.makeGui;
s.meter;
(
~srcfunc = { SinOsc.ar()};
~spatfunc = {|in = 0, aziDeg = 0, eleDeg = 0, gainDB = 0, delayMs = 1, lpHz = 15000, hpHz = 1, spread = 1 |
	var gain= gainDB.dbamp;   // convert gainDB to gainAMP
	var delay = delayMs * 0.001;    // convert to seconds
	var slewDelay = 0.3; //  note: this needs to be improved ... smoother
	var slewGain = 0.1;
	var slewFilter = 0.6;
	var slewPanning = 0.030;
	var panWeights;

	var aziScale = 0.01 * (100 - spread);
	var theta = aziScale * aziDeg *  0.01745329251994;  // radians
	var index = SinOsc.kr(0, theta);
	var outsig;

	outsig =  LPF.ar(DelayC.ar(
		VarLag.kr(gain, slewGain) * in,
		maxdelaytime: 0.5,
		delaytime: delay.lag(slewDelay)),   lpHz.lag(slewFilter)    );

	outsig = BHiPass.ar(outsig, VarLag.kr(hpHz, slewFilter )  );

	Pan2.ar(outsig, index );
};

~mapfunc = {| aziDeg = 0, eleDeg = 0, gainDB = -90, delayMs = 1, lpHz = 15000, hpHz = 0.5 , spread = 1, myfactor = 1 |
	var myazi = myfactor * aziDeg;
	[myazi, myfactor * eleDeg, gainDB, delayMs, lpHz, hpHz, spread];
}
)


(
SynthDef(\text,
	// can the "gate" arg name be changed to avoid conflicts with plugin-synthDefs that use it
	{	var in, env, out, mapped;
		in = SynthDef.wrap(~srcfunc);
		// in -> dest
		mapped = SynthDef.wrap(~mapfunc);
		out = SynthDef.wrap(~spatfunc, prependArgs: [in] ++ mapped);
		//var out = SynthDef.wrap(item, prependArgs: [in, vol, delay, azi, ele]);
		Out.ar(0, out);

}).add;
)


x= Synth(\text);

x.set(\gainDB, 0);
x.set(\aziDeg, 90);
x.set(\myfactor, 0.5);