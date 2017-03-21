using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
//using Oz.Game;



/// <summary>
///  this object has not yet been thoroughly tested out
/// </summary>


namespace OscSimpl.Examples
{

    public class zkOSCsimplMoveCam :  MonoBehaviour
    {

		public string OSCaddress = "";		// when empty, automatically creates an OSC address using the object's name, making:  "/objName/position"

        [Tooltip("make sure  object transforms with OscIn components also have zk_transformTag components that have the same tagName")]

		public string tagName="default";

		public OscIn oscIn;


		private Transform transformToMove;

        //movementModeProp = serializedObject.FindProperty ("movementMode");

        private Vector3 targetPos = new Vector3();
//		private Vector3 startPos = new Vector3(); // Never used warning


        public bool Xenable = true;
        public float xscale = 1;

        public bool Yenable = true;
        public float yscale = 1;

        public bool Zenable = true;
        public float zscale = 1;



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
                //Debug.LogWarning(transform.name + " : " + GetType() + " : " + "Start(): generating the following path: "+OSCaddress);
                OSCaddress = "/" + transform.name + "/position";
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


		void OnEnable()
		{
			if (!_start )
				return;

			// Debug.Log(transform.name + " : " + GetType() + " : " + "OnEnable()");


			if (oscIn != null)
				oscIn.Map( OSCaddress, OnOSCMessage );
			
            if (transformToMove == null)
            {
                Transform hostTransform = GetComponent<Transform>();
                if (hostTransform != null)
                    transformToMove = hostTransform;
            }
            //Debug.Log("ONENABLE  OBJ NAME: " + transformToMove.name);
//			_positionSmoothingTime = positionSmoothingTime; // Never used warning
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

            if (_isLerping)
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
                transformToMove.localPosition = Vector3.Lerp(_startPosition, _endPosition, percentageComplete);

                //When we've completed the lerp, we set _isLerping to false
                if (percentageComplete >= 1.0f)
                {
                    _isLerping = false;
                }
            }
        }


        // expects messages with either one, two, or three data, as below:
        // y
        // x z
        // x y z
        void OnOSCMessage( OscMessage message )
        {
            float x = 0;
            float y = 0;
            float z = 0;
            int count = message.args.Count;

            if (count < 1 || count > 3 )
            {
                Debug.LogError(transform.name + " : " + GetType() + " OnOSCMessage() : for: " +OSCaddress+" : takes one, two or three valus,  ignoring");
                return;
            }

            if (count == 1)     // Y
            {
                if (message.args[0] is float)
                    y = (float)message.args[0];
                _oscCurValue.y = y;
                
            }
            else if (count == 2)  // X and Z
            {
                if (message.args[0] is float)
                    x = (float)message.args[0];

                if (message.args[1] is float)
                    z = (float)message.args[1];
                _oscCurValue.x = x;
                _oscCurValue.z = z;
            }
            else
            {
                if (message.args[0] is float)
                    x = (float)message.args[0];

                if (message.args[1] is float)
                    y = (float)message.args[1];

                if (message.args[2] is float)
                    z = (float)message.args[2];
                              
                _oscCurValue.Set(x, y, z);
            }

            if ( ! OSCpollingEnable )
                processData();
        }


        void processData( )
        {

            float x, y, z;

            if (transformToMove == null)
                return;

            if (_oscCurValue == _oscLastValue)
                return;

            x = (Xenable) ? xscale * _oscCurValue.x : transformToMove.transform.localPosition.x;
            y = (Yenable) ? yscale * _oscCurValue.y : transformToMove.transform.localPosition.y;
            z = (Zenable) ? zscale * _oscCurValue.z : transformToMove.transform.localPosition.z;

            _oscLastValue = _oscCurValue;

            targetPos = new Vector3(x, y, z); 
            _isLerping = true;
            _timeStartedLerping = Time.time;

            //We set the start position to the current position, and the finish to 10 spaces in the 'forward' direction
            _startPosition = transformToMove.localPosition;
            _endPosition = targetPos;
        }
    }
}