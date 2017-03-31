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




public class SATIENodeTest : MonoBehaviour
{
	
    [System.Serializable]
    public class MessArgs
    {
        public float randLow;
        public float randHigh;
        public bool truncate;
    }


    public string _nodeMessRoot;

    private bool _initialized = false;

    private SATIEnode SATIEnodeCS;

    public enum nodeMessType
    {
        set,
        setvec,
        update,
        property

    }

 
    public nodeMessType messType = nodeMessType.set;

    public string messageKey = "note";

    public List <MessArgs> randMessArgs = new List<MessArgs>();


    private string _nodeMessAddr;

    //public MessArgs[] randMessArgs;


    int _distance;

    public bool TXenable = false;
    private bool _TXenable = false;

 


    [Tooltip("range from 0.1 to 100")]
    public float messagesPerSecond = 1;
    private float _messagesPerSecond;
    private float _secsPerMessage;





    private bool _start = false;




    void Start()
    {

        if (SATIEsetup.Instance == null)
        {
            Debug.LogError(transform.name + " : " + GetType() + ".start(): SATIEsetup class not defined in scene: can't run, aborting");
            Destroy(this);
        }


        SATIEnodeCS = transform.GetComponent<SATIEnode>();   // look for SATIEsetup component in this transform

        if (!SATIEnodeCS)
        {
            Debug.LogError(transform.name + " : " + GetType() + ".start(): SATIEnode  component not found in transform : can't run, aborting");
            Destroy(this);
        }

        _TXenable = TXenable;

        _messagesPerSecond = messagesPerSecond = Mathf.Clamp(messagesPerSecond, .01f, 100f);

        _secsPerMessage = 1f / messagesPerSecond;



        _initialized = true;

        StartCoroutine(afterStart()); 

        //updateState();
    }



    void updateMessType()
    {
        switch (messType)
        {
            case nodeMessType.set:
                _nodeMessAddr = _nodeMessRoot + "/set";
                if (randMessArgs.Count != 1)
                {
                    randMessArgs.Clear();
                    randMessArgs.Add(new MessArgs());
                }
                break;
            case nodeMessType.setvec:
                _nodeMessAddr = _nodeMessRoot + "/setvec";
                break;
            case nodeMessType.update:
                _nodeMessAddr = _nodeMessRoot + "/update";
                if (randMessArgs.Count != 1)
                {
                    randMessArgs.Clear();
                    randMessArgs.Add(new MessArgs());
                    randMessArgs.Add(new MessArgs());
                    randMessArgs.Add(new MessArgs());
                    randMessArgs.Add(new MessArgs());
                    randMessArgs.Add(new MessArgs());
                    randMessArgs.Add(new MessArgs());
                }
                break;
            case nodeMessType.property:
                _nodeMessAddr = _nodeMessRoot + "/proerty";
                if (randMessArgs.Count != 1)
                {
                    randMessArgs.Clear();
                    randMessArgs.Add(new MessArgs());
                }
                break;                                
        }
    }

    IEnumerator afterStart() // now that litener(s) have been conection related parameters.
    {

        yield return new WaitForFixedUpdate();
        if (SATIEnodeCS.isProcess)
            _nodeMessRoot = "/satie/process";
        else
            _nodeMessRoot = "/satie/" + SATIEnodeCS.nodeType;

        updateMessType();

        if (TXenable)
            StartCoroutine(iter()); 
    }



    void sendMess()
    {
        if (messageKey.Length == 0) return;

        OscMessage message = new OscMessage(_nodeMessAddr);
        message.Add(SATIEnodeCS.nodeName);
        message.Add(messageKey);
        foreach (MessArgs messArg in randMessArgs) 
        { 
            float value = UnityEngine.Random.Range(messArg.randLow, messArg.randHigh);
            if (messArg.truncate) value = Mathf.Round(value);
            message.Add( value );
        }
        SATIEsetup.sendOSC(message);

    }





    IEnumerator iter() // now that litener(s) have been conection related parameters.
    {
        while (TXenable)
        {
            sendMess();
           // Debug.Log(transform.name + " : " + GetType() + "iter:  *******");
            yield return new WaitForSeconds(_secsPerMessage); 

        }
    }


    //float lastTime = 0f;


    void Update()
    {
//        Debug.Log(transform.name + " : " + GetType() +  "IS PROCESS??: "+SATIEnodeCS.isProcess);

//        if ( (Time.time - lastTime)  > _secsPerMessage)
//        {
//            lastTime = Time.time;
//            sendMess();
//        }
    }


 
    // called when inspector's values are modified
    public virtual void OnValidate()
    {
//        if (!_start)
//            return;
        
        if (!_initialized)
            return;

        updateMessType();

        if (_messagesPerSecond != messagesPerSecond)
        {
            _messagesPerSecond = messagesPerSecond = Mathf.Clamp(messagesPerSecond, .01f, 100f);

            _secsPerMessage = 1f / messagesPerSecond;
        }

        if (_TXenable != TXenable)
        {
            _TXenable = TXenable;
            if (TXenable)
                StartCoroutine(iter()); 
        }
    }
        
}

