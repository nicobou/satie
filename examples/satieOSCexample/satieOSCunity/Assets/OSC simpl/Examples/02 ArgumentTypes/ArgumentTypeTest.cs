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
	public class ArgumentTypeTest : MonoBehaviour
	{
		public OscIn oscIn;
		public OscOut oscOut;

		public Text outputHeaderLabel;
		public Text inputHeaderLabel;

		public Text floatOutputLabel;
		public Text doubleOutputLabel;
		public Text intOutputLabel;
		public Text longOutputLabel;
		public Text boolOutputLabel;
		public Image colorOutputImage;
		public InputField timetagYearOutputField;
		public InputField timetagMonthOutputField;
		public InputField timetagDayOutputField;
		public InputField timetagHourOutputField;
		public InputField timetagMinuteOutputField;
		public InputField timetagSecondOutputField;
		public InputField timetagMillisecondOutputField;
		public RawImage blobOutputRawImage;

		public Slider floatInputSlider;
		public Slider doubleInputSlider;
		public Slider intInputSlider;
		public Slider longInputSlider;
		public InputField stringInputField;
		public InputField charInputField;
		public Toggle boolInputToggle;
		public Image colorInputImage;
		public RawImage blobInputRawImage;
		public InputField timetagYearInputField;
		public InputField timetagMonthInputField;
		public InputField timetagDayInputField;
		public InputField timetagHourInputField;
		public InputField timetagMinuteInputField;
		public InputField timetagSecondInputField;
		public InputField timetagMillisecondInputField;
		public Toggle timetagImmediateIinputToggle;
		public Image impulseInputImage;
		public Image nullInputImage;
		public Image emptyInputImage;

		public Text floatInputLabel;
		public Text doubleInputLabel;
		public Text intInputLabel;
		public Text longInputLabel;
		public Text boolInputLabel;

		const string floatAddress = "/test/float";
		const string doubleAddress = "/test/double";
		const string intAddress = "/test/int";
		const string longAddress = "/test/long";
		const string stringAddress = "/test/string";
		const string charAddress = "/test/char";
		const string boolAddress = "/test/bool";
		const string colorAddress = "/test/color";
		const string blobAddress = "/test/blob";
		const string timetagAddress = "/test/timetag";
		const string impulseAddress = "/test/impulse";
		const string nullAddress = "/test/null";
		const string emptyAddress = "/test/empty";

		Texture2D blobInputTexture;
		Texture2D blobOutputTexture;

		OscTimeTag timetag;

		Color defaultColor;
		float hue;


		void Awake()
		{
			defaultColor = emptyInputImage.color;
			timetag = new OscTimeTag( new System.DateTime( 1900, 1, 1 ) );
		}


		void Update()
		{
			outputHeaderLabel.text = "OUTPUT (port: " + oscOut.port + ", address: " + oscOut.ipAddress + ")";
			string multicastString = oscIn.mode == OscReceiveMode.UnicastBroadcast ? "" : ", multicast address: " + oscIn.multicastAddress + "";
			inputHeaderLabel.text = "INPUT (port: " + oscIn.port + multicastString + ")";
		}




		#region send methods

		// The following methods are meant to be linked to Unity's runtime UI from the Unity Editor.


		public void SendFloat( float value )
		{
			oscOut.Send( floatAddress, value );
			floatOutputLabel.text = value.ToString();
		}


		public void SendDouble( float value )
		{
			double doubleValue = value;
			if( doubleValue != 0 && doubleValue != 1 ) doubleValue += double.Epsilon; // add more digits for testing
			oscOut.Send( doubleAddress, doubleValue );
			doubleOutputLabel.text = doubleValue.ToString();
		}


		public void SendInt( float value )
		{
			int intValue = (int) ( (int.MaxValue-64) * value ); // minus 64 to avoid sign flip at maximum
			oscOut.Send( intAddress, intValue );
			intOutputLabel.text = intValue.ToString();
		}


		public void SendLong( float value )
		{
			long longValue = (long) ( long.MaxValue * value );
			oscOut.Send( longAddress, longValue );
			longOutputLabel.text = longValue.ToString();
		}


		public void SendString( string value )
		{
			oscOut.Send( stringAddress, value );
		}


		public void SendChar( string value )
		{
			if( value.Length == 0 ) return;
			char charValue = value[0];
			oscOut.Send( charAddress, charValue );
		}


		public void SendBool( bool value )
		{
			oscOut.Send( boolAddress, value );
			boolOutputLabel.text = value.ToString();
		}


		public void SendColor()
		{
			hue = ( hue + 0.2f ) % 1f;
			Color32 color = Color.HSVToRGB( hue, 0.3f, 1 );
			colorOutputImage.color = color;
			oscOut.Send( colorAddress, color );
		}


		public void GenerateAndSendBlob()
		{
			int size = 16;
			Color32[] pixels = new Color32[size*size];
			for( int p=0; p<pixels.Length; p++ ) pixels[p] = new Color32( (byte) (int) (Random.value*255), (byte) (int) (Random.value*255), (byte) (int) (Random.value*255), 255 );
			if( blobOutputTexture == null ) blobOutputTexture = new Texture2D( size, size, TextureFormat.ARGB32, false );
			blobOutputTexture.SetPixels32( pixels );
			blobOutputTexture.Apply();
			blobOutputRawImage.texture = blobOutputTexture;
			byte[] blob = blobOutputTexture.EncodeToPNG();

			oscOut.Send( blobAddress, blob );
		}


		public void SendTimeTagYear( string stringValue )
		{
			if( stringValue.Length == 0 ) stringValue = "0";
			int year = Mathf.Clamp( System.Convert.ToInt32( stringValue ), 1, 9999 );
			timetagYearOutputField.text = year.ToString();
			System.DateTime time = timetag.time;
			time = new System.DateTime( year, time.Month, time.Day, time.Hour, time.Minute, time.Second, time.Millisecond );
			timetag.time = time;
			oscOut.Send( timetagAddress, timetag );
		}


		public void SendTimeTagMonth( string stringValue )
		{
			if( stringValue.Length == 0 ) stringValue = "0";
			int month = Mathf.Clamp( System.Convert.ToInt32( stringValue ), 1, 12 );
			timetagMonthOutputField.text = month.ToString();
			System.DateTime time = timetag.time;
			time = new System.DateTime( time.Year, month, time.Day, time.Hour, time.Minute, time.Second, time.Millisecond );
			timetag.time = time;
			oscOut.Send( timetagAddress, timetag );
		}


		public void SendTimeTagDay( string stringValue )
		{
			if( stringValue.Length == 0 ) stringValue = "0";
			int day = Mathf.Clamp( System.Convert.ToInt32( stringValue ), 1, 31 );
			timetagDayOutputField.text = day.ToString();
			System.DateTime time = timetag.time;
			time = new System.DateTime( time.Year, time.Month, day, time.Hour, time.Minute, time.Second, time.Millisecond );
			timetag.time = time;
			oscOut.Send( timetagAddress, timetag );
		}


		public void SendTimeTagHour( string stringValue )
		{
			if( stringValue.Length == 0 ) stringValue = "0";
			int hour = Mathf.Clamp( System.Convert.ToInt32( stringValue ), 0, 23 );
			timetagHourOutputField.text = hour.ToString();
			System.DateTime time = timetag.time;
			time = new System.DateTime( time.Year, time.Month, time.Month, hour, time.Minute, time.Second, time.Millisecond );
			timetag.time = time;
			oscOut.Send( timetagAddress, timetag );
		}


		public void SendTimeTagMinute( string stringValue )
		{
			if( stringValue.Length == 0 ) stringValue = "0";
			int minute = Mathf.Clamp( System.Convert.ToInt32( stringValue ), 0, 59 );
			timetagMinuteOutputField.text = minute.ToString();
			System.DateTime time = timetag.time;
			time = new System.DateTime( time.Year, time.Month, time.Month, time.Day, minute, time.Second, time.Millisecond );
			timetag.time = time;
			oscOut.Send( timetagAddress, timetag );
		}


		public void SendTimeTagSecond( string stringValue )
		{
			if( stringValue.Length == 0 ) stringValue = "0";
			int second = Mathf.Clamp( System.Convert.ToInt32( stringValue ), 0, 59 );
			timetagSecondOutputField.text = second.ToString();
			System.DateTime time = timetag.time;
			time = new System.DateTime( time.Year, time.Month, time.Month, time.Day, time.Minute, second, time.Millisecond );
			timetag.time = time;
			oscOut.Send( timetagAddress, timetag );
		}


		public void SendTimeTagMillisecond( string stringValue )
		{
			if( stringValue.Length == 0 ) stringValue = "0";
			int millisecond = Mathf.Clamp( System.Convert.ToInt32( stringValue ), 0, 999 );
			timetagMillisecondOutputField.text = millisecond.ToString();
			System.DateTime time = timetag.time;
			time = new System.DateTime( time.Year, time.Month, time.Month, time.Day, time.Minute, time.Second, millisecond );
			timetag.time = time;
			oscOut.Send( timetagAddress, timetag );
		}


		public void SendTimeTagImmediate( bool state )
		{
			timetag.immediately = state;
			oscOut.Send( timetagAddress, timetag );
		}


		public void SendImpulse()
		{
			oscOut.Send( impulseAddress, new OscImpulse() );
		}


		public void SendNull()
		{
			oscOut.Send( nullAddress, null );
		}


		public void SendEmpty()
		{
			oscOut.Send( emptyAddress );
		}

		#endregion



		#region receive methods

		// The following methods are meant to be set up as "mappings" in the inspector panel of an OscIn object.

		public void OnReceiveFloat( float value )
		{
			floatInputSlider.value = value;
			floatInputLabel.text = value.ToString();
		}


		public void OnReceiveDouble( double value )
		{
			doubleInputSlider.value = (float) value;
			doubleInputLabel.text = value.ToString();
		}


		public void OnReceiveInt( int value )
		{
			intInputSlider.value = (float) ( value / (double) int.MaxValue );
			intInputLabel.text = value.ToString();
		}


		public void OnReceiveLong( long value )
		{
			longInputSlider.value = (float) ( value / (double) long.MaxValue );
			longInputLabel.text = value.ToString();
		}


		public void OnReceiveString( string value )
		{
			stringInputField.text = value;
		}


		public void OnReceiveChar( char value )
		{
			charInputField.text = value.ToString();
		}


		public void OnReceiveBool( bool value )
		{
			boolInputToggle.isOn = value;
			boolInputLabel.text = value.ToString();
		}


		public void OnReceiveColor( Color32 value )
		{
			colorInputImage.color = value;
		}


		public void OnReceiveBlob( byte[] value )
		{
			// Presuming we are receiving a image in png or jpeg format.
			if( blobInputTexture == null ) blobInputTexture = new Texture2D(2,2);
			blobInputTexture.LoadImage( value );
			blobInputRawImage.texture = blobInputTexture;
		}


		public void OnReceiveTimeTag( OscTimeTag timetag )
		{
			timetagYearInputField.text = timetag.time.Year.ToString();
			timetagMonthInputField.text = timetag.time.Month.ToString();
			timetagDayInputField.text = timetag.time.Day.ToString();
			timetagHourInputField.text = timetag.time.Hour.ToString();
			timetagMinuteInputField.text = timetag.time.Minute.ToString();
			timetagSecondInputField.text = timetag.time.Second.ToString();
			timetagMillisecondInputField.text = timetag.time.Millisecond.ToString();
			timetagImmediateIinputToggle.isOn = timetag.immediately;
		}


		public void OnReceiveImpulse()
		{
			StartCoroutine( FlashImageCoroutine( impulseInputImage ) );
		}


		public void OnReceiveNull()
		{
			StartCoroutine( FlashImageCoroutine( nullInputImage ) );
		}


		public void OnReceiveEmpty()
		{
			StartCoroutine( FlashImageCoroutine( emptyInputImage ) );
		}

		#endregion


		IEnumerator FlashImageCoroutine( Image image )
		{
			float startTime = Time.time;
			float timeElapsed = 0;
			float duration = 0.2f;
			while( timeElapsed < duration )
			{
				yield return 0;
				image.color = Color.Lerp( Color.black, defaultColor, timeElapsed / duration );
				timeElapsed = Time.time - startTime;
			}
			image.color = defaultColor;
		}

	}
}