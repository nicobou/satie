/*
	Created by Carl Emil Carlsen.
	Copyright 2016 Sixth Sensor.
	All rights reserved.
	http://sixthsensor.dk
*/

using UnityEngine;
using UnityEngine.Events;
using System;
using System.Collections.Generic;
using System.Net;
using System.Text.RegularExpressions;
using System.Net.Sockets;
using OscSimpl;

#pragma warning disable 169 // Don't complain over editor foldout flags (_settingsFoldout etc.)

/// <summary>
/// MonoBehaviour for receiving OscMessage objects.
/// </summary>

[ExecuteInEditMode]
public class OscIn : MonoBehaviour
{
	/// <summary>
	/// Gets the local port that this application is set to listen to. (read only).
	/// To set, call the Open method.
	/// </summary>
	public int port { get { return _port; } }
	[SerializeField] int _port = 7000;

	/// <summary>
	/// Gets the transmission mode (read only). Can either be UnicastBroadcast or Multicast.
	/// The mode is automatically derived from arguments passed to the Open method.
	/// </summary>
	public OscReceiveMode mode {
		get { return _mode; }
	}
	[SerializeField] OscReceiveMode _mode = OscReceiveMode.UnicastBroadcast;

	/// <summary>
	/// Gets the remote address to the multicast group that this application is set to listen to (read only).
	/// To set, call the Open method and provide a valid multicast address.
	/// </summary>
	public string multicastAddress {
		get { return _multicastAddress; }
	}
	[SerializeField] string _multicastAddress = OscHelper.multicastAddressDefault;

	/// <summary>
	/// Gets the local network IP address for this device (read only).
	/// Returns an empty string if the address is not available. In that case
	/// ensure that your device is connected to a network. Using a VPN may 
	/// block you from getting the local IP.
	/// </summary>
	public static string ipAddress {
		get {
			string address = Network.player.ipAddress;
			if( address == IPAddress.Any.ToString() ) return IPAddress.Loopback.ToString();
			return address;
		}
	}

	/// <summary>
	/// Indicates whether the Open method has been called and the object is ready to receive.
	/// </summary>
	public bool isOpen {
		get { return _udpClient != null && _isReceiving; }
	}

	/// <summary>
	/// When enabled, only one message per OSC address will be forwarded every Update call.
	/// The last (newest) message received will be used. Default is true.
	/// </summary>
	public bool filterDuplicates {
		get { return _filterDuplicates; }
		set { _filterDuplicates = value; }
	}
	[SerializeField] bool _filterDuplicates = true;

	/// <summary>
	/// When enabled, timetags from bundles are added to contained messages as last argument.
	/// Incoming bundles are never exposed, so if you want to access a time tag from a incoming bundle then enable this.
	/// Default is false.
	/// </summary>
	public bool addTimeTagsToBundledMessages {
		get { lock( _lock ) return _addTimeTagsToBundledMessages; }
		set { lock( _lock ) _addTimeTagsToBundledMessages = value; }
	}
	[SerializeField] bool _addTimeTagsToBundledMessages = false;

	/// <summary>
	/// Gets the number of messages received since last update.
	/// </summary>
	public int messageCount {
		get { return _messageCount; }
	}
	int _messageCount = 0;

	/// <summary>
	/// Add listener to this event to receive a call when any OscMessage is received on
	/// the specified port.
	/// The event is influenced by the state of 'filterDuplicates' property.
	/// </summary>
	public OscMessageEvent onAnyMessage {
		get { return _onAnyMessage; }
	}
	OscMessageEvent _onAnyMessage = new OscMessageEvent();

	// Indicates whether Open should be called automatically on Awake. Set only using the inspector.
	[SerializeField] bool _openOnAwake = false;

	// Flag for requesting update of '_mappingLookup'
	[SerializeField] bool _dirtyMappings = true;

