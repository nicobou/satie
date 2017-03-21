

/*
* UniOSC
* Copyright © 2014 Stefan Schlupek
* All rights reserved
* info@monoflow.org
*/
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
//using OSCsharp.Data;
	

/// </summary>
/// hopefully this class no longer exists and can be ignore
/// </summary>



public class zkOSCsimpl6dof :  MonoBehaviour
    {
    }
/*		public GameObject fish;
		public GameObject birds;


		public bool fishSwarming = false;
		public bool birdSwarming = false;
		public float updateDelta = 2f;   // two meter swarming update resolution

		public string oscAddressPos;
		public string oscAddressRot;
		public string oscAddressQuat;

		private Vector3 targetPos = new Vector3();
//		private Vector3 startPos = new Vector3(); // Never used warning



		public float positionSmoothingTime = 1f;
		//public float smoothRotMs = 30f;
		//public float smoothQuatMs = 30f;
		

		//Whether we are currently interpolating or not
		private bool _isLerping;
		
		//The start and finish positions for the interpolation
		private Vector3 _startPosition;
		private Vector3 _endPosition;
		
		//The Time.time value when we started the interpolation
		private float _timeStartedLerping;

		private Vector3 _lastBirdPos = new Vector3();
		private Vector3 _lastFishPos = new Vector3();

		/// <summary>
		/// Called to begin the linear interpolation
		/// </summary>



		void Awake ()
		{
            oscAddressPos = "/aqk/" + transform.name + "/pos"; 
            oscAddressRot = "/aqk/" + transform.name + "/rot"; 
            oscAddressQuat = "/aqk/" + transform.name + "/quat"; 
		}


			
		/// <summary>
		/// Start this instance.
		/// </summary>
		void Start ()
		{
			//Don't forget this!!!!
			//base.Start ();
			//here your custom code
			targetPos = transform.position;
		}
			
		/// <summary>
		/// Raises the enable event.
		/// If you want to listen to several OSC messages you have to  set the OSCAddresses property before you call base.OnEnable()
		/// OSCAddresses.Clear();
		/// OSCAddresses.Add(...);
		/// </summary>
		void OnEnable ()
		{
			//optional 
			//receiveAllAddresses = true;
			_Init ();
			//Don't forget this!!!!
			//base.OnEnable ();
			//here your custom code
		}
			
		/// <summary>
		/// this is a custom init function. Called from OnEnable
		/// </summary>
		private void _Init ()
		{

//			receiveAllAddresses = false;
//			
//			_oscAddresses.Clear ();
//			// add the message strings to our address list
//			_oscAddresses.Add (oscAddressPos);
//			_oscAddresses.Add (oscAddressRot);
//			_oscAddresses.Add (oscAddressQuat);
		}
			
			
			
		/// <summary>
		/// Raises the disable event.
		/// </summary>
		void OnDisable ()
		{
			//Don't forget this!!!!
			//base.OnDisable ();
			//here your custom code
		}
			
		void Update ()
		{
			//Don't forget this!!!!
			//base.Update ();
			
			
			if (birdSwarming)
			{
				if (birds != null)
				{
                    if ( Mathf.Abs(Vector3.Distance(transform.position, _lastBirdPos)) > updateDelta) 
					{
                        _lastBirdPos = transform.position;
                        birds.SendMessage("SetWaypointPosition", transform.position, SendMessageOptions.DontRequireReceiver); 
					}
				}
			}
			if (fishSwarming)
			{
				if (fish != null)
				{
                    if ( Mathf.Abs(Vector3.Distance(transform.position, _lastFishPos)) > updateDelta) 
					{
                        _lastFishPos = transform.position;
                        fish.SendMessage("SetWaypointPosition", transform.position, SendMessageOptions.DontRequireReceiver); 
					}
				}
			}
			//here your custom code

		}
			
		//We do the actual interpolation in FixedUpdate(), since we're dealing with a rigidbody
		void FixedUpdate()
		{
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
                transform.position = Vector3.Lerp (_startPosition, _endPosition, percentageComplete);
				
				//When we've completed the lerp, we set _isLerping to false
				if(percentageComplete >= 1.0f)
				{
					_isLerping = false;
				}
			}
		}

		/// <summary>
		/// Method is called from a OSCConnection when a OSC message arrives. 
		/// The argument is a UniOSCEventArgs object where all the related data is enclosed
		/// </summary>
		/// <param name="args">OSCEventArgs</param>
        void OnOSCMessageReceived(OscMessage msg)
		{
//			Vector3 pos; // Never used warning
//			Vector3 rot; // Never used warning
//			Vector4 quat; // Never used warning

//            Debug.Log("OSCRX");
//			OscMessage msg = (OscMessage)args.Packet;
//			if(msg.Data.Count <1)return;
//
//

				
		}	
			
	}
		
}
*/