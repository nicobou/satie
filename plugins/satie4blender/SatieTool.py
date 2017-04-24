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
from . import osc

class ToolsPanel(bpy.types.Panel):
    """SATIE tool shelf"""
    bl_label = "SATIE tool"
    bl_context = "objectmode"
    bl_category = "SATIE"
    bl_space_type = "VIEW_3D"
    bl_region_type = "TOOLS"
    # bl_options = {'DEFAULT_CLOSED'}

    def draw_header(self, context):
        layout = self.layout
        layout.label(text='', icon='SPEAKER')
    
    def draw(self, context):
        col = self.layout.column(align=True)
        col.label("SATIE connection")
        

        # col.prop(context.scene, "SatieSources")
        col.prop(context.scene, "OSCdestination")
        col.prop(context.scene, "OSC_destination_port")
        col.label("OSC server")
        col.prop(context.scene, "OSC_server_port")
        col.separator()
        col.prop(context.scene, "Active")


def useSatie(self, context):
    """Start osc server and add satie callback to update queue
    """
    active = context.scene.Active
    control.setSatieSendCtl(active)
    if active:
        osc.scene_clear()
        if bpy.s4b_OSCserver:
            if osc.osc_rcv_cb not in bpy.app.handlers.scene_update_post:
                try:
                    bpy.app.handlers.scene_update_post.append(osc.osc_rcv_cb)
                except Exception as e:
                    print("could not add osc_rcv_cb to queue:", e)
        else:
            print("OSC server was not ready so callback  not loaded")
        if control.satieInstanceCb not in bpy.app.handlers.scene_update_post:
            bpy.app.handlers.scene_update_post.append(control.satieInstanceCb)
    else:
        if control.satieInstanceCb in bpy.app.handlers.scene_update_post:
            control.cleanCallbackQueue()
        if osc.osc_rcv_cb in bpy.app.handlers.scene_update_post:
            bpy.app.handlers.scene_update_post.remove(osc.osc_rcv_cb)
            try:
                osc.scene_clear()
                osc.stop_osc_server()
            except Exception as e:
                print("Could not strop osc server, reason:", e)

def initToolsProperties():
    bpy.types.Scene.Active = bpy.props.BoolProperty(
        name = "Use Satie",
        description = "Activate SATIE communication",
        default = False,
        update = useSatie
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

    bpy.types.Scene.OSC_destination_port = bpy.props.IntProperty(
        name = "destination OSC port",
        description = "SATIE server OSC port",
        default = properties.satie_port,
        update = control.setOSC_destination_port
    )

    bpy.types.Scene.OSC_server_port = bpy.props.IntProperty(
        name = "OSC server port",
        description = "OSC server port",
        default = properties.server_port,
        update = control.setOSC_server_port
    )


initToolsProperties()
