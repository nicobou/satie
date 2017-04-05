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
	public class UsingUnicast : MonoBehaviour
	{
		public GameObject uiWrapper;
		public Text sendLabel;
		public Text receiveLabel;

		OscOut oscOut;
		OscIn oscIn;

		const string address = "/test";


		void Start()
		{
			// Create objects for sending and receiving.
			oscOut = gameObject.AddComponent<OscOut>();
			oscIn = gameObject.AddComponent<OscIn>(); 

			// Prepare for unicasting messages to this (same) device to be received by applications listening on port 7000.
			oscOut.Open( 7000 );

			// Alternatively, prepare for unicasting messages to device with IP address to be received by applications listening on port 7000.
			//oscOut.Open( 7000, "192.168.1.101" );

			// Prepare for receiving unicasted and broadcasted messages from this and other devices on port 7000
			oscIn.Open( 7000 );

			// Forward recived messages with address to method.
			oscIn.Map( address, OnMessageReceived );

			// Show UI.
			uiWrapper.SetActive( true );
		}


		void Update()
		{
			// Send a random value.
			float value = Random.value;
			oscOut.Send( address, value );

			// Update label.
			if( oscOut.isOpen ) sendLabel.text = value.ToString();
		}


		void OnMessageReceived( OscMessage message )
		{
			// Get the value.
			float value;
			if( !message.TryGet( 0, out value ) ) return;

			// Update label.
			receiveLabel.text = value.ToString();
		}
	}
}