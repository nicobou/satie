# Inbound OSC Messages
## Scene Messages



```javascript

/satie/scene createSource  nodeName  synthDefName<uriPath>   groupName<optional>   // default group name is 'default'
/satie/scene createGroup nodeName
/satie/scene deleteNode nodeName
/satie/scene clear

/satie/scene/prop keyword value(s) (string, float or int)     // to set scene parameters like 'dspState'  or 'listenerFormat' etc


```


```javascript

## Node Messages


/satie/source/uri nodeName type://name  (e.g.  plugin://testnoise~ )
/satie/source/prop nodeName keyword value(string, float or int)     
/satie/source/state nodeName value  // 1=DSP_active 0=DSP_inactive
/satie/source/event nodeName eventName <opt> atom1 atom2...atomN    

/satie/group/uri nodeName type://name  (e.g.  plugin://testnoise~ )
/satie/group/prop nodeName keyword value(string, float or int)     
/satie/group/state nodeName value  // 1=DSP_active 0=DSP_inactive
/satie/group/event nodeName eventName <opt> atom1 atom2...atomN    



/satie/source/update nodeName azimuthRADIANS elevationRADIANS gainDB delayMS  lpHZ  distanceMETERS
/satie/source/spread  nodeName value  // exponent for incidence effect:  0 = no effect;  1 = normal;   >1 = more intense               


```