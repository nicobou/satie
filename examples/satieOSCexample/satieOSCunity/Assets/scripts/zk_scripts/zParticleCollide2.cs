using UnityEngine; 
using System.Collections;
using System.Collections.Generic;

// note:  this script is for use with particle systemes of ONLY ONE particle.



public class zParticleCollide2: MonoBehaviour 
{ 

    public float initDelayMS = 3000f;  //
    private bool _initializedFlag = false;

    [Range(0.01f, 1f)]
    public float trigThresh = 0.05f;    // collisions under this force will not output the trigger message


    [Range(-60f, 0f)]
    public float dbThresh = -40;    // collisions under this gain level will not be output
    public float maximumForce = 20f; // 
    private float _forceScaler; 

    public float particleRateDeltaMs;  // time in milliseconds between particules
    private float _currentEmmisionRate;

	private bool _particleState = false;
	private bool _runable = false;

	private ParticleSystem pSystem;
    
    private ParticleCollisionEvent[] collisionEvents;

	private ParticleSystem.Particle[] m_Particles;

	private SATIEsource satieSourceCS;
   
    private SATIEprocess satieProcessCS; 

    private Transform srcNode;

    private bool _start = false;


    public bool enableThinning = false;
   
    [Range(1, 1000)]
    public float maxOscTxPerSecond = 100f;

    [Range(10, 2000)]
    public float deltaMs = 50;   // particlePerSecond update delta 
 
    [Range(10, 100)]
    public float thinningThresholdPercent = 50;

    private float _oscTxPerDelta;
     private float _deltaSecs;
    private float _maxOscTxPerDelta;
    private int particleCounter = 0;   // running counter of particles, used for thinning
    private float _thinningThresholdMPS;
    private float _thinningThresholdFactor;
    private float _normalizationFactor;



    void Start() 
	{
        _start = true;

 
		collisionEvents = new ParticleCollisionEvent[16];

		pSystem = GetComponent<ParticleSystem>();

        srcNode = transform.GetChild(0);

		_runable = false;

 
        updateParams();

		InitializeIfNeeded();

        //
		if (srcNode == null) 
        {
            Debug.LogError ("zParticleCollide2:  start()  child node named srcNode not found, can not run");
			return;
		}
		
		satieSourceCS = srcNode.GetComponent<SATIEsource>();

        satieProcessCS = srcNode.GetComponent<SATIEprocess>();


		if (satieSourceCS == null) 
        {
			Debug.LogError ("zParticleCollide2:  start()  child node srcNode  missing satieSourceCS component, can not run");
			return;
		}

        if (satieProcessCS == null) 
        {
            Debug.LogError ("zParticleCollide2:  start()  child node srcNode  missing satieProcessCS component, can not run");
            return;
        }

        _runable = true;
        StartCoroutine( afterStart() );
        StartCoroutine( CPS() );

    }


    void updateParams()
    {
        _forceScaler = 1f/maximumForce; 

        _thinningThresholdFactor = thinningThresholdPercent * 0.01f;
        _deltaSecs = deltaMs / 1000f;
        _maxOscTxPerDelta =  _deltaSecs * maxOscTxPerSecond;
        _thinningThresholdMPS  = _maxOscTxPerDelta * _thinningThresholdFactor;
        _normalizationFactor =  1f / ( 1 - _thinningThresholdFactor);

    }


    IEnumerator CPS() // now that litener(s) have been conection related parameters.
    {

        while(true)
        {
            yield return new WaitForSeconds(_deltaSecs);
           //  SATIEsetup.OSCdebug("/debug/collisionsPerDelta", _oscTxPerDelta); 

            //Debug.Log(_oscTxPerDelta + " COLLISIONS PER delta--------------");
            _oscTxPerDelta = 0;
        }

    }





    IEnumerator afterStart() // now that litener(s) have been conection related parameters.
    {
        yield return new WaitForFixedUpdate ();

            particleRateDeltaMs = (pSystem.emissionRate == 0) ? 1000 : 1000 * 1 / pSystem.emissionRate; 
            _currentEmmisionRate = pSystem.emissionRate;

            satieProcessCS.setParameter ("triggerIntervalMs", particleRateDeltaMs );

        yield return new WaitForSeconds ( initDelayMS*0.001f );
        _initializedFlag = true;

    }


    void Update()
    {
        if (_currentEmmisionRate != pSystem.emissionRate)
        {
            _currentEmmisionRate = pSystem.emissionRate; 
            particleRateDeltaMs = (pSystem.emissionRate == 0) ? 1000 : 1000 * 1 / pSystem.emissionRate; 
            satieProcessCS.setParameter("triggerIntervalMs", particleRateDeltaMs);
        }
    }


    void OnValidate(){

        if (!_start) return;
        updateParams();
    }



	void InitializeIfNeeded()
	{
		if (pSystem == null)
			pSystem = GetComponent<ParticleSystem>();
		
		if (m_Particles == null || m_Particles.Length < pSystem.maxParticles)
			m_Particles = new ParticleSystem.Particle[pSystem.maxParticles]; 
	}



