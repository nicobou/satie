using UnityEngine; 
using System.Collections;
using System.Collections.Generic;

// note:  this script is for use with particle systemes of ONLY ONE particle.




public class zParticleCollide1: MonoBehaviour 
{ 

	private bool _particleState = false;
	private bool _runable = false;


	private ParticleSystem pSystem;
    
    private ParticleCollisionEvent[] collisionEvents;

	ParticleSystem.Particle[] m_Particles;

	private SATIEsource satieSourceCS;

	private Transform srcNode;


	private float FORCE_CLAMP = 20f;
//	private float VEL_TORQUE_FAC = .2f; // velocities of 1 / VEL_TORQUE_FAC  will be unity.
//	public float bounceImpactThreshold = 1.3f;  // 1.3 bounce, .26  velocMag
//	public float bounceVelocityThreshold = .26f;  // vales chosen by observation using Physics Settings: mon bounc = 1.5
//


    void Start() 
	{
	    

		collisionEvents = new ParticleCollisionEvent[16];

		pSystem = GetComponent<ParticleSystem>();

		srcNode = transform.GetChild(0);

		_runable = false;


		InitializeIfNeeded();
		

		//Debug.Log ("zParticleCollide1.start:  found: " + srcNode.name);
		//		satieSourceCS = GetComponent<SATIEsource>();

		if (pSystem.maxParticles > 1) {
			Debug.LogWarning ("zParticleCollide1:  ignoring: " + pSystem.name + ",  system contains more than one particle, can not enable as satie source");
			return;
		}

		if (srcNode == null) {
			Debug.LogWarning ("zParticleCollide1:  start()  child node named srcNode not found, can not enable as satie source");
			return;
		}
		

		satieSourceCS = srcNode.GetComponent<SATIEsource>();

		if (satieSourceCS == null) {
			Debug.LogWarning ("zParticleCollide1:  start()  child node srcNode  missing satieSourceCS component, can not enable as satie source");
			return;
		}



		_runable = true;


//		if (satieSourceCS == null)
//			Debug.LogWarning("zParticleCollide1:  transform missing satieSourceCS component: disabling "+ pSystem.name+" as source ");
//		else _runable = true;
//



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

		int safeLength = pSystem.GetSafeCollisionEventSize ();
		if (collisionEvents.Length < safeLength)
			collisionEvents = new ParticleCollisionEvent[safeLength];
        

		int numCollisionEvents = pSystem.GetCollisionEvents (other, collisionEvents);
		int i = 0;
		while (i < numCollisionEvents) {

			List<object> items = new List<object> ();


			//Debug.Log("bjamBounceTrigger.OnCollisionEnter:  hitting " + collision.gameObject.tag);


			Vector3 velocityVec = collisionEvents [i].velocity.normalized;     // particle angle of travel

			float impactIncidence = Vector3.Dot (collisionEvents [i].normal, velocityVec.normalized);  // angle diff of particle and impactObjevt at impact point



			float impactForce = Mathf.Sqrt (collisionEvents [i].velocity.magnitude);


			float force = impactForce;
            force = Mathf.Min (force, FORCE_CLAMP);   // clip to 20 max


			force = Mathf.Pow (force * .05f, 1.5f); // "tune" the range to favor changes on the soft side of the scale


            // build output message
			items.Add ("trigger");
			items.Add (120);  // pitch field not used
			items.Add (force);
			items.Add (impactIncidence);

			// Debug.Log ("OnParticleCollision: force: " + force + " incidence: " + impactIncidence);

			Vector3 collisionHitLoc = collisionEvents [i].intersection;
			//myExplosion = Instantiate (prefabExplosion, collisionHitLoc, Quaternion.identity) as GameObject;
			//Debug.Log("OnParticleCollision: particle:" + i + "  at: " + collisionHitLoc);
			satieSourceCS.sendEvent (items);


			i++;
		}
	}
    

	private void LateUpdate()
	{
		InitializeIfNeeded();
		
		if (!_runable) return;


		// GetParticles is allocation free because we reuse the m_Particles buffer between updates
		int numParticlesAlive = pSystem.GetParticles(m_Particles);

		bool pstate = (numParticlesAlive > 0) ? true:false;


		if (_particleState != pstate)	// detect "note on / off"
		{
			//Debug.Log("particle system:   _particleState:  " + pstate);

			_particleState = pstate ;
		}

		// only deal with the single ONE particle of the system 
		// Change only the particles that are alive
		for (int i = 0; i < numParticlesAlive; i++)
		{
			if (i == 0)  	// only deal with the single ONE particle of the system 
			{
				srcNode.position = m_Particles[i].position;

				//Debug.Log("particle [" + i + "]   pos:  " + m_Particles[i].position);
				//Debug.Log("particle [" + i + "]   seed:  " + m_Particles[i].randomSeed);
				//Debug.Log("particle [" + i + "]   lifetime:  " + m_Particles[i].lifetime);
				//Debug.DrawRay(m_Particles[i].position, Vector3.forward * 10f);
			
			}
			//m_Particles[i].velocity += Vector3.up * m_Drift;
		}
		
		// Apply the particle changes to the particle system
		//pSystem.SetParticles(m_Particles, numParticlesAlive);
	}


}