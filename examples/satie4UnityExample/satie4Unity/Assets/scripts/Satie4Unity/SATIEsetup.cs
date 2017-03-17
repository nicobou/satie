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
using UnityEngine.UI;
using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Threading;
using System.Runtime.InteropServices;
using System.Net;
//using OSC.NET;

//using OscSimpl;

public class SATIEsetup : MonoBehaviour
{

    // public GameObject uiWrapper;

    //public bool enabled = true;
    private bool connected = false;

    public bool isConnected()
    {
        return connected;
    }

    //private static OSCTransmitter sender;

    public static OscOut oscOutNode;

    private static OscMessage uBlobSrcMess;
    private static OscMessage uBlobProcMess;

    private static OscBundle bundle;

    public string RendererAddress = "127.0.0.1";
    public int RendererPort = 18032;

 
    public int getPort()
    {
        return RendererPort;
    }

    public OscOut getOscOut()
    {
        return oscOutNode;
    }


    public string getAddress()
    {
        return RendererAddress;
    }

    public bool useFixedUpdate = false;

    public float updateRateMs = 30;
    private float _updateRateMs;

    [Tooltip("sends node updates using osc blobs, with lower rez params") ]
    public bool enableOscBlobTX = true;

    public bool invertAzimuth = false;

    public static bool invertAzi = false;
    // this is referenced by source connections


    public static bool debugMessTx_static = false;
    public bool debugMessTx = false;


//    const string uBlobSrcAddress = "/satie/source/ublob";
//    const string uBlobProcAddress = "/satie/process/ublob";

    [HideInInspector] 
    public static float updateRateSecs = .02f;


      
    // list of all instantiated nodes
    [HideInInspector] 
    public  static List<SATIEnode> SATIEnodeList = new List<SATIEnode>();
  


    private bool _enabled = false;

    public static bool OSCenabled { get { return _instance._enabled; } }


    public static bool updateBlobEnabled { get { return _instance.enableOscBlobTX; } }

    //private static readonly SATIEsetup _instance = new SATIEsetup();

    private static  SATIEsetup _instance = null;

    public static SATIEsetup Instance { get { return _instance; } }

    public SATIEsetup()
    {
    }



    Text fpsText = null;
    // used to display FPS

    private int frameCount = 0;
    private float dt = 0.0f;
    private float fps = 0.0f;
    private float updateRate = 4.0f;
    // 4 updates per sec.

 
    // set up translator(s)  for now, using only the basic translator
    void Awake()
    {
        if (_instance != null)
        {
            Debug.LogError(GetType()+".Awake(): multiple instances of SATIEsetup not allowed, duplicate instance found in:" + transform.name);
            return;
        }
	
        //            try
//            {
//
//            }
//            catch (Exception e)
//            {
//                Debug.LogError(GetType()+".Awake: OSC TX:  failed to connect to " + RendererAddress + ":" + RendererPort + "can't initialize SATIE");
//                Debug.LogWarning(e.Message);
//                return;
//
//            }

        if (RendererAddress.Equals("localhost"))
            RendererAddress = "127.0.0.1";

        oscOutNode = gameObject.GetComponent<OscOut>();
        if (oscOutNode == null)
        {
            oscOutNode = gameObject.AddComponent<OscOut>();
        }
        oscOutNode.Open(RendererPort, RendererAddress);


        bundle = new OscBundle();
//        uBlobSrcMess = new OscMessage(uBlobSrcAddress, new byte[0]);
//        uBlobProcMess = new OscMessage(uBlobProcAddress, new byte[0]);

        // connected and ready to initialize object

        connected = true;
        _instance = this;    // force singleton
        _instance._enabled = true;

        string localHostName = Dns.GetHostName();
        IPHostEntry hostEntry = Dns.GetHostEntry(localHostName);
        foreach (IPAddress ipAddr in hostEntry.AddressList)
        {
            Debug.Log(GetType()+".Awake: MY IP:" + ipAddr.ToString());
        }
        Debug.Log(GetType()+".Awake: OSC TX to:  " + RendererAddress + ":" + RendererPort);

        setUpdateRate(updateRateMs);
    }



	
    void Start()
    {
        GameObject obj = GameObject.Find("FPStext");

        if (obj != null)
            fpsText = obj.GetComponent<Text>();

        invertAzi = invertAzimuth;

        debugMessTx_static = debugMessTx;



        // Show UI
        // uiWrapper.SetActive( true );


        StartCoroutine(initSatie());
    }

	
    void OnValidate()
    {
        if (!connected)
            return;

        if (_updateRateMs != updateRateMs)
            setUpdateRate(updateRateMs);

        if (invertAzi != invertAzimuth)
            invertAzi = invertAzimuth;

        if (debugMessTx_static != debugMessTx)
            debugMessTx_static = debugMessTx;
    }


