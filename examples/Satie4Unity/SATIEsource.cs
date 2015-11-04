using System.Collections;
using System.Collections.Generic;
using System;
using System.IO;
using UnityEngine;



//SATIEsetup.setDopplerFactor (nodeName, s, dopplarEffect);
    
//SATIEsetup.setDistanceFactor (nodeName, s, distanceEffect);


//SATIEsetup.setDirectivityFactor (nodeName, s, incidenceEffect);


//SATIEsetup.setMaxGainClip (nodeName, s, maxGainClipDB);


//SATIEsetup.setConnectionMute (nodeName, listener, mute);


public class SATIEconnection {
    public float doppler = 100f;
    public float distance = 100f;
    public float directivity = 100f;
    public float maxGainClip = 0f;
    public float radius = 0f;
    public float radiusTransitionFactor = 1.5f;
    public SATIElistener listener=null; 
    public float currentspread=-1;
    public float spread = 1;
	public bool updateFlag = false;
}


public class SATIEsource : SATIEnode {

    //public string listener="*";
    public string group = "default";   
  
    //public bool mute = false;   not used
    //private bool _mutestate;

    //  threw out vertical directivity: too complicated to avoid gimble lock.
    public string sourceDirectivity = "omni";
    public float cardioidDirectivityExp = 1;  // used when "cardioid" type of source diffusity is selected
  
    public float sourceFocusPercent = 100f;   // this % value is used in the connection to the listener(s), and determines the "spread" of the source on the listener, 0 = widest (omni), 100 = narrowest 
 
    public float radius = 0f;
    public float radiusTransitionFactor = 1.5f;

    //private float defaultEffectValue = 100f;  // default connection effect parameters value

    public float dopplarEffect = 100f;
    public float distanceEffect = 100f;
    public float incidenceEffect = 100f;

    public float maxGainClipDB = 0f;

	public List<SATIElistener> myListeners = new List<SATIElistener>(); 

    private float SPEED_OF_SOUND = 0.340f;

    [HideInInspector]
    public List<SATIEconnection> myConnections = new List<SATIEconnection>();

    delegate float SrcDirFnPtr(float theta);   //holds function for node's H directivity
    SrcDirFnPtr srcDirFnPtr;

   

   public override void Start()
    {
 

        //bool result = false;
		nodeType = "source";

		if (gameObject.tag == null) group = "default";
		else if (gameObject.tag != "Untagged")  
			group = gameObject.tag;
        else group = "default";

		Debug.Log("************ source: " + nodeName + "  group_______: " + group);

        initNode();  // must be called before parent's "Start()"
        base.Start();
       
		//Debug.Log("************\tsource: " + nodeName + "  group_______: " + group);


        sourceFocusPercent = Mathf.Clamp(sourceFocusPercent, 0f, 100f);
 
        setHorizontalDirectivity(sourceDirectivity);
 
        //Debug.Log("SATIEsetup.setDirectivity " + nodeName + "  htab:" + HorizontalDirectivity + "  vtab:" + VerticalDirectivity);
        //result = SATIEsetup.setDirectivity(nodeName, hDirectivity, vDirectivity);
//        if (result == false)
//            Debug.LogWarning("SATIEsource.start: bad directiviry table name"); 



//        if (radius != 0f)
//        {
//            //SATIEsetup.setRadius(nodeName, radius);
//            //SATIEsetup.setTransitionRadiusFactor(nodeName, radiusTransitionFactor);
//        }


//        if (listener != "")   // any connection parameters to set ?
//        {
//            if (listener != "*")
//            {
//                foreach (Transform obj in listenerInsatances)
//                {
//					string s = obj.name;
//                    if (s.Contains(listener))
//                    {
//                        listener = s;
//                        break;
//                    }
//                 }
//
//            }
          StartCoroutine( connectionInit() );
         //}
     }


