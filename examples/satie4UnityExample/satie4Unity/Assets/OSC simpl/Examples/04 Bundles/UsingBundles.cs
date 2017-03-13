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
	public class UsingBundles : MonoBehaviour
	{
		public GameObject uiWrapper;
		public Text sendLabel1;
		public Text sendLabel2;
		public Text receiveLabel1;
		public Text receiveLabel2;

		OscOut oscOut;
		OscIn oscIn;

		const string address1 = "/test";
		const string address2 = "/test2";


		void Start()
		{
			// Create objects for sending and receiving
			oscOut = gameObject.AddComponent<OscOut>();
			oscIn = gameObject.AddComponent<OscIn>(); 

			// Prepare for sending messages to applications on this device on port 7000.
			oscOut.Open( 7000 );

			// Prepare for receiving messages on port 7000.
			oscIn.Open( 7000 );

			// Forward recived messages with addresses to methods.
			oscIn.Map( address1, OnMessage1Received );
			oscIn.Map( address2, OnMessage2Received );

			// Show UI.
			uiWrapper.SetActive( true );
		}


		void Update()
		{
			// Create a bundle, add two messages with seperate addresses and values, then send.
			OscBundle bundle = new OscBundle();
			OscMessage message1 = new OscMessage( address1, Random.value );
			OscMessage message2 = new OscMessage( address2, Random.value );
			bundle.Add( message1 );
			bundle.Add( message2 );
			oscOut.Send( bundle );

			// Update UI.
			sendLabel1.text = message1.ToString();
			sendLabel2.text = message2.ToString();
		}



		void OnMessage1Received( OscMessage message )
		{
			// Update UI.
			receiveLabel1.text = message.ToString();
		}


		void OnMessage2Received( OscMessage message )
		{
			// Update UI
			receiveLabel2.text = message.ToString();
		}
	}
}