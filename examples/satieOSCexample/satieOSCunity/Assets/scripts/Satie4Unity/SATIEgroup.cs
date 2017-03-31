// Satie4Unity, audio rendering support for Unity
// Copyright (C) 2016  Zack Settel

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
// -----------------------------------------------------------
using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class SATIEgroup : SATIEnode {
    
	public List <string> members = new List<string>();


    public string stringToEdit = "Modify me.";
    void OnGUI() {
        stringToEdit = GUI.TextField(new Rect(10, 10, 200, 20), stringToEdit, 25);
        if (GUI.changed)
            Debug.Log("Text field has changed.");
        
    }

       
    public override void Start()
    {

		transform.name = nodeName = "Untagged";

		nodeType = "group";

		if (gameObject.tag != "Untagged")  
			nodeName = transform.name = gameObject.tag;
        else nodeName = transform.name = "default";

		bool result;

		if (!SATIEsetup.OSCenabled)
		{
			Debug.LogError(transform.name + ":  SATIEnode.Start:  SATIEsetup: translator(s) not enabled");
			//return false;
		}

//		result = SATIEsetup.createGroup(nodeName);
//		if (!result)
//		{ 
//			Debug.LogError("SATIEgroup.start: failed to create group node, duplicate node tag (node name) ?");
//			return;
//		}

		//nodeName = nodeName + "_sourceGroup";
		
		//Debug.Log("SATIEnode.initNode: CREATING SPAT_OSCNODE: "+nodeName+"  type: "+ nodeType);
		// SATIEsetup.setURI(nodeName, uriString);   NO NEED TO DO THIS NOW THAT THE URI IS CREATED WITH THE SOURCE

		initNode();  // must be called before parent's "Start()"
        base.Start();
	
        
    }


	public override void OnValidate()
	{
		base.OnValidate();
		
	}


    public override void Update()
    {
        base.Update();

          if (GUI.changed)
            Debug.Log("Text field has changed.");
    }

    public override void FixedUpdate()
    {
        base.FixedUpdate();
    }

	public override void LateUpdate()
	{
		base.LateUpdate();
	}
	
    public void dropMember (SATIEsource source)
	{
//        string path = "/satie/group/drop";
//
//        List<object> items = new List<object>();

        members.Remove(source.name);

        // no more group messages to server
//        items.Add(source.name);                
//        SATIEsetup.OSCtx(path, items);
//        items.Clear();
	}


	public void addMember (SATIEsource source )
	{
//        string path = "/satie/group/add";
//        List<object> items = new List<object>();
//
//        source.group = name;
		members.Add (source.name);


        // no more group messages to server
//        items.Add(source.name);   
//
//        SATIEsetup.OSCtx(path, items);
//        items.Clear(); 
	}

    public override void  setNodeActive(string nodeName, bool nodeEnabled)
    {
        base.setNodeActive(nodeName, nodeEnabled);
    }
    
    public override  void deleteNode(string nodeName)
    {
        base.deleteNode(nodeName);
    }
		

}

