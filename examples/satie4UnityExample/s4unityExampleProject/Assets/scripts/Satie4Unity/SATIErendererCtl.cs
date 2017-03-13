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

    [Tooltip ("default == unity project file name")]
    public string projectName = "default";

    [Tooltip ("default == dirPathToThisProject/Assets/StreamingAssets")]
    public string projectDir = "default";
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
    private bool _initialized = false;
    //private Thread thread;

    private SATIEsetup SATIEsetupCS;

//    public int port = 18032;
//    //MH faceShiftOSC default port
//    public string address = "localhost";
//    // defalut to localhost

    //private OscOut sharedOscOutNode;

    //OscBundle objectBundle;


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

        //objectBundle = new OscBundle();

        SATIEsetupCS = transform.GetComponent<SATIEsetup>();   // look for SATIEsetup component in this transform
        
        if (!SATIEsetupCS)
        {
            Debug.LogError(transform.name + " : " + GetType() +  ".start(): SATIEsetup class component not found in transform : can't run, aborting");
            Destroy(this);
        }

        if (projectName.Equals("default"))
        {
            string[] s = Application.dataPath.Split('/');
            projectName = s[s.Length - 2];
            Debug.Log("project = " + projectName);
        }

        _initialized = true;
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
        SATIEsetup.sendOSC(message);
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
        else if (projectDir.Equals("default"))    // users can specify $DROPBOX, and assuming a standard filepath like  "C:\Users or /Users,  we replace /Users/name with "~"
        {
            _projectDir = projectDir = path = Application.streamingAssetsPath;
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
                Debug.LogWarning(transform.name + " : " + GetType() + " updateProjectDir(): no DROPBOX and/or /Users directory found, setting project path to default");
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
                Debug.LogError(transform.name + " : " + GetType() + " updateProjectDir(): poorly formated directory path (BUG??), setting project path to default");
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
            _projectDir = projectDir = path = Application.streamingAssetsPath;


        OscMessage message = new OscMessage(_projectMessage);
		
        message.Add("setProjectDir");
        message.Add(path);
        SATIEsetup.sendOSC(message);
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
        SATIEsetup.sendOSC(message);
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
        SATIEsetup.sendOSC(message);
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
        SATIEsetup.sendOSC(message);
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
        SATIEsetup.sendOSC(message);
    }

    private void updateOutputFormat()
    {
        OscMessage message = new OscMessage(_renderCtlmess);
        message.Add("setOutputFormat");
        message.Add(outputFormat);
        SATIEsetup.sendOSC(message);
    }

    // only three message value types
    public void projectMess(string key)
    {
        OscMessage message = new OscMessage(_projectMessage);
 
        Debug.Log(transform.name + " " + GetType() + " projectMess()  sending projectMess:    project: " + message + "   key: " + key);

        message.Add(key);
        SATIEsetup.sendOSC(message);
    }


    public void projectMess(string key, float val)
    {
        OscMessage message = new OscMessage(_projectMessage);

        Debug.Log(transform.name + " " + GetType() + "projectMess() sending projectMess:    project: " + message + "   key: " + key);
        message.Add(key);
        message.Add(val);
        SATIEsetup.sendOSC(message);
    }

    public void projectMess(string key, string val)
    {
        OscMessage message = new OscMessage(_projectMessage);

        Debug.Log(transform.name + " " + GetType() + " projectMess() sending projectMess:    project: " + message + "   key: " + key);
        message.Add(key);
        message.Add(val);
        SATIEsetup.sendOSC(message);
    }

    // called when inspector's values are modified
    public virtual void OnValidate()
    {
//        if (!_start)
//            return;
        
        if (!_initialized)
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
}

