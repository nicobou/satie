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

// This file is loaded automatically by main.scd

// ****************** usage with OSC ************************

~createSoundSource = {| args |
	var argSize = args.size;
	var name = args[2].asSymbol;
	var synth = args[3].asSymbol;
	var proxy = \default;
	args.postln;

	case
	{ argSize == 5 } {
		proxy = args[4].asSymbol;
		postf("creating source % using % and adding to group %\n", name, synth, proxy);
		~scbr.makeInstance(name, synth, proxy);
	}
	{ argSize == 4 } {
		postf("creating source % using % and adding to group %\n", name, synth, proxy);
		~scbr.makeInstance(name, synth, proxy);
	}
	{ argSize < 4 } {
		postf("Message reguires 4 or 5 arguments, there were only %\n", argSize);
		postf("The message was: %\n", args);
	}

};

~removeSoundSource = { |sourceName|
	var name = sourceName;
	postf("Removing and cleaning %\n", name);
	~scbr.cleanInstance(name);
};

~coreCallback = { | msg |
	var command = msg[1];
	// postf("coreCallback argument: %\n", msg);

	switch(command,
		\createSoundSource,
		{
			var instanceName = msg[2];
			postf("Creating sound source: ---> %\n", instanceName);
			~scbr.oscInterface.createSourceOSC(instanceName, ~createSoundSource);
		},
		\deleteSoundSource,
		{
			var instanceName = msg[2];
			postf("Removing sound source: ---> %\n", instanceName);
			~scbr.oscInterface.removeSourceOSC(instanceName);
			~removeSoundSource.value(instanceName);
		}
	)
};

s.sync;
~scbr.oscInterface.newOSC(\satieOSC, ~coreCallback);

