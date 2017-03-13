/*
	Created by Carl Emil Carlsen.
	Copyright 2016 Sixth Sensor.
	All rights reserved.
	http://sixthsensor.dk
*/

using UnityEngine;
using System.Collections;

namespace OscSimpl
{
	public enum OscMessageType
	{
		OscMessage,	// Full OSCMessage
		Float,		// Single floating point value
		Double,
		Int,
		Long,
		String,
		Char,
		Bool,
		Color,
		Blob,
		TimeTag,
		ImpulseNullEmpty,		// Message OscImpuse or Null as first argument, or no arguments
	}
}