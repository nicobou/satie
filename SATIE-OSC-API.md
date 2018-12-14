# SATIE OSC protocol API

## Scene Messages

A "scene" contains source/effect/process nodes which are kept in groups.
These messages create and manage scene content.

#### /satie/load filename
Load and evaluate a file in supercollider. Filename must be a full file path to a file located on the audio rendering machine

#### /satie/scene/createSource nodeName synthdefName \<groupName\>
Instantiate an audio generator plugin.

- nodeName : the name of the instance.
- synthDefName : the name of the synthdef registered with the system.
- groupName : (optional) the name of the group. Default: '\\default'

#### /satie/scene/createEffect nodeName synthdefName \<groupName\> \<auxBus\>
   Instantiate an audio effect plugin

-  nodeName : the name of the instance.
-  synthDefName : the name of the synthdef registered with the system.
-  groupName : (optional) the name of the group. Default: '\defaultFx'
-  auxBus: (optional) number of aux bus for the effect's input. Default: '0'

#### /satie/scene/createProcess nodeName processName \<optargs\>
Create/instantiate a `process`

-  nodeName : the name of the instance.
-  processName : the name of the defined process followed by its arguments, if any

#### /satie/scene/createSourceGroup nodeName
Create a new group at the head of the Satie's DSP chain

-  nodeName : name of the group.

#### /satie/scene/createEffectGroup nodeName
Create a new group at the end of Satie's DSP chain

-  nodeName : name of the group.

#### /satie/scene/createProcessGroup nodeName
Create a new group on the head of the DSP chain

-  nodeName : name of the group.

#### /satie/scene/deleteNode nodeName
Delete a node

-  nodeName : the name of the node to be deleted

#### /satie/scene/clear
Clear the scene. Removes all instances and groups.

#### /satie/scene/debug debugFlag
   Enable or disable debug printing
-  debugFlag : 1 or 0, defaults to 0

## Node messages

Nodes are instances of audio sources, effects or processes. Nodes also belong to groups. There are three ways of addressing a node:

-   source - individual instance of type `source` or `effect`
-   group
-   process

#### /satie/\<nodeType\>/state nodeName value
Node state (whether it is playing/computing or not): 1 = active, 0 = inactive

#### /satie/\<nodeType\>/set nodeName key1 val1 key2 val2 .... keyN valN
Set a property

#### /satie/\<nodeType\>/setvec nodeName key val1 ..... valN
Set a vector

<pre class=note>
<span class=note text>NOTE:<span> `set` and `setvec` messages are used to address specific properties. Each node has two groups of properties: those provided by the spatializer and those specific to the node. The latter vary from node to node.
</pre>
Properties common to all:

- preBus\_gainDB (dB) default = 0
- postBus\_gainDB (dB) default = 0

Spatializer properties (contained in most spatializers)

- aziDeg  (0 - 360 (degrees)) default = 0
- eleDeg (-90 - 90 (degrees)) default 0
- gainDB (dB) default = 0
- delayMs (milliseconds) default 1
- lpHz (Hz) default = 15000
- hpHz (Hz) default = 1
- spread (range (0 to 100)) default = 1

## Only for nodeTypes: source and process

#### /satie/\<nodeType\>/update nodeName azimuth elevation gainDB delayMS lpHz distance
Update many essential properties at once. This message is typically sent every frame, all properties relate to node's position.

<pre class=note>
<span class=note text>NOTE:<span> 'distance' applies only to processes.
</pre>

-  nodeName : name of the node
-  azimuth : azimuth in degrees (-180 ... 180)
-  elevation : elevation in degrees (-180 ... 180)
-  gainDB : gain in decibles
-  delayMS : delay in miliseconds
-  lpHz : low pas filter in Hertz
-  distance : distance in meters (can be omitted when updating sources and groups)

### Only for noteType: process

#### /satie/process/property processName key value
Update a process environment property

- property key, value

#### /satie/process/eval processName handlerName optArg1 ... opeArgN
Invoke a process function with zero or more arguments

- eval handlerName, args\[\]

## Introspection

You can query SATIE via OSC and get some information. SATIE responds to the following messages:

#### /satie/plugins
get existing synthdefs

SATIE responds with an osc message: /plugins JSON string containing 3 objects: generators, effects and mastering, each being a JSON object name: {type, description} (where name = the "id" passed to Satie::makeSynthDef, type = SatiePlugin

Example output (line wrapped for readability):
``` javascript
{ "generators":
  { "mybuffer": { "description": "Play a buffer", "type": "sndBuffer"}
}}
```
#### /satie/pluginargs synthdefName
get arguments of some synthdef

- synthdefName string

SATIE responds with an osc message: /arguments JSON string representing plugin's name, description and list of arguments and default values, for exemple:
``` javascript
{ "test":
  { "description":
    "a standard test tone (sine)",
  "arguments":
    { "sfreq": 200 }, "srcName": "testtone"
  }
}
```
#### /satie/responder ip port
- *ip*, *port* are a string and int

<pre class=note>
<span class=warning>WARNING:</span> Keep in mind, however, that prior to any OSC communication, the default destination address is localhost:18060. If SATIE server is not being controlled, messages from Monitoring/Analysis destination
</pre>

#### /satie/plugindetails synthdefName  // get arguments of some synthdef

- synthdefName string

Like above, SATIE responds with an osc message: /arguments JSON string representing plugin's name, description and list of arguments, their types and default values, wrapped in a dictionary like the example below:
``` javascript
{ "misDrone":
    { "description": "a rich drone sound", "arguments":
        [ { "name": "freq", "value": 200, "type": "Integer" },
            { "name": "dur", "value": 22, "type": "Integer" },
            { "name": "amp", "value": 0.75, "type": "Float" } ],
        "srcName": "misDrone"
    }
}
```
<pre class=note>
<span class=note text>Note:</span> by default, the response is sent to ip:port of the sender. It can be set permanently for the duration of the session via by
sending <span class=.code>/satie/responder</span> a message containing IP and port.
</pre>

## Monitoring/Analysis

There are two other OSC handlers available:

#### /trigger
   forward trigger messages from `SendTrig`

#### /analysis
   forward messages received from `SendReply`

These two are provided as convenience functionality for getting information from running synths. The SendTrig and SendReply UGens can, of course, be used in your SynthDefs but SATIE can load plugins specially designed to measure signals and send triggers or streams measured data.