    IEnumerator connectionInit() // now that litener(s) have been conection related parameters.
    {
		yield return new WaitForFixedUpdate ();
		//yield return new WaitForSeconds(.05f);

		List<SATIElistener> tempListeners = new List<SATIElistener>(); 

        add2Group(group);  // this can be done now that objects are instantiated

        // now try to create myConnections

        if (listenerInsatances.Count == 0)
        {
            Debug.LogError("SATIEsource.connectionInit: node: " + nodeName + " no listeners found in environment, can't connect");
        } 
        else  // we are in business, make connection(s)
        {

            // check to make sure the listeners in myListeners are good, if not, remove them from myListeners list
            foreach (SATIElistener listener in myListeners)
            {
				if (listener != null)
                {
					if (listenerInsatances.Contains(listener))
                    {
						tempListeners.Add(listener);
                    } else
                    {
						Debug.LogError("SATIEsource.connectionInit:  myListeners's gameObj: " + listener.name + " INVALID LISTENER");
                    }
                }
            }

            if (tempListeners.Count != myListeners.Count)
            {
                myListeners.Clear();
				foreach (SATIElistener listener in tempListeners)
					myListeners.Add(listener);
                tempListeners.Clear();
            }

            // despite all, no valid listener objects were found in myListeners, so automatically put all listeners in myListeners
            if (myListeners.Count == 0)
            {
				foreach (SATIElistener listener in listenerInsatances)
					myListeners.Add(listener);
            }

            // set up parameters for connection(s)
			foreach (SATIElistener listener in myListeners)
            {
               // note: the current implimentation does not provide for multiple listeners with listener-specific connection params.

                SATIEconnection c = new SATIEconnection();
                
				c.listener = listener;
                c.doppler = dopplarEffect;
                c.distance = distanceEffect;
                c.directivity = incidenceEffect;
                c.maxGainClip = maxGainClipDB;
                c.radius = radius;
                c.radiusTransitionFactor = radiusTransitionFactor;
                c.spread = sourceFocusPercent * 0.01f; 

                
                myConnections.Add(c);

                //   /spatosc/core connect srcNode listenerNode
                string path = "/spatosc/core";
                List<object> items = new List<object>();
                
                
                items.Add("connect");
                items.Add(nodeName);
				items.Add(listener.name);
                
                
                SATIEsetup.OSCtx(path, items);
                items.Clear();
            }
        }
	}


	public void add2Group(string groupName)
	{
		//Debug.Log("add2Group:  add  " + transform.name + "  to sourceNode: " + groupName);

		foreach (SATIEnode obj in groupInsatances)  // check to see if source has same tag as any groups
		{
			if (obj.gameObject.tag == groupName)
			{
				obj.SendMessage("addMember", this);  // add to group
			    this.group = obj.gameObject.tag;
				//Debug.Log("sSAME TAG : " + gameObject.tag + " FOUND FOR GROUP OBJ: " + obj.name + " and  source: " + gameObject.name);

				break;   // source and only be a member of one group
			}
		}
		//GameObject groupObj = GameObject.FindWithTag (gameObject.tag);
 	}

	// best called in the context of lateUpdate() since flags can be set to true during FixedUpdate() or Uptade()
 	public void evalConnections()
    {
		if (!nodeEnabled) return;

		foreach ( SATIEconnection conn in myConnections)
		{
			if (conn.listener.updatePosFlag || conn.listener.updatePosFlag || updatePosFlag || updateRotFlag )
			{
				computeConnection(conn);
				updatePosFlag = updateRotFlag = false;
			}
		}
    }


    
    // ***************************************  start of connection stuff ****************

    void computeConnection(SATIEconnection conn)
    {

        string path;
        List<object> items = new List<object>();
        
		SATIElistener listener = conn.listener;
        Transform source = transform;

        // float dist = Vector3.Distance(source.position, listener.position);

  
    //    float _spread = conn.spread;
        float vdelMs_, distFq_, gainDB_;
        float radius = conn.radius;

        float azimuth, elevation,distance;
        Vector3 listenerAED = new Vector3();            

        // get distance and angles of source relative to listener
        listenerAED = getAedFromSink(source, listener);
        azimuth = listenerAED.x;
        elevation = listenerAED.y;
        distance = listenerAED.z;

        //For the gain and vdel calculation, we want the distance to the radius:
        float dist2Radius = distance - radius;

        // check to see if we are within the radius transition distance; if so, reduce the localization effect for panning: via spread
        if ( radius > 0f )    // using the radius effect ?
        {
 
            float radiusTransitionDistance = radius * conn.radiusTransitionFactor;
            float newSpread;
            
            newSpread = conn.directivity * .01f * getSpreadIndex(distance, radius, radiusTransitionDistance, conn.spread);
        
 
            if ( newSpread != conn.currentspread )   // changed ?
            {
                path = "/spatosc/core/connection/" + source.name + "->"+listener.name+"/spread";
                conn.currentspread = newSpread;

                items.Add(newSpread);             
                SATIEsetup.OSCtx(path, items);   // send spread message via OSC
                items.Clear();

                SATIEsetup.OSCdebug("/debug/getSpreadIndex", getSpreadIndex(distance, radius, radiusTransitionDistance, conn.spread));

            }
        }
        
        if (dist2Radius>0f)
        {
            // now from distance, compute gain, lowPassCutoff-fq and variable delay:
            float distanceScaler;
            float scaledDistance; 
            float srcDirectivityScaler;

            
            vdelMs_ = getVariableDelay(dist2Radius, conn.doppler);
            
            scaledDistance = Mathf.Pow(dist2Radius, conn.distance * 0.01f); // apply distanceFactor (effect) param
                       
            distFq_ = getDistFq(scaledDistance);  // using distance after distanceFactor applied
            
            distanceScaler = 1.0f / (1.0f + scaledDistance);

            srcDirectivityScaler = calcSrcDirectivity(conn);  

            if (debug) Debug.DrawRay (source.position, (source.forward * 50f * srcDirectivityScaler), Color.green, 2f); 

            // obtain connection energy using distance * sourceDirectivity (based on incidence to listener)
            gainDB_ = getGainDB(distanceScaler, srcDirectivityScaler, conn.directivity, conn.maxGainClip);

        }
        else
        {
            distFq_ = 22050.0f;  // this should be redone in terms of .5 * SampRate
            vdelMs_ = 0.0f;
            gainDB_ = conn.maxGainClip ;
        }
        // /spatosc/core/connection/sourceNode->listenerNode/update azimuthRADIANS elevationRADIANS gainDB delayMS  lpHZ 
        // Debug.Log("  AZI: "+ azimuth*Mathf.Rad2Deg+"  Elev: "+elevation*Mathf.Rad2Deg); 

        path = "/spatosc/core/connection/" + source.name + "->"+listener.name+"/update";

        items.Add(azimuth);
        items.Add(elevation);
        items.Add(gainDB_);
        items.Add(vdelMs_);
        items.Add(distFq_);

        SATIEsetup.OSCtx(path, items);
        items.Clear();
      }