	// Objects for receiving
	System.Object _lock = new System.Object();
	Dictionary<string,List<OscMessage>> _messages = new Dictionary<string,List<OscMessage>>();
	List<string> deadAddresses = new List<string>();
	[SerializeField] List<OscMapping> _mappings = new List<OscMapping>();
	Dictionary<string,OscMapping> _mappingLookup; // for faster lookup, to avoid using _mappings.Find.
	Queue<OscMessage> invokeUnmappedQueue;
	Queue<KeyValuePair<OscMapping,OscMessage>> invokeMappedQueue;

	// Flag to check if we should open socket OnEnable
	bool wasClosedOnDisable;

	// For the inspector
	[SerializeField] bool _settingsFoldout;
	[SerializeField] bool _mappingsFoldout;
	[SerializeField] bool _messagesFoldout;


	#region Udp

	volatile bool _isReceiving;
	UdpClient _udpClient;
	AsyncCallback _callback;

	// Needed for Async UdpClient receive 
	class UdpState
	{
		public IPEndPoint e;
		public UdpClient u;

		public UdpState( IPEndPoint ipEndPoint, UdpClient client ){
			e = ipEndPoint;
			u = client;
		}
	}

	#endregion


	#region Unity Methods

	void Awake()
	{
		if( _openOnAwake && enabled && Application.isPlaying && !isOpen ){
			if( _mode == OscReceiveMode.UnicastBroadcast ) Open( _port );
			else Open( _port, _multicastAddress );
		}
		_dirtyMappings = true;
	}


	void OnEnable()
	{
		if( wasClosedOnDisable && Application.isPlaying && !isOpen ){
			if( _mode == OscReceiveMode.UnicastBroadcast ) Open( _port );
			else Open( _port, _multicastAddress );
		}
	}


	void OnDisable()
	{
		if( Application.isPlaying && isOpen )
		{
			Close();
			wasClosedOnDisable = true;
		}
	}


	void Update()
	{
		if( _mappings == null ) return;

		if( !isOpen ) return;

		if( _mappingLookup == null || _dirtyMappings ) UpdateMappings();

		if( invokeUnmappedQueue == null ) invokeUnmappedQueue = new Queue<OscMessage>();
		if( invokeMappedQueue == null ) invokeMappedQueue = new Queue<KeyValuePair<OscMapping,OscMessage>>();
		deadAddresses.Clear();

		// Lock while we mess with '_messages'
		lock( _lock )
		{
			foreach( KeyValuePair<string,List<OscMessage>> pair in _messages )
			{
				List<OscMessage> groupedMessages = pair.Value;
				int gmCount = groupedMessages.Count;

				// Collect the dead
				if( gmCount == 0 ){
					deadAddresses.Add( pair.Key );
					continue;
				}

				// Get messages and invoke mapped handlers
				int gmBegin = _filterDuplicates ? gmCount-1 : 0;
				for( int gm=gmBegin; gm<gmCount; gm++ )
				{
					OscMessage message = groupedMessages[gm];
					OscMapping mapping;
					if( _mappingLookup.TryGetValue( message.address, out mapping ) )
					{
						// Enqueue mapped call
						invokeMappedQueue.Enqueue( new KeyValuePair<OscMapping,OscMessage>( mapping, message ) );
					} else {
						// Enqueue unmapped (catch all) call
						invokeUnmappedQueue.Enqueue( message );
					}
				}

				// Clear address group
				groupedMessages.Clear();
			}

			// Remove the dead
			foreach( string address in deadAddresses ) _messages.Remove( address );
		}

		// Count
		_messageCount = invokeUnmappedQueue.Count + invokeMappedQueue.Count;

		// Invoke handlers outside lock
		while( invokeUnmappedQueue.Count > 0 ) _onAnyMessage.Invoke( invokeUnmappedQueue.Dequeue() );
		while( invokeMappedQueue.Count > 0 )
		{
			KeyValuePair<OscMapping,OscMessage> pair = invokeMappedQueue.Dequeue();
			OscMapping mapping = pair.Key;
			OscMessage message = pair.Value;

			_onAnyMessage.Invoke( message );

			switch( mapping.type )
			{
			case OscMessageType.OscMessage:
				mapping.OscMessageHandler.Invoke( message );
				break;
			case OscMessageType.Float:
				float floatValue;
				if( message.TryGet( 0, out floatValue ) ) mapping.FloatHandler.Invoke( floatValue );
				break;
			case OscMessageType.Double:
				double doubleValue;
				if( message.TryGet( 0, out doubleValue ) ) mapping.DoubleHandler.Invoke( doubleValue );
				break;
			case OscMessageType.Int:
				int intValue;
				if( message.TryGet( 0, out intValue ) ) mapping.IntHandler.Invoke( intValue );
				break;
			case OscMessageType.Long:
				long longValue;
				if( message.TryGet( 0, out longValue ) ) mapping.LongHandler.Invoke( longValue );
				break;
			case OscMessageType.String:
				string stringValue;
				if( message.TryGet( 0, out stringValue ) ) mapping.StringHandler.Invoke( stringValue );
				break;
			case OscMessageType.Char:
				char charValue;
				if( message.TryGet( 0, out charValue ) ) mapping.CharHandler.Invoke( charValue );
				break;
			case OscMessageType.Bool:
				bool boolValue;
				if( message.TryGet( 0, out boolValue ) ) mapping.BoolHandler.Invoke( boolValue );
				break;
			case OscMessageType.Color:
				Color32 colorValue;
				if( message.TryGet( 0, out colorValue ) ) mapping.ColorHandler.Invoke( colorValue );
				break;
			case OscMessageType.Blob:
				byte[] blobValue;
				if( message.TryGet( 0, out blobValue ) ) mapping.BlobHandler.Invoke( blobValue );
				break;
			case OscMessageType.TimeTag:
				OscTimeTag timeTagValue;
				if( message.TryGet( 0, out timeTagValue ) ) mapping.TimeTagHandler.Invoke( timeTagValue );
				break;
			case OscMessageType.ImpulseNullEmpty:
				mapping.ImpulseNullEmptyHandler.Invoke();
				break;
			}
		}
	}


