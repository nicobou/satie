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

class SatieProperties(bpy.types.Panel):
    bl_space_type = "PROPERTIES"
    bl_region_type = "WINDOW"
    bl_context = "object"
    bl_label = "SATIE properties"
 
    def draw(self, context) :
        if properties.active:
            objs = context.selected_objects
            TheCol = self.layout.column(align = True)
            TheCol.prop(context.object, "useSatie")
            TheCol.prop(context.object, "satieSynth")
            TheCol.prop(context.object, "satieGroup")
            TheCol.prop(context.object, "bus")
        else:
            self.layout.label('Need SATIE? See toolbox')


def updatePanel(self, value):
    print("update called")

def initObjectProperties():
    bpy.types.Object.useSatie = bpy.props.BoolProperty(
        name = "Use SATIE",
        description = "Assign this object a SATIE sound source",
        default = False
    )

    bpy.types.Object.satieSynth = bpy.props.EnumProperty(
        name = "Sound source",
        description = "SATIE plugin to use",
        items = [("monoIn", "monoIn", "Direct signal on a bus"),
                 ("tastee", "tastee", "a drone procedural sound")
        ],
        update = updatePanel
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

    bpy.types.Scene.SatieSources = bpy.props.EnumProperty(
        items = [],
        name = "Sources")

initObjectProperties()