	Vector3 getAedFromSink(Transform src, SATIElistener snk)
	{
		Vector3 connVec = src.position - snk.transform.position;
		
		// Rotate connVec by the negative of the rotation described by the snk's
		// orientation. To do this, just flip the sign of the quat.w:
		
		//Quaternion negRot = snk.rotation * Quaternion.Euler(0, 0, 0);
		Quaternion negRot = snk.transform.rotation;
		negRot.w *= -1f;
		Vector3 rotConnVec = negRot * connVec;
		
		Vector3 aed = cartesianToSpherical(rotConnVec);
		
		//Debug.DrawRay (snk.position, rotConnVec); 
		return new Vector3 (-aed.x, aed.y, aed.z);   // invert x to work with UNITY
	}


    // does dot product to see how much source is pointing at sink
	float getSrcIncidenceOnSnk(Transform src, SATIElistener snk)
    {
        Vector3 connVec = Vector3.Normalize(snk.transform.position - src.position);  

        Vector3 srvVec = Vector3.Normalize(src.TransformDirection(Vector3.forward));

        float incidence = Vector3.Dot(srvVec , connVec);

        return incidence;        
    }


    Vector3 cartesianToSpherical(Vector3 v)
    {
        // swapped Y and Z for use with UNITY

        // http://en.wikipedia.org/wiki/Spherical_coordinate_system
        // but modified, since ground ref is the XY plane
        
        float azim, elev, dist;

        dist = Vector3.Magnitude(v);

        //azim = Mathf.Atan2(v.y,v.x) - Mathf.PI/2; original

        azim = Mathf.Atan2(v.z,v.x) - Mathf.PI/2;

        // put in range of [-pi,pi]
        if (azim > Mathf.PI)
            azim -= 2f * Mathf.PI;
        else if (azim < -Mathf.PI)
            azim += 2f * Mathf.PI;
        
        if (dist > 0.000001f)
            // elev = Mathf.PI/2f - Mathf.Acos(v.z / dist);  original
            elev = Mathf.PI/2f - Mathf.Acos(v.y / dist);
        else
            elev = 0.0f;

        return new Vector3(azim, elev, dist);    // elevation inverted for Unity 
    }


    float getDistFq(float distance)
    {
        // calculate a low-pass cutoff freq. to model air absorption of high frequencies over the distance
        float hz;
        float ms;
        
        distance = (distance < 1000f) ? distance : 1000f;  // clip distance to 1000m
        
        ms = distance * (1.0f / SPEED_OF_SOUND); // convert to milliseconds
        hz = (1f - (ms * 0.00034002f));
        hz= 500f + (hz*hz*19500f);
        return hz;
    }
    
    float getVariableDelay(float distance, float dopplerFactor)
    {
        return Mathf.Pow(distance * (1.0f / SPEED_OF_SOUND), dopplerFactor * 0.01f);
    }
    
    float getGainDB(float distanceScaler, float directivity, float directivityFactor, float gainClip)
    {
        
        float gainDB;
        
        float directivityScaler = Mathf.Pow(directivity, directivityFactor * 0.01f);
        gainDB = 20.0f * Mathf.Log10(distanceScaler * directivityScaler); 
        return ( gainDB > gainClip ) ? gainClip : gainDB ;
    }
    
