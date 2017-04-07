/*
	Created by Carl Emil Carlsen.
	Copyright 2016 Sixth Sensor.
	All rights reserved.
	http://sixthsensor.dk
*/

using UnityEngine;
using UnityEngine.UI;
using System.Text;
using System.Collections;
using System.Collections.Generic;

namespace OscSimpl.Examples
{
	[RequireComponent(typeof(RectTransform))]
	public class OscOutRuntimeUI : MonoBehaviour
	{
		public OscOut oscOut;
		public Toggle openToggle;
		public InputField portInputField;
		public Dropdown modeDropdown;
		public InputField ipAddressInputField;
		public Text messageBufferText;
		public Toggle messagesToggle;
		public Text messagesToggleLabel;
		public GameObject messageContainer;

		Queue<OscMessage> messageBuffer;

		int port;
		string ipAddress;

		const int messageBufferCapacity = 10;
		const string messageToggleTextEnabled = "Hide Messages";
		const string messageToggleTextDisabled = "Show Messages";

		string portPrefKey { get { return "OscOut Port -" + name; } }
		string ipAddressPrefKey { get { return "OscOut IP Address -" + name; } }
		string messagesVisibilityPrefKey { get { return "OscOut Messages Visibility -" + name; } }


		void OnEnable()
		{
			if( messageBuffer == null ) messageBuffer = new Queue<OscMessage>( messageBufferCapacity );

			// Load settings and apply.
			if( PlayerPrefs.HasKey( portPrefKey ) && PlayerPrefs.HasKey( ipAddressPrefKey ) && PlayerPrefs.HasKey( messagesVisibilityPrefKey ) ){
				int tempPort = PlayerPrefs.GetInt( portPrefKey );
				string tempIpAddress = PlayerPrefs.GetString( ipAddressPrefKey );
				oscOut.Open( tempPort, tempIpAddress );
				modeDropdown.value = (int) oscOut.mode; // avoid onChanged call
				messagesToggle.isOn = PlayerPrefs.GetInt( messagesVisibilityPrefKey ) == 1 ? true : false;
				OnMessageVisibilityChanged( messagesToggle.isOn );
			}

			// Subcribe to UI events.
			openToggle.onValueChanged.AddListener( OnOpenChanged );
			portInputField.onEndEdit.AddListener( OnPortEndEdit );
			modeDropdown.onValueChanged.AddListener( OnModeChanged );
			ipAddressInputField.onEndEdit.AddListener( OnIpAddressEndEdit );
			messagesToggle.onValueChanged.AddListener( OnMessageVisibilityChanged );
		}


		void OnDisable()
		{
			messageBuffer.Clear();

			// Unsubcribe to UI events.
			openToggle.onValueChanged.RemoveListener( OnOpenChanged );
			portInputField.onEndEdit.RemoveListener( OnPortEndEdit );
			modeDropdown.onValueChanged.RemoveListener( OnModeChanged );
			ipAddressInputField.onEndEdit.RemoveListener( OnIpAddressEndEdit );
			messagesToggle.onValueChanged.RemoveListener( OnMessageVisibilityChanged );

			// Save settings.
			PlayerPrefs.SetInt( portPrefKey, oscOut.port );
			PlayerPrefs.SetString( ipAddressPrefKey, oscOut.ipAddress );
			PlayerPrefs.SetInt( messagesVisibilityPrefKey, messagesToggle.isOn ? 1 : 0 );
		}



		void Update()
		{
			if( oscOut == null ){
				Destroy( this );
				return;
			}

			// Update UI.
			if( oscOut.isOpen != openToggle.isOn ) openToggle.isOn = oscOut.isOpen;
			if( oscOut.port != port ){
				port = oscOut.port;
				portInputField.text = port.ToString();
			}
			if( oscOut.mode != (OscSendMode) modeDropdown.value ){
				modeDropdown.value = (int) oscOut.mode;
			}
			if( oscOut.ipAddress != ipAddress ){
				ipAddress = oscOut.ipAddress;
				ipAddressInputField.text = ipAddress;
			}

			if( messagesToggle.isOn ){
				OscMessage[] messages = messageBuffer.ToArray();
				StringBuilder messagesText = new StringBuilder();
				for( int m=messages.Length-1; m>=0; m-- ) messagesText.AppendLine( messages[m].ToString() );
				messageBufferText.text = messagesText.ToString();
			}
		}


		void OnAnyMessage( OscMessage message )
		{
			if( messageBuffer.Count >= messageBufferCapacity ) messageBuffer.Dequeue();
			messageBuffer.Enqueue( message );
		}


		void OnOpenChanged( bool on )
		{
			if( on ) oscOut.Open( port, ipAddress );
			else oscOut.Close();
		}


		void OnPortEndEdit( string portString )
		{
			if( string.IsNullOrEmpty( portString ) ){
				portInputField.text = oscOut.port.ToString();
				return;
			}
			port = int.Parse( portString );
			oscOut.Open( port, ipAddress );
		}


		void OnModeChanged( int modeInt )
		{
			switch( (OscSendMode) modeInt ){
			case OscSendMode.UnicastToSelf: 	oscOut.Open( oscOut.port ); break;
			case OscSendMode.Unicast: 			oscOut.Open( oscOut.port, OscSimpl.OscHelper.unicastAddressDefault ); break;
			case OscSendMode.Multicast:			oscOut.Open( oscOut.port, OscSimpl.OscHelper.multicastAddressDefault ); break;
			case OscSendMode.Broadcast:			oscOut.Open( oscOut.port, System.Net.IPAddress.Broadcast.ToString() ); break;
			}
		}


		void OnIpAddressEndEdit( string ipAddress )
		{
			this.ipAddress = ipAddress;
			oscOut.Open( port, ipAddress );
		}


		void OnMessageVisibilityChanged( bool visible )
		{
			messageContainer.SetActive( visible );
			if( visible ){
				oscOut.onAnyMessage.AddListener( OnAnyMessage );
				messagesToggleLabel.text = messageToggleTextEnabled;
			} else {
				oscOut.onAnyMessage.RemoveListener( OnAnyMessage );
				messagesToggleLabel.text = messageToggleTextDisabled;
				messageBuffer.Clear();
			}
		}
	}
}