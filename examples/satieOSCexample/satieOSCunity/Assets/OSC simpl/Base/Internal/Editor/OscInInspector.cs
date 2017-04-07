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

namespace OscSimpl
{
	[CanEditMultipleObjects]
	[CustomEditor(typeof(OscIn))]
	public class OscInInspector : Editor
	{
		OscIn oscIn;
		
		SerializedProperty _openOnAwake;
		SerializedProperty _port;
		SerializedProperty _mode;
		SerializedProperty _multicastAddress;
		SerializedProperty _filterDuplicates;
		SerializedProperty _addTimeTagsToBundledMessages;
		SerializedProperty _mappings;
		SerializedProperty _dirtyMappings;
		SerializedProperty _settingsFoldout;
		SerializedProperty _mappingsFoldout;
		SerializedProperty _messagesFoldout;
		
		readonly GUIContent _portLabel = new GUIContent( "Port", "Receiving Port for this computer." );
		readonly GUIContent _modeLabel = new GUIContent( "Receive Mode", "Transmission mode." );
		readonly GUIContent _ipAddressLabel = new GUIContent( "Local IP Address", "IP Address for this computer." );
		readonly GUIContent _multicastIpAddressLabel = new GUIContent( "Multicast Address", "Multicast group address. Valid range 224.0.0.0 to 239.255.255.255." );
		readonly GUIContent _isOpenLabel = new GUIContent( "Is Open", "Indicates whether this OscIn object is open and ready to receive. In Edit Mode OSC objects are opened and closed automatically by their inspectors" );
		readonly GUIContent _openOnAwakeLabel = new GUIContent( "Open On Awake", "Open this Oscin object automatically when Awake is invoked by Unity (at runtime). The setting is only accessible using the inspector in Edit Mode." );
		readonly GUIContent _filterDuplicatesLabel = new GUIContent( "Filter Duplicates", "Forward only one message per OSC address every Update call. Use the last message received." );
		readonly GUIContent _addTimeTagsToBundledMessagesLabel = new GUIContent( "Add Time Tags To Bundled Messages", "When enabled, timetags from bundles are added to contained messages as last argument." );
		readonly GUIContent _addMappingButtonLabel = new GUIContent( "Add" );
		readonly GUIContent _removeMappingButtonLabel = new GUIContent( "X" );
		readonly GUIContent _settingsFoldLabel = new GUIContent( "Settings" );
		
		const string portControlName = "OSC Port";
		const string multicastAddressControlName = "OSC Multicast Ip Address";
		const int messageBufferCapacity = 10;

		string prevControlName;
		
		int tempPort;
		string tempMulticastAddress;
		