    void OnParticleCollision(GameObject other) {

		if (!_runable)
			return;

        if (! _initializedFlag )
            return;

        int thinner = 99999;   // defuault modulus value for no voice skipping

        if ( enableThinning && (_oscTxPerDelta >  _thinningThresholdMPS)  )  // if we reach the MessagePerSecond threshold
        {
            float headroomIndex =  Mathf.Clamp( (_oscTxPerDelta / _maxOscTxPerDelta), _thinningThresholdFactor, 1.0f);  // unit scale

            //SATIEsetup.OSCdebug("/debug/TTF", _thinningThresholdFactor); 

            //SATIEsetup.OSCdebug("/debug/headroomIndexRaw", headroomIndex); 

            float headroomIndexN = _normalizationFactor * ( headroomIndex - _thinningThresholdFactor);
 
            //SATIEsetup.OSCdebug("/debug/headroomIndexScaled", headroomIndexN); 

            float headroomIndexINV = (1 - headroomIndexN );  // invert

           // SATIEsetup.OSCdebug("/debug/INVheadroomIndex", headroomIndexINV); 
                  
            thinner = Mathf.RoundToInt( 1 + 10 * headroomIndexINV ) ;   // scale thinner degree by index. 

 
            //Debug.Log("/headroomIndex: " + headroomIndex + " /headroomIndexN: " + headroomIndexN + " /headroomIndexINV: " + headroomIndexINV + "  /thinning level: " + thinner + "  /_oscTxPerDelta: " + _oscTxPerDelta );


            if (thinner == 1) // message sending limit hit, return without sending message
            {
                //Debug.Log("bjamBounceTrigger.OnCollisionEnter:  Thinning SATURATED:  " + thinner );
                //SATIEsetup.OSCdebug("/debug/saturated", 0); 
                Debug.Log("bjamBounceTrigger.OnCollisionEnter:  Skipping particle,  thinning level:  " + thinner + " _oscTxPerDelta: " + _oscTxPerDelta );

                return;
            }
            else 
            {
                //Debug.Log("/debug/thinner:  " + thinner );
               // SATIEsetup.OSCdebug("/debug/thinner", thinner); 
            }
        }


        int safeLength = pSystem.GetSafeCollisionEventSize ();

		if (collisionEvents.Length < safeLength)
			collisionEvents = new ParticleCollisionEvent[safeLength];
        
		int numCollisionEvents = pSystem.GetCollisionEvents (other, collisionEvents);

        int i = 0;

		while (i < numCollisionEvents) {

			List<object> items = new List<object> ();
            List<float> connParams = new List<float>();

            Vector3 particlePos = collisionEvents[i].intersection;

            particleCounter++;  // running counter used for thinning


            if ( ( particleCounter  % thinner ) == 0)   // ignore this particule
            {
                //SATIEsetup.OSCdebug("/debug/skip", 0); 

                Debug.Log("bjamBounceTrigger.OnCollisionEnter:  Skipping particle,  thinning level:  " + thinner + " _oscTxPerDelta: " + _oscTxPerDelta );
                i++;
                continue;
            }


            connParams = satieSourceCS.getParticleConnParams(particlePos);

            if (connParams[2] < dbThresh)
            {

               //  Debug.Log("bjamBounceTrigger.OnCollisionEnter:  UNDER DB Thresh  " + connParams[2] );
                i++;
                continue;
            }


            //Debug.Log("bjamBounceTrigger.OnCollisionEnter:  hitting " + collision.gameObject.tag);

            Vector3 velocityVec = collisionEvents [i].velocity.normalized;     // particle angle of travel

  			float impactIncidence = Vector3.Dot (collisionEvents [i].normal, velocityVec.normalized);  // angle diff of particle and impactObjevt at impact point

			float impactForce = Mathf.Sqrt (collisionEvents [i].velocity.magnitude);

			float force = impactForce;
            force = Mathf.Min (force, maximumForce);   // clip to 20 max
           
            force = Mathf.Pow (force * _forceScaler, 1.5f); // "tune" the range to favor changes on the soft side of the scale

            //Debug.Log("bjamBounceTrigger.OnCollisionEnter:  RAW FORCE " + impactForce + " COOKED FORCE: "+ force );

             //Debug.Log ("OnParticleCollision: connectionPARAMS: " + connParams);
           
            if (force >= trigThresh)
            {
                // prepare output message
                items.Add("trigger");
                items.Add(force);
                items.Add(impactIncidence);
          
                foreach (float f in connParams)
                {
                    items.Add(f);
                }             
                //Debug.Log ("OnParticleCollision force: " + force + " incidence: " + impactIncidence);

                satieSourceCS.sendEvent(items);   // list: "trigger", force, impactIncidence, azi, elev, gain, delayMs, lpassFq, hpassFq , distance
                _oscTxPerDelta++;
            }
            items.Clear();

			i++;
		}
	}
}
