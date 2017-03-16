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

// elininated:  /satie/source/uri sourceName type://name  (e.g.  plugin://synthDefName )
// eliminated:   /satie/source/prop sourceName keyword value (string, float or int)     
/satie/source/state sourceName value  // 1=DSP_active 0=DSP_inactive
/satie/source/event sourceName eventName <opt> atom1 atom2...atomN    
/satie/source/set sourceName key1 val1 key2 val2 .... keyN valN
/satie/process/update processName azimuthRADIANS elevationRADIANS gainDB delayMS  lpHZ  distanceMETERS
/satie/source/ublob sourceName byte1 ... byte12     // for update blob: packed encoded update message  (some loss)
// ublob message 
// byte order
// azi (1 byte:  unsigned 8bits: posivite wrapped angles 0 : 179 --> 0 : 127,  and -180 : -1 -->  128 : 255
// elev ( same as above )
// gain (4 bytes:  unsigned 32bits:  amplitude * 100000)
// delay (2 bytes : unsigned 16bits:  delayMs * 10 )
// lpHz (2 bytes) : unsigned 16bits: 
// distanceM (2 bytes : unsigned 16bits:  distanceMeters *100 )


// /satie/group/uri groupName type://name  (e.g.  plugin://synthDefName )
// eliminated   /satie/group/prop groupName keyword value ( string, float or int )     
/satie/group/state groupName value  // 1=DSP_active 0=DSP_inactive
/satie/group/event groupName eventName <opt> atom1 atom2...atomN    
/satie/group/add groupName sourceName    
/satie/group/drop groupName sourceName   
/satie/group/set groupName key1 val1 key2 val2 .... keyN valN


// /satie/process/uri processName type://name  (e.g.  process://processType )
// eliminated   /satie/process/prop processName keyword value ( string, float or int )   
/satie/process/property processName  key value    // sets named proocess environment variables
/satie/process/state processName value  // 1=active 0=inactive
/satie/process/event processName eventName <opt> atom1 atom2...atomN    
/satie/process/set processName key1 val1 key2 val2 .... keyN valN
/satie/process/update processName azimuthRADIANS elevationRADIANS gainDB delayMS  lpHZ  distanceMETERS
/satie/process/ublob processName byte1 ... byte12     // for update blob: packed encoded update message  (some loss)


// note, for sources, groups, and processes
// set message replaces  /satie/nodeType/update nodeName azimuthRADIANS elevationRADIANS gainDB delayMS  lpHZ  distanceMETERS
// set message replaces  /satie/nodeType/spread  sourceName value  // exponent for incidence effect:  0 = no effect;  1 = normal;   >1 = more intense               
// set message replaces  /satie/nodeType/hpHz  sourceName hpHZ  

// NOTE:  the same should be done for the /satie/nodeType/state message

```