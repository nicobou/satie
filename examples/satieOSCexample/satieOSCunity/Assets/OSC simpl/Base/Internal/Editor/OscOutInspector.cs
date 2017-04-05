/*
	Created by Carl Emil Carlsen.
	Copyright 2016 Sixth Sensor.
	All rights reserved.
	http://sixthsensor.dk
*/

using UnityEngine;
using UnityEditor;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Net;

namespace OscSimpl
{
	[CanEditMultipleObjects]
	[CustomEditor(typeof(OscOut))]
	public class OscOutInspector : Editor
	{
		OscOut oscOut;
		
		SerializedProperty _openOnAwake;
		SerializedProperty _ipAddress;
		SerializedProperty _port;
		SerializedProperty _multicastLoopback;
		SerializedProperty _bundleMessagesOnEndOfFrame;
		SerializedProperty _settingsFoldout;
		SerializedProperty _messagesFoldout;
		
		readonly GUIContent _portLabel = new GUIContent( "Port", "Port for target (remote) device." );
		readonly GUIContent _modeLabel = new GUIContent( "Send Mode", "Transmission mode." );
		readonly GUIContent _ipAdrressLabel = new GUIContent( "Target IP Address", "IP Address for target (remote) device. LED shows ping status; gray for pingning, yellow for fail, green for success." );
		readonly GUIContent _isOpenLabel = new GUIContent( "Is Open", "Indicates whether this OscOut object is open and ready to send. In Edit Mode OSC objects are opened and closed automatically by their inspectors." );
		readonly GUIContent _openOnAwakeLabel = new GUIContent( "Open On Awake", "Open this OscOut object automatically when Awake is invoked by Unity (at runtime). The setting is only accessible using the inspector in Edit Mode." );
		readonly GUIContent _multicastLoopbackLabel = new GUIContent( "Multicast Loopback", "Whether outgoing multicast messages are delivered to the sending application." );
		readonly GUIContent _bundleMessagesOnEndOfFrameLabel = new GUIContent( "Bundle Messages On End Of Frame", "Bundle all messages and send automatically at the end of the frame." );
		readonly GUIContent _settingsFoldLabel = new GUIContent( "Settings" );

		Queue<OscMessage> messageBuffer;

		const string ipAddressControlName = "OSC IP Address";
		const string portControlName = "OSC Port";
		const int messageBufferCapacity = 10;
		
		string prevControlName;
		
		string tempIPAddress;
		int tempPort;
		
		OscRemoteStatus statusInEditMode = OscRemoteStatus.Unknown;

		const float pingInterval = 1.0f; // Seconds
		const int executionOrderNum = -5000;

