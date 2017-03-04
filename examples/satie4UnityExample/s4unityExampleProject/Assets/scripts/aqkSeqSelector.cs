

using UnityEngine;
using System.Collections;
using System.Collections.Generic;


[ExecuteInEditMode]
public class aqkSeqSelector : MonoBehaviour
{

    SATIEsource SATIEsourceCS;

    private bool _start = false;

    public Vector3 lookAtPoint = Vector3.zero;
    public string sequenceName = "";

    private string _currentSequence = "";

    void Awake()
    {
        // string argvec[];
        string uriString = "";

        SATIEsourceCS = transform.GetComponent<SATIEsource>();

        if (SATIEsourceCS == null)
        {
            Debug.LogError("aqkSeqSelector.Awake(): component of type <SATIEsource> found in transform, aborting");
            return;
        }
    }


    void Start()
    {
         StartCoroutine( initMe() );

    }

    void sendPitchFile()
    {
        List<object> atoms = new List<object>();

        _currentSequence = sequenceName;

        atoms.Add("readPitches");
        atoms.Add(sequenceName);
        SATIEsourceCS.sendEvent(atoms);
    }



    IEnumerator initMe() // this is delayed to make sure the audio renderer has time to create the node beforehand
    {
        yield return new WaitForFixedUpdate();
        _start = true;
               if (_currentSequence != sequenceName)
        {
            sendPitchFile(); 
        }

    }

    // checks to see if editor has updated the sequenceName field in the meanwhile
    void Update()
    {
        if (_start != true)
            return;
        if (_currentSequence != sequenceName)
        {
            sendPitchFile(); 
        }
    }
}





