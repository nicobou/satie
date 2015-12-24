using UnityEngine;
using System.Collections;
using System.Collections.Generic;



// note:  this script must be in the transform that the SATIEsourceNode is in, and that node must have a "process" as a uri type
public class SATIEprocess : MonoBehaviour {

	public List <string> events = new List<string>();
	private List <string> _events = new List<string>();

	public List <string> parameters = new List<string>();
	private List <string> _parameters = new List<string>();


	SATIEsource SATIEsourceCS;


	// Use this for initialization
	void Start () 
	{
		SATIEsourceCS = transform.GetComponent<SATIEsource>();

		if (SATIEsourceCS == null)
		{
			Debug.LogError("SATIEprocess.start(): component of type <SATIEsource> found in transform, aborting");
			return;
		}
		// else

		if ( !SATIEsourceCS.uri.Contains("process"))
		{
			Debug.LogError("SATIEprocess.start(): source node in transform URI type is not a process, aborting");
			return;
		}

      	StartCoroutine( connectionInit() );
	

	}
	
	// Update is called once per frame
	void Update ()
	{
		if (Input.GetKey ("p")) {
			sendState ();
		}
	
	}


	IEnumerator connectionInit() // now that litener(s) have been conection related parameters.
	{
		yield return new WaitForFixedUpdate ();
		sendState ();  // by this time, all the start and initialization routines have been evaluated and we can assume that updates to this node will be received on the renderer.


	}

	void sendState ()
	{
		sendEvents (events, false);
		sendEvents (parameters, true);  
	}


	// called when inspector's values are modified
	public virtual void OnValidate()
	{

		if (_events.Count != events.Count)
		{
			// Debug.Log("_events.Count != events.Count");


			_events.Clear();
			foreach (string s in events)
			{
				_events.Add(s);
			}
			return;
		}

		for (int i=0; i<events.Count; i++)
		{
			// Debug.Log("events [i]:  " + events [i]);
			if (events [i] != _events [i])
			{
				List<string> property = new List<string>(events [i].Split(' '));
				string keyword = "";
				string svalues = "";


				//Debug.Log("CHANGED events [i]:  " + events [i]);

				// remove spaces
				for (int n = 0; n < property.Count; n++)
				{
					if (keyword == "" && property [n] != "") {
						keyword = property [n];

					} 
					else 
					{
						if (property [n] != "")
							svalues += " " + property [n];
						}
				}

				// Debug.Log("\t \t \t WE GOT:  MODIFIED PROPERTY: "+keyword+" : "+ svalue);
				//  Debug.Log("\t PROPERTY len = " + property.Count);
				//            foreach (string item in property)   Debug.Log("\t PROPERTY ATOM: " + item);       

				// if incomplete property abort
				if (keyword == "") 
				{
					//Debug.Log("propseryMessage too short:  " + events [i]);
					return;
				}

				// else the property is valid

				// rewrite event without white spaces
				//events[i] = keyword + " " + svalue;

				_events [i] = events [i] = keyword + svalues;
				sendEvents (events, false);


				//Debug.Log("MODIFIED PROPERTY: "+keyword+" : "+svalue);

			}
		}
	}



	void sendEvents(List <string> messages, bool setParamFlag)
	{

		foreach (string s in messages)
		{
			if (s.Equals("") ) continue;
			

			List<string> items = new List<string>(s.Split(' '));

			List<object> atoms = new List<object>();

			
			foreach (string value in items)
			{
				int ivalue;
				float fvalue;


				if (int.TryParse(value, out ivalue))
				{
					//Debug.Log("ITEM IS AN INTEGER = " + ivalue);
					atoms.Add(ivalue);
				} else if (float.TryParse(value, out fvalue))
				{
					//Debug.Log("ITEM IS A FLOAT = " + fvalue);
					atoms.Add(fvalue);
				} else
				{
					//Debug.Log("ITEM IS A STRING = " + svalue);
					atoms.Add(value);
				}
			}
			if (atoms.Count < 2)
			{
				Debug.LogWarning("SATIEprocess.sendState(): " + transform.name + ":  incomplete message");
			}
			else if (atoms[0].GetType() !=  typeof(string))
			{
				Debug.LogWarning("SATIEprocess.sendState(): " + transform.name + ":  first item in message must be a string");
			}
			else   // message good. Send it now
			{
				if (setParamFlag) atoms.Insert(0, "setParam");
				SATIEsourceCS.sendEvent(atoms);
			}
		}
	}


}
