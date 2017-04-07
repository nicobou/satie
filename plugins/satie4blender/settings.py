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
from bpy.props import EnumProperty
from bpy.types import PropertyGroup

from . import components
from . import properties
from . import osc

class SatieComponents(PropertyGroup):
    def get_current_item(self):
        print("*******", self)
        return self.satie_synth
        
    def update_types_menu(self, context):
        if properties.active:
            # print("updating types menu", self.satie_synth)
            components.load_synth_types()
            return(bpy.satie_types_list)

    def update_components(self, context):
        if properties.active:
            satie_type = str(context.object.satie_synth)
            print("updating synth menu", self, bpy.satie_types_list[self['satie_synth']][1])
            components.unload()
            components.load_synth_properties(satie_type)
		
    bpy.types.Object.satie_synth = EnumProperty(
        name = "Sound source",
        description = "SATIE plugin to use",
        items = update_types_menu,
        # get = get_current_item,
        update = update_components
)
