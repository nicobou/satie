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

// SatieOSC  - process handling

+ SatieOSC		{
	createProcessNode { | id, uriPath |
		var temp, type, charIndex, processName, myProcess, cloneGroup, cloneGroupName;
		var processClone = nil;
		var rawArgVec = nil;
		var argList = List[];

		processName= uriPath.asString.split($ )[0];
		rawArgVec = uriPath.asString.split($ );
		rawArgVec.removeAt(0);  // drop first item in list

		if ( satie.config.debug,  { postf("•satieOSC.createProcessNode:   %   URI  %   optArgs: %\n", id, uriPath, rawArgVec);});

		// make list of items in argString
		rawArgVec.do( { arg item;
			if ( item != "",
				{
					argList.add(item);
				});
		});

		if (satie.processInstances[id.asSymbol]  != nil,
			{
				error("satieOSC.createProcessNode source Process node: "++id++",   ALREADY EXISTS, aborting \n", );
			},
			// else ALL GOOD,  instantiate
			{
				satie.makeProcessInstance(id.asSymbol, processName);
				postf(">>satieOSC.createProcessNode: creating: %,  with  process:  %   and arglist: % \n", id, processName, argList);
			});
	}
}
