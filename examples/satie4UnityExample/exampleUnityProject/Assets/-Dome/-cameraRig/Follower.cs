//the camera rig must follow the character or the characterSmoothFollower if present

//every object following the cameraRig must follow the SmoothFollower if present

using UnityEngine;
using System.Collections;

public class Follower : MonoBehaviour {
public GameObject objectToFollow;
//public GameObject objectToFollow2;
	
	
	// Update is called once per frame
	void LateUpdate () {
	transform.position=objectToFollow.transform.position;
	//transform.position=objectToFollow2.transform.position;
	}
}
