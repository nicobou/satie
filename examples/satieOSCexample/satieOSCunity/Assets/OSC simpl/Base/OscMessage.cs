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
/// Class representing an OSC message. Messages have an OSC address an a number of OSC arguments.<br>
/// <br>
/// Supported argument types and their Unity translations:
/// <ul>
/// <li>float (f) <-> float</li>
/// <li>integer (i) <-> int</li>
/// <li>string (s), symbol (S) <-> string</li>
/// <li>blob (b) <-> byte[]</li>
/// <li>long (h) <-> long</li>
/// <li>double (d) <-> double</li>
/// <li>boolean (T,F) <-> bool</li>
/// <li>character (c) <-> char</li>
/// <li>color (r) <-> Color32, Color</li>
/// <li>timetag (t) <-> OscTimeTag, DateTime</li>
/// <li>impulse (I) <-> OscImpulse</li>
/// <li>nil (N)<-> null</li>
/// </ul>
/// </summary>
[Serializable]
public class OscMessage : OscPacket
{
    const char addressPrefix = '/';
    const char tagPrefix = ',';
    const char tagFloat = 'f';
	const char tagDouble = 'd';
	const char tagInt = 'i';
    const char tagLong = 'h';
    const char tagString = 's';
    const char tagSymbol = 'S';
	const char tagChar = 'c';
	const char tagTrue = 'T';
	const char tagFalse = 'F';
	const char tagColor = 'r';
    const char tagBlob = 'b';
    const char tagTimetag = 't';
    const char tagNull = 'N';
	const char tagImpulse = 'I'; // As in OSC 1.1. In OSC 1.0 it was 'Infinitum'. For trigger events (Bang). No bytes are allocated.

	/// <summary>
	/// Gets or sets the address of the message. Must start with '/'.
	/// </summary>
	public string address {
		get { return _address; }
		set {
			if( string.IsNullOrEmpty( value ) ) value = "/";
			else if( value[0] != addressPrefix ) value = "/" + value;
			_address = value;
		}
	}
	string _address;

	/// <summary>
	/// Gets or sets the OSC arguments. Manipulate the list directly.
	/// </summary>
	public List<object> args {
		get { return _args; }
		set { _args = value; }
	}
	List<object> _args;


	public OscMessage( string address ) : this( address, 1 ){}

	/// <summary>
	/// Constructor taking an address and an arbitrary number of OSC type arguments.
	/// </summary>
	public OscMessage( string address, params object[] args ) : this( address, args == null ? 1 : args.Length ){
		if( args == null ) _args.Add( null );
		else _args.AddRange( args );
	}


	OscMessage( string address, int capacity = 1 )
    {
		this.address = address;
		_args = new List<object>( capacity );
    }


	/// <summary>
	/// Add one or more OSC type arguments. Shorthand for message.args.Add.
	/// </summary>
	public void Add( params object[] args ){
		if( args == null ) _args.Add( null );
		else _args.AddRange( args );
	}


	/// <summary>
	/// Clear all arguments. Shorthand for message.args.Clear.
	/// </summary>
	public void Clear()
	{
		_args.Clear();
	}


	/// <summary>
	/// Tries to get argument at index of type float. Returns success status.
	/// </summary>
	public bool TryGet( int index, out float value )
	{
		if( index >= _args.Count || index < 0 ){
			value = 0;
			LogOscMessageArgBoundsWarning( index ); return false;
		}
		object a = _args[index];
		if( !( a is float ) ){
			value = 0;
			LogOscMessageArgTypeWarning( typeof( float ), index ); return false;
		}
		value = (float) a;
		return true;
	}

	/// <summary>
	/// Same as above, double type.
	/// </summary>
	public bool TryGet( int index, out double value )
	{
		if( index >= _args.Count || index < 0 ){
			value = 0d;
			LogOscMessageArgBoundsWarning( index ); return false;
		}
		object a = _args[index];
		if( !( a is double ) ){
			value = 0d;
			LogOscMessageArgTypeWarning( typeof( double ), index ); return false;
		}
		value = (double) a;
		return true;
	}

