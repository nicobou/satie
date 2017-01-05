import bpy
from . import control
from . import properties

class SatieProperties(bpy.types.Panel):
    bl_space_type = "PROPERTIES"
    bl_region_type = "WINDOW"
    bl_context = "object"
    bl_label = "SATIE properties"
#    def draw(self, context) :
#        TheCol = self.layout.column(align = True)
#        TheCol.prop(context.scene, "make_satie_properties")
#        TheCol.operator("mesh.add_satie_properties", text = "SATIE properties")
#        TheCol.prop(self, "useSatie")
#        TheCol.prop(self, "satieID")
 
    def draw(self, context) :
        objs = context.selected_objects
        if len(objs) is not 1:
            self.layout.label('Select exactly ONE object')
        else:
            TheCol = self.layout.column(align = True)
            #TheCol.prop(context.scene, "make_satie_properties")
            #TheCol.operator("mesh.add_satie_properties", text = "SATIE properties")
            TheCol.prop(context.object, "useSatie")
            TheCol.prop(context.object, "satieID")
            TheCol.prop(context.object, "satieSynth")
            TheCol.prop(context.object, "satieGroup")
            TheCol.prop(context.object, "hiPass")
            TheCol.prop(context.object, "loPass")
            # TheCol.prop(context.object, "sendToSATIE")
            # TheCol.prop(context.object, "state")

def initObjectProperties():
    # print("********************************************* properties **************************************")
    bpy.types.Object.useSatie = bpy.props.BoolProperty(
        name = "Use SATIE",
        description = "Assign this object a SATIE sound source",
        default = False
    )
    bpy.types.Object.satieID = bpy.props.StringProperty(
        name = "ID",
        description = "Sound source ID",
        default = ""
    )
    bpy.types.Object.satieSynth = bpy.props.StringProperty(
        name = "Sound source",
        description = "SATIE plugin to use",
        default = "tastee"
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
    bpy.types.Object.state = bpy.props.BoolProperty(
        name = "Source playing state",
        description = "Playing state (on, off)",
        default = False
    )

    bpy.types.Object.hiPass = bpy.props.FloatProperty(
        name = "High pass",
        description = "High pass filter",
        default = 0.5,
        set = control.setSatieHP
    )
    bpy.types.Object.loPass = bpy.props.FloatProperty(
        name = "Low pass",
        description = "Low pass filter",
        default = 15000.00
    )

    bpy.types.Scene.active = bpy.props.BoolProperty(
        name = "Use Satie",
        description = "Activate SATIE communication",
        default = False,
        set = control.setSatieSendCtl,
        get = control.getSatieSendCtl
    )

    bpy.types.Scene.SatieSources = bpy.props.EnumProperty(
        items = [],
        name = "Sources")


# satieObject = SatieObject()
    
# bpy.utils.register_class(SatieObject)
# bpy.ops.mesh.satie_sound()

initObjectProperties()
# print("******************* PANEL executed ***********************")

