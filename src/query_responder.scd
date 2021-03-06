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

~generatorsJSON = String.new;
~effectsJSON = String.new;

~makeJsonFromArgnames = {|key, val|
	var str, param, value, type;
	str = "";
	param = key.asString.quote;
	value = ~checkForNil.value(val);
	type = value.class.asString.quote;
	str = "{"++~jsonParam.value("name", param)++","++~jsonParam.value("value", value)++","++~jsonParam.value("type",type) ++ "},";
	~json = ~json ++ str;

};

~checkForNil = {|val|
	var value;
	if (val != nil,
		{
			value = val;
		},
		{
			value = "unused".quote;
		}
	)
};

~makeJsonArray = {| item, index |
	var str = String.new;
	postln("new item: "++ item);
	if (~satie.generatorSynthDef.includes(item.asSymbol),
		{ postln(item ++ " found in generators");
			str = item.asString.quote;
		},
		{ format("% not found in generators", item).warn}
	);
	if (~satie.effectSynthDef.includes(item.asSymbol),
		{
			postln(item ++ " found in effects");
			str = item.asString.quote;
		},
		{ format("% not found in effects", item).warn}
		);
	// TODO: separate generators and effects into two different json objects
	~json = ~json ++ str;

};

~printType = {
	| item i |
	postf("% is a %\n", item, item.class);
};

~jsonBrace = {|str|
	var ret;
	// surround a string with curly braces
	ret = "{"++str++"}";
	ret;
};

~makeGeneratorsJSON = { |key, val|
	var str;
	str = ~toJSON.value(key, val);
	~generatorsJSON = ~generatorsJSON++str;
};


~makeEffectsJSON = { |key, val|
	var str;
	str = ~toJSON.value(key, val);
	~effectsJSON = ~effectsJSON ++ str;

};


~toJSON = { |key, val|
	var str, keyName, sName;
	keyName = key[0].asString.quote;
	sName = key[1].asString.quote;
	str = ~jsonParam.value("name", keyName)++",";
	str = str++~jsonParam.value("srcName", sName)++",";
	str = str++~jsonParam.value("description", "Description...".quote);
	str = ~jsonBrace.value(str);
	str;
};

~jsonParam = {|param, value|
	// provide a quoted string representing json param followed by a colon (:)
	var str;
	str = param.quote++": "++value.asString;
};


~getAudioPlugins = { | msg , time, addr, recvPort|
	// get present synthdefs and send them via OSC as json object
	var keys, generators, effects;
	~setResponderAddress.value(addr);
	~satie.generatorSynthDef.keysValuesDo({|key, value| generators = generators.add(Array[key, value])});
	~satie.effectSynthDef.keysValuesDo({|key, value| effects = effects.add(Array[key, value])});
	generators.do(~makeGeneratorsJSON);
	effects.do(~makeEffectsJSON);
	~generatorsJSON = ~generatorsJSON.replace("\}\{", "\}, \{");
	~generatorsJSON = "["++~generatorsJSON++"]";
	~generatorsJSON = ~jsonParam.value("sources", ~generatorsJSON)++",";
	~effectsJSON = ~effectsJSON.replace("\}\{", "\}, \{");
	~effectsJSON = "["++~effectsJSON++"]";
	~effectsJSON = ~jsonParam.value("effects", ~effectsJSON);
	~json = "{" ++ ~generatorsJSON++~effectsJSON ++ "}";
	~responder.sendMsg("/plugins", ~json);
	~effectsJSON = "";
	~generatorsJSON = "";
	~json = "";
};

~getPluginArguments = { | msg , time, addr, recvPort|
	// get synth definition arguments and send them as json object
	var synth, argnames;
	~setResponderAddress.value(addr);
	synth = msg[1];
	if (~satie.pluginLoader.audioPlugins.keys.includes(synth.asSymbol),
		{
			argnames = ~satie.pluginLoader.audioPlugins[synth].def.keyValuePairsFromArgs;
		},
		{
			// FIXME: we assume it's an effect but we should make sure...
			argnames = ~satie.pluginLoader.effectPlugins[synth].def.keyValuePairsFromArgs;
		}
	);
	// watch out: there is a trailing comma after running the following line
	argnames.asArray.pairsDo(~makeJsonFromArgnames);
	// seems I need to join, else I get "Attempted to write to immutable object" on the next operation
	~json = ~json.join;
	// remove the trailing comma
	~json.removeAt(~json.size - 1);
	~json = "{\n" ++ synth.asString.quote ++ ": \n[" ++ ~json ++ "\n]}\n";
	~responder.sendMsg("/arguments", ~json);
	~json;
	~json = "";
	nil;
};


~setResponderAddress = {
	|addr|
	~responder = addr;
	postf("Sending responses to: %\n", addr);
};

OSCdef(\audioplugins, ~getAudioPlugins, '/satie/audioplugins', recvPort: 18032);
OSCdef(\pluginArgs, ~getPluginArguments, '/satie/pluginargs', recvPort: 18032);
OSCFunc(~setResponderAddress, '/satie/setAddr', recvPort: 18032);
)