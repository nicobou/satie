/*
	Created by Carl Emil Carlsen.
	Copyright 2016 Sixth Sensor.
	All rights reserved.
	http://sixthsensor.dk
*/

using UnityEngine;
using UnityEngine.UI;
using System.Collections;

namespace OscSimpl.Examples
{
    public class zkOSCsimplSendPos : MonoBehaviour
    {
        public OscOut oscOut;

        private string OSCaddress;
        // automatically creates an OSC address using the object's name, making:  "/objName/position"

        [Tooltip("make sure  object transforms with OscIn components also have zk_transformTag components that have the same tagName")]

        public string tagName = "undefined";

        private OscMessage oscPosMessage;
        private Vector3 _oscLastValue;
        private bool _start = false;

        void Start()
        {
            // Ensure that we have a OscOut component.
            //f( !oscOut ) oscOut = gameObject.AddComponent<OscOut>();

            if (oscOut != null)   // already chosen manually
                return;

            OSCaddress = "/" + transform.name + "/position";

            // Prepare for sending messages to applications on this device on port 7000.
            //oscOut.Open( 7000 );

            // Or, to a target IP Address (Unicast).
            //oscOut.Open( 7000, "192.168.1.101" );

            // Or to all devices on the local network (Broadcast).
            //oscOut.Open( 7000, "255.255.255.255" );

            // Or to a multicast group (Multicast).
            //oscOut.Open( 7000, "224.1.1.101" );
            _oscLastValue = new Vector3(transform.position.x, transform.position.y, transform.position.z);

//            if (OSCaddress.Length==0)
//            {
//                Debug.LogError(transform.name + " : " + GetType() + " : " + "Awake(): need to specify a valid OSC address, e.g. /sheefa,  aborting");
//                Destroy(this);
//                return;
//            }

            // look for the OscIn object(s) among children of gameroot using tag
            if (oscOut != null)   // already chosen manually
                return;
            

            if (zk_transformTag.zk_transformTagList.Count == 0)
            {
                Debug.LogError(transform.name + " : " + GetType() + " : " + "Start(): can't find any objects with with both a 'zk_transformTag' compenent and an oscOut component in the transform, aborting");
                Destroy(this);
                return;
            }

            //zk_transformTagsCS = ;

            zk_transformTag oscOutTagCS = null;

            foreach (zk_transformTag tag in zk_transformTag.zk_transformTagList)
            {
                oscOutTagCS = tag;
                if (tag.tagName.Equals(tagName)) 
                {
                    break;   // all good... object found on transform with corresponding tag                  
                }
                //Debug.Log(transform.name + " : " + GetType() + " : " + "Matching on tag:"+tagName);
            }


            oscOut = oscOutTagCS.gameObject.GetComponent<OscOut>();

            if (oscOut == null)
            {
                Debug.LogError(transform.name + " : " + GetType() + " : " + "Start(): can't find locate OscIn object(s) in the transform of"+ oscOutTagCS.gameObject.name + ", aborting");
                Destroy(this);
                return;
            }

            if (!oscOutTagCS.tagName.Equals(tagName)) 
                Debug.LogWarning(transform.name + " : " + GetType() + " : " + "Start():can't locate oscOut component with zk_transformTag: "+tagName+" in transform.  Using OscIn component associated with tag: "+oscOutTagCS.tag+" in transform of object: "+oscOutTagCS.gameObject.name);


                
            oscPosMessage = new OscMessage(OSCaddress);
            oscPosMessage.Add(_oscLastValue.x);
            oscPosMessage.Add(_oscLastValue.y);
            oscPosMessage.Add(_oscLastValue.z);            
            oscOut.Send(oscPosMessage);
         
        }


 

        void Update()
        {

            if (_oscLastValue != transform.position)
            {
                _oscLastValue = transform.position;

                oscPosMessage.args[0] = _oscLastValue.x;
                oscPosMessage.args[1] = _oscLastValue.y;
                oscPosMessage.args[2] = _oscLastValue.z;
                oscOut.Send(oscPosMessage);
            }
        }
    }
}