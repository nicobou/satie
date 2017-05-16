# Inbound OSC Messages
## Scene Messages

The following messages are recognized by the renderer.

```javascript

// experimental
/satie/load filename    // loads and evaluates file in supercollider.  Filename must be a full file path to a file located on the audiorendering machine


/satie/rendererCtl setNearFieldRadius valueDist   // disabled when ==  0, othwewise defines the radius of a spherical region of attenuation around the listener
                                               
/satie/rendererCtl setNearFieldExp  valueExponent  // transition quality across the region:   linear transition when == 1, otherwise exponential transition
/satie/rendererCtl nearFieldInvert valueToggle   //when == true,  attenuates  sounds WITHIN the near field radius around the listener, when == false,  attenuates  sounds OUTSIDE of the near field radius around the listener
/satie/rendererCtl setOutputDB  valueDB  // set renderer output to value
/satie/rendererCtl setOutputTrimDB  valueDB  // set renderer output trim to value
/satie/rendererCtl setOutputDIM  valueToggle  // DIM renderer output to value
/satie/rendererCtl setOutputMute  valueToggle  // DIM renderer output to value
/satie/rendererCtl freeSynths   // clears supercollider's synths
/satie/rendererCtl setOrientationDeg  azimuthOffset elevationOffset  // to offset the renderer's listener orientation  (nb. only effects panning)


```
