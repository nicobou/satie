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

		result = SATIEsetup.createGroup(nodeName);
		if (!result)
		{ 
			Debug.LogError("SATIEgroup.start: failed to create group node, duplicate node tag (node name) ?");
			return;
		}

		//nodeName = nodeName + "_sourceGroup";
		
		//Debug.Log("SATIEnode.initNode: CREATING SPAT_OSCNODE: "+nodeName+"  type: "+ nodeType);
		// SATIEsetup.setURI(nodeName, uriString);   NO NEED TO DO THIS NOW THAT THE URI IS CREATED WITH THE SOURCE

		initNode();  // must be called before parent's "Start()"
        base.Start();
	
        
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


	public void dropMember (SATIEsource source)
	{
        string path = "/spatosc/core/group/" + nodeName + "/drop";
        List<object> items = new List<object>();

        members.Remove(source.name);

        items.Add(source.name);                
        SATIEsetup.OSCtx(path, items);
        items.Clear();
	}


	public void addMember (SATIEsource source )
	{
        string path = "/spatosc/core/group/" + nodeName + "/add";
        List<object> items = new List<object>();

        source.group = name;
		members.Add (source.name);
        items.Add(source.name);   

        SATIEsetup.OSCtx(path, items);
        items.Clear(); 
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