    // returns value ranging from 0 to 1, corresponding to  position within transitionRadius
    // 0: distance <= radius
    // 1: distance <= radiusTransitionDistance
    // or inBetween
    float getSpreadIndex(float distance, float radius, float radiusTransitionDistance, float sourceSpread)
    {
        
        
        if (distance <= radius) return (0f);  // return spread of zero,  i.e. cos to the zeroth power = 1 - no panning effect
        
        if (distance >= radiusTransitionDistance ) return (sourceSpread);  // not within the transition radius, so set spread to "normal"
        
        // else we are inbetween radius and radiusTransition limit, so calculate spread using scaled incidenceFactor_
        
        return ( sourceSpread * (distance- radius) / (radiusTransitionDistance - radius) );   
    }

    float  calcSrcDirectivity(SATIEconnection conn)
    {

        Transform src = transform;
        SATIElistener snk = conn.listener;

        float distance = Vector3.Distance( src.position, snk.transform.position ); 

        float incidence = getSrcIncidenceOnSnk(src, snk);
        float radiusClip;

   
        if(radius < 0f)
            radiusClip = 0f;
        else
            radiusClip = radius;

        // float srcIncidenceScaler = srcDirFnPtr(azimut) * vDirFnPtr(elevation);
        // not using spatOSC's two incidence tables,  since its too complicated to avoid gimble lock

        // SATIEsetup.OSCdebug("/debug/incidence", incidence);

        float theata = .5f *(2 - (incidence + 1f)) * Mathf.PI;

        //SATIEsetup.OSCdebug("/debug/theata", theata * Mathf.Rad2Deg);

        float srcIncidenceScaler = srcDirFnPtr(theata);

         //SATIEsetup.OSCdebug("/debug/srcIncidenceScaler", srcIncidenceScaler);

        float radiusScaler = calcFactorFromDirectivityRadius( distance, radiusClip, conn.radiusTransitionFactor);

        srcIncidenceScaler = srcIncidenceScaler*radiusScaler + (1.0f-radiusScaler);

        return srcIncidenceScaler;
    }

    
    float calcFactorFromDirectivityRadius(float dist, float radius, float radiusTransitionFactor)
    {
        if(dist <= radius)
            return 0.0f;
        
        if(dist >= radius*radiusTransitionFactor)
            return 1.0f;
        
        float radiusScaler = (dist - radius) / (radius * (radiusTransitionFactor-1.0f));
        
        return radiusScaler;
    }


    //  functions pointed to by srcDirFnPtr to calculate directivities

    float getOmni(float theata)
    {
        return (1f);
    }


    float getCardoid(float theata)
    {
        return Mathf.Pow(.5f * (1f + Mathf.Cos(theata)), cardioidDirectivityExp);
    }

    float getHemisphere(float theata) // not implemented yet
    {
        return (1f);
    }

    float getCone(float theata)   // not implemented yet
    {
        return (1f);
//        double cone_width_scaler = 1./8.;  // corresponding to PI/8 == 22.5 degrees * 2 due table symmetry,  == PI/4 == 45 degrees
//        double cone_width = size*cone_width_scaler;

    }

// ***************************************  end of connection stuff ****************


    public override void  setNodeActive(string nodeName, bool nodeEnabled)
    {
        base.setNodeActive(nodeName, nodeEnabled);
        //SATIElistener.UpdateConnection += UpdateConnection;  // subscribe to SATIElistener class
		if (!nodeEnabled) updatePosFlag = updateRotFlag = false;
    }

    public override  void deleteNode(string nodeName)
    {
        base.deleteNode(nodeName);
        //SATIElistener.UpdateConnection -= UpdateConnection;  // unsubscribe to SATIElistener class
        myConnections.Clear();
        myListeners.Clear();

    }

    public override void Update()
    {
        base.Update();

//		if (Input.GetKeyDown("e"))
//		{
//
//			float pitch = UnityEngine.Random.Range(40f, 80f);
//			String pstr = pitch.ToString() + ", 1.0";
//
//			Debug.Log(pstr);
//
//
//			//SATIEsetup.sendNodeEvent(nodeName, "note", pstr);
//			//SATIEsetup.sendNodeEvent(nodeName, "t_gate", "1.0" );
//			//Debug.Log("source:Update  sending t_gate event");
//		}
    }


    public override void FixedUpdate()
    {
		base.FixedUpdate();

    }

	public override void LateUpdate()
	{
		base.LateUpdate();
				
	}


    void setHorizontalDirectivity(string tabName)
    {
        switch (tabName)
        {
            case "cardioid":
                srcDirFnPtr = getCardoid;    // sets srcDirFnPtr to point to getCardoid()
                Debug.Log("SETTING CARDOID");
                return;
            case "hemisphere":          // not implemented
                srcDirFnPtr = getHemisphere;
                return;
            case "cone":        // not implemented
                srcDirFnPtr = getCone;
                return;
        }
        // else
        sourceDirectivity = "omni";
        srcDirFnPtr = getOmni;
        Debug.Log("SETTING OMNI");
    }

}
