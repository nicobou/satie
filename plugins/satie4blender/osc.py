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
import os

from . import json_handler
from . import properties as props

bpy.s4b_OSCserver = None
bpy.s4b_OSCclient = None


NODE_TYPES = ["source", "group", "process"]
SCENE_URI = "/satie/scene"

OSC_ADDRESS = liblo.Address(props.destination, props.satie_port)

def init_osc_server():
    bpy.s4b_OSCclient = liblo.Address(props.destination, props.satie_port)
    try:
        bpy.s4b_OSCserver = liblo.Server(props.server_port)
    except Exception as e:
        print("could not create OSC server:", e)
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
    msg = liblo.Message(address, msg)
    bpy.s4b_OSCserver.send(bpy.s4b_OSCclient, msg)
    #server.recv()
    #server.free()

def stop_osc_server():
    print("stopping OSC server....")
    bpy.s4b_OSCserver.free()
    del bpy.s4b_OSCserver
    bpy.s4b_OSCserver = None
    bpy.s4b_OSCclient = None

def osc_rcv_cb(context):
    bpy.s4b_OSCserver.recv(0.01)

def scene_create_source(nodeName, synthdefName, schemaName='plugin', group='default'):
    """Create an audio source
    An audio source is generator that produces sound (as opposed to DSP plugin or effect)

    signature scene_create_source (nodeName, synthdefName, <group>)

    nodeName: string - name of the SATIE instance
    synthdefName: string - name of the compiled synthdef
    group: string - optional, 'default' by default
    """
    liblo.send(bpy.s4b_OSCclient, SCENE_URI, "createSource", nodeName,  "plugin://"+synthdefName, group)

def scene_create_effect(nodeName, synthdefName, schemaName='plugin', group='defaultFx', in_bus=0):
    """Create an audio effect
    An audio source is a DSP plugin that acts on the signal provided on its bus number

    signature scene_create_effect(nodeName, synthdefName, schema, <group>, in_bus)

    nodeName: string - name of the SATIE instance
    synthdefName: string - name of the compiled synthdef
    group: string - optional, 'default' by default
    in_bus: int - bus number, default=0
    """
    liblo.send(bpy.s4b_OSCclient, SCENE_URI, "createSource", nodeName, "effect://"+synthdefName, group, in_bus)

def scene_delete_node(nodeName):
    liblo.send(bpy.s4b_OSCclient, SCENE_URI, "deleteNode", nodeName)

def scene_create_group(nodeName, schema='plugin'):
    """Create a group"""
    liblo.send(bpy.s4b_OSCclient, SCENE_URI, "createGroup", nodeName, "{}:".format(schema))

def scene_clear():
    liblo.send(bpy.s4b_OSCclient, SCENE_URI, "clear")

def scene_set(key, value):
    liblo.send(bpy.s4b_OSCclient, os.path.join(SCENE_URI, "set"), key, value)

def node_state(nodeType, nodeName, value):
    uri = os.path.join("/satie", nodeType, "state")
    liblo.send(bpy.s4b_OSCclient, uri, nodeName, value)

def node_event(nodeType, nodeName, eventName, *args):
    uri = os.path.join("/satie", nodeType, "event")
    liblo.send(bpy.s4b_OSCclient, uri, nodeName, eventName, args)

def node_set(nodeType, nodeName, *args):
    """Set property
    nodeType: string - nodeType: source, group, process
    nodeName: string - instance name
    args: array - key, value pairs alternating
    """
    uri = os.path.join("/satie", nodeType, "set")
    liblo.send(bpy.s4b_OSCclient, uri, nodeName, args)
    
def node_setvec(nodeType, nodeName, key, *args):
    """Send a keyword, vector

    nodeType: string
    nodeName: string
    key: string
    *args: tuple of numeric values
    """
    uri = os.path.join("/satie", nodeType, "setvec")
    liblo.send(bpy.s4b_OSCclient, uri, nodeName, key, args)

def node_update(nodeType, nodeName, azimuth, elevation, gain, delay,  lp,  distance):
    """Update some essential properties

    nodeType: string
    nodeName: string
    azimuth: float - horizontal angle - degrees
    elevation: float - vertical angle - degrees
    gain: float - decibels
    delay: int - miliseconds
    lp: float - low-pass filter frequency - herz
    distance: float - meters
    """
    uri = os.path.join("/satie", nodeType, "update")
    liblo.send(bpy.s4b_OSCclient, uri, nodeName, azimuth, elevation, gain, delay,  lp,  distance)