		IEnumerator pingEnumerator;
		DateTime lastPingTime;
		
		
		void OnEnable()
		{
			oscOut = target as OscOut;
			if( messageBuffer == null ) messageBuffer = new Queue<OscMessage>( messageBufferCapacity );

			// Get serialized properties.
			_openOnAwake = serializedObject.FindProperty("_openOnAwake");
			_ipAddress = serializedObject.FindProperty("_ipAddress");
			_port = serializedObject.FindProperty("_port");
			_multicastLoopback = serializedObject.FindProperty("_multicastLoopback");
			_bundleMessagesOnEndOfFrame = serializedObject.FindProperty("_bundleMessagesOnEndOfFrame");
			_settingsFoldout = serializedObject.FindProperty("_settingsFoldout");
			_messagesFoldout = serializedObject.FindProperty("_messagesFoldout");
			
			// Store socket info for change check workaround.
			tempIPAddress = _ipAddress.stringValue;
			tempPort = _port.intValue;
			
			// Ensure that OscOut scripts will be executed early, so that if Open On Awake is enabled the socket will open before other scripts are called.
			MonoScript script = MonoScript.FromMonoBehaviour( target as MonoBehaviour );
			if( MonoImporter.GetExecutionOrder( script ) != executionOrderNum ) MonoImporter.SetExecutionOrder( script, executionOrderNum );
			
			// When object is selected in Edit Mode then we start listening.
			if( oscOut.enabled && !Application.isPlaying && !oscOut.isOpen ){
				oscOut.Open( oscOut.port, oscOut.ipAddress );
				statusInEditMode = oscOut.mode == OscSendMode.UnicastToSelf ? OscRemoteStatus.Connected : OscRemoteStatus.Unknown;
			}
			
			// Subscribe to OSC messages
			oscOut.onAnyMessage.AddListener( OnOSCMessage );

			// If in Edit Mode, then start a coroutine that will update the connection status. Unity can't start coroutines in Runtime.
			if( !Application.isPlaying && oscOut.mode == OscSendMode.Unicast ){
				pingEnumerator = OscHelper.StartCoroutineInEditMode( PingCoroutine(), ref lastPingTime );
			}
		}
		
		
		void OnDisable()
		{
			// When object is deselected in Edit Mode then we stop listening.
			if( !Application.isPlaying && oscOut.isOpen ) oscOut.Close();
			
			// Unsubscribe from messsages.
			oscOut.onAnyMessage.RemoveListener( OnOSCMessage );
		}
		
		
		public override void OnInspectorGUI()
		{
			string currentControlName;
			bool deselect;

			// Check for key down before drawing any fields because they might consume the event.
			bool enterKeyDown = Event.current.type == EventType.keyDown && Event.current.keyCode == KeyCode.Return;
			
			// Load serialized object.
			serializedObject.Update();

			// Port field.
			EditorGUI.BeginChangeCheck();
			GUI.SetNextControlName( portControlName );
			int newPort = EditorGUILayout.IntField( _portLabel, oscOut.port );
			if( EditorGUI.EndChangeCheck() ){
				_port.intValue = newPort;
				if( oscOut.isOpen ) oscOut.Close(); // Close socket while editing
			}
			currentControlName = GUI.GetNameOfFocusedControl();
			bool enterKeyDownPort = enterKeyDown && currentControlName == portControlName;
			if( enterKeyDownPort ) UnfocusAndUpdateUI();
			deselect = prevControlName == portControlName && currentControlName != portControlName;
			if( ( deselect || enterKeyDownPort ) && !oscOut.isOpen ){
				if( oscOut.Open( _port.intValue, _ipAddress.stringValue ) ){
					tempPort = _port.intValue;
				} else {
					_port.intValue = tempPort; // Undo
					oscOut.Open( _port.intValue, _ipAddress.stringValue );
				}
			}

			// Mode field.
			EditorGUI.BeginChangeCheck();
			OscSendMode newMode = (OscSendMode) EditorGUILayout.EnumPopup( _modeLabel, oscOut.mode );
			if( EditorGUI.EndChangeCheck() && newMode != oscOut.mode ){
				switch( newMode ){
				case OscSendMode.UnicastToSelf: 	oscOut.Open( oscOut.port ); break;
				case OscSendMode.Unicast: 			oscOut.Open( oscOut.port, OscHelper.unicastAddressDefault ); break;
				case OscSendMode.Multicast:			oscOut.Open( oscOut.port, OscHelper.multicastAddressDefault ); break;
				case OscSendMode.Broadcast:			oscOut.Open( oscOut.port, IPAddress.Broadcast.ToString() ); break;
				}
				UpdateStatusInEditMode();
			}

			// IP Address field.
			EditorGUI.BeginChangeCheck();
			GUI.SetNextControlName( ipAddressControlName );
			EditorGUILayout.BeginHorizontal();
			EditorGUILayout.PrefixLabel( _ipAdrressLabel );
			string newIp = EditorGUILayout.TextField( oscOut.ipAddress ); // Field
			if( EditorGUI.EndChangeCheck() ){
				System.Net.IPAddress ip;
				if( System.Net.IPAddress.TryParse( newIp, out ip ) ) _ipAddress.stringValue = newIp; // Accept only valid ip addresses
				if( oscOut.isOpen ) oscOut.Close(); // Close socket while editing
				if( !Application.isPlaying ){
					if( pingEnumerator != null ) pingEnumerator = null; // Don't update ping coroutine while editing
					if( statusInEditMode != OscRemoteStatus.Unknown ) statusInEditMode = OscRemoteStatus.Unknown;
				}
			}
			GUILayout.FlexibleSpace();
			Rect rect = GUILayoutUtility.GetRect( 16, 5 );
			rect.width = 5;
			rect.x += 3;
			rect.y += 7;
			OscRemoteStatus status = Application.isPlaying ? oscOut.remoteStatus : statusInEditMode;
			EditorGUI.DrawRect( rect, StatusToColor( status ) );
			EditorGUILayout.EndHorizontal();
			GUILayoutUtility.GetRect( 1, 2 ); // vertical spacing
			currentControlName = GUI.GetNameOfFocusedControl();
			bool enterKeyDownIp = enterKeyDown && currentControlName == ipAddressControlName;
			if( enterKeyDownIp ) UnfocusAndUpdateUI();
			deselect = prevControlName == ipAddressControlName && currentControlName != ipAddressControlName;

			if( ( deselect || enterKeyDownIp ) && !oscOut.isOpen ){ // All this mess to check for end edit, OMG!!! Not cool.
				if( oscOut.Open( _port.intValue, _ipAddress.stringValue ) ){
					tempIPAddress = _ipAddress.stringValue;
					UpdateStatusInEditMode();
				} else {
					_ipAddress.stringValue = tempIPAddress; // Undo
				}
			}
			
			// Is Open field.
			EditorGUI.BeginDisabledGroup( true );
			EditorGUILayout.Toggle( _isOpenLabel, oscOut.isOpen );
			EditorGUI.EndDisabledGroup();

			// Open On Awake field.
			EditorGUI.BeginDisabledGroup( Application.isPlaying );
			EditorGUILayout.PropertyField( _openOnAwake, _openOnAwakeLabel );
			EditorGUI.EndDisabledGroup();

			EditorGUI.indentLevel++;

			// Settings ...
			_settingsFoldout.boolValue = EditorGUILayout.Foldout( _settingsFoldout.boolValue, _settingsFoldLabel );
			if( _settingsFoldout.boolValue )
			{
				// Multicast loopback field.
				EditorGUILayout.BeginHorizontal();
				EditorGUILayout.LabelField( _multicastLoopbackLabel, GUILayout.Width( 150 ) );
				GUILayout.FlexibleSpace();
				EditorGUI.BeginChangeCheck();
				_multicastLoopback.boolValue = EditorGUILayout.Toggle( _multicastLoopback.boolValue, GUILayout.Width( 30 ) );
				if( EditorGUI.EndChangeCheck() && oscOut.mode == OscSendMode.Multicast ) oscOut.multicastLoopback = _multicastLoopback.boolValue;
				EditorGUILayout.EndHorizontal();

				// Bundle Messages On End Of Frame field.
				BoolSettingsField( _bundleMessagesOnEndOfFrame, _bundleMessagesOnEndOfFrameLabel );
			}

			// Messages ...
			EditorGUI.BeginDisabledGroup( !oscOut.isOpen );
			GUIContent messagesFoldContent = new GUIContent( "Messages (" + oscOut.messageCount + ")", "Messages received since last update" );
			_messagesFoldout.boolValue = EditorGUILayout.Foldout( _messagesFoldout.boolValue, messagesFoldContent );
			if( _messagesFoldout.boolValue ){
				OscMessage[] messages = messageBuffer.ToArray();
				StringBuilder messagesText = new StringBuilder();
				for( int m=messages.Length-1; m>=0; m-- ) messagesText.Append( ( m != messages.Length-1 ? Environment.NewLine : "" ) + messages[m].ToString() );
				EditorGUILayout.HelpBox( messagesText.ToString(), MessageType.None );
			}
			EditorGUI.EndDisabledGroup();

			EditorGUI.indentLevel--;

			// Apply
			serializedObject.ApplyModifiedProperties();
			
			// Request OnInspectorGUI to be called every frame as long as inspector is active
			EditorUtility.SetDirty( target );
			
			// Update ping coroutine manually in Edit Mode. (Unity does not run coroutines in Edit Mode)
			if( !Application.isPlaying && pingEnumerator != null ) OscHelper.UpdateCoroutineInEditMode( pingEnumerator, ref lastPingTime );

			// Store name of focused control to detect unfocus events
			prevControlName = GUI.GetNameOfFocusedControl();
		}


