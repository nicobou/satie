Platform.userHomeDir

// ~satieRootPath = thisProcess.nowExecutingPath.dirname++ "/..";   //  needed when calling ~satieMaker

(
if ( ~satieRootPath == nil,
	{
		~satieRootPath = Platform.userHomeDir++"/Dropbox/Unity3D/audioRendering/satie";
});


// AmbIEM binaural ambisonics hybrid

// The speaker positions [eleveation],[azimuth]
e = [90,40,40,40,40,0,0,0,0,0,0,0,-40,-40,-40,-40];
a = [0,45,135,225,315,25,75,130,180,230,285,335,0,90,180,270];

// adjust your path to the Kemar data
//Kemar.path = "/Applications/SuperCollider/full/";
Kemar.path = ~satieRootPath++"/utils/hrtf/full";

Kemar.initBuffers(a, e);

)


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

// a ProxySpace example
p = ProxySpace.push;

~test = { EnvGen.kr(Env.adsr, Impulse.kr(3)) * PinkNoise.ar(0.8); };

~enc = { PanAmbi3O.ar(~test.ar, MouseX.kr(-pi, pi), MouseY.kr(-pi, pi)) };
~dec = { DecodeAmbi3O.ar(~enc.ar, '1_4_7_4') };
~enc[0].scope

~bin = { Kemar.ar(~dec.ar) };
~bin.play;


~bin.clear

p.pop

