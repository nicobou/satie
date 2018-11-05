SatieQueryTree {
	var server, msg, <nodeIds, index;

	*get { |action, server|
		var node = RootNode(server);

		OSCFunc(
			{ |msg|
				var snapshot = SatieQueryTree(server, msg);
				action.value(snapshot);
			},
			'/g_queryTree.reply'
		).oneShot;

		// '0' means don't reply with Synth control values
		server.sendMsg("/g_queryTree", node.nodeID, 0);
	}

	*new { |server, msg|
		^super.newCopyArgs(server, msg).parse;
	}

	parse {
		// start index at rootNode's ID
		index = 2;
		nodeIds = List.new;
		this.parseNode;
	}

	parseNode {
		var nodeId, numChildren;
		nodeId = this.next;
		numChildren = this.next;

		// numChildren -1 is a Synth, >=0 is a Group
		if(numChildren < 0) {
			nodeIds.add(nodeId);
			// skip SynthDef name
			this.next;
		} {
			// recurssively parse Group
			numChildren.do {
				this.parseNode;
			};
		}
	}

	next {
		var nextMsgItem = msg[index];
		index = index + 1;
		^nextMsgItem
	}

}

