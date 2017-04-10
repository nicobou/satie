# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import bpy
import liblo
from bpy.props import FloatProperty, StringProperty, IntProperty, BoolProperty, PointerProperty
from bpy.types import PropertyGroup

from . import osc
from . import control

bpy.satie_types_list = []
bpy.satiePropertiesLayouts = {}
bpy.satieRegisteredTypes = {}

def load():
    # bpy.utils.register_class(SatiePropertiesPanel)
    print("loading layout")
        
    for groupName, groupAttributes in bpy.satiePropertiesLayouts.items():
        attributes = {}
        for attribute in groupAttributes:
            aType = attribute["type"]
            aName = attribute["name"]
            aDefault = attribute["value"]
            if aType == "Integer":
                attributes[aName] = IntProperty(
                    name=aName,
                    default=aDefault,
                    update=update_property
                )
            elif aType == "Float":
                attributes[aName] = FloatProperty(
                    name=aName,
                    default=aDefault,
                    update=update_property
                )
            elif aType == "String":
                attributes[aName] = StringProperty(
                    name=aName,
                    default=aDefault,
                    update=update_property
                )
            # FIXME: need to find a way of lading an Array with correct types
            elif aType == "Array":
                attributes[aName] = StringProperty(
                    name=aName,
                    default=aDefault,
                    update=update_property
                )
            else:
                raise TypeError("Unsupported type ({}) for {} on {}".format(aType, aName, groupName))

        # build the class representing a property group
        propertyGroupClass = type(groupName, (PropertyGroup, ), attributes)

        # register with blender
        bpy.utils.register_class(propertyGroupClass)

        # apply to all objects
        setattr(bpy.types.Object, groupName, PointerProperty(type=propertyGroupClass))

        # keep track of it
        # bpy.satieRegisteredTypes[groupName] = propertyGroupClass

    print("loaded SATIE property panel")

def unload():
    # bpy.utils.unregister_class(SatiePropertiesPanel)

    print("unloading layout")
    # unregister stores components
    try: 
        for key, val in bpy.satieRegisteredTypes.items():
            delattr(bpy.types.Object, key)
            bpy.utils.unregister_class(val)
    except:
        pass
    bpy.satieRegisteredTypes = {}

def update_property(self, context):
    aName = type(self).__name__
    owner = context.active_object.name
    for i in self.items():
        control.set_param(owner, i[0], i[1])
    

def load_synth_properties(synth):
    osc.satie_send("/satie/pluginargs", synth)

def load_synth_types():
    osc.satie_send("/satie/audioplugins", 1)

def set_types_list(types):
    """Update a variable
    types: list of tuples
    """
    bpy.satie_types_list = types
