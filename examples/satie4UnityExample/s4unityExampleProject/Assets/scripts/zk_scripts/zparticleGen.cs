using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class zparticleGen : MonoBehaviour {

	public int particleGenCount;
	public GameObject partPrefab;
	public float loopTime = 2f;  // two second loop time

	private List <SATIEprocess> SATIEprocessCSnodes = new List<SATIEprocess>();


	// NB:  this script works on particule generators of no more than one particule

	// Use this for initialization
	void Start () {

		if (!partPrefab )
		{
			Debug.LogError("zparticleGen.Start: zparticle prefab not found in: Asset/Resources");
			return;
			
		}


		for (int i = 0; i < particleGenCount; i++)
		{


			ParticleSystem part;
			Transform srcNode;
			
//			GameObject gob = (GameObject)Instantiate (particlePrefab, transform.position, transform.rotation); // instantiate bones
			GameObject gob = (GameObject)Instantiate (partPrefab, transform.position, partPrefab.transform.rotation); // instantiate bones
			gob.name = partPrefab.name + "_"+i;
			//gob.renderer.material.SetTexture(    "_MainTex", textureBaseName+i);

			
			part = gob.GetComponent<ParticleSystem>();
			part.emissionRate = 1f/loopTime;
			part.maxParticles = 1;   // make sure this is no more than one


			 
			part.startDelay =  loopTime*i*1f/particleGenCount;
			part.startLifetime =  loopTime;

			srcNode = gob.transform.FindChild("srcNode");
			if (srcNode == null)
			{
				Debug.LogError("zparticleGen.start:  prefab missing child named srcNode. Verify prefab. Aborting");
					return;
			}

			srcNode.name = "srcNode" + "_"+i;

			SATIEprocess SATIEprocessCS = srcNode.GetComponent<SATIEprocess>();
			if (SATIEprocessCS == null)
			{
				Debug.LogError("zparticleGen.start: node " +  srcNode.name + " missing SATIEprocess script,  Aborting");
				return;
			}
			SATIEprocessCSnodes.Add (SATIEprocessCS);

			gob.transform.SetParent(transform);

		}
		//GameObject.Destroy(particlePrefab);  
		StartCoroutine( afterStart() );

	
	}


	IEnumerator afterStart() // now that litener(s) have been conection related parameters.
	{
		yield return new WaitForFixedUpdate ();

		float cloudDuration = 1000f * (loopTime / particleGenCount);
		// fresh updadte once we are up and running
		foreach (SATIEprocess SATIEprocessCS in SATIEprocessCSnodes)
			SATIEprocessCS.setParameter ("triggerIntervalMs", cloudDuration );
	}




	// Update is called once per frame
	void Update () {
	
	}
}