		void UpdateStatusInEditMode()
		{
			switch( oscOut.mode ){
			case OscSendMode.UnicastToSelf:
				statusInEditMode = OscRemoteStatus.Connected;
				pingEnumerator = null;
				break;
			case OscSendMode.Unicast:
				statusInEditMode = OscRemoteStatus.Unknown;
				if( !Application.isPlaying ) pingEnumerator = OscHelper.StartCoroutineInEditMode( PingCoroutine(), ref lastPingTime );
				break;
			case OscSendMode.Multicast:
				statusInEditMode = OscRemoteStatus.Unknown;
				pingEnumerator = null;
				break;
			case OscSendMode.Broadcast:
				statusInEditMode = OscRemoteStatus.Unknown;
				pingEnumerator = null;
				break;
			}
		}


		void BoolSettingsField( SerializedProperty prop, GUIContent label )
		{
			EditorGUILayout.BeginHorizontal();
			EditorGUILayout.LabelField( label, GUILayout.Width( 220 ) );
			GUILayout.FlexibleSpace();
			prop.boolValue = EditorGUILayout.Toggle( prop.boolValue, GUILayout.Width( 30 ) );
			EditorGUILayout.EndHorizontal();
		}


		void UnfocusAndUpdateUI()
		{
			GUI.FocusControl("");
			EditorUtility.SetDirty( target );
		}
		
		
		void OnOSCMessage( OscMessage message )
		{
			if( messageBuffer.Count >= messageBufferCapacity ) messageBuffer.Dequeue();
			messageBuffer.Enqueue( message );
		}


		Color StatusToColor( OscRemoteStatus status )
		{
			switch( status )
			{
			case OscRemoteStatus.Unknown: return Color.yellow;
			case OscRemoteStatus.Connected: return Color.green;
			case OscRemoteStatus.Disconnected: return Color.red;
			default: return Color.gray;
			}
		}
		

		// This coroutine is only run in Edit Mode.
		IEnumerator PingCoroutine()
		{
			while( true )
			{
				Ping ping = new Ping( oscOut.ipAddress );
				yield return new WaitForSeconds( pingInterval );
				//Debug.Log( "Ping time " + ping.time );
				statusInEditMode = ( ping.isDone && ping.time >= 0 ) ? OscRemoteStatus.Connected : OscRemoteStatus.Disconnected;
			}
		}
	}
}