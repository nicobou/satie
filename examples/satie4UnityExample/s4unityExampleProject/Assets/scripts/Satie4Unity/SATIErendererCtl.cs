// Satie4Unity, audio rendering support for Unity
// Copyright (C) 2016  Zack Settel

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
// -----------------------------------------------------------
using UnityEngine;
using System;
using System.IO;
using System.Threading;
using System.Collections;
using System.Collections.Generic;
using System.Net;
using OscSimpl;


//using OSC.NET;



public class SATIErendererCtl : MonoBehaviour
{
	
    public bool dspState = true;
    private bool _dspState;

    public string projectName = "default";

    public string projectDir;
    // defaults to $PROJECT/StreamingAssets
    private string _projectDir;

    [Range(-90f, 18)]
    public float outputGainDB = -10f;
    private float _outputGainDB;
    
    [Range(-24f, 24)]
    public float outputTrimDB = -0f;
    private float _outputTrimDB;
    
    public bool dim = false;
    private bool _dim;
    
    public bool mute = false;
    private bool _mute;

    //private bool _start = false;


    public string outputFormat = "stereo";
    // builtin choices:  stereo quad five.one seven.one octo dome mono labodome
    private string _outputFormat;

    private string _renderCtlmess = "/satie/rendererCtl";

    private string _projectMessage;

    // private OSCTransmitter sharedOscOutNode = null;
    private bool connected = false;
    //private Thread thread;

    private SATIEsetup SATIEsetupCS;

//    public int port = 18032;
//    //MH faceShiftOSC default port
//    public string address = "localhost";
//    // defalut to localhost

    private OscOut sharedOscOutNode;

    OscBundle objectBundle;


    public void UnityOSCTransmitter()
    {
    }

//    public int getPort()
//    {
//        return port;
//    }
//
    public void Start()
    {
        //Debug.Log(string.Format("{0}.Awake(): called", GetType()), transform);

        objectBundle = new OscBundle();

        SATIEsetupCS = transform.GetComponent<SATIEsetup>();   // look for SATIEsetup component in this transform
        
        if (!SATIEsetupCS)
        {
            Debug.LogWarning(transform.name + " : " + GetType() +  " Awake(): SATIEsetup class component not found in transform :  Using local address and port");
        }
        else
        {
//            port = SATIEsetupCS.RendererPort; //MH faceShiftOSC default port
//            address = SATIEsetupCS.RendererAddress;  // defalut to localhost
            sharedOscOutNode = SATIEsetupCS.getOscOut(); 
        }
        
//        try
//        {
//            Debug.Log(transform.name + " : " + GetType() +  " Awake():  sending to " + address + ":" + port);
//            connected = true;
//            sharedOscOutNode = new OSCTransmitter(address, port);
//            //thread = new Thread(new ThreadStart(listen));
//            //thread.Start();
//        }
//        catch (Exception e)
//        {
//            Debug.LogError(transform.name + " : " + GetType() +  " Awake():  OSC failed to connect to " + address + ":" + port + " cannot initialize component");
//            Debug.LogError(e.Message);
//            connected = false;
//            sharedOscOutNode = null;
//            return;
//        }
//        string localHostName = Dns.GetHostName();
//        IPHostEntry hostEntry = Dns.GetHostEntry(localHostName);
//        foreach (IPAddress ipAddr in hostEntry.AddressList)
//        {
//            Debug.Log(transform.name + " : " + GetType() +  " Awake():  MY IP:" + ipAddr.ToString());
//        }

        _dspState = dspState;
        _outputGainDB = outputGainDB;
        _dim = dim;
        _outputTrimDB = outputTrimDB;
        _mute = mute;
        _outputFormat = outputFormat;
        _projectMessage = "/satie/project/" + projectName;

        updateProjectDir();
        updateGainDB();
        updateTrimDB();
        updateMute();
        updateOutputFormat();
    }


//    private bool reconnet2renderer()
//    {
//        if ( sharedOscOutNode.isOpen)
//            return true;
//        try
//        {
//            Debug.Log(transform.name + " : " + GetType() +  " reconnet2renderer(): sending to " + address + ":" + port);
//            connected = true;
//            sharedOscOutNode = new OSCTransmitter(address, port);
//            //thread = new Thread(new ThreadStart(listen));
//            //thread.Start();
//        }
//        catch (Exception e)
//        {
//            Debug.LogError(transform.name + " : " + GetType() +  " reconnet2renderer(): OSC failed to connect to " + address + ":" + port + " cannot initialize component");
//            Debug.LogError(e.Message);
//            connected = false;
//            sharedOscOutNode = null;
//            return false;
//        }
//        string localHostName = Dns.GetHostName();
//        IPHostEntry hostEntry = Dns.GetHostEntry(localHostName);
//        foreach (IPAddress ipAddr in hostEntry.AddressList)
//        {
//            Debug.Log(transform.name + " : " + GetType() +  " reconnet2renderer(): MY IP:" + ipAddr.ToString());
//        }
//        return true;
//    }
//


 
    private void updateDSPstate()
    {
        OscMessage message = new OscMessage(_renderCtlmess);
        float state = (dspState) ? 1f : 0f;
        
        message.Add("setDSP");
        message.Add(state);
        sendOSC(message);
    }