	/// <summary>
	/// Same as above, int type.
	/// </summary>
	public bool TryGet( int index, out int value )
	{
		if( index >= _args.Count || index < 0 ){
			value = 0;
			LogOscMessageArgBoundsWarning( index ); return false;
		}
		object a = _args[index];
		if( !( a is int ) ){
			value = 0;
			LogOscMessageArgTypeWarning( typeof( int ), index ); return false;
		}
		value = (int) a;
		return true;
	}

	/// <summary>
	/// Same as above, long type.
	/// </summary>
	public bool TryGet( int index, out long value )
	{
		if( index >= _args.Count || index < 0 ){
			value = 0L;
			LogOscMessageArgBoundsWarning( index ); return false;
		}
		object a = _args[index];
		if( !( a is long ) ){
			value = 0L;
			LogOscMessageArgTypeWarning( typeof( long ), index ); return false;
		}
		value = (long) a;
		return true;
	}

	/// <summary>
	/// Same as above, string type.
	/// </summary>
	public bool TryGet( int index, out string value )
	{
		if( index >= _args.Count || index < 0 ){
			value = "";
			LogOscMessageArgBoundsWarning( index ); return false;
		}
		object a = _args[index];
		if( !( a is string ) ){
			value = "";
			LogOscMessageArgTypeWarning( typeof( string ), index ); return false;
		}
		value = (string) a;
		return true;
	}
		
	/// <summary>
	/// Same as above, char type.
	/// </summary>
	public bool TryGet( int index, out char value )
	{
		if( index >= _args.Count || index < 0 ){
			value = ' ';
			LogOscMessageArgBoundsWarning( index ); return false;
		}
		object a = _args[index];
		if( !( a is char ) ){
			value = ' ';
			LogOscMessageArgTypeWarning( typeof( char ), index ); return false;
		}
		value = (char) a;
		return true;
	}

	/// <summary>
	/// Same as above, bool type.
	/// </summary>
	public bool TryGet( int index, out bool value )
	{
		if( index >= _args.Count || index < 0 ){
			value = false;
			LogOscMessageArgBoundsWarning( index ); return false; 
		}
		object a = _args[index];
		if( !( a is bool ) ){
			value = false;
			LogOscMessageArgTypeWarning( typeof( bool ), index ); return false;
		}
		value = (bool) a;
		return true;
	}

	/// <summary>
	/// Same as above, color type.
	/// </summary>
	public bool TryGet( int index, out Color32 value )
	{
		if( index >= _args.Count || index < 0 ){
			value = new Color32();
			LogOscMessageArgBoundsWarning( index ); return false;
		}
		object a = _args[index];
		if( !( a is Color32 ) ){
			value = new Color32();
			LogOscMessageArgTypeWarning( typeof( Color32 ), index ); return false;
		}
		value = (Color32) a;
		return true;
	}

	/// <summary>
	/// Same as above, blob type.
	/// </summary>
	public bool TryGet( int index, out byte[] value )
	{
		if( index >= _args.Count || index < 0 ){
			value = new byte[0];
			LogOscMessageArgBoundsWarning( index ); return false;
		}
		object a = _args[index];
		if( !( a is byte[] ) ){
			value = new byte[0];
			LogOscMessageArgTypeWarning( typeof( byte[] ), index ); return false;
		}
		value = (byte[]) a;
		return true;
	}


	/// <summary>
	/// Same as above, osc timetag type.
	/// </summary>
	public bool TryGet( int index, out OscTimeTag value )
	{
		if( index >= _args.Count || index < 0 ){
			value = new OscTimeTag( OscTimeTag.epochTime );
			LogOscMessageArgBoundsWarning( index ); return false;
		}
		object a = _args[index];
		if( !( a is OscTimeTag ) ){
			value = new OscTimeTag( OscTimeTag.epochTime );
			LogOscMessageArgTypeWarning( typeof( OscTimeTag ), index ); return false;
		}
		value = (OscTimeTag) a;
		return true;
	}

	/// <summary>
	/// Same as above, null type.
	/// </summary>
	public bool TryGetNull( int index )
	{
		if( index >= _args.Count || index < 0 ){ LogOscMessageArgBoundsWarning( index ); return false; }
		object a = _args[index];
		if( a != null ){ LogOscMessageArgTypeWarning( null, index ); return false; }
		return true;
	}

