using UnityEngine;
using System;
using System.Threading;
using System.Collections;
using System.Collections.Generic;

using OSC.NET;

//  MODIFIED BY ZACK
// This Object will send the "OSCMessageReceived" message to all objects that have the "OSClistener" tag, and a script that implements that message
//   e.g     public void OSCMessageReceived(OSC.NET.OSCMessage message);  



public class UnityOSCReceiver : MonoBehaviour {
	
	private bool connected = false;
	public int port = 8338; //MH faceShiftOSC default port
	private OSCReceiver receiver;
	private Thread thread;


    private GameObject[] listeners;  // note, these game oojects are TAGGED with "OSClistener" and will be sent the message "OSCMessageReceived" 
  
    private List<OSCMessage> processQueue = new List<OSCMessage>();
	
	public UnityOSCReceiver() {}

	public int getPort() {
		return port;
	}
			
    void Awake()
    {
   
        listeners = GameObject.FindGameObjectsWithTag("OSClistener");


        if (listeners == null)
        {
            Debug.LogWarning("UnityOSCReceiver.Awake:  no listeners found");
        }


    }

	public void Start() {
        try
        {
            Debug.Log("UnityOSCReceiver.Start: listening to port " + port);
            connected = true;
            receiver = new OSCReceiver(port);
            thread = new Thread(new ThreadStart(listen));
            thread.Start();
        } catch (Exception e)
        {
            Debug.Log("failed to connect to port " + port);
            Debug.LogException(e);

//            foreach (GameObject gobj in listeners)
//            {
////                //List<Component> components = gobj.GetComponents(typeof("Script");
////
////                Debug.Log("found " + gobj.transform.name);
////                Debug.Log("components: " + components );
//
//            }
        }
    }
        
        /**
	 * Call update every frame in order to dispatch all messages that have come
	 * in on the listener thread
	 */
	public void Update() {
		//processMessages has to be called on the main thread
		//so we used a shared proccessQueue full of OSC Messages
		lock(processQueue){
			foreach( OSCMessage message in processQueue)
            {
                foreach (GameObject gobj in listeners)
                {
                    if (gobj.activeSelf)
                        gobj.SendMessage("OSCMessageReceived", message, SendMessageOptions.DontRequireReceiver);
                }
			}
			processQueue.Clear();
		}
	}
	
	public void OnApplicationQuit(){
		disconnect();
	}
	
	public void disconnect() {
      	if (receiver!=null){
      		 receiver.Close();
      	}
      	
       	receiver = null;
		connected = false;
	}

	public bool isConnected() { return connected; }

	private void listen() {
		while(connected) {
			try {
				OSCPacket packet = receiver.Receive();
				if (packet!=null) {
					lock(processQueue){
						
						//Debug.Log( "adding  packets " + processQueue.Count );
						if (packet.IsBundle()) {
							ArrayList messages = packet.Values;
							for (int i=0; i<messages.Count; i++) {
								processQueue.Add( (OSCMessage)messages[i] );
							}
						} else{
							processQueue.Add( (OSCMessage)packet );
						}
					}
				} else Console.WriteLine("null packet");
			} catch (Exception e) { 
				Debug.Log( e.Message );
				Console.WriteLine(e.Message); 
			}
		}
	}
}