	void OnDestroy()
	{
		Close();

		// Forget all mappings.
		_onAnyMessage.RemoveAllListeners();
		foreach( OscMapping mapping in _mappings ) mapping.Clear();
	}


	#endregion


	#region Udp Management

	/// <summary>
	/// Open to receive messages on specified port and (optionally) from specified multicast IP address.
	/// Returns success status.
	/// </summary>
	public bool Open( int port, string multicastAddress = "" )
	{
		// Close and garbage existing receiver
		if( _udpClient != null ) Close();

		// Validate port number range
		if( port < OscHelper.portMin || port > OscHelper.portMax ){
			Debug.LogWarning( "<b>[OscIn]</b> Open failed. Port " + port + " is out of range." + Environment.NewLine );
			return false;
		}
		_port = port;

		// Derive mode from multicastAddress
		if( !string.IsNullOrEmpty( multicastAddress ) ){
			if( Regex.IsMatch( multicastAddress, OscHelper.multicastAddressPattern ) ){
				_mode = OscReceiveMode.UnicastBroadcastMulticast;
				_multicastAddress = multicastAddress;
			} else {
				Debug.LogWarning( "<b>[OscIn]</b> Open failed. Multicast IP address " + multicastAddress + " is out not valid. It must be in range 224.0.0.0 to 239.255.255.255." + Environment.NewLine );
				return false;
			}
		} else {
			_mode = OscReceiveMode.UnicastBroadcast;
		}

		// Attempt to open socket
		try {
			_udpClient = new UdpClient();

			// Ensure that we can have multiple OscIn objects listening to the same port. Must be set before bind.
			// Note that only one OscIn object will receive the packet anyway: http://stackoverflow.com/questions/22810511/bind-multiple-listener-to-the-same-port
			_udpClient.ExclusiveAddressUse = false;
			_udpClient.Client.SetSocketOption( SocketOptionLevel.Socket, SocketOptionName.ReuseAddress, true );

			// Bind the socket to the endpoint
			IPEndPoint ipEndPoint = new IPEndPoint( IPAddress.Any, port );
			_udpClient.Client.Bind( ipEndPoint );

			// Join multicast group if in multicast mode
			if( _mode == OscReceiveMode.UnicastBroadcastMulticast ){
				IPAddress multicastIp = IPAddress.Parse( _multicastAddress );
				_udpClient.JoinMulticastGroup( multicastIp, OscHelper.timeToLiveMax );
			}

			// Begin recieve
			UdpState udpState = new UdpState( ipEndPoint, _udpClient );
			_callback = new AsyncCallback( EndReceive );
			_isReceiving = true;
			_udpClient.BeginReceive( _callback, udpState );

		} catch( Exception e ){
			// Socket error reference: https://msdn.microsoft.com/en-us/library/windows/desktop/ms740668(v=vs.85).aspx

			if( e is SocketException && ( e as SocketException ).ErrorCode == 10048 ){ // "Address already in use"
				Debug.LogWarning( "<b>[OscIn]</b> Could not open port " + _port + " because another application is listening on it." + Environment.NewLine );

			} else if( e is SocketException && _mode == OscReceiveMode.UnicastBroadcastMulticast ) {
				Debug.LogWarning( "<b>[OscIn]</b> Could not subscribe to multicast group. Perhaps you are offline, or your router is not multicast enabled." + Environment.NewLine + (e as SocketException).ErrorCode + ": " + e.ToString() );
			
			} else if( e.Data is ArgumentOutOfRangeException ){
				Debug.LogWarning( string.Format( "[OscIn] Could not open port {0}. Invalid Port Number.\n{1}", _port, e.ToString() ) );

			} else {
				//Debug.Log( e );
			}

			Close();
			return false;
		}

		// Deal with the success
		if( Application.isPlaying ){
			string logString;
			if( _mode == OscReceiveMode.UnicastBroadcast ) logString = "[OscIn] Listening for unicast and broadcast messages on port " + _port + Environment.NewLine;
			else logString = "<b>[OscIn]</b> Listening for multicast messages on address " + _multicastAddress + ", unicast and broadcast messages on port " + _port + Environment.NewLine;
			//logString += "Buffer size: " + _udpClient.Client.ReceiveBufferSize + " bytes. " + Environment.NewLine;
			Debug.Log( logString );
		}
		_port = port;
		return true;
	}


