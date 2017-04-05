/*
	Created by Carl Emil Carlsen.
	Copyright 2016 Sixth Sensor.
	All rights reserved.
	http://sixthsensor.dk
*/

using UnityEngine;
using System;
using System.Collections;
using System.Net;
using System.Net.Sockets;
using System.Text.RegularExpressions;
using OscSimpl;

/// <summary>
/// MonoBehaviour for sending OscMessage and OscBundle objects.
/// </summary>

public class OscOut : MonoBehaviour
{
	/// <summary>
	/// Gets the port to be send to on the target remote device (read only).
	/// To set, call the Open method.
	/// </summary>
	public int port {
		get { return _port; }
	}
	[SerializeField] int _port = 8000;

	/// <summary>
	/// Gets the transmission mode (read only). Can either be UnicastToSelf, Unicast, Broadcast or Multicast.
	/// The mode is automatically derived from the IP address passed to the Open method.
	/// </summary>
	public OscSendMode mode {
		get { return _mode; }
	}
	[SerializeField] OscSendMode _mode = OscSendMode.UnicastToSelf;

	/// <summary>
	/// Gets the IP address of the target remote device (read only). To set, call the 'Open' method.
	/// </summary>
	public string ipAddress {
		get { return _ipAddress; }
	}
	[SerializeField] string _ipAddress = IPAddress.Loopback.ToString(); // 127.0.0.1;

	/// <summary>
	/// Indicates whether the Open method has been called and the object is ready to send.
	/// </summary>
	public bool isOpen {
		get { return _udpClient != null && _udpClient.Client != null; }
	}

	/// <summary>
	/// Gets the remote connection status (read only). Can either be Connected, Disconnected or Unknown.
	/// </summary>
	public OscRemoteStatus remoteStatus {
		get { return _remoteStatus; }
	}
	[SerializeField] OscRemoteStatus _remoteStatus = OscRemoteStatus.Unknown;

	/// <summary>
	/// Gets the number of messages send since last update.
	/// </summary>
	public int messageCount {
		get { return _messageCount; }
	}
	int _messageCount;

	/// <summary>
	/// Add listener to this event to receive a call when any OscMessage is send.
	/// </summary>
	public OscMessageEvent onAnyMessage = new OscMessageEvent();

	/// <summary>
	/// Indicates whether outgoing multicast messages are also delivered to the sending application.
	/// Default is true.
	/// </summary>
	public bool multicastLoopback {
		get { return _multicastLoopback; }
		set {
			_multicastLoopback = value;
			// Re-open.
			if( isOpen && _mode == OscSendMode.Multicast ) Open( _port, _ipAddress );
		}
	}
	[SerializeField] bool _multicastLoopback = true; // UdpClient default is true

	/// <summary>
	/// When enabled, messages will automatically be buffered in a single OscBundle and send
	/// at the end of the frame (i.e. Unity's WaitForEndOfFrame). Default is false.
	/// </summary>
	public bool bundleMessagesOnEndOfFrame {
		get { return _bundleMessagesOnEndOfFrame; }
		set {
			_bundleMessagesOnEndOfFrame = value;
			if( !value ) _endOfFrameBundle.Clear();
		}
	}
	[SerializeField] bool _bundleMessagesOnEndOfFrame = false;

	// Indicates whether Open should be called automatically on Awake. Set using the inspector.
	[SerializeField] bool _openOnAwake = false;

	UdpClient _udpClient;
	IPEndPoint _endPoint;

	// Flag to indicate if we should open UDPTransmitter OnEnable.
	bool wasClosedOnDisable;

	// For the inspector
	[SerializeField] bool _settingsFoldout;
	[SerializeField] bool _messagesFoldout;

	// For keeping track of the ping coroutine.
	IEnumerator _pingCoroutine;

	const float _pingInterval = 1f; // Seconds

	OscBundle _endOfFrameBundle;


	void Awake()
	{
		_endOfFrameBundle = new OscBundle();
		if( enabled && Application.isPlaying && _openOnAwake ) Open( _port, _ipAddress );
	}


	// OnEnable is only called when Application.isPlaying.
	void OnEnable()
	{
		if( !isOpen && wasClosedOnDisable ) Open( _port, _ipAddress );
	}


	void Update()
	{
		// Reset message count.
		_messageCount = 0;

		// Coroutines only work at runtime.
		if( Application.isPlaying && _bundleMessagesOnEndOfFrame ) StartCoroutine( SendBundleOnEndOfFrame() );
	}