    void setUpdateRate(float updateMs)
    {
        _updateRateMs = updateMs;
        updateRateSecs = updateMs / 1000f;
    }


    IEnumerator initSatie() // now that litener(s) have been conection related parameters.
    {
        yield return new WaitForSeconds(.1f);   // may need to be bigger for large scenes
        refreshNodes();    // or do this using a coroutine to avoid OSC peaking
    }

    public void refreshNodes()
    {
        foreach (SATIEnode  node in SATIEnodeList)
            node.refreshState();
    }

    // connections are serviced after the previous frame's physics engine is updated during lateUpdate()
    public virtual void FixedUpdate()
    {
        if (useFixedUpdate)
            serviceConnections(); 
    }
	
    // Update is called once per frame
    public virtual void Update()
    {
        frameCount++;
        dt += Time.deltaTime;
        if (dt > 1.0f / updateRate)
        {
            fps = frameCount / dt;
            frameCount = 0;
            dt -= 1.0f / updateRate;
        }
        if (fpsText)
            fpsText.text = ((int)fps).ToString() + " fps, frameDurMS: " + ((int)(Time.deltaTime * 1000f)).ToString();
        if (!useFixedUpdate)
            serviceConnections();    
    }

    private float _lastUpdate;

    void serviceConnections()
    {
        if (!connected)
            return;

        if (Time.time - _lastUpdate > updateRateSecs)
        {
            // service all nodes
            foreach (SATIEnode node in SATIEnode.sourceInsatances)
            {
                SATIEsource src = (SATIEsource)node;
                src.evalConnections();
            }
            // reset listener flags
            foreach (SATIEnode node in SATIEnode.listenerInsatances)
            {
                node.updatePosFlag = node.updateRotFlag = false;
            }
            _lastUpdate = Time.time;
        }
    }

    public void freeSrcNodesInGroup(string groupName)
    {
        if (!connected)
            return;

        // iterate backwards to modify collection
        for (int i = SATIEnode.sourceInsatances.Count - 1; i >= 0; i--)
        {           
            SATIEsource src = (SATIEsource)SATIEnode.sourceInsatances[i];
                         
            if (src.group.Equals(groupName))
            {
                Debug.Log(GetType() + ".freeSrcNodesInGroup():   deleting node: " + src.nodeName + "  in group: " + src.group);                 
                SATIEnode.sourceInsatances.RemoveAt(i);
                src.deleteNode(src.nodeName);                 
            }
        }

    }







    void OnDestroy()
    {

    }




    public void OnApplicationQuit()
    {

        OscMessage message = new OscMessage("/satie/scene");

        Debug.Log(GetType()+".OnApplicationQuit:  APP QUIT");
        Debug.Log(GetType()+".OnDestroy");

        message.Add("clear");
        sendOSC(message);

         disconnect();   

    }

    public void disconnect()
    {
        if (oscOutNode.isOpen)
        {
            oscOutNode.Close();
        }
        oscOutNode = null;
        connected = false;
    }
    

