# H2 Inbound OSC Messages
## H2 Scene Messages



```javascript

/satie/scene createSource  nodeName uriPath<or emptyString>  groupName<or emptyString>
/satie/scene createGroup nodeName
/satie/scene deleteNode nodeName
/satie/scene clear

/satie/scene/prop keyword value(s) (string, float or int)     // to set scene parameters like 'dspState'  or 'listenerFormat' etc


```


```javascript

## H2 Node Messages


/spatosc/core/listener/nodeName/uri  type://name  (e.g.  plugin://testnoise~ )
/spatosc/core/listener/nodeName/prop keyword value(s) (string, float or int)     
/spatosc/core/listener/nodeName/state value  // 1=DSP_active 0=DSP_inactive
/spatosc/core/listener/nodeName/event  eventName <opt> atom1 atom2...atomN      

/spatosc/core/source/nodeName/uri  type://name  (e.g.  plugin://testnoise~ )
/spatosc/core/source/nodeName/prop keyword value(s) (string, float or int)     
/spatosc/core/source/nodeName/state value  // 1=DSP_active 0=DSP_inactive
/spatosc/core/source/nodeName/event  eventName <opt> atom1 atom2...atomN    

/spatosc/core/group/nodeName/uri  type://name  (e.g.  plugin://testnoise~ )
/spatosc/core/group/nodeName/prop keyword value(s) (string, float or int)     
/spatosc/core/group/nodeName/state value  // 1=DSP_active 0=DSP_inactive
/spatosc/core/group/nodeName/event  eventName <opt> atom1 atom2...atomN    



/satie/source/update azimuthRADIANS elevationRADIANS gainDB delayMS  lpHZ  distanceMETERS
/satie/source/spread  value  // exponent for incidence effect:  0 = no effect;  1 = normal;   >1 = more intense               


```