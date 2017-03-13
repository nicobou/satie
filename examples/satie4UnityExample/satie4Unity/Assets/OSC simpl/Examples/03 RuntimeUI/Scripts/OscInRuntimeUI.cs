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
	public class OscInRuntimeUI : MonoBehaviour
	{
		public OscIn oscIn;
		public Toggle openToggle;
		public InputField portInputField;
		public Dropdown modeDropdown;
		public Text localIpAddressLabel;
		public InputField multicastAddressInputField;
		public Text messageBufferText;
		public Toggle messagesToggle;
		public Text messagesToggleLabel;
		public GameObject messageContainer;

		RectTransform componentRect;

		Queue<OscMessage> messageBuffer;

		int port;
		string multicastAddress;
		OscReceiveMode mode;

		const int messageBufferCapacity = 10;
		const string messageToggleTextEnabled = "Hide Messages";
		const string messageToggleTextDisabled = "Show Messages";
		const int componentHeightNonMulticast = 163;
		const int componentHeightMulticast = 193;

		string portPrefKey { get { return "OscIn Port -" + name; } }
		string modePrefKey { get { return "OscIn Mode -" + name; } }
		string multicastAddressPrefKey { get { return "OscIn Multicast Address -" + name; } }
		string messagesVisibilityPrefKey { get { return "OscIn Messages Visibility -" + name; } }


		void Awake()
		{
			componentRect = gameObject.GetComponent<RectTransform>();
		}


		void OnEnable()
		{
			if( messageBuffer == null ) messageBuffer = new Queue<OscMessage>( messageBufferCapacity );

			// Load settings and apply
			if(
				PlayerPrefs.HasKey( portPrefKey ) && 
				PlayerPrefs.HasKey( modePrefKey ) &&
				PlayerPrefs.HasKey( multicastAddressPrefKey ) && 
				PlayerPrefs.HasKey( messagesVisibilityPrefKey )
			){
				int tempPort = PlayerPrefs.GetInt( portPrefKey );
				OscReceiveMode tempMode = (OscReceiveMode) PlayerPrefs.GetInt( modePrefKey );
				string tempMulticastAddress = PlayerPrefs.GetString( multicastAddressPrefKey );
				modeDropdown.value = (int) tempMode; // avoid onChanged call
				Open( tempPort, tempMode, tempMulticastAddress );
				messagesToggle.isOn = PlayerPrefs.GetInt( messagesVisibilityPrefKey ) == 1 ? true : false;
				OnMessageVisibilityChanged( messagesToggle.isOn );
			}

			// Subcribe to UI events
			openToggle.onValueChanged.AddListener( OnOpenChanged );
			portInputField.onEndEdit.AddListener( OnPortEndEdit );
			modeDropdown.onValueChanged.AddListener( OnModeChanged );
			multicastAddressInputField.onEndEdit.AddListener( OnIpAddressEndEdit );
			messagesToggle.onValueChanged.AddListener( OnMessageVisibilityChanged );
		}


		void OnDisable()
		{
			messageBuffer.Clear();

			// Unsubcribe to UI events
			openToggle.onValueChanged.RemoveListener( OnOpenChanged );
			portInputField.onEndEdit.RemoveListener( OnPortEndEdit );
			modeDropdown.onValueChanged.RemoveListener( OnModeChanged );
			multicastAddressInputField.onEndEdit.RemoveListener( OnIpAddressEndEdit );
			messagesToggle.onValueChanged.RemoveListener( OnMessageVisibilityChanged );

			// Save settings
			PlayerPrefs.SetInt( portPrefKey, oscIn.port );
			PlayerPrefs.SetInt( modePrefKey, (int) oscIn.mode );
			PlayerPrefs.SetString( multicastAddressPrefKey, oscIn.multicastAddress );
			PlayerPrefs.SetInt( messagesVisibilityPrefKey, messagesToggle.isOn ? 1 : 0 );
		}


		void Update()
		{
			if( oscIn == null ){
				Destroy( this );
				return;
			}

			// Update UI
			if( oscIn.isOpen != openToggle.isOn ) openToggle.isOn = oscIn.isOpen;
			if( oscIn.port != port ){
				port = oscIn.port;
				portInputField.text = port.ToString();
			}
			if( oscIn.mode != (OscReceiveMode) modeDropdown.value ){
				mode = oscIn.mode;
				modeDropdown.value = (int) oscIn.mode;
			}
			if( OscIn.ipAddress != localIpAddressLabel.text ){
				if( string.IsNullOrEmpty( OscIn.ipAddress ) ) localIpAddressLabel.text = "Local IP Not found";
				else localIpAddressLabel.text = OscIn.ipAddress;
			}
			if( oscIn.multicastAddress != multicastAddress ){
				multicastAddress = oscIn.multicastAddress;
				multicastAddressInputField.text = multicastAddress;
			}

			if( messagesToggle.isOn ){
				OscMessage[] messages = messageBuffer.ToArray();
				StringBuilder messagesText = new StringBuilder();
				for( int m=messages.Length-1; m>=0; m-- ) messagesText.AppendLine( messages[m].ToString() );
				messageBufferText.text = messagesText.ToString();
			}
		}


		void Open( int port, OscReceiveMode mode, string multicastAddress )
		{
			switch( mode ){
			case OscReceiveMode.UnicastBroadcast:
				oscIn.Open( port );
				componentRect.sizeDelta = new Vector2( componentRect.sizeDelta.x, componentHeightNonMulticast );
				break;
			case OscReceiveMode.UnicastBroadcastMulticast:
				oscIn.Open( port, multicastAddress );
				componentRect.sizeDelta = new Vector2( componentRect.sizeDelta.x, componentHeightMulticast );
				break;
			}
		}


		void OnAnyMessage( OscMessage message )
		{
			if( messageBuffer.Count >= messageBufferCapacity ) messageBuffer.Dequeue();
			messageBuffer.Enqueue( message );
		}


		void OnOpenChanged( bool on )
		{
			if( on ) Open( port, mode, multicastAddress );
			else oscIn.Close();
		}


		void OnPortEndEdit( string portString )
		{
			if( string.IsNullOrEmpty( portString ) ){
				portInputField.text = oscIn.port.ToString();
				return;
			}
			port = int.Parse( portString );
			Open( port, mode, multicastAddress );
		}


		void OnModeChanged( int modeInt )
		{
			mode = (OscReceiveMode) modeInt;
			Open( port, mode, multicastAddress );
		}


		void OnIpAddressEndEdit( string multicastAddress )
		{
			this.multicastAddress = multicastAddress;
			Open( port, mode, multicastAddress );
		}


		void OnMessageVisibilityChanged( bool visible )
		{
			messageContainer.SetActive( visible );
			if( visible ){
				oscIn.onAnyMessage.AddListener( OnAnyMessage );
				messagesToggleLabel.text = messageToggleTextEnabled;
			} else {
				oscIn.onAnyMessage.RemoveListener( OnAnyMessage );
				messagesToggleLabel.text = messageToggleTextDisabled;
				messageBuffer.Clear();
			}
		}
	}
}