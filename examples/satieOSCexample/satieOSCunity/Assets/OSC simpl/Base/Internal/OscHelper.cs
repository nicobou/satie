/*
	Created by Carl Emil Carlsen.
	Copyright 2016 Sixth Sensor.
	All rights reserved.
	http://sixthsensor.dk
*/

using UnityEngine;
using System;
using System.Collections;
using System.Reflection;

namespace OscSimpl
{
	public static class OscHelper
	{
		public const string unicastAddressDefault = "192.168.1.1";

		public const string multicastAddressDefault = "224.1.1.1";

		// By Andrew Cheong http://stackoverflow.com/questions/13145397/regex-for-multicast-ip-address
		public const string multicastAddressPattern = "2(?:2[4-9]|3\\d)(?:\\.(?:25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]\\d?|0)){3}";

		public const int timeToLiveMax = 255;

		// https://msdn.microsoft.com/en-us/library/tst0kwb1(v=vs.110).aspx
		public const int portMin = 1;
		public const int portMax = 65535;

		// http://stackoverflow.com/questions/1098897/what-is-the-largest-safe-udp-packet-size-on-the-internet
		//public const int bufferSizeOnInternet = 512;

		// https://msdn.microsoft.com/en-us/library/system.net.sockets.socket.receivebuffersize(v=vs.110).aspx
		// https://github.com/Unity-Technologies/mono/blob/unity-staging/mcs/class/System/System.Net.Sockets/UdpClient.cs
		//public const int bufferSizeDefault = 8192;

		// http://stackoverflow.com/questions/1098897/what-is-the-largest-safe-udp-packet-size-on-the-internet
		//public const int bufferSizeOnWindows = 65507;

		/// <summary>
		/// Starts a coroutine in Edit Mode. Call UpdateCoroutineInEditMode subsequently on every update.
		/// </summary>
		/// <returns>The coroutine in edit mode.</returns>
		/// <param name="coroutine">Coroutine Method.</param>
		/// <param name="lastPingTime">DateTime object used to time coroutine updates.</param>
		public static IEnumerator StartCoroutineInEditMode( IEnumerator enumerator, ref DateTime lastPingTime )
		{
			lastPingTime = DateTime.Now;
			return enumerator;
		}

		/// <summary>
		/// Updates a coroutine in Edit Mode. The method currently only supports WaitForSeconds yield instructions.
		/// </summary>
		/// <param name="coroutine">IEnumerator object from a Coroutine.</param>
		/// <param name="lastPingTime">DateTime object used to time coroutine updates.</param>
		public static void UpdateCoroutineInEditMode( IEnumerator coroutine, ref DateTime lastPingTime )
		{
			float waitDuration = 0;
			if( coroutine.Current is WaitForSeconds ){
				FieldInfo secondsField = typeof( WaitForSeconds ).GetField( "m_Seconds", BindingFlags.NonPublic | BindingFlags.Instance );
				if( secondsField == null ){
					Debug.LogWarning( "UpdateCoroutineInEditMode failed. Needs update for newer UnityEngine." + Environment.NewLine );
					return;
				}
				waitDuration = (float) secondsField.GetValue( coroutine.Current as WaitForSeconds );
			}
			float secondsElapsed = (float) ( DateTime.Now - lastPingTime ).TotalSeconds;
			if( secondsElapsed > waitDuration ){
				coroutine.MoveNext();
				lastPingTime = DateTime.Now;
			}
		}
	}
}