    private void updateProjectDir()
    {
        string path = "";

        //Debug.Log ("PROJECT DIR: "+ projectDir);

        if (projectDir == "")
        {
            return;   // if no project path is provided, use the one that is definied in the satie server project

//            _projectDir = projectDir = "../StreamingAssets";
//            path = Application.streamingAssetsPath;
            // Debug.Log ("projectDir EMPTY,  path= "+ path);
        }
        else if (projectDir.StartsWith("$DROPBOX"))    // users can specify $DROPBOX, and assuming a standard filepath like  "C:\Users or /Users,  we replace /Users/name with "~"
        {
            string[] pathItems;
//			int dirIndex = 0; // Never used warning
            string relPath = "~";
            int counter = 0;
            int usersIndex = 0;
//			int dropBoxIndex = 0; // Never used warning
            char delimiter = '/';  // Path.DirectorySeparatorChar;   NOT NEEDED FOR WINDOWS ANYMORE


            // will default to this if there are errors
            _projectDir = projectDir = "../StreamingAssets";
            path = Application.streamingAssetsPath;


            //Debug.Log("***************************** PATH= "+path);

            if (!path.Contains("Dropbox") || (!path.Contains("Users") && !path.Contains("Utilisateurs")))
            {
                Debug.LogWarning(transform.name + " : " + GetType() +  " updateProjectDir(): no DROPBOX and/or /Users directory found, setting project path to default");
                return;
            }

            pathItems = path.Split(delimiter);   // get array of directory items
 
            counter = 0;
            foreach (string s in pathItems)
            {
                if (s == "Users" || s == "Utilisateurs")
                {
                    usersIndex = counter;
                    break;
                }
                counter++;
            }

            if (pathItems.Length < usersIndex + 3)   // /users/name/relativestuff.....
            {
                Debug.LogError(transform.name + " : " + GetType() +  " updateProjectDir(): poorly formated directory path (BUG??), setting project path to default");
                return;
            }

            for (int i = usersIndex + 2; i < pathItems.Length; i++)
            {
                relPath += "/" + pathItems[i];
            }
            //Debug.Log("***************************** pathItems[0] = " + pathItems[0]);
            // Debug.Log("RELPATH= "+relPath);
            _projectDir = projectDir = relPath;
            path = relPath;
        }
        else if (projectDir.StartsWith("/"))
            path = projectDir;
        else
            path = Application.streamingAssetsPath + "/" + projectDir;


        OscMessage message = new OscMessage(_projectMessage);
		
        message.Add("setProjectDir");
        message.Add(path);
        sendOSC(message);
    }

    public float getOutputDB()
    {
        return outputGainDB;
    }


    public void setOutputDB(float db)
    {
        _outputGainDB = outputGainDB = db;
        updateGainDB();
    }

    private void updateGainDB()
    {
        OscMessage message = new OscMessage(_renderCtlmess);
        
        message.Add("setOutputDB");
        message.Add(outputGainDB);
        sendOSC(message);
    }

 
    public void setOutputTrimDB(float db)
    {
        _outputTrimDB = outputTrimDB = db;
        updateTrimDB();
    }

