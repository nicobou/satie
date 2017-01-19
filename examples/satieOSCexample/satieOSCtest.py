#!/usr/bin/env python3

import liblo
import os
import time

scosc = liblo.Address("127.0.0.1", 18032)

#---------------------------------
# test pinksyn
#---------------------------------
group = "synths"
synthName = "pinky"
synthType = "pinksin"
print("Create group synths")
liblo.send(scosc, "/satie", "create", group)
print("create and add {} to group {} as {}".format(synthType, group, synthName))
liblo.send(scosc, os.path.join("/satie", group), "create", synthName, synthType)
time.sleep(1)
prop = "sfreq"
print("set group's property {}".format(prop))
liblo.send(scosc, os.path.join("/satie", group), "set", prop, 400, "gainDB", -20)
time.sleep(2)
print("set instance property {}".format(prop))
liblo.send(scosc, os.path.join("/satie", group, synthName), "set", prop, 800)
time.sleep(2)
print("destroy pinky")
liblo.send(scosc, os.path.join("/satie", group, synthName), "delete")

#---------------------------------
# test strings
#---------------------------------
group = "strings"
synthA = "string1"
synthB = "string2"
synthType = "string"
print("Create group synths")
liblo.send(scosc, "/satie", "create", group)
print("create and add {} to group {} as {}".format(synthType, group, synthA))
liblo.send(scosc, os.path.join("/satie", group), "create", synthA, synthType)
time.sleep(1)
print("create and add {} to group {} as {}".format(synthType, group, synthB))
liblo.send(scosc, os.path.join("/satie", group), "create", synthB, synthType)
prop = "note"
trig = "t_trig"
print("set group's property {}".format(prop))
liblo.send(scosc, os.path.join("/satie", group), "set", prop, 62, "gainDB", -20)
liblo.send(scosc, os.path.join("/satie", group), "set", trig, 1)
time.sleep(2)
print("set instance property {}".format(prop))
liblo.send(scosc, os.path.join("/satie", group, synthA), "set", prop, 70, trig, 1)
liblo.send(scosc, os.path.join("/satie", group, synthB), "set", prop, 67, trig, 1)
time.sleep(1)
liblo.send(scosc, os.path.join("/satie", group), "set", trig, 1)
time.sleep(2)
print("destroy {}".format(group))
liblo.send(scosc, os.path.join("/satie", group), "delete")

#---------------------------------
# test strings with reverb
#---------------------------------
time.sleep(1)
group = "strings"
synthA = "string1"
synthB = "string2"
synthType = "string_third_aux"
fxGroup = "fx"
fxBus = 0
fxType = "busreverb"
fxName = "rev"
print("Create group synths")
liblo.send(scosc, "/satie", "create", group)
print("create and add {} to group {} as {}".format(synthType, group, synthA))
liblo.send(scosc, os.path.join("/satie", group), "create", synthA, synthType)
time.sleep(1)
print("create and add {} to group {} as {}".format(synthType, group, synthB))
liblo.send(scosc, os.path.join("/satie", group), "create", synthB, synthType)
print("create an fx group named {}".format(fxGroup))
liblo.send(scosc, "/satie", "createFX", fxGroup)
print("instantiate and effect {} named {}".format(fxType, fxName))
liblo.send(scosc, os.path.join("/satie", fxGroup), "create", fxName, fxType)
print("set several parameters of effect {} in fx group {} all at once".format(fxName, fxGroup))
liblo.send(scosc, os.path.join("/satie", fxGroup, fxName), "set", "in", 2, "mix", 1, "room", 0.7, "damp", 1, "gainDB", -5, "aziDeg", 30)
prop = "note"
trig = "t_trig"
group = "strings"
print("set group's property {}".format(prop))
liblo.send(scosc, os.path.join("/satie", group), "set", prop, 62, "gainDB", -10, "aziDeg", -10)
liblo.send(scosc, os.path.join("/satie", group), "set", trig, 1)
time.sleep(2)
print("set instance property {}".format(prop))
liblo.send(scosc, os.path.join("/satie", group, synthA), "set", prop, 70, trig, 1)
liblo.send(scosc, os.path.join("/satie", group, synthA), "set", prop, 63, trig, 1)
time.sleep(1)
liblo.send(scosc, os.path.join("/satie", group), "set", trig, 1)
time.sleep(2)
print("destroy {}".format(group))
liblo.send(scosc, os.path.join("/satie", group), "delete")
time.sleep(2)
print("clear all SATIE")
#liblo.send(scosc, "/satie", "clear")

