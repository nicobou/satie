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

from . import json_handler

bpy.s4b_OSCserver = None
bpy.s4b_OSCclient = None


def init_osc_server():
    bpy.s4b_OSCclient = liblo.Address("localhost", 18032)

    bpy.s4b_OSCserver = liblo.Server(6666)
    #msg = liblo.Message("/notify", 1)
    # msg = liblo.Message("/satie/pluginargs", synth)

    def echo(path, args):
        print(path, args)

    def handle_plugin_properties(path, args):
        json_handler.parse_plugin_properties(args[0])

    def handle_plugin_list(path, args):
        json_handler.parse_plugin_list(args[0])

    def fallback(path, args):
        print("received osc message:", path, args)

    bpy.s4b_OSCserver.add_method("/arguments", "s", handle_plugin_properties)
    bpy.s4b_OSCserver.add_method("/plugins", "s", handle_plugin_list)
    bpy.s4b_OSCserver.add_method(None, None, fallback)

def satie_send(address, msg):
    """Send an osc message to SATIE
    address - OSC address in the form /blah
    msg - OSC message
    
    """
    print("about to send following message", address, msg)
    msg = liblo.Message(address, msg)
    bpy.s4b_OSCserver.send(bpy.s4b_OSCclient, msg)
    #server.recv()
    #server.free()

def stop_osc_server():
    print("stopping OSC server....")
    bpy.s4b_OSCserver.free()
    bpy.s4b_OSCserver = None
    bpy.s4b_OSCclient = None

def osc_rcv_cb(context):
    bpy.s4b_OSCserver.recv(0.01)
