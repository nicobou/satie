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

The plugin will create a new tab in the Tool Shelf. Click on SATIE tab, expand "SATIE tool" and click the button labelled "SATIE sound source" in order to activate addon's processing of events.

Another panel, called "SATIE proprties" is created in the object properties section 
Check Use SATIE in order to instantiate a SATIE plugin. 
ID field is mandatory 

# Disclaimer

This is a prorotype that show some functionality. You can attach a SATIE instance to a blender object, move it around and hear the movement in the speakers. There is not much error checking, no synth object management and there are bugs. Use it at your own risk.