	/// <summary>
	/// Same as above, impulse type.
	/// </summary>
	public bool TryGetImpulse( int index )
	{
		if( index >= _args.Count || index < 0 ){ LogOscMessageArgBoundsWarning( index ); return false; }
		object a = _args[index];
		if( !( a is OscImpulse ) ){ LogOscMessageArgTypeWarning( typeof( OscImpulse ), index ); return false; }
		return true;
	}


	void LogOscMessageArgBoundsWarning( int index )
	{
		Debug.LogWarning( "[OscMessage] TryGet failed. Augument index " + index + " out of bounds. Message with address '" + _address + "' has " + _args.Count + " arguments." + Environment.NewLine );
	}


	void LogOscMessageArgTypeWarning( Type type, int index )
	{
		Debug.LogWarning( "[OscMessage] TryGet failed. Augument is not type '" + type + "'. It is '" + _args[index].GetType() + "'." + Environment.NewLine );
	}


	public override bool ToBytes( out byte[] bytes )
    {
		bytes = null;

		// Estimate byte length assuming address is "/address1" and all arguments are floats.
		int estimatedByteLength = 9 + 1+_args.Count + _args.Count * 4;

		// TODO A good optimisation here would be to precompute the packet byte length and use an Array instead of a List.

		// Create temp buffer for collecting the content
		List<byte> byteList = new List<byte>( estimatedByteLength );

		// Add address
		byteList.AddRange( StringToBytes( _address ) );

		// Add type tag
		char[] typeTags = new char[1+_args.Count];
		typeTags[0] = tagPrefix;
		for( int a=0; a<_args.Count; a++ )
		{
			object o = _args[a];
			if( o == null ){
				typeTags[1+a] = tagNull;
			} else if( o is float ){
				typeTags[1+a] = tagFloat;
			} else if( o is double ){
				typeTags[1+a] = tagDouble;
			} else if( o is int ){
				typeTags[1+a] = tagInt;
			} else if( o is long ){
				typeTags[1+a] = tagLong;
			} else if( o is string ){
				typeTags[1+a] = tagString;
			} else if( o is char ){
				typeTags[1+a] = tagChar;
			} else if ( o is bool ){
				typeTags[1+a] = ( (bool) o ) ? tagTrue : tagFalse;
			} else if( o is byte[] ){
				typeTags[1+a] = tagBlob;
			} else if( o is Color32 || o is Color ){
				typeTags[1+a] = tagColor;
			} else if( o is OscTimeTag || o is DateTime ){
				typeTags[1+a] = tagTimetag;
			} else if( o is OscImpulse ){
				typeTags[1+a] = tagImpulse;
			} else {
				Debug.LogWarning( "[OscMessage] ToBytes ignored. Argument type '" + a.GetType() + "' at index " + a + " is not supported." + Environment.NewLine );
				return false;
			}
		}
		byteList.AddRange( StringToBytes( typeTags ) );

		// Add arguments
		foreach( object arg in _args )
		{
			byte[] argDat = null;

			// TODO when GetTypeCode() becomes available in Unity, use that.
			// http://stackoverflow.com/questions/17774255/what-is-the-fastest-way-to-check-a-type
			// For now, we order the types by what we anticipate to be the most used.
			if( arg is string ){
				argDat = StringToBytes( (string) arg );

			} else if( arg is float ){
				argDat = BitConverter.GetBytes( (float) arg );
				if( BitConverter.IsLittleEndian ) Reverse4Bytes( argDat );

			} else if( arg is int ){
				argDat = BitConverter.GetBytes( (int) arg );
				if( BitConverter.IsLittleEndian ) Reverse4Bytes( argDat );

			} else if( arg is Color32 ){
				Color32 col = (Color32) arg;
				argDat = new byte[]{ col.r, col.g, col.b, col.a };
				if( BitConverter.IsLittleEndian ) Reverse4Bytes( argDat );

			}  else if( arg is Color ){
				Color32 col = (Color32) (Color) arg;
				argDat = new byte[]{ col.r, col.g, col.b, col.a };
				if( BitConverter.IsLittleEndian ) Reverse4Bytes( argDat );

			} else if( arg is long ){
				argDat = BitConverter.GetBytes( (long) arg );
				if( BitConverter.IsLittleEndian ) Reverse8Bytes( argDat );

			} else if( arg is double ){
				argDat = BitConverter.GetBytes( (double) arg );
				if( BitConverter.IsLittleEndian ) Reverse8Bytes( argDat );

			} else if( arg is byte[] ){
				byte[] rawBlob = (byte[]) arg;
				int blobLength = 4 + rawBlob.Length;
				blobLength += 4 - ( blobLength % 4 ); // ensure multiple of 4 bytes
				argDat = new byte[blobLength];
				byte[] lengthBytes = BitConverter.GetBytes( rawBlob.Length );
				if( BitConverter.IsLittleEndian ) Reverse4Bytes( lengthBytes );
				Array.Copy( lengthBytes, argDat, 4 );
				Array.Copy( rawBlob, 0, argDat, 4, rawBlob.Length );

			} else if( arg is OscTimeTag ){
				argDat = ( (OscTimeTag) arg ).ToByteArray(); // OscTimeTag ensures big-endian byte oder internally.

			} else if( arg is DateTime ){
				argDat = new OscTimeTag( (DateTime) arg ).ToByteArray(); // OscTimeTag ensures big-endian byte oder internally.

			} else if( arg is char ){
				argDat = BitConverter.GetBytes( Convert.ToInt32( (char) arg ) );
				if( BitConverter.IsLittleEndian ) Reverse4Bytes( argDat );

			} else if( arg is bool ) {
				// This type has no content (it's state is represented in the OSC tag)

			} else if( arg is OscImpulse ){
				// This type has no content

			} else if( arg == null ){
				// This type has no content (it's state is represented in the OSC tag)

			} else {
				Debug.LogWarning( "[OscMessage] ToBytes failed. Unsupported argument type: " + arg.GetType() + Environment.NewLine );
				bytes = null;
				return false;
			}

			if( argDat != null ) byteList.AddRange( argDat );
		}

		bytes = byteList.ToArray();
        return true;
    }

