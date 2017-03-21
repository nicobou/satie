/*
* UniOSC
* Copyright © 2014-2015 Stefan Schlupek
* All rights reserved
* info@monoflow.org
*/
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;

//using OSCsharp.Data;



// strips off last item in OSC address path, and calls corresponding method by name for all scripts of game object and children
// note,  this object can only handle at most, one datum in the received OSC message


namespace OscSimpl.Examples{

    /// <summary>
    /// Moves a GameObject in normalized coordinates (ScreenToWorldPoint)
    /// </summary>
    // [AddComponentMenu("UniOSC/MoveGameObject")]
    public class zkOSCsimplapplyMess :  MonoBehaviour {

        private string _oscMatchAddr = "";
        private bool _start = false;
        public bool alsoSendToChildren = false;

        public bool debug = false;


        public string OSCaddress = "";      // automatically creates an OSC address using the object's name, making:  "/objName/position"

        [Tooltip("make sure that the OscIn objects in the environment have a corresponding tag")]

        public string tagName="";

        public OscIn oscIn;
         


        void Start()
        {

            if (OSCaddress.Length==0)
            {
                Debug.Log(transform.name + " : " + GetType() + " : " + "Start(): need to specify a valid OSC address, e.g. /sheefa,  aborting");
                Destroy(this);
                return;
            }

            if (oscIn != null)   // already chosen manually
                return;

            // look for the OscIn object(s) among children of gameroot using tag


            if (zk_transformTag.zk_transformTagList.Count == 0)
            {
                Debug.LogError(transform.name + " : " + GetType() + " : " + "Start(): can't find any objects with with both a 'zk_transformTag' compenent and an oscIn component in the transform, aborting");
                Destroy(this);
                return;
            }

            //zk_transformTagsCS = ;

            zk_transformTag oscInTagCS = null;

            foreach (zk_transformTag tag in zk_transformTag.zk_transformTagList)
            {
                oscInTagCS = tag;
                if (tag.tagName.Equals(tagName))
                {
                    break;   // all good... object found on transform with corresponding tag                  
                }
                //Debug.Log(transform.name + " : " + GetType() + " : " + "Matching on tag:"+tagName);
            }


            oscIn = oscInTagCS.gameObject.GetComponent<OscIn>();

            if (oscIn == null)
            {
                Debug.LogError(transform.name + " : " + GetType() + " : " + "Start(): can't find locate OscIn object(s) in the transform of" + oscInTagCS.gameObject.name + ", aborting");
                Destroy(this);
                return;
            }

            if (!oscInTagCS.tagName.Equals(tagName))
                Debug.LogWarning(transform.name + " : " + GetType() + " : " + "Start():can't locate oscIn component with zk_transformTag: " + tagName + " in transform.  Using OscIn component associated with tag: " + oscInTagCS.tag + " in transform of object: " + oscInTagCS.gameObject.name);



			checkOSCprependedPath ();
			_start = true;
            OnEnable();   // this can not be called until START has set up the state
        }

       void OnValidate()
        {
            if (!_start)
                return;
			if (OSCaddress != _oscMatchAddr)
                checkOSCprependedPath();
         }


        public void OnEnable()
        {
            if (!_start == true)
                return;

            //Debug.Log(transform.name + " : " + GetType() + " : " + "OnEnable()");
            if (oscIn != null)                   
				oscIn.onAnyMessage.AddListener( OnOSCMessage );  // Subscribe to all OSC messages
        }


        void OnDisable()
        {
            // Unsubscribe from messsages
            if (oscIn != null)                   
                oscIn.onAnyMessage.RemoveListener( OnOSCMessage );   // unsubsccribe
        }

//		void Update()
//        {
//        }
//
		void checkOSCprependedPath()
		{
			if ( !OSCaddress.Contains("/") || !OSCaddress.StartsWith("/")  )               
			{
				Debug.LogError(string.Format("{0}.Awake():  OSC path format error: {1}, aborting", GetType(), OSCaddress), transform);
				_oscMatchAddr = "";
				return;
			}

			if (OSCaddress.EndsWith("/*"))    // all good
				_oscMatchAddr = OSCaddress.TrimEnd(new char[] { '/', '*' });
			else if (OSCaddress.EndsWith("/"))
			{
				_oscMatchAddr = OSCaddress.TrimEnd(new char[] { '/' });
				OSCaddress += "*";
			}
			else
			{
				_oscMatchAddr = OSCaddress;
				OSCaddress += "/*";
			}
		}

		public void OnOSCMessage(OscMessage msg )
        {
			string address = msg.address;
            int matchLen = _oscMatchAddr.Length;
            string methodName;
			string sval;
			float fval;
			int ival;
  
			if (msg.args.Count > 1)
            {
				Debug.LogWarning(transform.name + ": "+ GetType() + ".OnOSCMessage():  can only have maximum of one datum in message, aborting ");
                return;
            }
 
            if (address.Length <= matchLen+1)
                return;

 
            if (debug)
            {
				Debug.Log("MESS: " + address + "   count: " + msg.args.Count);
 
            }

            if (_oscMatchAddr == address.Substring(0, matchLen))
            {

                if (debug) Debug.Log("\t\taddress match: " + address.Substring(0, matchLen));
                methodName = address.Substring(matchLen + 1);
            }
            else
                return;
            
            // address matched, using remainder of address as method name

            if (debug)  Debug.Log("\t\tMESSAGE MATCHED: " +      _oscMatchAddr + " for method: "  + methodName);
                   // send message to all scripts on this gameobject, and its children
           // gameObject.BroadcastMessage(methodName, (float)msg.Data[0], SendMessageOptions.DontRequireReceiver);  

  
			// OSC address only, no data to include in message
			if (msg.args.Count == 0)
            {

                gameObject.SendMessage(methodName, null, SendMessageOptions.DontRequireReceiver);  
                if (alsoSendToChildren)
                {
                    Transform[] transforms = gameObject.GetComponentsInChildren<Transform>();
                    foreach (Transform t in transforms)
                    {
                        t.SendMessage(methodName, null, SendMessageOptions.DontRequireReceiver);  
                    }
                }

                return;
            }


			// is the datum is a string
			if( msg.TryGet( 0, out sval ) ) 
				{
					gameObject.SendMessage(methodName, sval, SendMessageOptions.DontRequireReceiver);  

					if (alsoSendToChildren)
					{
						Transform[] transforms = gameObject.GetComponentsInChildren<Transform>();
						foreach (Transform t in transforms)
						{
							t.SendMessage(methodName, sval, SendMessageOptions.DontRequireReceiver);  
						}
					}
					return;
				}


			// is the datum is a float
			if( msg.TryGet( 0, out fval )) // is it a string
			{
				gameObject.SendMessage(methodName, fval, SendMessageOptions.DontRequireReceiver);  

				if (alsoSendToChildren)
				{
					Transform[] transforms = gameObject.GetComponentsInChildren<Transform>();
					foreach (Transform t in transforms)
					{
						t.SendMessage(methodName, fval, SendMessageOptions.DontRequireReceiver);  
					}
				}
				return;
			}


			// is the datum is an int, cast as float
			if( msg.TryGet( 0, out ival )) // is it a string
			{
				gameObject.SendMessage(methodName, (float) ival, SendMessageOptions.DontRequireReceiver);  

				if (alsoSendToChildren)
				{
					Transform[] transforms = gameObject.GetComponentsInChildren<Transform>();
					foreach (Transform t in transforms)
					{
						t.SendMessage(methodName, (float) ival, SendMessageOptions.DontRequireReceiver);  
					}
				}
				return;
			}


		}
    }
}