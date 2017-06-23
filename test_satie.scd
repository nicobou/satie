// testing...

(
s = Server.supernova.local;
~satie = Satie.new(s);
~satie.satieRoot;
~satie.configure_(s, "stereo");
~satie.satieConfiguration.options.blockSize = 1024;
s.reboot();
s.meter;
s.
// ~satie.satieConfiguration;
)

(
~printem = {|k, v|
	"%:\nName: %\nDescription: %\nsource%\n".format(
		k, v.getName, v.getDescription, v.getSrc.asCompileString)
	.postln;
}
)

~satie.audioPlugins.keysValuesDo(~printem);
~satie.fxPlugins.keysValuesDo(~printem);
~satie.spatPlugins.keysValuesDo(~printem);
~satie.mapperPlugins.keysValuesDo(~printem);