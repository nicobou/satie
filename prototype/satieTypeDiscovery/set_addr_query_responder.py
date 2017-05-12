
# coding: utf-8

# # Setting OSC address example
# 
# - run ${SATIE_DIR}/examples/satieOSCexample/protocolTest.scd
# - execute the blocks below one after another
# 

import liblo

sc = liblo.Address("localhost", 18032)
server = liblo.Server(9000)

def echo(path, args):
    print(path, args)

server.add_method(None, None, echo)

msg = liblo.Message("/satie/setAddr")
server.send(sc, msg)
server.recv(2)

msg = liblo.Message('/satie/audioplugins')
server.send(sc, msg)
# should respond with a JSON
server.recv(2)

msg = liblo.Message('/satie/pluginargs')
msg.add('DustDust')
server.send(sc, msg)
# should respond with a JSON
server.recv(2)





