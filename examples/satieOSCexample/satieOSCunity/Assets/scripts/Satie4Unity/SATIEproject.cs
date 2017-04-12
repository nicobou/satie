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



public class SATIEproject : MonoBehaviour
{
	

    [Tooltip ("default == unity project file name")]
    public string projectName = "default";

    [Tooltip ("default == dirPathToThisProject/Assets/StreamingAssets")]
    public string projectDir = "default";
    // defaults to $PROJECT/StreamingAssets
    private string _projectDir;

      //private bool _start = false;



     private string _projectMessage;

     // private OSCTransmitter sharedOscOutNode = null;
    private bool _initialized = false;
    //private Thread thread;

    private SATIEsetup SATIEsetupCS;


    private bool _start = false;


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
        _projectMessage = "/satie/project/" + projectName;
 

        updateProjectDir();
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
        if (!_initialized)
            return;
		

        if (_projectDir != projectDir)
        {
            _projectDir = projectDir;
            updateProjectDir();
        }


    }
}