	IEnumerator SendBundleOnEndOfFrame()
	{
		yield return new WaitForEndOfFrame();

		_endOfFrameBundle.timeTag.time = DateTime.Now;
		Send( _endOfFrameBundle );
		_endOfFrameBundle.Clear();
	}


	// OnEnable is only called when Application.isPlaying.
	void OnDisable()
	{
		if( isOpen ){
			Close();
			wasClosedOnDisable = true;
		}
		_remoteStatus = OscRemoteStatus.Unknown;
	}


	void OnDestroy()
	{
		if( isOpen ) Close();
	}

	/// <summary>
	/// Open to send messages to specified port and (optional) IP address.
	/// If no IP address is given, messages will be send locally on this device.
	/// Returns success status.
	/// </summary>
	public bool Open( int port, string ipAddress = "" )
	{
		// Close and stop pinging.
		if( _udpClient != null ) Close();

		// Validate IP.
		IPAddress ip;
		if( string.IsNullOrEmpty( ipAddress ) ) ipAddress = IPAddress.Loopback.ToString();
		if( ipAddress == IPAddress.Any.ToString() || !IPAddress.TryParse( ipAddress, out ip ) ){
			Debug.LogWarning( "<b>[OscOut]</b> Open failed. Invalid IP address " + ipAddress + "." + Environment.NewLine );
			return false;
		} else if( ip.AddressFamily != AddressFamily.InterNetwork ){
			Debug.LogWarning( "<b>[OscOut]</b> Open failed. Only IPv4 addresses are supported. " + ipAddress + " is " + ip.AddressFamily + "." + Environment.NewLine );
			return false;
		}
		_ipAddress = ipAddress;

		// Detect and set transmission mode.
		if( _ipAddress == IPAddress.Loopback.ToString() ){
			_mode = OscSendMode.UnicastToSelf;
		} else if( _ipAddress == IPAddress.Broadcast.ToString() ){
			_mode = OscSendMode.Broadcast;
		} else if( Regex.IsMatch( _ipAddress, OscHelper.multicastAddressPattern ) ){
			_mode = OscSendMode.Multicast;
		} else {
			_mode = OscSendMode.Unicast;
		}

		// Validate port number range
		if( port < OscHelper.portMin || port > OscHelper.portMax ){
			Debug.LogWarning( "<b>[OscOut]</b> Open failed. Port " + port + " is out of range." + Environment.NewLine );
			return false;
		}
		_port = port;

		// Create new client and end point.
		_udpClient = new UdpClient();
		_endPoint = new IPEndPoint( ip, _port );

		// Multicast senders do not need to join a multicast group, but we need to set a few options.
		if( _mode == OscSendMode.Multicast )
		{
			 // Set a time to live, indicating how many routers the messages is allowed to be forwarded by.
			_udpClient.Client.SetSocketOption( SocketOptionLevel.IP, SocketOptionName.MulticastTimeToLive, OscHelper.timeToLiveMax );

			// Apply out multicastLoopback field.
			_udpClient.MulticastLoopback = _multicastLoopback;
		}

		// Set time to live to max. I haven't observed any difference, but we better be safe.
		_udpClient.Ttl = OscHelper.timeToLiveMax;

		// If an outgoing packet happen to exceeds the MTU (Maximum Transfer Unit) then throw an error instead of fragmenting.
		_udpClient.DontFragment = true;

		// Set buffer size to windows limit since we can't tell the actual limit.
		//_udpClient.Client.SendBufferSize = OscHelper.udpPacketSizeMaxOnWindows;

		// Note to self about buffer size:
		// We can't get the MTU when Unity is using scripting backend ".NET 2.0 Subset" (in Unity 5.3).
		// https://msdn.microsoft.com/en-us/library/system.net.networkinformation.ipv4interfaceproperties.mtu(v=vs.110).aspx
		// Also, this method gives a "NotSupportedException: This platform is not supported"
		// https://msdn.microsoft.com/en-us/library/system.net.networkinformation.ipv4interfaceproperties.mtu(v=vs.110).aspx

		// DO NOT CONNECT UDP CLIENT!
		//_udpClient.Connect( _endPoint );

		// Note to self about connecting UdpClient:
		// We do not use udpClient.Connect(). Instead we pass the IPEndPoint directly to _udpClient.Send().
		// This is because a connected UdpClient purposed for sending will throw a number of (for our use) unwanted exceptions and in some cases disconnect.
		//		10061: SocketException: Connection refused 									- When we attempt to unicast to loopback address when no application is listening.
		//		10049: SocketException: The requested address is not valid in this context	- When we attempt to broadcast while having no access to the local network.
		//		10051: SocketException: Network is unreachable								- When we pass a unicast or broadcast target to udpClient.Connect() while having no access to a network.

		// Handle pinging
		if( Application.isPlaying )
		{
			_remoteStatus = _mode == OscSendMode.UnicastToSelf ? OscRemoteStatus.Connected : OscRemoteStatus.Unknown;
			if( _mode == OscSendMode.Unicast ){
				_pingCoroutine = PingCoroutine();
				StartCoroutine( _pingCoroutine );
			}
		}

		// Log
		if( Application.isPlaying ){
			string addressTypeString = string.Empty;
			switch( _mode ){
			case OscSendMode.Broadcast: addressTypeString = "broadcast"; break;
			case OscSendMode.Multicast: addressTypeString = "multicast"; break;
			case OscSendMode.Unicast: addressTypeString = "IP"; break;
			case OscSendMode.UnicastToSelf: addressTypeString = "local"; break;
			}
			Debug.Log(
				"<b>[OscOut]</b> Ready to send to " + addressTypeString + " address " + ipAddress + " on port " + port + "." + Environment.NewLine// + 
				//"Buffer size: " + _udpClient.Client.SendBufferSize + " bytes."
			);
		}

		return true;
	}


