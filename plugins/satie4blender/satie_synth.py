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
import math
import os
from . import utils
from . import properties as props

print("imported satie synth module")

class SatieSynth():
    """
    Object representing a synth in SATIE
    This implementation uses the satieOSC prorocol
    """
    def __init__(self, parent, id):
        """
        Params:
        parent - bpy_types.Object
        id - parent's name
        """
        self.node_name = id
        self.group = "default"
        self.myParent = parent
        self.azi = 0
        self.ele = 0
        self.gain = -99
        self.delay = 1
        self.lowpass = 15000
        self.highpass = 1
        self.spread = 1
        self.distance = 1
        self.debug = False
        # self.fontCurve = None
        # self.debugTextOb = None
        # self._debug_text()
                
    def updateAED(self):
        # oscURI = os.path.join(self.oscbaseurl, self.group, self.id)
        self.azi, self.ele, self.gain = self._getAED()
        
    def _get_distance_from_cam(self):
        cam_world_matrix = bpy.data.objects['Camera'].matrix_world

        parent = self._getParent()
        parent_world_matrix = parent.matrix_world
        transf = cam_world_matrix * parent_world_matrix
        distance = transf.translation
        return distance

    def _getParent(self):
        parent = [o for o in bpy.context.visible_objects if o.name == self.node_name]
        return parent[0]

    def _getAED(self):
        distance = self._get_distance_from_cam()
        aed = utils.xyz_to_aed(distance)
        gain = math.log(utils.distance_to_attenuation(aed[2])) * 20
        aed[2] = gain
        return aed

    # def _debug_text(self):
    #     self.fontCurve = bpy.data.curves.new(type="FONT",name=self.node_name+"debugText")
    #     self.debugTextOb = bpy.data.objects.new(self.node_name+"debugTextOb",self.fontCurve)
    #     self.debugTextOb.data.body = "distance from cam {}\n".format(self._get_distance_from_cam())
    #     bpy.context.scene.objects.link(self.debugTextOb)
    #     self.debugTextOb.parent = self.myParent
    #     # bpy.context.scene.update()

    def show_debug(self):
        # self.debugTextOb.data.body = "distance from cam {}\n".format(self._get_distance_from_cam())
        print(self._getAED())