	void EndReceive( IAsyncResult asyncResult )
	{
		if( !_isReceiving ) return;

		try
		{
			UdpState udpState = (UdpState) asyncResult.AsyncState;
			IPEndPoint endPoint = udpState.e;
			UdpClient udpClient = udpState.u;

			// TODO will this contain the souce of the datagram?
			//Debug.Log( endPoint.Address + "  " + endPoint.Port );

			// Get the data
			byte[] data = udpClient.EndReceive( asyncResult, ref endPoint );

			// Begin receiving again
			udpClient.BeginReceive( _callback, udpState );

			// Parse packet and forward  it
			if( data != null && data.Length > 0 )
			{
				OscPacket packet;
				if( OscPacket.FromBytes( data, out packet ) ) OnOscPacketReceived( packet );
			} else {
				// Ignore
			}

		} catch( Exception e ){
			if( e is ObjectDisposedException ){
				// Ignore.
			} else {
				Debug.LogWarning( "[OscIn] Error occurred while receiving message." + Environment.NewLine + e.ToString() );
			}
		}
	}


	/// <summary>
	/// Close and stop receiving messages.
	/// </summary>
	public void Close()
	{
		_isReceiving = false;

		if( _udpClient != null )
		{
			if( _mode == OscReceiveMode.UnicastBroadcastMulticast && !string.IsNullOrEmpty( _multicastAddress ) ){
				IPAddress multicastIp = IPAddress.Parse( _multicastAddress );
				try {
					_udpClient.DropMulticastGroup( multicastIp ); // not sure if this is necessary, Close() might do the job.
				} catch {
					// Ignore
				}
			}
			_udpClient.Close();
			_udpClient = null; // important for garbage collection
		}

		lock( _lock ) _messages.Clear();

		wasClosedOnDisable = false;
	}