	/// <summary>
	/// Close and stop sending messages.
	/// </summary>
	public void Close()
	{
		if( _pingCoroutine != null ){
			StopCoroutine( _pingCoroutine );
			_pingCoroutine = null;
		}
		_remoteStatus = OscRemoteStatus.Unknown;

		if( _udpClient == null ) return;
		_udpClient.Close();
		_udpClient = null;

		wasClosedOnDisable = false;
	}


	/// <summary>
	/// Send a OscMessage with specified address and arguments.
	/// Returns success status.
	/// </summary>
	public bool Send( string address, params object[] args ){ return Send( new OscMessage( address, args ) ); }


	/// <summary>
	/// Send an OscMessage or OscBundle.
	/// Returns success status.
	/// </summary>
	public bool Send( OscPacket packet )
	{
		if( !isOpen ) return false;

		if( _bundleMessagesOnEndOfFrame && packet is OscMessage ){
			_endOfFrameBundle.Add( packet );
			return true;
		}

		// try to pack the message
		byte[] data;
		if( !packet.ToBytes( out data ) ) return false;

		try {
			 // Send!!
			_udpClient.Send( data, data.Length, _endPoint );
				
		// Socket error reference: https://msdn.microsoft.com/en-us/library/windows/desktop/ms740668(v=vs.85).aspx
		} catch( SocketException ex )
		{
			if( ex.ErrorCode == 10051 ){ // "Network is unreachable"
				// Ignore. We get this when broadcasting while having no access to a network.

			} else if( ex.ErrorCode == 10065 ){ // "No route to host"
				// Ignore. We get this sometimes when unicasting.

			} else if( ex.ErrorCode == 10049 ){ // "The requested address is not valid in this context"
				// Ignore. We get this when we broadcast and have no access to the local network. For example if we are using a VPN.

			} else if( ex.ErrorCode == 10061 ){ // "Connection refused"
				// Ignore.

			} else if( ex.ErrorCode == 10040 ){ // "Message too long"
				Debug.LogWarning( "<b>[OscOut]</b> Failed to send message. Packet is too big (" + data.Length + " bytes)." );

			} else {
				Debug.LogWarning( "<b>[OscOut]</b> Failed to send message to " + ipAddress + " on port " + port + Environment.NewLine + ex.ErrorCode + ": " + ex.ToString() );
			}
			return false;
		} catch( Exception ex ) {
			Debug.LogWarning( "<b>[OscOut]</b> Failed to send message to " + ipAddress + " on port " + port + Environment.NewLine + ex.ToString() );
			return false;
		}

		InvokeAnyMessageEventRecursively( packet );
		return true;
	}


	void InvokeAnyMessageEventRecursively( OscPacket packet )
	{
		if( packet is OscBundle ){
			OscBundle bundle = packet as OscBundle;
			foreach( OscPacket subPacket in bundle.packets ) InvokeAnyMessageEventRecursively( subPacket );
		} else {
			onAnyMessage.Invoke( packet as OscMessage );
			_messageCount++;
		}
	}


	IEnumerator PingCoroutine()
	{
		while( true )
		{
			Ping ping = new Ping( _ipAddress );
			yield return new WaitForSeconds( _pingInterval );
			_remoteStatus = ( ping.isDone && ping.time >= 0 ) ? OscRemoteStatus.Connected : OscRemoteStatus.Disconnected;
		}
	}

}