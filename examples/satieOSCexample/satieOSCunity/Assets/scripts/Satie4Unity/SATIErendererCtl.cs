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

    [Tooltip ("files for renderer to load.. accepts  '~' ")]
       public List <string> rendererLoadFiles = new List<string>();



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


    [Tooltip ("enables debug mode on renderer")]
    public bool rendererDebugFlag = false;
    private bool _rendererDebugFlag;


    private string _renderCtlmess = "/satie/rendererCtl";

    private string _loadMessage = "/satie/load";

    private string _satieSceneAddr = "/satie/scene"; 

    // private OSCTransmitter sharedOscOutNode = null;
    private bool _initialized = false;
    //private Thread thread;

    private SATIEsetup SATIEsetupCS;


    private bool _start = false;


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



        _initialized = true;
        _dspState = dspState;
        _outputGainDB = outputGainDB;
        _dim = dim;
        _outputTrimDB = outputTrimDB;
        _mute = mute;
        _outputFormat = outputFormat;
        _rendererDebugFlag = rendererDebugFlag;
 

        updateLoadFiles();
        updateGainDB();
        updateTrimDB();
        updateMute();
        updateOutputFormat();
        updateSatieDebugMode();


    }

     
    private void updateDSPstate()
    {
        OscMessage message = new OscMessage(_renderCtlmess);
        float state = (dspState) ? 1f : 0f;
        
        message.Add("setDSP");
        message.Add(state);
        SATIEsetup.sendOSC(message);
    }

    private void updateLoadFiles()
    {
        string path = "";

       
        foreach(string s in rendererLoadFiles)
        {
            OscMessage message = new OscMessage(_loadMessage);		
            message.Add(s);
            SATIEsetup.sendOSC(message);
        }
    }

    public void setSatieDebugMode(float state)
    {
        
        _rendererDebugFlag = rendererDebugFlag = (state == 0) ? false : true;
        updateSatieDebugMode();
    }

    public void updateSatieDebugMode()
    {
        OscMessage message = new OscMessage(_satieSceneAddr);

        message.Add("debugFlag");
        message.Add(rendererDebugFlag);
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
        OscMessage message = new OscMessage(_loadMessage);
 
        Debug.Log(transform.name + " " + GetType() + " projectMess()  sending projectMess:    project: " + message + "   key: " + key);

        message.Add(key);
        SATIEsetup.sendOSC(message);
    }


    public void projectMess(string key, float val)
    {
        OscMessage message = new OscMessage(_loadMessage);

        Debug.Log(transform.name + " " + GetType() + "projectMess() sending projectMess:    project: " + message + "   key: " + key);
        message.Add(key);
        message.Add(val);
        SATIEsetup.sendOSC(message);
    }

    public void projectMess(string key, string val)
    {
        OscMessage message = new OscMessage(_loadMessage);

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
		
        if (_rendererDebugFlag != rendererDebugFlag)
        {
            _rendererDebugFlag = rendererDebugFlag;
            updateSatieDebugMode();
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

