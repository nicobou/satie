/*
	Created by Carl Emil Carlsen.
	Copyright 2016 Sixth Sensor.
	All rights reserved.
	http://sixthsensor.dk
*/

/*
About OscTimeTag for OSC io
 * ---------------------------
 * 
 * Timetags in 'OSC io' are send implicitly with bundles and explicitly as message 
 * arguments.
 * 
 * 'OSC io' never exposes incoming bundles to the user. Instead, the contained
 * messages are unwrapped automatically and send to mapped methods. If you want 
 * to receive timetags from bundles, then enable 'addTimeTagsToBundledMessages' 
 * on OscIn and grab the timetag from the last argument of your incoming bundled 
 * message.
 * 
 * 
 * About timed scheduling
 * ----------------------
 * 'OSC io' DOES NOT support timed scheduling of received bundled messages. The 
 * OSC 1.0 specification states that this is required. However, a paper published 
 * in 2009 describing the (ever) forthcoming OSC 1.1 specification states that 
 * automatic timed shceduling is optional.
 * 
 * "[...] we have decided to embrace [implementations where all message processing 
 * is immediately on receipt] by simply not specifying time tag semantics at all 
 * in OSC 1.1."
 * http://opensoundcontrol.org/spec-1_1
 * http://archive.notam02.no/arkiv/proceedings/NIME2009/nime2009/pdf/author/nm090097.pdf
 * 
 * 
 * About temporal precision
 * ------------------------
 * An OSC-timetag contains a time value with the theoretical precision of "about 
 * 200 picoseconds" (see below), that's 0.0000002 milliseconds or 0.002 
 * System.DateTime ticks. However, since OscTimeTag's time is manipulated via System.DateTime, 
 * the precision is limited to DateTime ticks. There are 10 million DateTime ticks in one second, 
 * that means a precision of about 0.0001 milliseconds can be expected. Though, keep in mind 
 * that to optain such a precision DateTime.Now is useless and you should instead create your 
 * DateTime from ticks obtained from something like System.Diagnostics.Stopwatch. But be aware:
 * 
 * "Stopwatch ticks are different from DateTime.Ticks. Each tick in the DateTime.Ticks 
 * value represents one 100-nanosecond interval. Each tick in the ElapsedTicks value represents 
 * the time interval equal to 1 second divided by the Frequency."
 * https://msdn.microsoft.com/en-us/library/system.diagnostics.stopwatch.elapsedticks(v=vs.110).aspx
 * 
 * If you want higher precision than 0.0001 milliseconds and are ready to get your hands dirty,
 * then you can manipulate the timetag through the 'oscNtp' property directly.
 * 
 * "Time tags are represented by a 64 bit fixed point number. The first 32 bits specify 
 * the number of seconds since midnight on January 1, 1900, and the last 32 bits specify 
 * fractional parts of a second to a precision of about 200 picoseconds. This is the 
 * representation used by Internet NTP timestamps. The time tag value consisting of 63 
 * zero bits followed by a one in the least signifigant bit is a special case meaning 
 * "immediately.""
 * http://opensoundcontrol.org/spec-1_0
 */

using UnityEngine;
using System;
using System.Collections.Generic;

/// <summary>
/// Class representing a OSC timetag.
/// OscTimeTag objects are send implicitly with bundles and explicitly as message arguments.
/// Incoming bundles are never exposed to the user. Instead, the contained messages are unwrapped 
/// automatically and send to mapped methods. If you want to receive timetags from bundles, then 
/// enable 'addTimeTagsToBundledMessages' on OscIn and grab the timetag from the last argument of 
/// your incoming bundled message. Timed scheduling of received bundled messages is not supported.
/// </summary>
public class OscTimeTag
{
	/// <summary>
	/// Gets or sets the time with DateTime tick precision.
	/// </summary>
    public DateTime time {
		get { return GetTime(); }
		set { SetTime( value ); }
	}

	/// <summary>
	/// Gets or sets the 'immediately' flag. Some OSC implementations may interpret the flag
	/// as "process immediately on receipt" - as opposed to "schedule the recieved bundle 
	/// for processing at time" - while other implementations may ignore it.
	/// Default is true.
	/// </summary>
	public bool immediately {
		get { return ( _oscNtp & 1 ) != 0; }
		set {
			if( value ) _oscNtp |= ( 1 << 0 );
			else _oscNtp &= ~ ( (ulong) 1 << 0 );
		}
	}

