## SATIE (Spatial Audio Toolkit for Immersive Environments)

SATIE is an audio spatialization engine developed for realtime rendering of dense audio scenes to large multi-channel loudspeaker systems. It is a lower-level audio rendering process that maintains a dynamic DSP graph which is created and controlled via OSC messages from an external process. SATIE’s modular development environment provides for optimized real-time audio scene and resource management. There is no geometry per se in SATIE, rather, SATIE maintains a DSP graph of source nodes that are accumulated to a single "listener", corresponding to the renderer’s output configuration (stereo and/or multi-channel).

Its aim is to facilitate using 3D space in music/audio composition and authoring, to play well with 3D audio engines (so far it has been used with Blender and Unity3D) or to serve as a volumetric audio spatialization addition to more traditional desktop DAW systems.

SATIE is built with SuperCollider, an audio programming environment and language and is controlled via OSC. See instructions for [installing SuperCollider 3.9](INSTALL-SC.md).

See [SATIE OSC API](SATIE-OSC-API.md) for details on OSC communication.

There are also some known efforts to make bridges for specific software:

- [gdosc](https://github.com/djiamnot/gdosc) module for [Godot](https://godotengine.org) game engine.
- A Unity example can be found here: https://gitlab.com/sat-metalab/satie4unityExample
- [PySATIE](https://gitlab.com/sat-metalab/PySATIE) is a Python module which allows for some SATIE control directly from python code (particularly useful for use with [Blender](https://www.blender.org/) or [Panda3d](https://www.panda3d.org/))

## Directory structure

SATIE internal plugins:
- audiosources:  sound sources (like file player)
- effects:       effect (like reverb)
- spatializers:  spatialization (like stereo)
- mappers:       mapper
- postprocessors:  audio mastering
- processes:     generating many events algorithmically

other:
- HelpSource:    documentation, in schelp format, available within SC IDE (scide)
- src:           SATIE implementation
- satie-assets:  submodule containing some ambisonics related assets
- utils:         diagnostics and other tools
- tests:         unit tests and other testing scripts

## License

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version. See [LICENSE](LICENSE) for the license text.

## Sponsors

This project is made possible thanks to the [Society for Arts and Technology](http://www.sat.qc.ca/) [SAT] and to the Ministère de l'Économie, de la Science et de l'Innovation (MESI) du Québec.
