# Inbound OSC Messages
## Scene Messages



```javascript

/satie/scene createSource  nodeName  synthDefName<uriPath and optional args>   groupName<opt>   // default group name is 'default'
/satie/scene createGroup nodeName
/satie/scene createProcess nodeName
/satie/scene deleteNode nodeName
/satie/scene clear

//  /satie/set/prop keyword value (string, float or int)     // to set scene parameters like 'dspState'  or 'listenerFormat' etc
```
## Project Messages

```javascript

/satie/projectName setProjectDir   // full path to supercollider resources, such as soundfiles or midi files

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



// ublob message structure 
// byte order
// aziDeg (1 byte:  unsigned 8bits: posivite wrapped angles 0 : 179 --> 0 : 127,  and -180 : -1 -->  128 : 255
// elevDeg ( same as above )
// gain (4 bytes:  unsigned 32bits:  amplitude * 100000)
// delay (2 bytes : unsigned 16bits:  delayMs * 10 )
// lpHz (2 bytes) : unsigned 16bits: 
// distanceM (2 bytes : unsigned 16bits:  distanceMeters *100 )


```