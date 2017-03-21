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
//using Oz.Game;
namespace OscSimpl.Examples
{
    public class zkOSCsimplMoveGameObject :  MonoBehaviour {




		public string OSCaddress;		

        [Tooltip("make sure  object transforms with OscIn components also have zk_transformTag components that have the same tagName")]

        public string tagName="default";

        public OscIn oscIn;

		public enum PosMapping { direct, offset }
		private Transform transformToMove;

        //movementModeProp = serializedObject.FindProperty ("movementMode");

        private Vector3 targetPos = new Vector3();
//		private Vector3 startPos = new Vector3(); // Never used warning

 
 

        [Header("")]
        public bool Xenable = true;
		public float xscale = 1;
        public PosMapping Xmapping = PosMapping.direct;
        private float _xpos;

        [Header("")]
        public bool Yenable = true;
		public float yscale = 1;
        public PosMapping Ymapping = PosMapping.direct;
        private float _ypos;

        [Header("")]
        public bool Zenable = true;
		public float zscale = 1;
        public PosMapping Zmapping = PosMapping.direct;
        private float _zpos;



        //Whether we are currently interpolating or not
        private bool _isLerping;

        //The start and finish positions for the interpolation
        private Vector3 _startPosition;
        private Vector3 _endPosition;

        //The Time.time value when we started the interpolation
        private float _timeStartedLerping;

        private bool _start=false;



        [Header("")]


        public float positionSmoothingTime = 0.25f;

        [Header("OSCrx Polling Option")]

        // OSC POLLING CONTROL
        private Vector3 _oscCurValue;
        private Vector3 _oscLastValue;
        public bool OSCpollingEnable = true;
        public float OSCpollIntervalMs = 30f;  // polling interval ms for current OSC values
        private float _lastPollTime;

        private void OnValidate()
        {
            if (!_start)
                return;
            if (positionSmoothingTime <= 0)
                positionSmoothingTime = 0.0001f;
            if (OSCpollIntervalMs < 0)
                OSCpollIntervalMs = 0f;
        }


        void Start()
        {
            
            _oscCurValue = new Vector3(0,0,0);
            _oscLastValue = new Vector3(0, 0, 0);

            if (OSCaddress.Length==0)
            {
                OSCaddress = "/" + transform.name + "/position";  // automatically create an OSC address using the object's name, making:  "/objName/position"
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
                Debug.LogError(transform.name + " : " + GetType() + " : " + "Start(): can't find locate OscIn object(s) in the transform of"+ oscInTagCS.gameObject.name + ", aborting");
                Destroy(this);
                return;
            }

            if (!oscInTagCS.tagName.Equals(tagName)) 
                Debug.LogWarning(transform.name + " : " + GetType() + " : " + "Start():can't locate oscIn component with zk_transformTag: "+tagName+" in transform.  Using OscIn component associated with tag: "+oscInTagCS.tag+" in transform of object: "+oscInTagCS.gameObject.name);
                        
            _start = true;
            OnEnable();   // this can not be called until START has set up the state
        }


		public void OnEnable()
		{
            if (!_start )
                return;
            
            // Debug.Log(transform.name + " : " + GetType() + " : " + "OnEnable()");


            if (oscIn != null)
                oscIn.Map( OSCaddress, OnOSCMessage );

			if(transformToMove == null){
				Transform hostTransform = GetComponent<Transform>();
				if(hostTransform != null) transformToMove = hostTransform;
			}
           //Debug.Log("ONENABLE  OBJ NAME: " + transformToMove.name);

            _xpos = transform.position.x;
            _ypos = transform.position.y;
            _zpos = transform.position.z;

		}

        void OnDisable()
        {
            if (!_start)
                return;
            if (oscIn != null)
                oscIn.Unmap( OnOSCMessage );
        }