	void OnOscPacketReceived( OscPacket packet )
	{
		lock( _lock ){
			if( packet is OscMessage ) EnqueueMessage( packet as OscMessage );
			else EnqueueMessagesInBundle( packet as OscBundle );
		}
	}


	void EnqueueMessage( OscMessage message )
	{
		List<OscMessage> groupedMessages;
		if( !_messages.TryGetValue( message.address, out groupedMessages ) ){
			groupedMessages = new List<OscMessage>();
			_messages.Add( message.address, groupedMessages );
		}

		if( _filterDuplicates && groupedMessages.Count > 0 ) groupedMessages.Clear();
			
		groupedMessages.Add( message );
	}


	void EnqueueMessagesInBundle( OscBundle bundle )
	{
		foreach( OscPacket packet in bundle.packets ){
			if( packet is OscMessage ){
				OscMessage message = packet as OscMessage;
				if( _addTimeTagsToBundledMessages ) message.args.Add( bundle.timeTag );
				EnqueueMessage( message );
			} else {
				// Call recursively until all messages have been unpacked
				EnqueueMessagesInBundle( packet as OscBundle );
			}
		}
	}


	#endregion


	#region Mapping

	/// <summary>
	/// Request that incoming messages with OSC 'address' are forwarded to 'method'.
	/// </summary>
	public void Map( string address, UnityAction<OscMessage> method ){ Map<OscMessage>( address, method, OscMessageType.OscMessage ); }

	/// <summary>
	/// Request that float type argument is extracted from incoming messages with OSC 'address' and forwarded to 'method'.
	/// </summary>
	public void MapFloat( string address, UnityAction<float> method ){ Map<float>( address, method, OscMessageType.Float ); }

	/// <summary>
	/// Same as above, for double type.
	/// </summary>
	public void MapDouble( string address, UnityAction<double> method ){ Map<double>( address, method, OscMessageType.Double ); }

	/// <summary>
	/// Same as above, for int type.
	/// </summary>
	public void MapInt( string address, UnityAction<int> method ){ Map<int>( address, method, OscMessageType.Int ); }

	/// <summary>
	/// Same as above, for long type.
	/// </summary>
	public void MapLong( string address, UnityAction<long> method ){ Map<long>( address, method, OscMessageType.Long ); }

	/// <summary>
	/// Same as above, for string type.
	/// </summary>
	public void MapString( string address, UnityAction<string> method ){ Map<string>( address, method, OscMessageType.String ); }

	/// <summary>
	/// Same as above, for char type.
	/// </summary>
	public void MapChar( string address, UnityAction<char> method ){ Map<char>( address, method, OscMessageType.Char ); }

	/// <summary>
	/// Same as above, for bool type.
	/// </summary>
	public void MapBool( string address, UnityAction<bool> method ){ Map<bool>( address, method, OscMessageType.Bool ); }

	/// <summary>
	/// Same as above, for color type.
	/// </summary>
	public void MapColor( string address, UnityAction<Color32> method ){ Map<Color32>( address, method, OscMessageType.Color ); }

	/// <summary>
	/// Same as above, for blob type.
	/// </summary>
	public void MapBlob( string address, UnityAction<byte[]> method ){ Map<byte[]>( address, method, OscMessageType.Blob ); }

	/// <summary>
	/// Same as above, for time tag type.
	/// </summary>
	public void MapTimeTag( string address, UnityAction<OscTimeTag> method ){ Map<OscTimeTag>( address, method, OscMessageType.TimeTag ); }