    // expand this to bundle N messages during a certain delta time T;
    public static bool sendOSC(OscMessage mess)
    {
        bool status;

        if (oscOutNode == null)
        {
            Debug.LogWarning(_instance.GetType()+".sendOSC():  OSCout object not found, skipping message: " + mess.address);
            return false;
        }

        if (!oscOutNode.isOpen)
        {
            Debug.LogError(_instance.GetType()+".sendOSC():  OSCout object not available, skipping message: " + mess.address);
            return false;
        }

        // int bytesSent = 0;
        bundle.Add(mess);
        // bundle.Add( blobMessage );
        status = oscOutNode.Send(bundle);
        bundle.Clear();

//            OSCBundle objectBundle = new OSCBundle();
//            objectBundle.Append(mess);
//            bytesSent = sender.Send(objectBundle);

        return status;
    }


    //    /satie/scene createSource  nodeName  synthDefName<uriPath>   groupName<opt>
    public static bool createSource(string nodeName, string uriString, string groupName)
    {
        bool result;
        const string path = "/satie/scene";
        //OSCMessage message = new OSCMessage(path);
        OscMessage creationMess = new OscMessage(path);
        creationMess.Add("createSource");
        creationMess.Add(nodeName);
        creationMess.Add(uriString);
        creationMess.Add(groupName);

        result = sendOSC(creationMess);

        return result;
    }

    //    /satie/scene createProcess  nodeName  synthDefName<uriPath>   groupName<opt>
    public static bool createProcess(string nodeName, string uriString, string groupName)
    {
        bool result;
        const string path = "/satie/scene";
        //OSCMessage message = new OSCMessage(path);
        OscMessage creationMess = new OscMessage(path);
        creationMess.Add("createProcess");
        creationMess.Add(nodeName);
        creationMess.Add(uriString);
        creationMess.Add(groupName);

        result = sendOSC(creationMess);

        return result;
    }

    public static bool createGroup(string nodeName)
    {
        
        bool result;
        const string path = "/satie/scene";
        //OSCMessage message = new OSCMessage(path);
        OscMessage creationMess = new OscMessage(path);
        creationMess.Add("createGroup");
        creationMess.Add(nodeName);

        result = sendOSC(creationMess);

        return result;

    }

    public static bool OSCtx(string path, List<object> items)
    {
        OscMessage message = new OscMessage(path);
        bool result;

        // Debug.Log("OSCtx: "+path+"  "+items);

        foreach (object value in items)
        {
            Type t = value.GetType();
            float floatVal;
            string strVal;

            if (t.Equals(typeof(String)))
            {
                strVal = Convert.ToString(value);
                message.Add((string)strVal);
            }
            else
            {
                floatVal = Convert.ToSingle(value);
                message.Add(floatVal);
            }

        }
        result = sendOSC(message);
        return result;
        
    }


    public static void OSCdebug(string path, string val)
    {
        if (!debugMessTx_static)
            return;
        OscMessage message = new OscMessage(path);
        message.Add(val);
        sendOSC(message); 
    }

    public static void OSCdebug(string path, float val)
    {
        if (!debugMessTx_static)
            return;
        OscMessage message = new OscMessage(path);
        message.Add(val);
        sendOSC(message); 
    }

    public static void OSCdebug(string path, List <object> items)
    {
        if (!debugMessTx_static)
            return;
        OscMessage message = new OscMessage(path);

        // Debug.Log("OSCtx: "+path+"  "+items);

        foreach (object value in items)
        {
            Type t = value.GetType();
            float floatVal;
            string strVal;

            if (t.Equals(typeof(String)))
            {
                strVal = Convert.ToString(value);
                message.Add((string)strVal);
            }
            else
            {
                floatVal = Convert.ToSingle(value);
                message.Add(floatVal);
            }

        }
        sendOSC(message);
    }
}



/// the following code needs to be patched into OSCsimpl OscOut.cs
///     void OnDestroy()
/* 
{
    if( isOpen ) Close();
}

public bool Open( int port)
{
    return Open_( port, "");
}


public bool Open( int port, string ipAddress)
{
    return Open_( port, ipAddress);

}

*/