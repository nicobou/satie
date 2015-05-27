//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

SpatOSCManager {
	var allNodes;
	classvar <oscRoot = "/spatosc/core", <synthDefs;

	*initClass {
		synthDefs = Dictionary.newFrom([
			\ks, SynthDef(\spatOSCKarplusStrong, {|out=0, t_trig=0, freq=440, decay=3, dur=0.001|
				var sig;
				sig = Pluck.ar(
					in: WhiteNoise.ar(0.1),
					trig: Trig.ar(t_trig, dur),
					maxdelaytime: 0.2,
					delaytime: 1/freq,
					decaytime: decay,
					coef: 0.5
				);
				Out.ar(out, sig);
			}),
			\fm, SynthDef(\spatOSCKarplusStrong, {})
		]);

	}

	*new {}

	init {
		allNodes = Dictionary.new;
		OSCdef(\createSource,{|msg|
			var action = msg[1];
			var nodeName = msg[2].asSymbol;
			var connectTo = msg[3].asSymbol;
			switch ( action,
				"createSource", {
					allNodes.add(nodeName -> SpatOSCSource(nodeName));
				},
				"createListener", {
					allNodes.add(nodeName -> SpatOSCListener(nodeName));
				},
				"deleteNode", {
					allNodes[nodeName].delete;
				},
				"connect", {
					allNodes[nodeName].connect(allNodes[connectTo]);
				},
				"disconnect", {
					allNodes[nodeName].disconnect(allNodes[connectTo]);
				},
				"clearScene", {
					allNodes.do{|i| i.delete;};
				}
			);

		}, oscRoot, nil, 18032);

		synthDefs.do{|i| i.add(Server.default)};
	}
}


SpatOSCNode {

	var name, synth, oscFuncs, bus;

	*new { |name|
		super.newCopyArgs(name).init();
	}

	delete {

	}

	connect {

	}

	disconnect {

	}
}

SpatOSCSource : SpatOSCNode {
	var funcs, parameters;

	init {
		parameters = [\uri, \prop, \event, \state];
		oscFuncs = List[];
		bus = Bus.audio(Server.default, 1);
		funcs = Dictionary.newFrom([
			\uri, {|msg| //parse msg to extract synthDef name, eg \spatOSCKarplusStrong
				//SpatOSCManager.synthDefs[msg[1]].name;
				synth = Synth.tail(Server.default, msg[1], [
					\out, bus
				]);
			},
			\prop, { |msg|
				synth.set( *msg[1..]);
			},
			\state, { |msg|
				synth.run(msg[1]);
			},
			\event, { |msg|
				synth.set( *msg[1..]);
			}
		]);


		parameters.do{|item|
			OSCdef((name ++ item).asSymbol, funcs[item],
				SpatOSCManager.oscRoot +/+ "source" +/+ name +/+ item, nil, 18032
			);
		};

	}
}

SpatOSCConnection : SpatOSCNode {}

SpatOSCListener : SpatOSCNode {}