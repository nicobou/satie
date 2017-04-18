# Inbound OSC Messages
## Scene Messages

The following messages are recognized by the renderer.

```javascript

// experimental
/satie/load filename    // loads and evaluates file in supercollider.  Filename must be a full file path to a file located on the audiorendering machine


/satie/rendererCtl setNearFieldRadius    valueDist  // set renderer output to value
/satie/scene createSource  setNearFieldInvert  valueToggle  // set renderer output to value
/satie/scene createProcess setOutputDB  valueDB  // set renderer output to value
/satie/scene createProcess setOutputTrimDB  valueDB  // set renderer output trim to value
/satie/scene createProcess setOutputDIM  valueToggle  // DIM renderer output to value
/satie/scene createProcess setOutputMute  valueToggle  // DIM renderer output to value
/satie/renderCtl  freeSynths   // clears supercollider's synths


```
