/*
	Created by Carl Emil Carlsen.
	Copyright 2016 Sixth Sensor.
	All rights reserved.
	http://sixthsensor.dk
*/

using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

namespace OscSimpl
{
	[Serializable]
    public abstract class OscPacket
    {
		public abstract bool ToBytes( out byte[] data );


		public static bool FromBytes( byte[] data, out OscPacket packet )
        {
            int start = 0;
			if( !FromBytes( data, ref start, data.Length, out packet ) ) return false;
			return true;
        }


		public static bool FromBytes( byte[] data, ref int pos, int end, out OscPacket packet )
        {
			if( data[pos] == '#' ){
				if( !OscBundle.FromBytes( data, ref pos, end, out packet ) ) return false;
            } else {
				//
				//while( pos < data.Length && data[pos] == 0 ) pos++;

				if( !OscMessage.FromBytes( data, ref pos, out packet ) ) return false;
            }
			return true;
        }
    }
}