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
	createProcess {| sourceName, uriPath , groupName = \default |
		if (allSourceNodes.includesKey(sourceName),
			{
				postf("satieOSC.createSource:   % exists, no action \n", sourceName);
			},
			// else create new node
			{
				var type;
				type = this.getUriType(uriPath);

				if ( type == \process,  {
					this.createProcessNode(sourceName.asSymbol, uriPath,groupName );
				},
				// else
				{
					postf("satieOSC.createProcess: node  %  URI: %,  wrong type,  no action \n", sourceName, type);
				});
			}
		);
	}

	createProcessNode { | sourceName, uriPath , groupNameDummy = \default |
			var temp, type, charIndex, processName, myProcess, cloneGroup, cloneGroupName;
			var processClone = nil;
			var rawArgVec = nil;
			var argList = List[];

			if ( satie.satieConfiguration.debug,  { postf("•satieOSC.createProcessNode:   %   URI  % \n", sourceName, uriPath);});

			processName= uriPath.asString.split($ )[0].split($/)[2];
			rawArgVec = uriPath.asString.split($ );
			rawArgVec.removeAt(0);  // drop first item in list

			// make list of items in argString
			rawArgVec.do( { arg item;
				if ( item != "",
					{
						argList.add(item);
				});
			});


			if (allSourceNodes[sourceName.asSymbol]  != nil,
				{
					error("satieOSC.createProcessNode source Process node: %,   ALREAYD EXISTS, aborting \n", sourceName);
				},
				// else ALL GOOD,  instantiate
				{
					processClone = satie.cloneProcess(processName.asSymbol);
					if (processClone == nil,
						{
							error("satieOSC.createProcessNode: undefined process name:"++processName++"   ,  node not created \n");
						},						// else node good to go
						{
							allSourceNodes[sourceName.asSymbol] = Dictionary();   // create node  -- create node-specific dict.
							allSourceNodes[sourceName.asSymbol].put(\plugin, \nil);

							// generate groupName unique to source node
							cloneGroupName = sourceName ++ "_group";
							cloneGroup = this.createGroup(cloneGroupName.asSymbol);   // create group for this node and its clones


							cloneGroup = allGroupNodes[cloneGroupName.asSymbol].at(\group); // must be called after createGroup() above

							allSourceNodes[sourceName.asSymbol].put(\process, processClone);
							allSourceNodes[sourceName.asSymbol].put(\groupNameSym, cloneGroupName.asSymbol);

							myProcess = allSourceNodes[sourceName.asSymbol].at(\process);

							// send URI's argsString to setup without any error checking

							myProcess[\setup].value(myProcess, sourceName.asSymbol, cloneGroupName.asSymbol, argList );   // set the state of the process
							this.setSynth(sourceName.asSymbol, "");  // sets dummy plugin as placeholder

							postf(">>satieOSC.createProcessNode: creating: %,  with  process:  %   and arglist: % \n", sourceName, processName, argList);

					});
			});
		}
}