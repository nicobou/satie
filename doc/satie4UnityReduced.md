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


// node messages

// for nodeTypes:  source, group, or process
/satie/<nodeType>/state nodeName value  // 1=active 0=inactive
/satie/<nodeType>/event nodeName eventName <opt> atom1 atom2...atomN    
/satie/<nodeType>/set nodeName key1 val1 key2 val2 .... keyN valN

// only for nodeTypes: source and process
/satie/<nodeType>/update processName azimuthRADIANS elevationRADIANS gainDB delayMS  lpHZ  distanceMETERS
/satie/<nodeType>/ublob sourceName byte1 ... byte12     // for update blob: packed encoded update message  (some loss)

// only for nodeType: groups
/satie/group/add groupName sourceName    
/satie/group/drop groupName sourceName   

// only for noteType: process
/satie/process/event processName eventName <opt> atom1 atom2...atomN       



// ublob message structure 
// byte order
// azi (1 byte:  unsigned 8bits: posivite wrapped angles 0 : 179 --> 0 : 127,  and -180 : -1 -->  128 : 255
// elev ( same as above )
// gain (4 bytes:  unsigned 32bits:  amplitude * 100000)
// delay (2 bytes : unsigned 16bits:  delayMs * 10 )
// lpHz (2 bytes) : unsigned 16bits: 
// distanceM (2 bytes : unsigned 16bits:  distanceMeters *100 )


```