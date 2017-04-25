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

SPEED_OF_SOUND = 0.34

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
        self._doppler_factor = 100

    def update(self):
        self._updateAEG()
        self.delay = self._variable_delay(self.distance, self._doppler_factor)
        self.lowpass = self._get_distance_freq(self.distance)

    def _updateAEG(self):
        """azimuth, elevation, gain
        """
        azi, ele, distance = self._getAED()
        self.azi = azi
        self.ele = ele
        self.distance = distance
        self.gain = self._gain_from_distance(self.distance)

    def _gain_from_distance(self, distance):
        gain = math.log(utils.distance_to_attenuation(distance)) * 20
        return(gain)
        
    def _get_vector_from_cam(self):
        cam_world_matrix = bpy.data.objects['Camera'].matrix_world
        cam_matrix_inverted = cam_world_matrix.inverted()
        parent = self._getParent()
        parent_world_matrix = parent.matrix_world
        transf = parent_world_matrix * cam_matrix_inverted
        vec = transf.translation
        return vec

    def _variable_delay(self, distance, factor):
        return(math.pow(distance * (1.0 / SPEED_OF_SOUND), factor * 0.01))

    def _get_distance_freq(self, distance):
        """Calculate low pass cut-off
        simulate air absorbtion based on distance.
        """
        if distance > 1000.0:
            dist = 1000.0
        else:
            dist = distance

        ms = distance * (1.0 / SPEED_OF_SOUND)
        hz = (1.0 - (ms * 0.00034002))
        hz = 100.0 + (hz * hz * 19900.0)
        return(hz)

    def _getParent(self):
        parent = [o for o in bpy.context.visible_objects if o.name == self.node_name]
        return parent[0]

    def _getAED(self):
        vec = self._get_vector_from_cam()
        aed = utils.xyz_to_aed(vec)
        return aed

    def show_debug(self):
        print("AED vector", self._getAED())

