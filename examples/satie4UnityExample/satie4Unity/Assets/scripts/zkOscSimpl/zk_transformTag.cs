using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class zk_transformTag : MonoBehaviour
{

    public static List<zk_transformTag> zk_transformTagList = new List<zk_transformTag>();


    public string tagName = "default";





    // Use this for initialization
   void Awake()
    {
        zk_transformTagList.Add(this);
    }

    // Use this for initialization
    void Start()
    {
	
    }

    public void fuckme()
    {
        Debug.Log("FUCK ME THANKS");
    }

    void OnDestroy()
    {
        zk_transformTagList.Remove(this);
    }

    // Update is called once per frame
    void Update()
    {
	
    }
}
