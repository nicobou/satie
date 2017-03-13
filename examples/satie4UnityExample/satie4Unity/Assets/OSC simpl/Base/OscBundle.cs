/*
	Created by Carl Emil Carlsen.
	Copyright 2016 Sixth Sensor.
	All rights reserved.
	http://sixthsensor.dk
*/

using UnityEngine;
using System;
using System.Collections.Generic;
using System.Text;
using OscSimpl;

/// <summary>
/// Class representing an OSC bundle. Bundles have a OscTimeTag and can contain OscMessage
/// and OscBundle objects.
/// </summary>
public sealed class OscBundle : OscPacket
{
	
	const string prefix = "#bundle";
	const int prefixByteSize = 7;
	static byte[] prefixBytes = Encoding.ASCII.GetBytes( prefix );
	const int headerByteSize = 16; // prefix + timetag

	/// <summary>
	/// Gets or sets the timetag for this bundle.
	/// </summary>
    public OscTimeTag timeTag {
		get { return _timeTag; }
		set { _timeTag = value; }
	}
    OscTimeTag _timeTag;

	/// <summary>
	/// Gets the list of OscMessage and OscBundle objects.
	/// </summary>
	public List<OscPacket> packets { get { return _packets; } }
	List<OscPacket> _packets;

	/// <summary>
	/// Constructor for creating a bundle with a timetag containing the current time.
	/// </summary>
    public OscBundle() : this( new OscTimeTag() ){}

	/// <summary>
	/// Constructor for creating a bundle with specified timetag.
	/// </summary>
    public OscBundle( OscTimeTag timeTag )
    {
		_timeTag = timeTag;
		_packets = new List<OscPacket>();
    }

	/// <summary>
	/// Add a OscMessage or OscBundle to this bundle. Shorthand for bundle.packets.Add.
	/// </summary>
	public void Add( OscPacket packet )
	{
		_packets.Add( packet );
	}

	/// <summary>
	/// Remove all OscMessage and OscBundle object in this bundle, and
	/// do so recursively for all contained bundles.
	/// </summary>
	public void Clear()
	{
		foreach( OscPacket packet in _packets ){
			if( packet is OscBundle ) (packet as OscBundle).Clear();
		}
		_packets.Clear();
	}


	public override bool ToBytes( out byte[] data )
	{
		data = null;
		List<byte> bytes = new List<byte>( headerByteSize );

		// Add prefix
		bytes.AddRange( prefixBytes );

		// Ensure bytes multiple of 4
		bytes.Add( 0 );

		// Add timetag
		bytes.AddRange( _timeTag.ToByteArray() );

		// Add packets
		foreach( OscPacket packet in _packets )
		{
			if( packet == null ) continue;

			// Silently ensure that nested bundle's timetag is >= than parent bundle's timetag.
			if( packet is OscBundle && ( packet as OscBundle ).timeTag < _timeTag ){
				( packet as OscBundle ).timeTag.time = _timeTag.time;
			}

			// Convert packet to bytes
			byte[] packetBytes;
			if( !packet.ToBytes( out packetBytes ) ) return false;

			// Add length of packet
			byte[] lengthBytes = BitConverter.GetBytes( packetBytes.Length );
			if( BitConverter.IsLittleEndian ) Array.Reverse( lengthBytes ); // Big-endian byte order required by OSC 1.0
			bytes.AddRange( lengthBytes );

			// Add packet
            bytes.AddRange( packetBytes );
        }

		data = bytes.ToArray();
		return true;
    }


	public static new bool FromBytes( byte[] data, ref int pos, int end, out OscPacket packet )
    {
		// Check header size
		int bundleByteSize = end - pos;
		if( bundleByteSize < headerByteSize ){
			Debug.LogWarning( "[OSC io] OscBundle with invalid header was ignored." + Environment.NewLine );
			packet = null;
			return false;
		}

		// Check prefix
		string prefixInput = Encoding.ASCII.GetString( data, pos, prefixByteSize );
		if( prefixInput != prefix ){
			Debug.LogWarning( "[OSC io] OscBundle with invalid header was ignored." + Environment.NewLine );
			packet = null;
			return false;
		}
		pos += prefixByteSize + 1; // + 1 to ensure bytes multiple of 4

		// Get timetag
		byte[] oscNtpBytes = new byte[OscTimeTag.byteSize];
		Array.Copy( data, pos, oscNtpBytes, 0, OscTimeTag.byteSize );
		OscTimeTag timeTag = new OscTimeTag( oscNtpBytes );
		pos += OscTimeTag.byteSize;
        
		// Create and fill bundle
		packet = new OscBundle( timeTag );
		OscBundle bundle = packet as OscBundle;
		while( pos < end )
        {
			int length = BitConverter.ToInt32( data, 0 );
			pos += 4;
			int packetEnd = pos + length;
			OscPacket subPacket;
			if( pos < end && OscPacket.FromBytes( data, ref pos, packetEnd, out subPacket ) ) bundle.Add( subPacket );
        }

        return true;
    }
}