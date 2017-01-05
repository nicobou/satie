#!/bin/bash
cd satie4blender
version=`blender --version | egrep -o "Blender [0-9.]+" | egrep -o "[0-9.]+"`
mkdir -p ~/.config/blender/$version/scripts/addons/satie4blender
cp -v * ~/.config/blender/$version/scripts/addons/satie4blender
