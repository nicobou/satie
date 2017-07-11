## SATIE (Spatial Audio Toolkit for Immersive Environments)

SATIE is an audio spacialization engine developed for realtime rendering of dense audio scenes to large multi-channel loudspeaker systems. It is a lower-level audio rendering process that maintains a dynamic DSP graph which is created and controlled via OSC messages from an external process. SATIE’s modular development environment provides for optimized real-time audio scene and resource management. There is no geometry per se in SATIE, rather, SATIE maintains a DSP graph of source nodes that are accumulated to a single "listener", corresponding to the renderer’s output configuration (stereo and/or multi-channel).

Its aim is to facilitate using 3D space in audio music/audio composition and authoring and to play well with 3D audio engines (so far it has been used with Blender and Unity3D) and could also serve as volumetric audio spacialization addition to more traditional desktop DAW systems. 

SATIE is built with SuperCollider, an audio programming environment and language and is controlled via OSC. See instructions for [installing SuperCollider 3.8](INSTALL-SC.md). 

