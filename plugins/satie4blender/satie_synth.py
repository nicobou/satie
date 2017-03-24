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
    def __init__(self, parent, id, plugin):
        """
        Params:
        parent - bpy_types.Object
        id - parent's name
        """
        self.id = id
        self.synth = plugin
        self.group = "default"
        self.oscaddress = liblo.Address(props.destination, props.port)
        self.oscbaseurl = "/satie"
        self.oscURI = None
        self.myParent = parent
        self.selected = False
        self.playing = False
        self.setURI()
        self.createSource()
        self.play()

    def setURI(self):
        self.oscURI = os.path.join(self.oscbaseurl, self.group)

    def createSource(self):
        liblo.send(self.oscaddress, self.oscbaseurl, "create", self.id, self.synth)

    def deleteNode(self):
        oscURI = os.path.join(self.oscbaseurl, self.group, self.id)
        liblo.send(self.oscaddress, oscURI, "delete")

    def set(self, prop, val):
        oscURI = os.path.join(self.oscbaseurl, self.group, self.id)
        if not val:
            self.playing = False
        else:
            self.playing = True
        liblo.send(self.oscaddress, oscURI, "set", prop, val)

    def play(self):
        oscURI = os.path.join(self.oscbaseurl, self.group, self.id)
        liblo.send(self.oscaddress, oscURI, "set", "t_trig", 1)
        print("sent play")
                
    def updateAED(self):
        oscURI = os.path.join(self.oscbaseurl, self.group, self.id)
        azi, ele, gain = self._getAED()
        liblo.send(self.oscaddress, oscURI, "set", "aziDeg", azi, "elevDeg", ele, "gainDB", gain)
        
        
    def _getLocation(self):
        cam_world_matrix = bpy.data.objects['Camera'].matrix_world
        parent = self._getParent()
        parent_world_matrix = parent.matrix_world
        transf = cam_world_matrix - parent_world_matrix
        location = transf.translation
        return location

    def _getParent(self):
        listener = [o for o in bpy.context.visible_objects if o.name == self.id]
        return listener[0]


    def _getAED(self):
        distance = self._getLocation()
        aed = utils.xyz_to_aed(distance)
        gain = math.log(utils.distance_to_attenuation(aed[2])) * 20
        aed[2] = gain
        return aed
