/*
	Created by Carl Emil Carlsen.
	Copyright 2016 Sixth Sensor.
	All rights reserved.
	http://sixthsensor.dk
*/

using UnityEngine;
using System.Collections;

namespace OscSimpl.Examples
{
	public class TestMessageGenerator : MonoBehaviour
	{
		public OscOut oscOut;


		void Update()
		{
			oscOut.Send( "/test", Random.value );
		}
	}
}