	// Array.Reverse is slow, so we do this manually.
	static void Reverse4Bytes( byte[] data )
	{
		byte tmp;
		tmp = data[0]; data[0] = data[3]; data[3] = tmp;
		tmp = data[1]; data[1] = data[2]; data[2] = tmp;
	}


	static void Reverse8Bytes( byte[] data )
	{
		byte tmp;
		tmp = data[0]; data[0] = data[7]; data[7] = tmp;
		tmp = data[1]; data[1] = data[6]; data[6] = tmp;
		tmp = data[2]; data[2] = data[5]; data[5] = tmp;
		tmp = data[3]; data[3] = data[4]; data[4] = tmp;
	}


	public static bool FromBytes( byte[] data, ref int pos, out OscPacket packet )
    {
		// Get address
		string address = StringFromBytes( data, ref pos );
		if( address.Length == 0 || address[0] != addressPrefix ){
			Debug.LogWarning( "[OscMessage] Ignoring message because address \"" + address + "\" is not starting with \"" + addressPrefix + "\"." + Environment.NewLine + ( "pos: " + pos + ", data: " + data.Length ) );
			packet = null;
			return false;
		}

		// Get type tags
		char[] tags = StringFromBytes( data, ref pos ).ToCharArray();
        int tagCount = tags.Length; // including prefix
		if( tags.Length == 0 || tags[0] != tagPrefix ){
			Debug.LogWarning( "[OscMessage] Ignoring message because typetag is missing." + Environment.NewLine );
			packet = null;
			return false;
		}

		// Construct message
		packet = new OscMessage( address, tagCount );
		OscMessage message = packet as OscMessage;

		// Get and add arguments
		for( int i=1; i<tagCount; i++ )
        {
            char tag = tags[i];
            object value;
            switch( tag )
            {
			case tagFloat:
				if( BitConverter.IsLittleEndian ) Array.Reverse( data, pos, 4 );
				value = BitConverter.ToSingle( data, pos );
				pos += 4;
				break;

			case tagDouble:
				if( BitConverter.IsLittleEndian ) Array.Reverse( data, pos, 8 );
				value = BitConverter.ToDouble( data, pos );
				pos += 8;
				break;
			
			case tagInt:
				if( BitConverter.IsLittleEndian ) Array.Reverse( data, pos, 4 );
				value = BitConverter.ToInt32( data, pos );
				pos += 4;
				break;

			case tagLong:
				if( BitConverter.IsLittleEndian ) Array.Reverse( data, pos, 8 );
				value = BitConverter.ToInt64( data, pos );
				pos += 8;
				break;

			case tagString:
			case tagSymbol:
				value = StringFromBytes( data, ref pos );
				break;

			case tagChar:
				if( BitConverter.IsLittleEndian ) Array.Reverse( data, pos, 4 );
				int charInt = BitConverter.ToInt32( data, pos );
				value = Convert.ToChar( charInt );
				break;

			case tagBlob:
				if( BitConverter.IsLittleEndian ) Array.Reverse( data, pos, 4 );
				int length = BitConverter.ToInt32( data, pos );
				pos += 4;
				byte[] blob = new byte[length];
				Array.Copy( data, pos, blob, 0, length );
				value = blob;
				pos += length;
				pos += 4 - ( pos % 4 );
				break;

			case tagTimetag:
				byte[] oscNtpBytes = new byte[OscTimeTag.byteSize];
				Array.Copy( data, pos, oscNtpBytes, 0, OscTimeTag.byteSize );
				value = new OscTimeTag( oscNtpBytes ); // OscTimeTag ensures big-endin byte oder internally.
				pos += 8;
				break;

			case tagColor:
				if( BitConverter.IsLittleEndian ) Array.Reverse( data, pos, 4 );
				value = new Color32( data[pos], data[pos+1], data[pos+2], data[pos+3] );
				pos += 4;
				break;

			case tagTrue:
				value = true;
				break;

			case tagFalse:
				value = false;
				break;

			case tagNull:
				value = null;
				break;

			case tagImpulse:
				value = new OscImpulse();
				break;

			default:
				Debug.LogWarning( "[OscMessage] FromBytes failed. Argument tag '" + tag + "' is not supported." + Environment.NewLine );
				return false;
            }

            message.args.Add( value );
        }

        return true;
    }


