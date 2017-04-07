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

bl_info = {
    "name": "SATIE OSC",
    "author": "Michal Seta",
    "version": (0, 1, 1),
    "blender": (2, 75, 0),
    "location": "View 3D > Tool Shelf > SATIE panel",
    "warning": "Early stages of development",
    "wiki_url": "",
    "description": "Author SATIE audio scenes with Blender",
    "category": "User",
}

# load SatieTool (module containing SATIE addon properties)
# and SatiePropertiesPanel (module containing SATIE object properties)

if "bpy" in locals():
    import imp
    imp.reload(SatieTool)
    imp.reload(SatiePropertiesPanel)
    imp.reload(components)
    imp.reload(settings)
    imp.reload(osc)
else:
    from . import SatieTool
    from . import SatiePropertiesPanel
    from . import components
    from . import settings
    from . import osc

# register SATIE in blender:

import bpy

def initialize():
    print("Initializing SATIE bridge")

def register():
    initialize()
    #bpy.utils.register_module(__name__)
    # register components related to the SATIE properties panel
    bpy.utils.register_class(settings.SatieComponents)
    # register SATIE properties panel
    bpy.utils.register_class(SatiePropertiesPanel.SatiePropertiesPanel)
    # register SATIE tool shelf panel
    bpy.utils.register_class(SatieTool.ToolsPanel)
    try:
        osc.init_osc_server()
        print("OSC sever started")
    except Exception as e:
        print("could not start osc server, reasons:", e)
    
    components.load()
 
def unregister():
    """Unregister various classes"""
    #bpy.utils.unregister_module(__name__)
    bpy.utils.unregister_class(SatiePropertiesPanel.SatiePropertiesPanel)
    bpy.utils.unregister_class(SatieTool.ToolsPanel)
    components.unload()
    try:
        osc.stop_osc_server()
    except Exception as e:
        print("Could not strop osc server, reason:", e)

if __name__ == "__main__":
    register()