	/// <summary>
	/// Request that 'method' is invoked when a message with OSC 'address' is received with type tag Impulse (i), Null (N) or simply without arguments.
	/// </summary>
	public void MapImpulseNullOrEmpty( string address, UnityAction method )
	{
		if( !ValidateAddressForMapping( address ) ) return;

		// Get or create mapping
		OscMapping mapping = null;
		GetOrCreateMapping( address, OscMessageType.ImpulseNullEmpty, out mapping );

		// Add listener
		mapping.ImpulseNullEmptyHandler.AddListener( method );

		// Add mapping inspector info (To unmap runtime handler, knowing we did it. Because UnityEvent is a black box)
		mapping.runtimeMethodInfo.Add( method.Method );
		string methodLabel = method.Target.GetType() + "." + method.Method.Name; // For display in inspector
		mapping.runtimeMethodLabels.Add( methodLabel );

		// Set dirty flag
		_dirtyMappings = true;
	}


	void Map<T>( string address, UnityAction<T> method, OscMessageType type )
	{
		if( string.IsNullOrEmpty( address ) ) return;
		if( method == null ) return;
		if( !ValidateAddressForMapping( address ) ) return;

		// Get or create mapping
		OscMapping mapping = null;
		GetOrCreateMapping( address, type, out mapping );
		
		// Add listener
		switch( type )
		{
		case OscMessageType.OscMessage:	mapping.OscMessageHandler.AddListener( method as UnityAction<OscMessage> ); break;
		case OscMessageType.Float:		mapping.FloatHandler.AddListener( method as UnityAction<float> ); break;
		case OscMessageType.Double:		mapping.DoubleHandler.AddListener( method as UnityAction<double> ); break;
		case OscMessageType.Int:		mapping.IntHandler.AddListener( method as UnityAction<int> ); break;
		case OscMessageType.Long:		mapping.LongHandler.AddListener( method as UnityAction<long> ); break;
		case OscMessageType.String:		mapping.StringHandler.AddListener( method as UnityAction<string> ); break;
		case OscMessageType.Char:		mapping.CharHandler.AddListener( method as UnityAction<char> ); break;
		case OscMessageType.Bool:		mapping.BoolHandler.AddListener( method as UnityAction<bool> ); break;
		case OscMessageType.Color:		mapping.ColorHandler.AddListener( method as UnityAction<Color32> ); break;
		case OscMessageType.Blob:		mapping.BlobHandler.AddListener( method as UnityAction<byte[]> ); break;
		case OscMessageType.TimeTag:	mapping.TimeTagHandler.AddListener( method as UnityAction<OscTimeTag> ); break;
		}

		// Add mapping inspector info (To unmap runtime handler, knowing we did it. Because UnityEvent is a black box)
		mapping.runtimeMethodInfo.Add( method.Method );

		// For display in inspector
		string handlerLabel;
		if( method.Target == null ){
			handlerLabel = "delegate";
		} else {
			handlerLabel = GetMethodLabel( method.Target, method.Method );
		}
		mapping.runtimeMethodLabels.Add( handlerLabel );

		// Set dirty flag
		_dirtyMappings = true;
	}


	string GetMethodLabel( object source, System.Reflection.MethodInfo methodInfo )
	{
		string simpleType = source.GetType().ToString();
		int dotIndex = simpleType.LastIndexOf('.')+1;
		simpleType = simpleType.Substring( dotIndex, simpleType.Length - dotIndex );
		return simpleType + "." + methodInfo.Name;
	}


	bool ValidateAddressForMapping( string address )
	{
		// Check address for slash
		if( address.Length < 2 || address[0] != '/' ){
			Debug.LogWarning( "<b>[OscIn]</b> Ignored attempt to create mapping. OSC addresses must begin with slash '/'." );
			return false;
		}

		// Check for whitespace
		if( address.Contains(" ") ){
			Debug.LogWarning( "<b>[OscIn]</b> Ignored attempt to create mapping. OSC addresses are advised not to contain whitespaces." );
			return false;
		}

		return true;
	}


	bool GetOrCreateMapping( string address, OscMessageType type, out OscMapping mapping )
	{
		mapping = _mappings.Find( m => m.address == address );
		if( mapping == null ){
			mapping = new OscMapping( address, type );
			_mappings.Add( mapping );
		} else if( mapping.type != type ){
			Debug.LogWarning( BuildFailedToMapMessage( address, type, mapping.type ) );
			return false;
		}
		return true;
	}


