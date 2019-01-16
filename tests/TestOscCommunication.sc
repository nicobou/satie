TestOscCommunication : UnitTest {

	var server, config, satie, addr, dummy;

	setUp {
		server = Server(this.class.name);
		config = SatieConfiguration(server);
		satie = Satie(config);
		satie.boot;
		this.wait({ satie.booted }, "Satie failed to boot after 5 seconds", 5);
		addr = NetAddr("localhost", 18032);
		dummy = Environment.make(
			{
				~routine;
				~myProperty = 0;
				~set = { |self, prop, val| self[prop] = val };
				~setVec = { |self, prop, valArray| self[prop] = valArray };
				~setUpdate = { |self...args| self.myProperty = args };
				~myFunction = { |self, val| self.myProperty = val };
				~makeRoutine = { |self|
					self.routine = Routine {
						// do nothing
						loop { 1.0.wait }
					}
				};
				~start = { |self|
					self.routine.reset;
					self.routine.play;
				};
				~setup = { |self|
					self.makeRoutine;
					self.start;
				};
				~cleanup = { |self| self.routine.stop };
			}
		);
		satie.makeSynthDef(\limit, \Limiter, spatSymbolArray: config.listeningFormat);
		satie.makeInstance(\mySource, \pbell1);
		satie.makeProcess(\testProcess, dummy);
		satie.makeProcessInstance(\myProcess, \testProcess);
		server.sync;
	}

	tearDown {
		satie.quit;
		server.remove;
	}

	test_responder_port {
		var result;
		var value = ["127.0.0.255", 18066];
		addr.sendMsg('/satie/responder', value[0], value[1]);
		server.sync;
		result = [satie.osc.oscClientIP, satie.osc.oscClientPort];
		this.assertEquals(result, value, "/satie/responder set the client's ip:port.");
	}

	test_loadFile {
		var path = PathName(this.class.filenameSymbol.asString).pathOnly +/+ "/data/loadFile.scd";
		~loaded = false;
		addr.sendMsg('/satie/load', path);
		this.wait({ ~loaded }, "/satie/load failed to load file", 1);
	}

	test_scene_clear {
		var scene;
		addr.sendMsg('/satie/scene/clear');
		server.sync;
		scene = satie.groupInstances.collect { |dict| dict.isEmpty };
		this.assertEquals(
			scene.asEvent,
			(default: true, defaultFx: true, postProc: true, ambiPostProc: true),
			"/satie/scene/clear cleared the scene."
		);
	}

	test_scene_debug {
		addr.sendMsg('/satie/scene/debug', 1);
		server.sync;
		this.assertEquals(satie.config.debug, true, "/satie/scene/debug set the debug flag");
	}

	test_scene_deleteNode {
		addr.sendMsg('/satie/scene/deleteNode', 'mySource');
		server.sync;
		this.assertEquals(
			satie.groupInstances[\default][\mySource].isNil,
			true,
			"/satie/scene/deleteNode deleted the specified node"
		);
	}

	test_scene_createSource {
		addr.sendMsg('/satie/scene/createSource', 'anotherSource', 'testtone');
		server.sync;
		this.assertEquals(
			satie.groupInstances[\default][\anotherSource].isNil.not,
			true,
			"/satie/scene/createSource created a new source node"
		);
	}

	test_scene_createProcess {
		addr.sendMsg('/satie/scene/createProcess', 'anotherProcess', 'testProcess');
		server.sync;
		this.assertEquals(
			satie.processInstances[\anotherProcess].isNil.not,
			true,
			"/satie/scene/createProcess created a new process"
		);
	}

	test_scene_createEffect {
		addr.sendMsg('/satie/scene/createEffect', 'myEffect', 'limit');
		server.sync;
		this.assertEquals(
			satie.groupInstances[\defaultFx][\myEffect].isNil.not,
			true,
			"/satie/scene/createEffect created an effects Synth node"
		);
	}

	test_scene_createSourceGroup {
		addr.sendMsg('/satie/scene/createSourceGroup', 'mySourceGroup');
		server.sync;
		this.assertEquals(
			satie.groups[\mySourceGroup].isNil.not,
			true,
			"/satie/scene/createSourceGroup created a new source group"
		);
	}

	test_scene_createEffectGroup {
		addr.sendMsg('/satie/scene/createEffectGroup', 'myEffectGroup');
		server.sync;
		this.assertEquals(
			satie.groups[\myEffectGroup].isNil.not,
			true,
			"/satie/scene/createEffectGroup created a new effect group"
		);
	}

	test_scene_createProcessGroup {
		addr.sendMsg('/satie/scene/createProcessGroup', 'myProcessGroup');
		server.sync;
		this.assertEquals(
			satie.groups[\myProcessGroup].isNil.not,
			true,
			"/satie/scene/createProcessGroup created a new process group"
		);
	}

	test_nodeType_set {
		var result;
		var value = [-12.0, -6.0];
		[
			['/satie/source/set', 'mySource'],
			['/satie/group/set', 'default']
		].do { |msg|
			result = [];
			addr.sendMsg(msg[0], msg[1], 'gainDB', value[0], 'trimDB', value[1]);
			server.sync;
			['gainDB', 'trimDB'].do { |argument|
				satie.groupInstances[\default][\mySource].get(
					argument,
					{ |val|
						result = result.add(val)
					}
				)
			};
			server.sync;
			this.assertEquals(
				result,
				value,
				"/satie/<nodeType>/set set the control arguments for node: %.".format(msg[1])
			);
		}
	}

	test_nodeType_setvec {
		var result;
		var value = [62.0, 1.0, 0.5];
		[
			['/satie/source/setvec', 'mySource'],
			['/satie/group/setvec', 'default']
		].do { |msg|
			addr.sendMsg(msg[0], msg[1], 'note', value[0], value[1], value[2]);
			server.sync;
			satie.groupInstances[\default][\mySource].getn(index: \note, count: 3, action: { |val| result = val });
			server.sync;
			this.assertEquals(
				result,
				value,
				"/satie/<nodeType>/setvec set the arrayed control argument of node: %.".format(msg[1])
			);
		}
	}

	test_process_set {
		var value = 5;
		addr.sendMsg('/satie/process/set', 'myProcess', 'myProperty', value);
		server.sync;
		this.assertEquals(
			satie.processInstances[\myProcess].at(\myProperty),
			value,
			"/satie/process/set called the process' set function"
		);
	}

	test_process_setvec {
		var value = [100, 200, 300];
		addr.sendMsg('/satie/process/setvec', 'myProcess', 'myProperty', value[0], value[1], value[2]);
		server.sync;
		this.assertEquals(
			satie.processInstances[\myProcess].at(\myProperty),
			value,
			"/satie/process/setvec called the process' setVec function."
		);
	}

	test_source_update {
		var result;
		var value = [90.0, 45.0, -50.0];
		addr.sendMsg('/satie/source/update', 'mySource', value[0], value[1], value[2]);
		server.sync;
		satie.groupInstances[\default][\mySource].getn(index: 3, count: 3, action: { |val| result = val });
		server.sync;
		this.assertEquals(
			result,
			value,
			"/satie/source/update set all the node's update arguments."
		);
	}

	test_process_update {
		var result;
		var value = [90.0, 45.0, -50.0, []];
		addr.sendMsg('/satie/process/update', 'myProcess', value[0], value[1], value[2]);
		server.sync;
		result = satie.processInstances[\myProcess].at(\myProperty);
		this.assertEquals(
			result,
			value,
			"/satie/process/update called the process' setUpdate function."
		);
	}

	test_process_property {
		var value = 100;
		addr.sendMsg('/satie/process/property', 'myProcess', 'myProperty', value);
		server.sync;
		this.assertEquals(
			satie.processInstances[\myProcess].at(\myProperty),
			value,
			"/satie/process/property set the specified process property."
		);
	}

	test_process_eval {
		var value = [200, 300, 400];
		addr.sendMsg('/satie/process/eval', 'myProcess', 'myFunction', value[0], value[1], value[2]);
		server.sync;
		this.assertEquals(
			satie.processInstances[\myProcess].at(\myProperty),
			value,
			"/satie/process/eval evaluated the specified process function."
		);
	}

	test_introspection_plugins {
		var result;
		OSCFunc({ |msg| result = msg[0] }, '/plugins');
		addr.sendMsg('/satie/plugins');
		server.sync;
		this.assertEquals(
			result,
			'/plugins',
			"/satie/plugings introspection message received"
		);
	}

	test_introspection_pluginargs {
		var result;
		OSCFunc({ |msg| result = msg[0] }, '/arguments');
		addr.sendMsg('/satie/pluginargs', 'testtone');
		server.sync;
		this.assertEquals(
			result,
			'/arguments',
			"/satie/plugingargs introspection message received"
		);
	}

	test_introspection_plugindetails {
		var result;
		OSCFunc({ |msg| result = msg[0] }, '/arguments');
		addr.sendMsg('/satie/plugindetails', 'testtone');
		server.sync;
		this.assertEquals(
			result,
			'/arguments',
			"/satie/plugindetails introspection message received"
		);
	}

}