        //We do the actual interpolation in FixedUpdate(), since we're dealing with a rigidbody
        void Update()
        {

            if (OSCpollingEnable)
            {
                if (1000 * (Time.unscaledTime - _lastPollTime) > OSCpollIntervalMs)
                {
                    _lastPollTime = Time.unscaledTime;
                    processData();
                }
            }


            //base.FixedUpdate ();
            if(_isLerping)
            {
                //We want percentage = 0.0 when Time.time = _timeStartedLerping
                //and percentage = 1.0 when Time.time = _timeStartedLerping + timeTakenDuringLerp
                //In other words, we want to know what percentage of "timeTakenDuringLerp" the value
                //"Time.time - _timeStartedLerping" is.
                float timeSinceStarted = Time.time - _timeStartedLerping;
                float percentageComplete = timeSinceStarted / positionSmoothingTime;

                //Perform the actual lerping.  Notice that the first two parameters will always be the same
                //throughout a single lerp-processs (ie. they won't change until we hit the space-bar again
                //to start another lerp)
                transformToMove.localPosition = Vector3.Lerp (_startPosition, _endPosition, percentageComplete);

                //When we've completed the lerp, we set _isLerping to false
                if(percentageComplete >= 1.0f)
                {
                    _isLerping = false;
                }
            }
        }


        // expects three data:  x y z
        void OnOSCMessage( OscMessage message )
        {
            float x = 0;
            float y = 0;
            float z = 0;

            if (message.args.Count != 3)
            {
                Debug.LogError(transform.name + " : " + GetType() + " : " + "oscRx(): takes three valus: "+OSCaddress+" X Y Z");
                return;
            }
                
            if (message.args[0] is float)
                x = (float)message.args[0];
            
            if (message.args[1] is float)
                y = (float)message.args[1];
            
            if (message.args[2] is float)
                z = (float)message.args[2];

            // store current value
             _oscCurValue.Set(x, y, z);

            if ( ! OSCpollingEnable )
                processData();
        }


        public void processData()
		{
            float data0, data1, data2;

            if (_oscCurValue == _oscLastValue)
                return;

            data0 = _oscCurValue.x;
            data1 = _oscCurValue.y;
            data2 = _oscCurValue.z;
            _oscLastValue = _oscCurValue;

			if(transformToMove == null) return;
			//OscMessage msg = (OscMessage)args.Packet;

            float x = transformToMove.transform.localPosition.x;
            float y = transformToMove.transform.localPosition.y;
            float z = transformToMove.transform.localPosition.z;

//            // handle for y no matter what
//            if (msg.Data.Count == 1)  // going to need to compute Y
//            {
//                if (Yenable)
//                {
//                    y = (Ymapping == PosMapping.direct) ? yscale * data0 : _ypos + yscale * data0;
//                }
//            }
//            else if (msg.Data.Count == 2)  // going to need to compute for XY
//            {
//                if (Xenable)
//                {
//                    x = (Xmapping == PosMapping.direct) ? xscale * data0 : _xpos + xscale * data0;
//                }
//                if (Zenable)
//                {
//                    z = (Ymapping == PosMapping.direct) ? zscale * data1 : _zpos + zscale * data1;
//                }
//
//            }
//            else if (msg.Data.Count == 3)  // going to need to compute  XYZ
//            {
                if (Xenable)
                {
                    x = (Xmapping == PosMapping.direct) ? xscale * data0 : _xpos + xscale * data0;
                }
                if (Yenable)
                {
                    y = (Ymapping == PosMapping.direct) ? yscale * data1 : _ypos + yscale * data1;
                }
                if (Zenable)
                {
                    z = (Ymapping == PosMapping.direct) ? zscale * data2 : _zpos + zscale * data2;
                }
//            }
//            else
//            {
//                Debug.LogError("qk_OscMoveGameObject.OSCrx: expects 1, two, or three values");
//                return;
//            }


            targetPos = new Vector3 (x,y,z); 
            _isLerping = true;
            _timeStartedLerping = Time.time;

            //We set the start position to the current position, and the finish to 10 spaces in the 'forward' direction
            _startPosition = transformToMove.localPosition;
            _endPosition = targetPos;
		}
    }
}