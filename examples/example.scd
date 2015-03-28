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



//  s.makeGui;

// Server.default;




if ( false,
	{

	Server.supernova;

    o = Server.local.options;
		o.device = "MADIface USB (23635751)";
		o.memSize = 2**18;
		o.numOutputBusChannels = 32;

		//o.blockSize = 2048;
		o.dump;


		s.boot;

		s.quit;
});

s.quit;


s.reboot;
(
s.waitForBoot{

	// finding source directory
	~rootSrcPath = thisProcess.nowExecutingPath.dirname ++ "/..";
	(~rootSrcPath ++ "/src/*.scd").pathMatch.do({arg item; item.loadPaths});

	// creating a sc-basic-renderer
	~scbr = ~scbrMaker.value(~rootSrcPath);
	// loading source plugins
	~scbr.pluginLoader.loadAudioPlugins(~rootSrcPath ++ "/audiosources/*.scd");
	// see the loaded plugins in the console
	~scbr.pluginLoader.audioPlugins;
	// loading spatializer plugins
	~scbr.pluginLoader.loadSpatPlugins(~rootSrcPath ++ "/spatializers/*.scd");
	~scbr.pluginLoader.spatPlugins;
	// generating SynthDef that are going to be used,
	// here a PinkSin source spatialized by
	//   - a stereo panner (starting channel 0)
	//   - a monoSpat (starting channel 2)
	//~scbr.makeSynthDef(\fool, \PinkSin, [\stereoPanner, \monoSpat], [0, 2]);
	//~scbr.makeSynthDef(\string, \zkarpluck1, [\stereoPanner, \monoSpat], [0, 2]);
	~scbr.makeSynthDef(\vbap31, \default, [\domeVBAP], [0]);
	~scbr.makeSynthDef(\vbap8, \default, [\octoVBAP], [0]);
	~scbr.makeSynthDef(\vbap24, \default, [\labodomeVBAP], [0]);
	~scbr.makeSynthDef(\ztest1, \zkarpluck1, [\labodomeVBAP], [0]);


	// be sure the synthDef is compiled on the server
	s.sync;

	// initialization is done, create and remove a source + controls

	// make a bunch of 'em
	g = ParGroup.new;
	//80.do ( {  Synth(\vbap31, [\spread,0] , g) });
	100.do ( {  Synth(\ztest1, [\spread,0] , g) });



	// control 'em
    g.set(\gainDB, -40);
    g.set(\t_trig, 1);

	// kille 'em all
	g.freeAll;


	// if it's a karpluck, pluck 'em
	{
	t = Task({ { g.set(\t_trig, 1); 0.2.wait; }.loop });
	t.start;
}.fork;



	// spat properties
	g.set(\gainDB, -40);
	g.set(\aziDeg, 0);
	g.set(\eleDeg, 90);
	g.set(\spread, 0);
	g.set(\lfoHz, 10000);

	// source property
	//y.set(\sfreq, 100);
	// remove source
	//y.release;

	//z = Synth.tail(s, \string);
	//z.set(\t_gate, 0);
	//z.release;
};  // s.waitForBoot
)


// vbap testing,  corresponding to the "Olie" speaker config
g.set(\eleDeg, 90);

g.set(\eleDeg, 45);
{[15,75,135,-165,-105,-45 ].do({|ang| y.set(\aziDeg, ang); 1.wait; }) }.fork;


g.set(\eleDeg, 22.5);
{[0, 30, 60, 90, 120, 150, 180, -150, -120, -90, -60, -30 ].do({|ang| y.set(\aziDeg, ang); 1.wait; }) }.fork;

g.set(\eleDeg, 0);
{[0, 30, 60, 90, 120, 150, 180, -150, -120, -90, -60, -30 ].do({|ang| y.set(\aziDeg, ang); 1.wait; }) }.fork;



w=Window.new("group contrp;", Rect(30, 30, 400, 100)).front;
w.view.decorator=FlowLayout(w.view.bounds);
w.view.decorator.gap=8@2;


h = EZSlider(w, 380@20, "azi", ControlSpec(-180, 180, \lin, 1, 0));
h.action_({ |ez| ( g.set(\aziDeg, (ez.value)))});

i = EZSlider(w, 380@20, "ele", ControlSpec(-90, 90, \lin, 1, 0));
i.action_({ |ez| ( g.set(\eleDeg, (ez.value)))});

j = EZSlider(w, 380@20, "spread", ControlSpec(0, 100, \lin, 0.1, 1));
j.action_({ |ez| ( g.set(\spread, (ez.value)))});

