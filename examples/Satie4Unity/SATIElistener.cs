using UnityEngine;
using System.Collections;

public class SATIElistener : SATIEnode {
    
    public delegate void SATIEConnection(Transform tr, bool posFlag, bool rotFlag);

    public  static event SATIEConnection UpdateConnection;       // subscribers

   // public SATIElistener() {}        // list of subscribers

    public override void Start()
    {
		nodeType = "listener";

        initNode();  // must be called before parent's "Start()"
        base.Start();
        
    }
    public override void Update()
    {
        base.Update();
    }

    public override void FixedUpdate()
    {
        base.FixedUpdate();
    }


    private float _lastUpdate = -1f;

    void LateUpdate()
    {

        if (UpdateConnection != null)
        {
            if (true)
            {
                if ( (Time.time - _lastUpdate )> SATIEsetup.updateRateSecs)
                {
                    //Debug.Log("SATIEsetup.LateUpdate:  current delta" + (Time.time - lastUpdate) + " is greater than " + _updateRate);
                    UpdateConnection(transform, updatePosFlag, updateRotFlag);  // send update connection to all connected delegates

                    if (updatePosFlag)
                        updatePosFlag = false; // reset flag
                    if (updateRotFlag)
                        updateRotFlag = false; // reset flag

                    _lastUpdate = Time.time;
                }


            }
        }
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
