# satie4blender

This is a plugin for the Blender editor, it allows interactions with [SATIE](https://gitlab.com/sat-metalab/SATIE) spatialization engine. 

# Dependencies

sudo apt install blender python3-liblo 


# Installation

run ./zipit.sh from this directory, it will produce satie4blender.zip archive in satie/plugins. 
Run blender, open preferences, locate addons tab, click "Install from File" button and locate the above archive. The plugin will appear as SATIE OSC in the "User" category. Activate it by clicking on the check-box.

# In place installation (for developer using blender 2.76)

```
mkdir -p ${HOME}/.config/blender/2.76/scripts/addons
ln -s ${HOME}/src/satie/plugins/satie4blender ${HOME}/.config/blender/scripts/addons
```

# Example use

The plugin will create a new tab in the Tool Shelf. Click on SATIE tab, expand it, if necessary. 
OSC destination is the IP address of the computer running SuperCollider. The destination OSC port is SATIE's destination port (18032 by default). OSC server is Blender addon's OSC server receiving various types of information from SATIE (6666 by default).

Click the toggle labeled "Use Satie" in order to activate the OSC processes.

Once SATIE addon is active it will populate SATIE specific properties in the Object Buttons section. Any Blender object can be associated with a SATIE source or effect. "SATIE properties" panel will list plugins by family (source, effect) and will show only the selected family. The sound source menu shows only plugins registered with SATIE (i.e. compiled synthdefs ready for instantiation). Selecting a sound source will also display its parameters.

Toggle "Use SATIE" to instantiate ou destroy selected sound source. 

# Disclaimer

This is a prorotype that show some functionality. You can attach a SATIE instance to a blender object, move it around and hear the movement in the speakers. There is not much error checking, no synth object management and there are bugs. Use it at your own risk.
