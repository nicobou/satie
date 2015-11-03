using UnityEngine;
using System;
using System.Threading;
using System.Collections;
using System.Collections.Generic;
using System.Net;

using OSC.NET;

public class SATIErendererCtl : MonoBehaviour {
	
    public bool dspState = true;
    private bool _dspState;
    
    public float outputGainDB = -10f;
    private float _outputGainDB;
    
    public float outputTrimDB = -0f;
    private float _outputTrimDB;
    
    public bool dim = false;
    private bool _dim;
    
    public bool mute = false;
    private bool _mute;


    public string outputFormat = "stereo"; // builtin choices:  stereo quad five.one seven.one octo dome mono labodome
    private string _outputFormat;

    private string _oscMessage = "/a.renderer";

    private OSCTransmitter sender = null;
    private bool connected = false;
    //private Thread thread;

    private SATIEsetup SATIEsetupCS;

    public int port = 18032; //MH faceShiftOSC default port
    public string address = "localhost";  // defalut to localhost
    

	public void UnityOSCTransmitter() {}

	public int getPort() {
		return port;
	}

    void Start()
    {

    }

	public void Awake() 
    {
        SATIEsetupCS = transform.GetComponent<SATIEsetup>();   // look for SATIEsetup component in this transform
        
        if (!SATIEsetupCS)
        {
            Debug.LogWarning("SATIErendererCtl.Awake: SATIEsetup class component not found in " + transform.name + " :  Using local address and port");
        } 
        else
        {
            port = SATIEsetupCS.RendererPort; //MH faceShiftOSC default port
            address = SATIEsetupCS.RendererAddress;  // defalut to localhost
        }
        
        try {
            Debug.Log("SATIErendererCtl.Awake: sending to " + address + ":" + port);
			connected = true;
			sender = new OSCTransmitter(address, port);
			//thread = new Thread(new ThreadStart(listen));
			//thread.Start();
		} catch (Exception e) {
            Debug.LogError("SATIErendererCtl.Awake: OSC failed to connect to " + address + ":" + port + " cannot initialize component");
            Debug.LogError(e.Message);
            connected = false;
            sender = null;
            return;
		}
		string localHostName = Dns.GetHostName();
		IPHostEntry hostEntry = Dns.GetHostEntry(localHostName);
		foreach (IPAddress ipAddr in hostEntry.AddressList) {
            Debug.Log ("SATIErendererCtl.Awake: MY IP:" + ipAddr.ToString ());
		}

        _dspState = dspState;
        _outputGainDB = outputGainDB;
        _dim = dim;
        _outputTrimDB = outputTrimDB;
        _mute = mute;
        _outputFormat = outputFormat;
        
        updateGainDB();
        updateTrimDB();
        updateMute();
        updateOutputFormat();
    }
	
    private void updateDSPstate()
    {
        OSCMessage message = new OSCMessage (_oscMessage);
        float state = (dspState) ? 1f:0f;
        
        message.Append ("setDSP");
        message.Append (state);
        sendOSC (message);
    }
    
    private void updateGainDB()
    {
        OSCMessage message = new OSCMessage (_oscMessage);
        
        message.Append ("setOutputDB");
        message.Append (outputGainDB);
        sendOSC (message);
    }
    
    private void updateTrimDB()
    {
        OSCMessage message = new OSCMessage (_oscMessage);
        
        message.Append ("setOutputTrimDB");
        message.Append (outputTrimDB);
        sendOSC (message);
    }
    
    private void updateMute()
    {
        OSCMessage message = new OSCMessage (_oscMessage);
        float state = (mute) ? 1f:0f;
        
        message.Append ("setOutputMute");
        message.Append (state);
        sendOSC (message);
    }
    
    private void updateDim()
    {
        OSCMessage message = new OSCMessage (_oscMessage);
        float state = (dim) ? 1f:0f;
        
        message.Append ("setOutputDIM");
        message.Append (state);
        sendOSC (message);
    }
    
    private void updateOutputFormat()
    {
        OSCMessage message = new OSCMessage (_oscMessage);
        message.Append ("setOutputFormat");
        message.Append (outputFormat);
        sendOSC (message);
    }

	/**
	 * Call update every frame in order to dispatch all messages that have come
	 * in on the listener thread
	 */
	public void Update() {
		//processMessages has to be called on the main thread
		//so we used a shared proccessQueue full of OSC Messages


        if (_outputGainDB != outputGainDB)
        {
            _outputGainDB = outputGainDB;
            updateGainDB();
        }
        
        if (_outputTrimDB != outputTrimDB)
        {
            _outputTrimDB = outputTrimDB;
            updateTrimDB();
        }
        
        if (_outputFormat != outputFormat)
        {
            _outputFormat = outputFormat;
            updateOutputFormat();
        }
        
        if (_dim != dim)
        {
            _dim = dim;
            updateDim();
        }
        
        if (_mute != mute)
        {
            _mute = mute;
            updateMute();
        }
        
        if (_dspState != dspState)
        {
            _dspState = dspState;
            updateDSPstate();
        }

//        if (Input.GetKeyDown ("d")) {
//
//            OSCMessage message = new OSCMessage ("/a.renderer/setOutputDB");
//			//message.Append ("fuckme");
//			message.Append (-12f);
//			sendOSC (message);
//			//Debug.Log("send mess");
//		}

	}

	
	public void OnApplicationQuit()
    {

        OSCMessage message = new OSCMessage ("/spatosc/core");
        //message.Append ("fuckme");
        message.Append ("clear");
        sendOSC (message);
        Debug.Log("APP QUIT");
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

        if (sender != null )
        {
            OSCBundle objectBundle = new OSCBundle();
            objectBundle.Append(mess);
            bytesSent = sender.Send(objectBundle);
            return (bytesSent);
        } else
        {
            Debug.LogError("SATIErendererCtl.sendOSC: OSC not initialized, can't send message");
            return(bytesSent);
        }
	}



//	public static OSCMessage setMessage(int s, int i, float x, float y, float a, float xVec, float yVec, float A, float m, float r)
//	{
//		OSCMessage message = new OSCMessage("/tuio/2Dobj");
//		message.Append("set");
//		message.Append(s);
//		message.Append(i);
//		message.Append(x);
//		message.Append(y);
//		message.Append(a);
//		message.Append(xVec);
//		message.Append(yVec);
//		message.Append(A);
//		message.Append(m);
//		message.Append(r);
//		return message;
//	}

}
