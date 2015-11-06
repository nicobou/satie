using UnityEngine;
using System.Collections;

public class SATIElistener : SATIEnode {
    
    public delegate void SATIEConnection(Transform tr, bool posFlag, bool rotFlag);
	

    public override void Start()
    {
		nodeType = "listener";

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
