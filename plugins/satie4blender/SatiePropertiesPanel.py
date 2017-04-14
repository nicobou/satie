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
from . import components
from . import properties

bpy.satie_types_list = []
bpy.satiePropertiesLayouts = {}
bpy.satieRegisteredTypes = {}
# plugins by family, i.e. sources or effects
bpy.satie_plugins = {}

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
            if bpy.satie_plugins:
                TheCol.prop(context.object, "plugin_family")
            self.layout.separator()
            TheCol.prop(context.object, "satie_synth")
            TheCol.prop(context.object, "satieGroup")
            self.layout.separator()
            # TheCol.prop(context.object, "bus")
            if bpy.satiePropertiesLayouts:
                for groupName, groupAttributes in bpy.satiePropertiesLayouts.items():
                    # get the instance of the group
                    try:
                        propertyGroup = getattr(obj, groupName)
                        TheCol.label("{} specific props: ".format(groupName))

                        for att in groupAttributes:
                            TheCol.prop(propertyGroup, att["name"])
                    except AttributeError:
                        # it lost its previous referencem, ignore
                        pass

            else:
                self.layout.label("------------- nothing to display")
                self.layout.label(
                    text="Perhaps there are no synth definitions loaded",
                    icon="QUESTION"
                )
        else:
            self.layout.label('Need SATIE? See toolbox')

    def get_satie_families(self, context):
        menu = []
        if bpy.satie_plugins:
            for key in bpy.satie_plugins.keys():
                t = tuple([key, key, "..."])
                menu.append(t)
            return(menu)
        else:
            return(('Waiting...', 'waiting....', '...'))

    def get_current_item(self):
        return self.satie_synth
        
    def update_types_menu(self, context):
        if properties.active:
            # print("updating types menu", self.satie_synth)
            components.load_synth_types()
            plugs_key = self.plugin_family
            menu = []
            if bpy.satie_plugins:
                for attr in bpy.satie_plugins[plugs_key]:
                    name = attr['name']
                    srcName = attr['srcName']
                    descr = attr['description']
                    t = tuple([srcName, name, descr])
                    menu.append(t)
                return(menu)

    def update_components(self, context):
        if properties.active:
            satie_type = str(context.object.satie_synth)
            components.unload()
            components.load_synth_properties(satie_type)

# def initObjectProperties():
    bpy.types.Object.useSatie = bpy.props.BoolProperty(
        name = "Use SATIE",
        description = "Assign this object a SATIE sound source",
        default = False
        # update = satie_instance
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
    bpy.types.Object.plugin_family = bpy.props.EnumProperty(
        name = "Plugin type",
        description = "SATIE plugins family",
        items = get_satie_families
    )

    bpy.types.Object.satie_synth = bpy.props.EnumProperty(
        name = "Sound source",
        description = "SATIE plugin to use",
        items = update_types_menu,
        # get = get_current_item,
        update = update_components
    )

# initObjectProperties()

