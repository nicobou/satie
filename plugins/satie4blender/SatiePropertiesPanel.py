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
from . import control
from . import properties

class SatiePropertiesPanel(bpy.types.Panel):
    bl_space_type = "PROPERTIES"
    bl_region_type = "WINDOW"
    bl_context = "object"
    bl_label = "SATIE properties"
 
    def draw(self, context) :
        if properties.active:
            obj = context.object
            TheCol = self.layout.column(align = True)
            TheCol.prop(context.object, "useSatie")
            TheCol.prop(context.object, "satie_synth")
            TheCol.prop(context.object, "satieGroup")
            self.layout.separator()
            # TheCol.prop(context.object, "bus")
            if bpy.satiePropertiesLayouts:
                for groupName, groupAttributes in bpy.satiePropertiesLayouts.items():
                    # get the instance of the group
                    propertyGroup = getattr(obj, groupName)
                    TheCol.label("{} specific props: ".format(groupName))

                    for att in groupAttributes:
                        TheCol.prop(propertyGroup, att["name"])
            else:
                self.layout.label("------------- nothing to display")
                self.layout.label(
                    text="Perhaps there are no synth definitions loaded",
                    icon="QUESTION"
                )
        else:
            self.layout.label('Need SATIE? See toolbox')

    # @staticmethod
    def updatePanel(self, value):
        print("update called")
                                                        
def initObjectProperties():
    bpy.types.Object.useSatie = bpy.props.BoolProperty(
        name = "Use SATIE",
        description = "Assign this object a SATIE sound source",
        default = False
    )
    
    bpy.types.Object.bus = bpy.props.IntProperty(
        name = "Bus number",
        description = "Input bus",
        default = 0,
        update = control.setInputBus
    )

    bpy.types.Object.satieGroup = bpy.props.StringProperty(
        name = "Group",
        description = "instrument/FX group",
        default = "default"
    )

    bpy.types.Object.sendToSATIE = bpy.props.BoolProperty(
        name = "Send to SATIE",
        description = "(Un)mute the SATIE instance",
        default = False
    )
    bpy.types.Object.state = bpy.props.BoolProperty(
        name = "Source playing state",
        description = "Playing state (on, off)",
        default = False
    )

    bpy.types.Object.hiPass = bpy.props.FloatProperty(
        name = "High pass",
        description = "High pass filter",
        default = 0.5,
        set = control.setSatieHP
    )
    bpy.types.Object.loPass = bpy.props.FloatProperty(
        name = "Low pass",
        description = "Low pass filter",
        default = 15000.00
    )

    bpy.types.Scene.active = bpy.props.BoolProperty(
        name = "Use Satie",
        description = "Activate SATIE communication",
        default = False,
        # set = control.setSatieSendCtl,
        # get = control.getSatieSendCtl
    )

    bpy.types.Scene.SatieSources = bpy.props.EnumProperty(
        items = [],
        name = "Sources")

initObjectProperties()

