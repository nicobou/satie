# Inbound OSC Messages
## Scene Messages



```javascript

/satie/scene createSource  nodeName  synthDefName<uriPath>   groupName<opt>   // default group name is 'default'
/satie/scene createGroup nodeName
/satie/scene deleteNode nodeName
/satie/scene clear

/satie/scene/prop keyword value (string, float or int)     // to set scene parameters like 'dspState'  or 'listenerFormat' etc


```

## Node Messages


```javascript

// /satie/source/uri sourceName type://name  (e.g.  plugin://synthDefName )
/satie/source/prop sourceName keyword value (string, float or int)     
/satie/source/state sourceName value  // 1=DSP_active 0=DSP_inactive
/satie/source/event sourceName eventName <opt> atom1 atom2...atomN    

// /satie/group/uri groupName type://name  (e.g.  plugin://synthDefName )
/satie/group/prop groupName keyword value (string, float or int)     
/satie/group/state groupName value  // 1=DSP_active 0=DSP_inactive
/satie/group/event groupName eventName <opt> atom1 atom2...atomN    

// /satie/process/uri processName type://name  (e.g.  process://processType )
/satie/process/prop processName keyword value(string, float or int)     
/satie/process/state processName value  // 1=active 0=inactive
/satie/process/event processName eventName <opt> atom1 atom2...atomN    


/satie/source/update sourceName azimuthRADIANS elevationRADIANS gainDB delayMS  lpHZ  distanceMETERS
/satie/source/spread  sourceName value  // exponent for incidence effect:  0 = no effect;  1 = normal;   >1 = more intense               

/satie/process/update processName azimuthRADIANS elevationRADIANS gainDB delayMS  lpHZ  distanceMETERS
/satie/process/spread  processName value  // exponent for incidence effect:  0 = no effect;  1 = normal;   >1 = more intense               

```