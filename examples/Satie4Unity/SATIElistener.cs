using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class SATIElistener : SATIEnode {
    
    //public delegate void SATIEConnection(Transform tr, bool posFlag, bool rotFlag);
	
	public bool submergedFlag = false;
	private bool _submergedFlag;

    public override void Start()
    {
		nodeType = "listener";

        initNode();  // must be called before parent's "Start()"
        base.Start();
    }

	public override void OnValidate()
	{
		base.OnValidate();


		if (_submergedFlag != submergedFlag)
		{
			_submergedFlag = submergedFlag;
			setSubmerseStatus();
			// setNodeActive(nodeName, nodeEnabled);
		}

		
	}

	void setSubmerseStatus()
	{

		string path;
		List<object> items = new List<object>();
		int state = (_submergedFlag) ? 1 : 0;
		
		items.Add( state );             

		foreach (SATIEnode src in sourceInsatances) 
		{
			path = "/spatosc/core/connection/" + src.name + "->" + name + "/hpHz";   // 
			SATIEsetup.OSCtx (path, items);   // send spread message via OSC
		}
		items.Clear();

	}




    public override void Update()
    {
        base.Update();
    }

    public override void FixedUpdate()
    {
        base.FixedUpdate();
    }

	public override void LateUpdate()
	{
		base.LateUpdate();
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