		Queue<OscMessage> messageBuffer;
		
		
		void OnEnable()
		{
			oscIn = target as OscIn;

			messageBuffer = new Queue<OscMessage>( messageBufferCapacity );
			
			_openOnAwake = serializedObject.FindProperty("_openOnAwake");
			_port = serializedObject.FindProperty("_port");
			_mode = serializedObject.FindProperty("_mode");
			_multicastAddress = serializedObject.FindProperty("_multicastAddress");
			_filterDuplicates = serializedObject.FindProperty("_filterDuplicates");
			_addTimeTagsToBundledMessages = serializedObject.FindProperty("_addTimeTagsToBundledMessages");
			_mappings = serializedObject.FindProperty("_mappings");
			_dirtyMappings = serializedObject.FindProperty("_dirtyMappings");
			_settingsFoldout = serializedObject.FindProperty("_settingsFoldout");
			_mappingsFoldout = serializedObject.FindProperty("_mappingsFoldout");
			_messagesFoldout = serializedObject.FindProperty("_messagesFoldout");
			
			// Store socket info for change check workaround
			tempPort = _port.intValue;
			tempMulticastAddress = _multicastAddress.stringValue;
			
			// Ensure that OscIn scripts will be executed early, so it can deliver messages before we compute anything.
			MonoScript script = MonoScript.FromMonoBehaviour( target as MonoBehaviour );
			if( MonoImporter.GetExecutionOrder( script ) != -5000 ) MonoImporter.SetExecutionOrder( script, -5000 );
			
			// When object is selected in Edit Mode then we start listening
			if( oscIn.enabled && !Application.isPlaying && !oscIn.isOpen ){
				if( oscIn.mode == OscReceiveMode.UnicastBroadcast ) oscIn.Open( oscIn.port );
				else oscIn.Open( oscIn.port, oscIn.multicastAddress );
			}
			
			// Subscribe to messages
			oscIn.onAnyMessage.AddListener( OnOSCMessage );
		}
		
		
		void OnDisable()
		{
			// When object is deselected in Edit Mode then we stop listening
			if( !Application.isPlaying && oscIn.isOpen ) oscIn.Close();
			
			// Unsubscribe from messsages
			oscIn.onAnyMessage.RemoveListener( OnOSCMessage );
		}
		
		
		public override void OnInspectorGUI()
		{
			string currentControlName;

			Color boxColor = EditorGUIUtility.isProSkin ? new Color( 1, 1, 1, 0.07f ) : new Color( 1, 1, 1, 0.35f );

			// Check for key down before drawing any fields because they might consume the event.
			bool enterKeyDown = Event.current.type == EventType.keyDown && Event.current.keyCode == KeyCode.Return;
			
			// Load serialized object
			serializedObject.Update();

			// Port field
			EditorGUI.BeginChangeCheck();
			GUI.SetNextControlName( portControlName );
			int newPort = EditorGUILayout.IntField( _portLabel, oscIn.port );
			if( EditorGUI.EndChangeCheck() ){
				_port.intValue = newPort;
				if( oscIn.isOpen ) oscIn.Close(); // Close UDPReceiver while editing
			}
			currentControlName = GUI.GetNameOfFocusedControl();
			bool enterKeyDownPort = enterKeyDown && currentControlName == portControlName;
			if( enterKeyDownPort ) UnfocusAndUpdateUI();
			bool deselect = prevControlName == portControlName && currentControlName != portControlName;
			if( ( deselect || enterKeyDownPort ) && !oscIn.isOpen ){
				if( oscIn.Open( _port.intValue ) ){
					tempPort = _port.intValue;
				} else {
					_port.intValue = tempPort; // undo
					oscIn.Open( _port.intValue );
				}
			}
				
			// Mode field
			EditorGUI.BeginChangeCheck();
			EditorGUILayout.PropertyField( _mode, _modeLabel );
			if( EditorGUI.EndChangeCheck() ){
				switch( (OscReceiveMode) _mode.enumValueIndex ){
				case OscReceiveMode.UnicastBroadcast:			oscIn.Open( oscIn.port ); break;
				case OscReceiveMode.UnicastBroadcastMulticast:	oscIn.Open( oscIn.port, oscIn.multicastAddress ); break; }
			}

			// Multicast field
			if( oscIn.mode == OscReceiveMode.UnicastBroadcastMulticast )
			{
				EditorGUI.BeginChangeCheck();
				GUI.SetNextControlName( multicastAddressControlName );
				EditorGUILayout.PropertyField( _multicastAddress, _multicastIpAddressLabel );
				if( EditorGUI.EndChangeCheck() ){
					if( oscIn.isOpen ) oscIn.Close(); // Close socket while editing
				}
				currentControlName = GUI.GetNameOfFocusedControl();
				bool enterKeyDownMulticastIpAddress = enterKeyDown && currentControlName == multicastAddressControlName;
				if( enterKeyDownMulticastIpAddress ) UnfocusAndUpdateUI();
				deselect = prevControlName == multicastAddressControlName && currentControlName != multicastAddressControlName;
				if( ( deselect || enterKeyDownMulticastIpAddress ) && !oscIn.isOpen ){
					if( oscIn.Open( _port.intValue, _multicastAddress.stringValue ) ){
						tempMulticastAddress = _multicastAddress.stringValue;
					} else {
						_multicastAddress.stringValue = tempMulticastAddress; // undo
						oscIn.Open( _port.intValue, _multicastAddress.stringValue );
					}
				}
			}



			// IP Address field
			EditorGUILayout.BeginHorizontal();
			string ipAddressString = OscIn.ipAddress.ToString();
			EditorGUI.BeginDisabledGroup( string.IsNullOrEmpty( ipAddressString ) );
			EditorGUILayout.PrefixLabel( _ipAddressLabel );
			EditorGUILayout.LabelField( " " );
			Rect rect = GUILayoutUtility.GetLastRect(); // UI voodoo to position the selectable label perfectly
			if( string.IsNullOrEmpty( ipAddressString ) ) EditorGUI.LabelField( rect, "Not found" );
			else EditorGUI.SelectableLabel( rect, ipAddressString );
			EditorGUI.EndDisabledGroup();
			EditorGUILayout.EndHorizontal();

			// Is Open field
			EditorGUI.BeginDisabledGroup( true );
			EditorGUILayout.Toggle( _isOpenLabel, oscIn.isOpen );
			EditorGUI.EndDisabledGroup();

			// Open On Awake field
			EditorGUI.BeginDisabledGroup( Application.isPlaying );
			EditorGUILayout.PropertyField( _openOnAwake, _openOnAwakeLabel );
			EditorGUI.EndDisabledGroup();

			EditorGUI.indentLevel++;

			// Settings ...
			_settingsFoldout.boolValue = EditorGUILayout.Foldout( _settingsFoldout.boolValue, _settingsFoldLabel );

			if( _settingsFoldout.boolValue )
			{
				// Filter Duplicates field
				BoolSettingsField( _filterDuplicates, _filterDuplicatesLabel );

				// Add Time Tags To Bundled Messages FIeld
				BoolSettingsField( _addTimeTagsToBundledMessages, _addTimeTagsToBundledMessagesLabel );
			}

			// Mappings ...
			string mappingsFoldLabel = "Mappings (" + _mappings.arraySize + ")";
			_mappingsFoldout.boolValue = EditorGUILayout.Foldout( _mappingsFoldout.boolValue, mappingsFoldLabel );
			if( _mappingsFoldout.boolValue )
			{
				// Mapping elements ..
				int removeIndexRequsted = -1;

				for( int m=0; m<_mappings.arraySize; m++ )
				{
					SerializedProperty mapping = _mappings.GetArrayElementAtIndex( m );

					// Background rect
					rect = GUILayoutUtility.GetLastRect();
					rect.yMin = rect.yMax + 2;
					rect.xMin += 16;
					rect.height = EditorGUI.GetPropertyHeight( mapping ) - OscMappingDrawer.bottomMargin;
					EditorGUI.DrawRect( rect, boxColor );

					// Mapping field (using costum property drawer)
					EditorGUI.BeginChangeCheck();
					EditorGUILayout.PropertyField( mapping, true );
					if( EditorGUI.EndChangeCheck() ){
						SerializedProperty address = mapping.FindPropertyRelative( "address" );
						address.stringValue = GetSanitizedAndUniqueAddress( _mappings, m, address.stringValue );
						_dirtyMappings.boolValue = true;
					}
					
					// Remove mapping button
					rect = EditorGUI.IndentedRect( GUILayoutUtility.GetLastRect() );
					rect.x = rect.x + rect.width - OscMappingDrawer.removeButtonWidth - OscMappingDrawer.fieldPaddingHorisontal;
					rect.y += OscMappingDrawer.drawerPaddingTop;
					rect.width = OscMappingDrawer.removeButtonWidth;
					rect.height = OscMappingDrawer.fieldHeight - 1;
					if( GUI.Button( rect, _removeMappingButtonLabel ) ) removeIndexRequsted = m;
				}
				
				// Handle mapping removal ..
				if( removeIndexRequsted != -1 ){
					_mappings.DeleteArrayElementAtIndex( removeIndexRequsted );
					_dirtyMappings.boolValue = true;
				}
				
				// Add mapping button
				rect = EditorGUI.IndentedRect( GUILayoutUtility.GetRect( 20, 30 ) );
				if( GUI.Button( rect, _addMappingButtonLabel ) ){
					_mappings.InsertArrayElementAtIndex( _mappings.arraySize );
					SerializedProperty mapping = _mappings.GetArrayElementAtIndex( _mappings.arraySize-1 );
					SerializedProperty address = mapping.FindPropertyRelative( "address" );
					address.stringValue = GetSanitizedAndUniqueAddress( _mappings, -1, address.stringValue );
					_dirtyMappings.boolValue = true;
				}
				EditorGUILayout.Space();
			}
			
			// Messages foldout
			GUIContent messagesFoldContent = new GUIContent( "Messages (" + oscIn.messageCount + ")", "Messages received since last update" );
			_messagesFoldout.boolValue = EditorGUILayout.Foldout( _messagesFoldout.boolValue, messagesFoldContent );
			if( _messagesFoldout.boolValue ){
				OscMessage[] messages = messageBuffer.ToArray();
				StringBuilder messagesText = new StringBuilder();
				for( int m=messages.Length-1; m>=0; m-- ) messagesText.Append( ( m != messages.Length-1 ? Environment.NewLine : "" ) + messages[m].ToString() );
				EditorGUILayout.HelpBox( messagesText.ToString(), MessageType.None );
			}
			
			EditorGUI.indentLevel--;


			
			// Apply
			serializedObject.ApplyModifiedProperties();
			
			// Request OnInspectorGUI to be called every frame as long as inspector is active
			EditorUtility.SetDirty( target );

			// Store name of focused control to detect unfocus events
			prevControlName = GUI.GetNameOfFocusedControl();
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
			GUI.FocusControl ("");
			EditorUtility.SetDirty( target );
		}
		
		
		void OnOSCMessage( OscMessage message )
		{
			if( messageBuffer.Count >= messageBufferCapacity ) messageBuffer.Dequeue();
			messageBuffer.Enqueue( message );
		}


		string GetSanitizedAndUniqueAddress( SerializedProperty mappingsProp, int mappingIndex, string address )
		{
			// Sanitize
			if( address.Length == 0 || address[0] != '/' ) address = "/" + address;
			if( address.Length == 1 ) address += "1";
			if( address.Length > 1 && address[address.Length-1] == '/' ) address = address.Substring( 0, address.Length-1 );
			address = address.Replace( " ", "" );

			// Gather all addresses, excluding the one from the mapping we are messing with (if any).
			List<string> addresses = new List<string>();
			for( int m = 0; m < mappingsProp.arraySize; m++ ){
				if( m != mappingIndex ){
					addresses.Add( mappingsProp.GetArrayElementAtIndex( m ).FindPropertyRelative("address").stringValue );
				}
			}
				
			// Make unique
			if( !addresses.Contains( address ) ) return address;
			string addressWithoutNumber = address.TrimEnd( new char[]{ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' } );
			for( int i=1; ; i++ )
			{
				string candidateAddress = addressWithoutNumber + i;
				if( !addresses.Contains( candidateAddress ) ) return candidateAddress;
			}
		}
	}
}