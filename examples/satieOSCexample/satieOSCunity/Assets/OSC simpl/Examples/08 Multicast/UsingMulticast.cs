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
	public class UsingMulticast : MonoBehaviour
	{
		public GameObject uiWrapper;
		public Text sendLabel;
		public Text receiveLabel;

		OscOut oscOut;
		OscIn oscIn;

		const string oscAddress = "/test";
		const string multicastAddress = "224.0.1.0";


		void Start()
		{
			// Create objects for sending and receiving.
			oscOut = gameObject.AddComponent<OscOut>();
			oscIn = gameObject.AddComponent<OscIn>(); 

			// Prepare for multicasting messages to devices with applications that have joined the 
			// multicast group with address 224.0.1.0 and are listening on port 7000.
			oscOut.Open( 7000, multicastAddress );

			// NOTE: Technically, multicasting addresses must be between 224.0.0.0 to 239.255.255.255, 
			// but addresses 224.0.0.0 to 224.0.0.255 are reserved for routing info so you should really 
			// only use 224.0.1.0 to 239.255.255.255.

			// Prepare for receiving messages that are send to multicast group with address 224.0.1.0
			// on port 7000. We will also be receiving unicasted and broadcasted messages.
			oscIn.Open( 7000, multicastAddress );

			// If you only want messages from the multicast group that have been send from other
			// applications, then set the multicastLoopback property on OscOut to false.
			//oscOut.multicastLoopback = false;

			// Forward recived messages with address to method.
			oscIn.Map( oscAddress, OnMessageReceived );

			// Show UI
			uiWrapper.SetActive( true );
		}


		void Update()
		{
			// Send a random value.
			float value = Random.value;
			oscOut.Send( oscAddress, value );

			// Update label.
			if( oscOut.isOpen ) sendLabel.text = value.ToString();
		}


		void OnMessageReceived( OscMessage message )
		{
			// Get the value.
			float value;
			if( message.TryGet( 0, out value ) ) return;

			// Update label.
			receiveLabel.text = value.ToString();
		}
	}
}