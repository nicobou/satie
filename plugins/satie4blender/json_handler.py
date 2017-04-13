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
import json
import re
from . import components

def parse_plugin_properties(j):
    """Load a json
    j - a string representing json object
    """
    my_json = None
    try:
        my_json = json.loads(j)
    except Exception as e:
        print("Invalid json", e)
        print(j)
        pass
    
    if my_json is not None:
        print("got json", my_json)
        bpy.satiePropertiesLayouts = my_json
        # FIXME: a cludge to ensure that the above dictionary is ready before components load
        components.load()

def parse_plugin_list(plugs):
    """Parse the json object containing plugins list

    plugs - string: contains json array

    """
    menu = []
    plugs_json = json.loads(plugs)
    bpy.satie_plugins = plugs_json

    components.set_types_list(menu)
