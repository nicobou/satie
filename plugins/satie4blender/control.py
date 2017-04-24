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
from . import properties as props
from . import satie_synth as ss
from . import osc

bpy.satie_debug = {}

def instanceHandler():
    synths = update_synth_list()
    visibleObjs = bpy.context.visible_objects 
    if len(visibleObjs) > 0:
        for o in visibleObjs:
            if o.useSatie:
                if len(o.name) > 0:
                    if o.name in synths:
                        pass
                    else:
                        synths_add_instance(o, o.name, o.satie_synth, o.satieGroup)
                else:
                    print("{}'s satie ID cannot be empty", o.name)
            else:
                if o.name in synths:
                    print(">>>>>> removing {} ".format(o.name) )
                    toRemove = [x for x in props.synths['source'] if o.name in synths]
                    for i in toRemove:
                        del props.synths['source'][i]
                        osc.scene_delete_node(i)

def update_synth_list():
    synths = props.synths['source'].keys()
    return(synths)

def synths_add_instance(parent, node_name, synth, group):
    synth_name = synth_name_from_src(synth)

    if group not in props.synths['group']:
        props.synths['group'].append(group)
        osc.scene_create_group(group)


    s_instance = create_instance(parent, node_name)
    s_instance.group = group

    props.synths['source'][node_name] = {
        'name': node_name,
        'group': group,
        'synth': synth_name,
        'instance': s_instance
    }
    bpy.satie_debug = props.synths
    osc.scene_create_source(node_name, synth_name)

def create_instance(parent, node_name):
    satie_instance = ss.SatieSynth(parent, node_name)
    return(satie_instance)

def delete_node(name):
    osc.scene_delete_node(name)

def synth_name_from_src(src_name):
    ret = [x for x in bpy.satie_plugins['sources'] if x['srcName'] == src_name]
    return(ret[0]['name'])

def satieInstanceCb(scene):
    instanceHandler()
    if props.synths['source']:
        [props.synths['source'][s]['instance'].updateAED() for s in props.synths['source']]
        [send_update(props.synths['source'][s]) for s in props.synths['source']]
        [props.synths['source'][s]['instance'].show_debug() for s in props.synths['source'] if props.synths['source'][s]['instance'].debug == True]

def send_update(s):
    osc.node_update('source', s['instance'].node_name, s['instance'].azi, s['instance'].ele, s['instance'].gain, s['instance'].delay, s['instance'].lowpass, s['instance'].distance)

def cleanCallbackQueue():
    if satieInstanceCb in bpy.app.handlers.scene_update_post:
        bpy.app.handlers.scene_update_post.remove(satieInstanceCb)

def getSatieSendCtl(self):
    return props.active

def setSatieSendCtl(value):
    props.active = value

        
def setOSCdestination(self, context):
    print ("setting host to ", context.scene.OSCdestination)
    destination = context.scene.OSCdestination
    props.destination = destination

def setOSC_destination_port(self, context):
    port = context.scene.OSC_destination_port    
    props.satie_port = port

def setOSC_server_port(self, context):
    port = context.scene.OSC_server_port    
    props.server_port = port
        
def set_instance_debug(self, value):
    props.synths['source'][self.name]['instance'].debug = self.debug_text