	static string StringFromBytes( byte[] data, ref int startIndex )
	{
		int count = 0;
		for( int i = startIndex; i < data.Length && data[i] != 0; i++ ) count++;
		string result = Encoding.ASCII.GetString( data, startIndex, count );
		startIndex += count + 1;

		// A sequence of non-null ASCII characters followed by a null, followed by 0-3 additional null characters to make the total number of bits a multiple of 32.
		startIndex = ((startIndex + 3)/4)*4;

		return result;
	}


	static byte[] StringToBytes( string text )
	{
		byte[] rawBytes = Encoding.ASCII.GetBytes( text );
		byte[] bytes = new byte[ rawBytes.Length + 4 - ( rawBytes.Length % 4 ) ]; // Ensure multiple of 4 bytes
		for( int i = 0; i < rawBytes.Length; i++ ) bytes[i] = rawBytes[i];
		//Array.Copy( rawBytes, bytes, rawBytes.Length );
		return bytes;
	}


	static byte[] StringToBytes( char[] text )
	{
		byte[] rawBytes = Encoding.ASCII.GetBytes( text );
		byte[] bytes = new byte[ rawBytes.Length + 4 - ( rawBytes.Length % 4 ) ]; // Ensure multiple of 4 bytes
		for( int i = 0; i < rawBytes.Length; i++ ) bytes[i] = rawBytes[i];
		return bytes;
	}


	public override string ToString()
	{
		if( _args.Count == 0 ) return _address;

		string arguments = string.Empty;
		foreach( object arg in _args )
		{
			if( arg is string ){
				arguments += " \"" + arg.ToString() + "\"";
			} else if( arg is char ){
				arguments += " '" + arg.ToString() + "'";
			} else if( arg is byte[] ){
				arguments += " Blob[" + ( (byte[]) arg ).Length + "]";
			} else if( arg is Color32 ){
				Color32 col = (Color32) arg;
				arguments += " RGBA(" + col.r + "," + col.g + "," + col.b + "," + col.a + ")";
			} else {
				arguments += " " + ( arg == null ? "Null" : arg.ToString() );
			}
		}
		return _address + arguments;
	}
}