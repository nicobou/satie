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

// This file is loaded by main.scd in the same directory


/*

This is a prototype for a step in SATIE introspection via OSC.

How to use:

- Execute the code below (between the parentheses)

- Execute the next block (next set of parentheses)

- start an OSC server:

oscdump 6666 # or use your favorite OSC server listening on port 6666

- send satie the following OSC messages:

oscsend localhost 18032 /satie/audioplugins
-- SATIE server responds with json array
oscsend localhost 18032 /satie/pluginargs s misDrone
-- SATIE server responds with json

*/


(
~responder = NetAddr("localhost", 6666);

~json = String.new;

~makeJsonFromArgnames = {|key, val|
	var str, param, value, type;
	str = "";
	param = key.asString.quote;
	value = val;
	type = val.class.asString.quote;
	str = "\t{\n\t\t" ++ "name".quote ++ ": " ++ param ++ "," ++ "value".quote ++ ": " ++ value ++ "," ++ "type".quote ++ ":" ++ type ++ "\n\t}\n";
	postln("mkJsn " ++ str);
	~json = ~json ++ str;

};

~makeJsonArray = {| item, index |
	var str = String.new;
	str = item.asString.quote;
	~json = ~json ++ str;
};

~printType = {
	| item i |
	postf("% is a %\n", item, item.class);
};

~getAudioPlugins = {
	var keys, newkeys;
	keys = ~satie.pluginLoader.audioPlugins.keys.asArray;
	keys.do(~makeJsonArray);
	~json = ~json.replace("\"\"", "\", \"");
	~json = "[" ++ ~json ++ "]";
	~responder.sendMsg("/plugins", ~json);

};

~getPluginArguments = { | msg , time, addr, recvPort|
	var synth, argnames;
	synth = msg[1];
	argnames = ~satie.pluginLoader.audioPlugins[synth].def.keyValuePairsFromArgs;
	argnames.do({|item, i| item.class.postln;});
	argnames.asArray.pairsDo(~makeJsonFromArgnames);
	~json = ~json.replace("}\n\t{", "},\n\t{");
	~json = "{\n" ++ synth.asString.quote ++ ": \n[" ++ ~json ++ "\n]}\n";
	~responder.sendMsg("/arguments", ~json);
	~json = "";
	nil;
};

OSCdef(\audioplugins, ~getAudioPlugins, '/satie/audioplugins', recvPort: 18032);
OSCdef(\pluginArgs, ~getPluginArguments, '/satie/pluginargs', recvPort: 18032);

)