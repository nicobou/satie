using UnityEngine;
using System.Collections;

public class zkRotate_TEST : MonoBehaviour {


    public float Xrpm = 0f;
    public float Yrpm = 10f;
    public float Zrpm = 0f;

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () 
    {
        transform.Rotate(Xrpm*Time.deltaTime, Yrpm*Time.deltaTime,Zrpm*Time.deltaTime);
	}
}