	/// <summary>
	/// Get or sets the OSC flavoured NTP encoded value in which a time and a 'immediately' flag is stored.
	/// Don't manipulate this property directly, unless you have read the OSC 1.0 specification.
	/// </summary>
	public ulong oscNtp {
		get { return _oscNtp; }
		set { _oscNtp = value; }
	}
	ulong _oscNtp = 1; // 'immediate' default is true

	public static readonly DateTime epochTime = new DateTime( 1900, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc );

	public static readonly long epochTicks = epochTime.Ticks;

	public const decimal secondsPerDateTimeTick = 1 / (decimal) TimeSpan.TicksPerSecond;

	const decimal ntp2Ticks = 1e7m / (1UL << 32);

	public const int byteSize = 8;


	/// <summary>
	/// Create new timetag with time set to now.
	/// </summary>
    public OscTimeTag() : this( DateTime.Now ) {}


	/// <summary>
	/// Create new timetag with 'time'.
	/// </summary>
    public OscTimeTag( DateTime time )
	{
		this.time = time;
    }

	/// <summary>
	/// Create new timetag with 'time' and 'immediately' flag.
	/// </summary>
	public OscTimeTag( DateTime time, bool immediately )
	{
		this.time = time;
		this.immediately = immediately;
	}
		
	public OscTimeTag( byte[] oscNtpBytes )
	{
		// Ensure big-endian bit order, required by the OSC 1.0 specification.
		if( BitConverter.IsLittleEndian ) Array.Reverse( oscNtpBytes );

		// Convert to unsigned 64bit integer
		_oscNtp = BitConverter.ToUInt64( oscNtpBytes, 0 );
	}



	public byte[] ToByteArray()
	{
		// Convert to bytes
		byte[] ntpBytes = BitConverter.GetBytes( _oscNtp );

		// Ensure big-endian bit order, required by the OSC 1.0 specification.
		if( BitConverter.IsLittleEndian ) Array.Reverse( ntpBytes );

		return ntpBytes;
	}



	void SetTime( DateTime time )
	{
		// Silently fix invalid time values.
		// We cannot go below the epoch, since the offset from epoch will be stored in an unsigned integer.
		if( time.Ticks - epochTicks < 0 ){
			Debug.LogWarning( "[OSC io] OSC timtags cannot store time values before epoch time 01/01/1900. Received time: " + time + Environment.NewLine );
			time = new DateTime( epochTicks );
		}

		// Store 'immediately' flag
		bool tempImmediate = immediately;

		// DateTime to OSC NTP
		_oscNtp = (ulong) ( ( time.Ticks - epochTicks ) / ntp2Ticks );

		// DateTime to NTP (Readable version)
		//long offTicks = time.Ticks - epochTicks;								// Get the offset from epoch time in ticks
		//uint offSec = (uint) ( offTicks / TimeSpan.TicksPerSecond );			// Get the offset from epoch time in seconds
		//long fracTicks = offTicks - ( offSec * TimeSpan.TicksPerSecond );		// Get the remaining ticks
		//double fracSec = fracTicks * (double) secondsPerDateTimeTick;			// Convert to seconds (normalize)
		//uint frac = (uint) ( fracSec * uint.MaxValue );						// Scale up value to use full resoultion of the uint
		//_oscNtp = offSec;														// Set seconds
		//_oscNtp = _oscNtp << 32;												// Push the seconds to the high-order 32 bits
		//_oscNtp += frac;														// Add factional second

		// Set 'immediately' flag
		immediately = tempImmediate;
	}


