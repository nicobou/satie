using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;

//using OSCsharp.Data;

namespace OscSimpl.Examples
{

    /// <summary>
    /// Moves a GameObject in normalized coordinates (ScreenToWorldPoint)
    /// </summary>
    // [AddComponentMenu("UniOSC/MoveGameObject")]

    public class zkOSCsimplRotateGameObj :  MonoBehaviour
    {
        public enum quatOrder { XYZW, YXZW }

        public string OSCaddress;

        [Tooltip("make sure that the OscIn objects in the environment have a corresponding tag")]

        public string tagName = "";

        public OscIn oscIn;


        private Transform transformToMove;

        //movementModeProp = serializedObject.FindProperty ("movementMode");

        public bool constrainX = false;

        public bool constrainY = false;

        public bool constrainZ = false;

        public Vector3 constaintsXYZ = new Vector3();



        //public float smoothRotMs = 30f;
        //public float smoothQuatMs = 30f;


        //Whether we are currently interpolating or not
        private bool _isLerping;

        //The start and finish positions for the interpolation
        private Quaternion _startRotation;
        private Quaternion _endRotation;

        //The Time.time value when we started the interpolation
        private float _timeStartedLerping;

        private bool _start = false;

        [Header("")]


        public float rotationSmoothingTime = 0.25f;

        [Header("OSCrx Polling Option")]

        // OSC POLLING CONTROL
        private Vector4 _oscCurValue;
        private Vector4 _oscLastValue;
        public bool OSCpollingEnable = true;
        public float OSCpollIntervalMs = 30f;
        // polling interval ms for current OSC values
        private float _lastPollTime;


        [Header("")]
        [Tooltip("use YXZW for use with Gyrosc")]
               public quatOrder quatAxisOrder = quatOrder.XYZW;


        private void OnValidate()
        {
            if (!_start)
                return;
            if (rotationSmoothingTime <= 0)
                rotationSmoothingTime = 0.0001f;
            if (OSCpollIntervalMs < 0)
                OSCpollIntervalMs = 0f;
        }


        void Start()
        {

            _oscCurValue = new Vector4(0, 0, 0, 0);
            _oscLastValue = new Vector4(0, 0, 0, 0);

            if (OSCaddress.Length == 0)
            {
                OSCaddress = "/" + transform.name + "/rotation";  // automatically create an OSC address using the object's name, making:  "/objName/position"
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

            _start = true;
            OnEnable();   // this can not be called until START has set up the state        }
        }


        void OnEnable()
        {

            if (!_start)
                return;

            Debug.Log(transform.name + " : " + GetType() + " : " + "OnEnable()");

            if (oscIn != null)
                oscIn.Map(OSCaddress, OnOSCMessage);


            if (transformToMove == null)
            {
                Transform hostTransform = GetComponent<Transform>();
                if (hostTransform != null)
                    transformToMove = hostTransform;
            }
            //Debug.Log("ONENABLE  OBJ NAME: " + transformToMove.name);
            _startRotation = _endRotation = transformToMove.localRotation;

        }

        void OnDisable()
        {
            if (!_start)
                return;
            if (oscIn != null)
                oscIn.Unmap(OnOSCMessage);
        }


        // changed from fixedUpdate which was too jerky
        void Update()
        {
             
            if (OSCpollingEnable)
            {
                if (1000 * (Time.unscaledTime - _lastPollTime) > OSCpollIntervalMs)
                {
                    _lastPollTime = Time.unscaledTime;
                    processQuat();
                }
            }

            if (_isLerping)
            {
                //We want percentage = 0.0 when Time.time = _timeStartedLerping
                //and percentage = 1.0 when Time.time = _timeStartedLerping + timeTakenDuringLerp
                //In other words, we want to know what percentage of "timeTakenDuringLerp" the value
                //"Time.time - _timeStartedLerping" is.
                float timeSinceStarted = Time.time - _timeStartedLerping;
                float percentageComplete = timeSinceStarted / rotationSmoothingTime;

                //Perform the actual lerping.  Notice that the first two parameters will always be the same
                //throughout a single lerp-processs (ie. they won't change until we hit the space-bar again
                //to start another lerp)
                transformToMove.localRotation = Quaternion.Slerp(_startRotation, _endRotation, percentageComplete);

                //When we've completed the lerp, we set _isLerping to false
                if (percentageComplete >= 1.0f)
                {
                    _isLerping = false;
                }
            }
        }

        void OnOSCMessage(OscMessage message)
        {
            float x = 0;
            float y = 0;
            float z = 0;
            float w = 0;

            if (message.args.Count < 3)
            {
                Debug.LogError(transform.name + " : " + GetType() + " : " + "oscRx(): takes three or four valus: " + OSCaddress + " X Y Z (W)");
                return;
            }

            if (message.args[0] is float)
                x = (float)message.args[0];

            if (message.args[1] is float)
                y = (float)message.args[1];

            if (message.args[2] is float)
                z = (float)message.args[2];

            if (message.args.Count == 3)
            {
                Quaternion q = Quaternion.Euler(x, y, z);
                _oscCurValue.Set(q.x, q.y, q.z, q.w);

            }
            else    // its a quat
            {

                if (message.args[3] is float)
                    w = (float)message.args[3];

                // store current value

                switch (quatAxisOrder)
                {
                    case quatOrder.YXZW:
                        _oscCurValue.Set(y, x, z, w);
                        break;
                    case quatOrder.XYZW:
                    default:    
                        _oscCurValue.Set(x, y, z, w);
                        break;   
                }
            }

            if (!OSCpollingEnable)
                processQuat();

            // Get string arguments at index 0 and 1 safely.
            //string text0, text1;
            //            if( message.TryGet( 0, out text0 ) && message.TryGet( 1, out text1 ) ){
            //                Debug.Log( "Received: " + text0 + " " + text1 );
            //            }

            // If you wish to mess with the arguments yourself, you can.
            //            foreach( object a in message.args ) 
            //
            //                if( a is float ) Debug.Log( "Received: " + a );

            // NEVER DO THIS AT HOME
            // Never cast directly, without ensuring that index is inside bounds and encapsulating
            // the cast in try-catch statement.
            //float value = (float) message.args[0]; // No no!
        }


        void processQuat()
        {
            float data0, data1, data2, data3;

            if (_oscCurValue == _oscLastValue)
                return;

            data0 = _oscCurValue.x;
            data1 = _oscCurValue.y;
            data2 = _oscCurValue.z;
            data3 = _oscCurValue.w;
            _oscLastValue = _oscCurValue;

            if (transformToMove == null)
                return;


            float x, y, z, w;
            Quaternion targetRot;

            x = data0;
            y = data1;
            z = data2;
            w = data3;

            targetRot = new Quaternion(x, y, z, w); 

            // if true, oh shit, we'll have to constrain rotation and accept the consequences
            if (constrainX || constrainY || constrainZ)
            {
                float pitch, yaw, roll;
                Vector3 eulers = targetRot.eulerAngles;

                pitch = (constrainX) ? constaintsXYZ.x : eulers.x;
                yaw = (constrainY) ? constaintsXYZ.y : eulers.y;
                roll = (constrainZ) ? constaintsXYZ.z : eulers.z;

                targetRot = Quaternion.Euler(pitch, yaw, roll); 

            }
            _isLerping = true;
            _timeStartedLerping = Time.time;

            //We set the start position to the current position, and the finish to 10 spaces in the 'forward' direction
            _startRotation = transformToMove.localRotation;
            _endRotation = targetRot;
        }
    }
}