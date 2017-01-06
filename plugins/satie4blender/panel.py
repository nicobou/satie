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

# print("Panel loaded")

class ToolsPanel(bpy.types.Panel):
    bl_label = "SATIE tool"
    bl_context = "objectmode"
    bl_category = "SATIE"
    bl_space_type = "VIEW_3D"
    bl_region_type = "TOOLS"
    bl_options = {'DEFAULT_CLOSED'}

    def draw_header(self, context):
        layout = self.layout
        layout.label(text='', icon='SPEAKER')
    
    def draw(self, context):
        layout = self.layout
        layout.label("SATIE connection")
        
        row = layout.row()
        # row.prop(context.object, "useSatie")
        # row.prop(context.scene, "active")

        row = layout.row()
        row.prop(context.scene, "SatieSources")
        row = layout.row()
        row.prop(context.scene, "OSCdestination")
        row = layout.row()
        row.prop(context.scene, "OSCport")
        row = layout.row()
        row.operator("mesh.satie_sound").active = True


class SatieObject(bpy.types.Operator):
    bl_idname = "mesh.satie_sound"
    bl_label = "SATIE sound source"
    bl_options = {"REGISTER", "UNDO"}
    fcount = 0
    active = bpy.props.BoolProperty()

    # def __init__(self):
    #     print("init in SatieObject")
    
    def execute(self, context):
        # print("Satie synth interface instantiated")
        if self.active:
            if control.instanceCb not in bpy.app.handlers.scene_update_post:
                bpy.app.handlers.scene_update_post.append(control.instanceCb)
        else:
            if control.instanceCb in bpy.app.handlers.scene_update_post:
                control.cleanCallbackQueue()
        # else:
        #     bpy.app.handlers.scene_update_post.remove(instanceCb)
        # if exeCallback not in bpy.app.handlers.scene_update_post:
        #     bpy.app.handlers.scene_update_post.append(exeCallback)
        # else:
        #     bpy.app.handlers.scene_update_post.remove(exeCallback)
        return {'FINISHED'}
                
    def getSatieID(self):
        print(bpy.context.object.satieID)



def initToolsProperties():
    bpy.types.Scene.active = bpy.props.BoolProperty(
        name = "Use Satie",
        description = "Activate SATIE communication",
        default = False,
        set = control.setSatieSendCtl,
        get = control.getSatieSendCtl
    )

    bpy.types.Scene.SatieSources = bpy.props.EnumProperty(
        items = [],
        name = "Sources")

    bpy.types.Scene.OSCdestination = bpy.props.StringProperty(
        name = "OSC destination",
        description = "hostname or IP address of SATIE server",
        default = properties.destination,
        update = control.setOSCdestination
    )

    bpy.types.Scene.OSCport = bpy.props.IntProperty(
        name = "OSC port",
        description = "OSC port",
        default = properties.port,
        update = control.setOSCport
    )


initToolsProperties()