	DateTime GetTime()
	{
		// NTP to DateTime
		return new DateTime( (long) Math.Round( _oscNtp * ntp2Ticks ) + epochTicks );

		// NTP to DateTime (Readable version)
		//uint offSec = (uint) ( _oscNtp >> 32 );									// Grab seconds offset from epoch at the high-order 32 bits
		//uint frac = (uint) ( _oscNtp & 0xffffffffL );								// Grab fractional second offset from epoch at the low-order 32 bits
		//long offTicks = offSec * TimeSpan.TicksPerSecond;							// Convert seconds offset to ticks
		//double fracSec = ( (ulong) frac ) / (double) uint.MaxValue;				// Convert fractional second to second
		//long fracTicks = (long) Math.Round( fracSec * TimeSpan.TicksPerSecond );	// Convert fractional second to ticks
		//long ticks = offTicks + fracTicks + epochTicks;							// Sum ticks
		//return new DateTime( ticks );
	}



	public static bool operator ==( OscTimeTag lhs, OscTimeTag rhs )
	{
		if( ReferenceEquals( lhs, rhs ) ) return true;
		if( ( (object) lhs == null) || ((object) rhs == null) ) return false;
		return lhs._oscNtp == rhs._oscNtp;
	}


	public static bool operator !=( OscTimeTag lhs, OscTimeTag rhs ){ return !( lhs == rhs ); }


	public static bool operator <( OscTimeTag lhs, OscTimeTag rhs ){ return lhs._oscNtp < rhs._oscNtp; }


	public static bool operator <=( OscTimeTag lhs, OscTimeTag rhs ){ return lhs._oscNtp <= rhs._oscNtp; }


	public static bool operator >( OscTimeTag lhs, OscTimeTag rhs ){ return lhs._oscNtp > rhs._oscNtp; }


	public static bool operator >=( OscTimeTag lhs, OscTimeTag rhs ) { return lhs._oscNtp >= rhs._oscNtp; }


	public static bool Equals( OscTimeTag lhs, OscTimeTag rhs )
	{
		return lhs.Equals( rhs );
	}


    public override bool Equals( object value )
	{
        if( value == null ) return false;
        OscTimeTag rhs = value as OscTimeTag;
        if( rhs == null ) return false;
		return _oscNtp.Equals( rhs._oscNtp );
    }


    public bool Equals( OscTimeTag value )
	{
        if( (object) value == null ) return false;
		return _oscNtp.Equals(value._oscNtp);
    }


	public override int GetHashCode(){ return _oscNtp.GetHashCode(); }


	public override string ToString(){ return "[" + time.ToString().Replace( " ", "-" ) + "," + immediately + "]"; }
    
}



/*
Original 1998 implementation by Matt Wright:
https://ccrma.stanford.edu/~rswilson/avr/avrlib/OSC-timetag_8c-source.html

00085 OSCTimeTag OSCTT_CurrentTime(void) {
	00086     uint64 result;
	00087     uint32 usecOffset;
	00088     struct timeval tv;
	00089     struct timezone tz;
	00090
	00091     BSDgettimeofday(&tv, &tz);
	00092
	00093     // First get the seconds right
	00094     result = (unsigned) SECONDS_FROM_1900_to_1970 +
	00095              (unsigned) tv.tv_sec -
	00096              (unsigned) 60 * tz.tz_minuteswest +
	00097              (unsigned) (tz.tz_dsttime ? 3600 : 0);
	00098
	00099 #if 0
	00100     // No timezone, no DST version ... 
	00101     result = (unsigned) SECONDS_FROM_1900_to_1970 +
	00102              (unsigned) tv.tv_sec;
	00103 #endif
	00104
	00105
	00106     // make seconds the high-order 32 bits 
	00107     result = result << 32;
	00108
	00109     // Now get the fractional part. 
	00110     usecOffset = (unsigned) tv.tv_usec * (unsigned) TWO_TO_THE_32_OVER_ONE_MILLION;
	00111     // printf("** %ld microsec is offset %x\n", tv.tv_usec, usecOffset); 
	00112
	00113     result += usecOffset;
	00114
	00115 //    printf("* OSCTT_CurrentTime is %llx\n", result); 
	00116     return result;
	00117 }
*/


/*
Implementation in oscP5:
https://code.google.com/p/oscp5/source/browse/trunk/src/oscP5/OscBundle.java

public void setTimetag(long theTime) {
	final long secsSince1900 = theTime / 1000 + TIMETAG_OFFSET;
	final long secsFractional = ((theTime % 1000) << 32) / 1000;
	timetag = (secsSince1900 << 32) | secsFractional;
}
*/