	/// <summary>
	/// Request that 'method' is no longer invoked.
	/// Note that only mappings made at runtime can be unmapped.
	/// </summary>
	public void Unmap( UnityAction<OscMessage> method )	{ Unmap<OscMessage>( method ); }

	/// <summary>
	/// Same as above for float type.
	/// </summary>
	public void UnmapFloat( UnityAction<float> method ){ Unmap<float>( method ); }

	/// <summary>
	/// Same as above for double type.
	/// </summary>
	public void UnmapDouble( UnityAction<double> method ){ Unmap<double>( method ); }

	/// <summary>
	/// Same as above for int type.
	/// </summary>
	public void UnmapInt( UnityAction<int> method ){ Unmap<int>( method ); }

	/// <summary>
	/// Same as above for long type.
	/// </summary>
	public void UnmapLong( UnityAction<long> method ){ Unmap<long>( method ); }

	/// <summary>
	/// Same as above for string type.
	/// </summary>
	public void UnmapString( UnityAction<string> method ){ Unmap<string>( method ); }

	/// <summary>
	/// Same as above for char type.
	/// </summary>
	public void UnmapChar( UnityAction<char> method ){ Unmap<char>( method ); }

	/// <summary>
	/// Same as above for bool type.
	/// </summary>
	public void UnmapBool( UnityAction<bool> method ){ Unmap<bool>( method ); }

	/// <summary>
	/// Same as above for color type.
	/// </summary>
	public void UnmapColor( UnityAction<Color32> method ){ Unmap<Color32>( method ); }

	/// <summary>
	/// Same as above for blob type.
	/// </summary>
	public void UnmapBlob( UnityAction<byte[]> method ){ Unmap<byte[]>( method ); }

	/// <summary>
	/// Same as above for time tag type.
	/// </summary>
	public void UnmapTimeTag( UnityAction<OscTimeTag> method ){ Unmap<OscTimeTag>( method ); }

	/// <summary>
	/// Same as above for methods with no arguments.
	/// </summary>
	public void UnmapImpulseNullOrEmpty( UnityAction method )
	{
		// UnityEvent is secret about whether we removed a runtime handler, so we have to iterate the whole array og mappings
		for( int m=_mappings.Count-1; m>=0; m-- )
		{
			OscMapping mapping = _mappings[m];

			// Check if runtime method exists
			System.Reflection.MethodInfo mappedRuntimeHandlerInfo = mapping.runtimeMethodInfo.Find( h => h == method.Method );
			if( mappedRuntimeHandlerInfo == null ) continue;

			// Remove inspector info
			string methodLabel = GetMethodLabel( method.Target, method.Method );
			mapping.runtimeMethodInfo.Remove( mappedRuntimeHandlerInfo );
			mapping.runtimeMethodLabels.Remove( methodLabel );
			int runtimeCount = mapping.runtimeMethodInfo.Count;

			// Remove the method from the UnityEvent. We have no way of accesing information about methods added at runtime.
			mapping.ImpulseNullEmptyHandler.RemoveListener( method );
			int editorCount = mapping.ImpulseNullEmptyHandler.GetPersistentEventCount();

			// If there are no editor or runtime methods mapped to the hanlder left, then remove mapping.
			if( editorCount + runtimeCount == 0 ) _mappings.RemoveAt( m );

		}
		_dirtyMappings = true;
	}

	/// <summary>
	/// Request that all methods that are mapped to OSC 'address' will no longer be invoked.
	/// This is useful for unmapping delegates.
	/// </summary>
	public void UnmapAll( string address )
	{
		OscMapping mapping = _mappings.Find( m => m.address == address );
		if( mapping != null ){
			mapping.Clear();
			_mappings.Remove( mapping );
		}
	}

