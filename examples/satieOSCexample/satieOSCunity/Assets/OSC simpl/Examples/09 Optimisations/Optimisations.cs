/*
	Created by Carl Emil Carlsen.
	Copyright 2016 Sixth Sensor.
	All rights reserved.
	http://sixthsensor.dk
*/

using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using System.Collections.Generic;

namespace OscSimpl.Examples
{
	public class Optimisations : MonoBehaviour
	{
		public GameObject uiWrapper;
		public Text sendFloatLabel;
		public Text sendBlobLabel;
		public Text receiveFloatLabel;
		public Text receiveBlobLabel;

		OscOut oscOut;
		OscIn oscIn;

		const string floatAddress = "/test/float";
		const string blobAddress = "/test/blob";

		OscMessage floatMessage;
		OscMessage blobMessage;
		OscBundle bundle;


		void Start()
		{
			// This should be familiar to you by now.
			oscOut = gameObject.AddComponent<OscOut>();
			oscIn = gameObject.AddComponent<OscIn>(); 
			oscOut.Open( 7000 );
			oscIn.Open( 7000 );
			oscIn.MapFloat( floatAddress, OnCachedReceived );
			oscIn.MapBlob( blobAddress, OnBlobReceived );

			bundle = new OscBundle();

			// OPTIMISATION #2: Cache outgoing messages.
			// If you are sending the same number of arguments to the same
			// address every update then you can cache a message to avoid 
			// calling the constructor continuously.
			floatMessage = new OscMessage( floatAddress, 0f );
			blobMessage = new OscMessage( blobAddress, new byte[0] );

			// Show UI
			uiWrapper.SetActive( true );
		}


		void Update()
		{
			// OPTIMISATION #2: Cache outgoing messages.
			// Use the cached message for sending.
			floatMessage.args[0] = Random.value;

			// OPTIMISATION #3: Use blobs for large arrays.
			// If you are sending large arrays, the you can compress the message
			// sending them as blobs. By doing this you avoid sending a type tag for every
			// element in the array. See the methods IntArrayToBlob and BlobToIntArray.
			int[] intArray = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
			byte[] blob = IntArrayToBlob( intArray );
			blobMessage.args[0] = blob;

			// OPTIMISATION #1: Bundle your messages
			// Sending one bundle instead of seperate messages is more efficient.
			bundle.Add( floatMessage );
			bundle.Add( blobMessage );
			oscOut.Send( bundle );
			bundle.Clear();

			// Update labels.
			if( oscOut.isOpen ){
				sendFloatLabel.text = floatMessage.args[0].ToString();
				string intArrayString = "";
				foreach( int i in intArray ) intArrayString += i + " ";
				sendBlobLabel.text = intArrayString;
			}
		}


		void OnCachedReceived( float value )
		{
			// Update label.
			receiveFloatLabel.text = value.ToString();
		}


		void OnBlobReceived( byte[] blob )
		{
			// Update label.
			int[] intArray = BlobToIntArray( blob );
			string intArrayString = "";
			foreach( int i in intArray ) intArrayString += i + " ";
			receiveBlobLabel.text = intArrayString;
		}


		static byte[] IntArrayToBlob( int[] array )
		{
			List<byte> temp = new List<byte>( array.Length * 4 );
			for( int i=0; i<array.Length; i++ )
			{
				byte[] bytes = System.BitConverter.GetBytes( array[i] );

				// Don't forget to esure the same bit order on different systems.
				if( System.BitConverter.IsLittleEndian ) System.Array.Reverse( bytes );

				temp.AddRange( bytes );
			}
			return temp.ToArray();
		}


		static int[] BlobToIntArray( byte[] blob )
		{
			int count = blob.Length / 4;
			int[] array = new int[count];
			for( int i=0; i<count; i++ )
			{
				// Don't forget to esure the same bit order on different systems.
				int index = i*4;
				if( System.BitConverter.IsLittleEndian ) System.Array.Reverse( blob, index, 4 );

				array[i] = System.BitConverter.ToInt32( blob, index );
			}
			return array;
		}
	}
}