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
	public class GettingStartedSending : MonoBehaviour
	{
		public OscOut oscOut;


		void Start()
		{
			// Ensure that we have a OscOut component.
			if( !oscOut ) oscOut = gameObject.AddComponent<OscOut>();

			// Prepare for sending messages to applications on this device on port 7000.
			oscOut.Open( 7000 );

			// Or, to a target IP Address (Unicast).
			//oscOut.Open( 7000, "192.168.1.101" );

			// Or to all devices on the local network (Broadcast).
			//oscOut.Open( 7000, "255.255.255.255" );

			// Or to a multicast group (Multicast).
			//oscOut.Open( 7000, "224.1.1.101" );
		}


		void Update()
		{
			// Send a message with one float argument.
			oscOut.Send( "/test1", Random.value );

			// Send a message with a number of assorted argument types.
			oscOut.Send( "/test2", Random.value, "Text", false );

			// Create a message and send it.
			OscMessage message = new OscMessage( "/test3" );
			message.Add( "Allo" );
			message.Add( "World" );
			message.args[0] = "Hello"; // Let's say we want overwrite the first argument
			oscOut.Send( message );
		}
	}
}