	void Unmap<T>( UnityAction<T> method )
	{
		// UnityEvent is secret about whether we removed a runtime handler, so we have to iterate the whole array og mappings
		Type type = typeof( T );
		for( int m=_mappings.Count-1; m>=0; m-- )
		{
			OscMapping mapping = _mappings[m];

			// Check if runtime method exists
			System.Reflection.MethodInfo mappedRuntimeHandlerInfo = mapping.runtimeMethodInfo.Find( h => h == method.Method );
			if( mappedRuntimeHandlerInfo == null ) continue;

			// Remove inspector info
			string methodLabel = GetMethodLabel( method.Target, method.Method );
			mapping.runtimeMethodInfo.Remove( mappedRuntimeHandlerInfo );
			mapping.runtimeMethodLabels.Remove( methodLabel );
			int runtimeCount = mapping.runtimeMethodInfo.Count;

			// Remove the method from the UnityEvent. We have no way of accesing information about methods added at runtime.
			int editorCount = 0;
			if( type == typeof( OscMessage ) ){
				mapping.OscMessageHandler.RemoveListener( method as UnityAction<OscMessage> );
				editorCount = mapping.OscMessageHandler.GetPersistentEventCount();
			} else if( type == typeof( float ) ){
				mapping.FloatHandler.RemoveListener( method as UnityAction<float> );
				editorCount = mapping.FloatHandler.GetPersistentEventCount();
			} else if( type == typeof( double ) ){
				mapping.DoubleHandler.RemoveListener( method as UnityAction<double> );
				editorCount = mapping.DoubleHandler.GetPersistentEventCount();
			} else if( type == typeof( int ) ){
				mapping.IntHandler.RemoveListener( method as UnityAction<int> );
				editorCount = mapping.DoubleHandler.GetPersistentEventCount();
			} else if( type == typeof( long ) ){
				mapping.LongHandler.RemoveListener( method as UnityAction<long> );
				editorCount = mapping.LongHandler.GetPersistentEventCount();
			} else if( type == typeof( string ) ){
				mapping.StringHandler.RemoveListener( method as UnityAction<string> );
				editorCount = mapping.StringHandler.GetPersistentEventCount();
			} else if( type == typeof( char ) ){
				mapping.CharHandler.RemoveListener( method as UnityAction<char> );
				editorCount = mapping.CharHandler.GetPersistentEventCount();
			} else if( type == typeof( bool ) ){
				mapping.BoolHandler.RemoveListener( method as UnityAction<bool> );
				editorCount = mapping.BoolHandler.GetPersistentEventCount();
			} else if( type == typeof( Color32 ) ){
				mapping.ColorHandler.RemoveListener( method as UnityAction<Color32> );
				editorCount = mapping.ColorHandler.GetPersistentEventCount();
			} else if( type == typeof( byte[] ) ){
				mapping.BlobHandler.RemoveListener( method as UnityAction<byte[]> );
				editorCount = mapping.BlobHandler.GetPersistentEventCount();
			} else if( type == typeof( OscTimeTag ) ){
				mapping.TimeTagHandler.RemoveListener( method as UnityAction<OscTimeTag> );
				editorCount = mapping.TimeTagHandler.GetPersistentEventCount();
			}

			// If there are no editor or runtime methods mapped to the hanlder left, then remove mapping.
			if( editorCount + runtimeCount == 0 ) _mappings.RemoveAt( m );
		}
		_dirtyMappings = true;
	}


	void UpdateMappings()
	{
		if( _mappingLookup == null ) _mappingLookup = new Dictionary<string,OscMapping>();
		else _mappingLookup.Clear();
		for( int m=0; m<_mappings.Count; m++ ) _mappingLookup.Add( _mappings[m].address, _mappings[m] );

		_dirtyMappings = false;
	}


	string BuildFailedToMapMessage( string address, OscMessageType type, OscMessageType mappedType )
	{
		return string.Format(
			"<b>[OscIn]</b> Failed to map address'{0}' to method with argument type '{1}'. Address is already set to receive type '{2}', either in the editor, or by a script. " + Environment.NewLine
			+ "Only one type per address is allowed.", address, type, mappedType );
	}


	#endregion
}