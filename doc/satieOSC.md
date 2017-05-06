# Inbound OSC Messages
## Scene Messages



```javascript

// experimental
/satie/load filename    // loads and evaluates file in supercollider.  Filename must be a full file path to a file located on the audiorendering machine


/satie/scene createSource  nodeName  URI<plugin://synthdefName groupName<opt>   // default groupName = 'default'
/satie/scene createSource  nodeName  URI<effect://synthdefName  optionalArgs: inbus N >   groupName<opt>   // defaults:  groupName = 'defaultFx',  inbus = 0
/satie/scene createGroup nodeName   optionalURI<effect://>   // uri determines the DSP position of group (head or tail)   -defaults to head
/satie/scene createProcess nodeName URI<uriPath process://processName optargs >   // unique group is automatically generated for each created process node
/satie/scene deleteNode nodeName
/satie/scene clear
/satie/scene/set keyword value   // to set scene parameters like 'debugFlag 1'



```
## Project Messages

```javascript

/satie/project/projectName setProjectDir   // full path to supercollider resources, such as soundfiles or midi files

```

## Node Messages


```javascript

// for nodeTypes:  source, group, or process
/satie/<nodeType>/state nodeName value  // 1=active 0=inactive
/satie/<nodeType>/event nodeName eventName <opt> atom1 atom2...atomN    
/satie/<nodeType>/set nodeName key1 val1 key2 val2 .... keyN valN
/satie/<nodeType>/setvec nodeName key val1 .....  valN

// only for nodeTypes: source and process
/satie/<nodeType>/update nodeName azimuthDegrees elevationDegrees gainDB delayMS  lpHZ  distanceMETERS
/satie/<nodeType>/ublob nodeName byte1 ... byte12     // for update blob: packed encoded update message  (some loss)


// only for noteType: process
/satie/process/property processName key value   // to update a process environment property       


```
#### ublob message structure 
```
byte order
aziDeg (1 byte:  unsigned 8bits: posivite wrapped angles 0 : 179 --> 0 : 127,  and -180 : -1 -->  128 : 255
elevDeg ( same as above )
gain (4 bytes:  unsigned 32bits:  amplitude * 100000)
delay (2 bytes : unsigned 16bits:  delayMs * 10 )
lpHz (2 bytes) : unsigned 16bits: 
distanceM (2 bytes : unsigned 16bits:  distanceMeters *100 )


```
## Processes message handling and method invocation
```javascript

Optional Override handlers

Message handelers can be defined in a processs environment. If defined, the handles will be called by satieOSC.
They override satieOSCs corresponding generic handlers, that apply these messages to the processNodes group (or environment, in the case of the  'property' message
satieOSC provides an override mechanism for the following  messages, which are handled by the corresponding process functions as shown:

/satie/process/update    processName  azi ele gdb del lpf dst    -->  handled by process[\update]
/satie/process/property  processName  key value  -->  handled by process[\property]
/satie/process/state     processName  state      -->   hadled by  process[\state]
/satie/process/set       processName  key value  -->  handled by process[key]
/satie/process/set       processName  key value  -->  handled by process[\set]   (unless process[key] is defined)
/satie/process/setvec    processName  key  val1 .... valN      -->   handled by process[key]


Custom key-specific message handlers  can be defiend for  'set'  and 'setvec'  messages
If defined, satie4unity will call these handlers according to the 'key'  with corresponding arguments as shown:
/satie/process/set nodeName key val    -->  hadled by  process[\key]   val
/satie/process/setvec  nodeName key  val1 ... valN    -->   -->  hadled by  process[\key]  val1 ... valN

```