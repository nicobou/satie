using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class UnityOSCListener : MonoBehaviour  {

 	public void OSCMessageReceived(OSC.NET.OSCMessage message){	
		string address = message.Address;    

        ArrayList args = message.Values;

        string arglist = "";

 

        //Debug.Log(address);
		//Debug.Log(message.Values);
		foreach( var item in args)
		{

			string itemStr = item.ToString();
			arglist = arglist + " " + itemStr;


			// parse values by type
		//	if ( item.GetType() == typeof(float)) Debug.Log("float: " + item.ToString());
		//	else if ( item.GetType() == typeof(double)) Debug.Log("double: "+ item.ToString());
		//	else if ( item.GetType() == typeof(int)) Debug.Log("Int: "+ item.ToString());
		//	else if ( item.GetType() == typeof(string)) Debug.Log("string: "+ item.ToString());
		}


		//Debug.Log("OSCRX:  address: " + address +  " items: " + arglist);

	}
}