// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

(
~satieOSCMaker = { | rootPath = "/satie", port = 18032 |
	var rootURI = rootPath;
	var oscPort = port;
	var e = Environment.make({

		// main OSC method
		~newOSC = {|self, id, cb , path = \default|
			var idsym = id.asSymbol;
			//postf("---> newOSC callback passed : %\n", cb);
			OSCdef(idsym, cb, path, recvPort: oscPort);
		};

		~deleteOSC = {|self, id|
			//postf("~deleteOSC  id: %\n",id.asSymbol);
			OSCdef(id.asSymbol ).free;
		};


	   // create  OSC callback for satieRendererCtl
		~makeRendererCtlOSC = {|self, cb|
			self.newOSC(\rendererCtl, cb,  rootURI +/+ "rendererCtl");
		};

		// remove  OSC callback for satieRendererCtl.
		~removeRendererCtlOSC = {|self|
			self.deleteOSC(\rendererCtl);
		};

		// create  OSC callback for satie projects
		~makeProjectOSC = {|self, projectName, cb|
			self.newOSC(projectName.asSymbol, cb,  rootURI+/+"project"+/+projectName);
		};

		// remove  OSC callback for satie projects
		~removeProjectOSC = {|self, projectName|
			self.deleteOSC(projectName.asSymbol);
		};


	});
	e.know = true;
	"satieOSC interface loaded".inform;
	e;
};
)