    private void updateTrimDB()
    {
        OscMessage message = new OscMessage(_renderCtlmess);
        
        message.Add("setOutputTrimDB");
        message.Add(outputTrimDB);
        sendOSC(message);
    }

    public void setOutputMute(float state)
    {
        _mute = mute = (state > 0);
        updateMute();
    }

    private void updateMute()
    {
        OscMessage message = new OscMessage(_renderCtlmess);
        float state = (mute) ? 1f : 0f;
        
        message.Add("setOutputMute");
        message.Add(state);
        sendOSC(message);
    }

    public void setOutputDIM(float state)
    {
        _dim = dim = (state > 0);
        updateDim();
    }

    private void updateDim()
    {
        OscMessage message = new OscMessage(_renderCtlmess);
        float state = (dim) ? 1f : 0f;
        
        message.Add("setOutputDIM");
        message.Add(state);
        sendOSC(message);
    }

    private void updateOutputFormat()
    {
        OscMessage message = new OscMessage(_renderCtlmess);
        message.Add("setOutputFormat");
        message.Add(outputFormat);
        sendOSC(message);
    }

    // only three message value types
    public void projectMess(string key)
    {
        OscMessage message = new OscMessage(_projectMessage);
 
        Debug.Log(transform.name + " " + GetType() + " projectMess()  sending projectMess:    project: " + message + "   key: " + key);

        message.Add(key);
        sendOSC(message);
    }


    public void projectMess(string key, float val)
    {
        OscMessage message = new OscMessage(_projectMessage);

        Debug.Log(transform.name + " " + GetType() + "projectMess() sending projectMess:    project: " + message + "   key: " + key);
        message.Add(key);
        message.Add(val);
        sendOSC(message);
    }

    public void projectMess(string key, string val)
    {
        OscMessage message = new OscMessage(_projectMessage);

        Debug.Log(transform.name + " " + GetType() + " projectMess() sending projectMess:    project: " + message + "   key: " + key);
        message.Add(key);
        message.Add(val);
        sendOSC(message);
    }

    /**
	 * Call update every frame in order to dispatch all messages that have come
	 * in on the listener thread
	 */
    public void Update()
    {

//        if (Input.GetKeyDown ("d")) {
//
//            OscMessage message = new OscMessage ("/a.renderer/setOutputDB");
//			//message.Add ("fuckme");
//			message.Add (-12f);
//			sendOSC (message);
//			//Debug.Log("send mess");
//		}

    }

    // called when inspector's values are modified
    public virtual void OnValidate()
    {
//        if (!_start)
//            return;
        
        if (!connected)
            return;
		
        if (_projectDir != projectDir)
        {
            _projectDir = projectDir;
            updateProjectDir();
        }

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
		
		
    }


    public void OnApplicationQuit()
    {

//        OscMessage message = new OscMessage ("/spatosc/core");
//        //message.Add ("fuckme");
//        message.Add ("clear");
//        sendOSC (message);
//        Debug.Log("APP QUIT");
        disconnect();
    }

    public void disconnect()
    {
        if (sharedOscOutNode.isOpen)
        {
            sharedOscOutNode.Close();
        }
      	
        sharedOscOutNode = null;
        connected = false;
    }

    public bool isConnected()
    {
        return connected;
    }


    // expand this to take multiple messages -- e.g.  mess[]
    public bool sendOSC(OscMessage mess)
    {
        bool status;

        if (sharedOscOutNode.isOpen)
        {
            objectBundle.Add(mess);

            status = sharedOscOutNode.Send(objectBundle);
            objectBundle.Clear();
            return status;
        }
        else
        {
            Debug.LogError(transform.name + " : " + GetType() +  " sendOSC(): OSC not initialized, can't send message");
            return false;
        }
    }



    //	public static OSCMessage setMessage(int s, int i, float x, float y, float a, float xVec, float yVec, float A, float m, float r)
    //	{
    //		OscMessage message = new OscMessage("/tuio/2Dobj");
    //		message.Add("set");
    //		message.Add(s);
    //		message.Add(i);
    //		message.Add(x);
    //		message.Add(y);
    //		message.Add(a);
    //		message.Add(xVec);
    //		message.Add(yVec);
    //		message.Add(A);
    //		message.Add(m);
    //		message.Add(r);
    //		return message;
    //	}

}

