using UnityEngine;
using System;
using System.Threading;
using System.Collections;
using System.Collections.Generic;
using System.Net;

using OSC.NET;

public class UnityOSCTransmitter : MonoBehaviour {
	
	private bool connected = false;
	public int port = 8338; //MH faceShiftOSC default port
	public string address = "127.0.0.1";  // defalut to localhost
	private OSCTransmitter sender;
	//private Thread thread;


	public UnityOSCTransmitter() {}

	public int getPort() {
		return port;
	}
			

	public void Start() {
		try {
			Debug.Log(" OSC sender connected");
			connected = true;
			sender = new OSCTransmitter(address, port);
			//thread = new Thread(new ThreadStart(listen));
			//thread.Start();
		} catch (Exception e) {
			Debug.LogWarning("failed to connect to " + address + ":" + port);
			Debug.LogWarning(e.Message);
		}
		string localHostName = Dns.GetHostName();
		IPHostEntry hostEntry = Dns.GetHostEntry(localHostName);
		foreach (IPAddress ipAddr in hostEntry.AddressList) {
			Debug.Log ("UnityOSCTransmitter: MY IP:" + ipAddr.ToString ());
		}
	}
	
	/**
	 * Call update every frame in order to dispatch all messages that have come
	 * in on the listener thread
	 */
	public void Update() {
		//processMessages has to be called on the main thread
		//so we used a shared proccessQueue full of OSC Messages

		if (Input.GetKeyDown ("d")) {

			OSCMessage message = new OSCMessage ("/sheefa/1");
			message.Append ("fuckme");
			message.Append (3.14159);
			sendOSC (message);
			Debug.Log("send mess");
		}

	}

	
	public void OnApplicationQuit(){
		disconnect();
	}
	
	public void disconnect() {
		if (sender!=null){
			sender.Close();
      	}
      	
       	sender = null;
		connected = false;
	}

	public bool isConnected() { return connected; }


	// expand this to take multiple messages -- e.g.  mess[]
	public int sendOSC( OSCMessage mess ) {
		int bytesSent = 0;
		OSCBundle objectBundle = new OSCBundle();
		objectBundle.Append(mess);
		bytesSent = sender.Send(objectBundle);
		return (bytesSent);
	}



	public static OSCMessage setMessage(int s, int i, float x, float y, float a, float xVec, float yVec, float A, float m, float r)
	{
		OSCMessage message = new OSCMessage("/tuio/2Dobj");
		message.Append("set");
		message.Append(s);
		message.Append(i);
		message.Append(x);
		message.Append(y);
		message.Append(a);
		message.Append(xVec);
		message.Append(yVec);
		message.Append(A);
		message.Append(m);
		message.Append(r);
		return message;
	}

}
