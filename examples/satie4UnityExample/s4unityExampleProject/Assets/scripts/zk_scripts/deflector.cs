using UnityEngine;
using System.Collections;

public class deflector : MonoBehaviour {

    
    public bool enableKeys = false;

    public enum tilt45states {NW, W,SW,N,FLAT,S,NE,E,SE}; 

    public enum tilt90states { _0, _90, _135, _225}; 


    private Vector3 ceilingPos = new Vector3();

    private Vector3 ceilingScale = new Vector3();

    private bool variableTilt = false;

    private Vector3 accelxyz = new Vector3();

   // private float floor_Z;

	// Use this for initialization
	void Start () 
    {
	
        ceilingPos = transform.localPosition;
        ceilingScale = transform.localScale;


        // by default the position should be 0,0,N, where N is the height, since parent is rotated
        //Debug.Log("HEIGHT_SCALER: ceiling Position " + ceilingPos); //floor_Z = -ceiling_Z;
	}

//    public Vector3 center;
//    
//    Vector3 position;
//    
//    float lastAngle = 0;
//


    private float hRotation = 0.0f;    //Horizontal angle
    private float vRotation = 0.0f;   //Vertical rotation angle of the camera
    public float tiltSpeed = 2f;
    public Vector3 tiltLimits = new Vector3(25f,25f,25f);
    public float TiltSmooth = .01f;


    public Vector3 currentRot = new Vector3();



    void FixedUpdate()        
    {
        if ( !variableTilt ) return;

        Vector3 rotateDelta = new Vector3(accelxyz.y * tiltSpeed, 0f, -accelxyz.x * tiltSpeed);
        Vector3 newRot = new Vector3();
        
        currentRot = transform.rotation.eulerAngles;
        newRot = currentRot + rotateDelta;
        
//        if (Mathf.Abs( ClampAngle(newRot.x)) > 89)
//            rotateDelta.x = 0f;
//        
//        if (Mathf.Abs(ClampAngle(newRot.z)) > 89)
//            rotateDelta.z = 0f;
        
         transform.Rotate(rotateDelta * TiltSmooth);


    }

    void reset()
    {
        setHeight(1f);
        transform.localScale = ceilingScale;
        hRotation = 0.0f;    //Horizontal angle
        vRotation = 0.0f;   //Vertical rotation angle of the camera

        //variableTilt = false;
    }
    
    // OSC PUSH / TOGGLE BUTTON ITEM 
    // float_arg0: state
    public void setVariable( ArrayList args )    
    {
        if (args.Count != 1)
        {
            Debug.LogError("deflector.setVariable: bad argument count");
            return;
        }
        float state = (float) args [0];

        setVariable( ( state > 0) ? true : false);
    }
    
    private void setVariable( bool state )
    {
        //transform.localScale = ceilingScale* ((state) ? 2f : 1f);


        transform.localScale = ceilingScale * 2f;   
        variableTilt = state;

//        float vAngleDiff = Quaternion.Angle(transform.rotation, Quaternion.Euler(Vector3.up));
//        float hAngleDiff = Quaternion.Angle(transform.rotation, Quaternion.Euler(Vector3.right));
//        
//        if ((hAngleDiff + vAngleDiff) > 180)
//        {
//            Debug.Log("ANGLE DIFF:" + (hAngleDiff + vAngleDiff));
//            transform.rotation = Quaternion.Inverse(transform.rotation);
//        }


     }
    
    public void accxyz( float x, float y, float z )    
    {
        //Debug.Log("deflector.accxyz: " + x + " " + y + " " + z);
        if (variableTilt)
        {
            accelxyz.x = x;
            accelxyz.y = y;
            accelxyz.z = z;

            return;

         }
    }

    // OSC MULTI TOGGLE/BUTTON ITEM   
    // float_arg0: column   float_arg1: row    float_arg2: state
    public void setHeight( ArrayList args )   // expecting (float)index    (float)state <optional>
    {
        if (args.Count != 3 )
        {
            Debug.Log("deflector.setHeight: bad arg count");
            return;
        }
        int rowCount = 1;  // this item has 1 rows
        
        float column = (float)args [0];
        float row = (float)args [1];
        float state =(float)args [2];
        
        float index = row - 1;
        index +=  rowCount * (column -1 );     

        if (state > 0f)
        {
            //Debug.Log("INDEX: " + index);
            float height = 2f - 4f * (index) / 4f;
            setHeight(height);
        }
    }

    // takes unit value, where 1 ==  parent's ceiling, -1 == parent's floor
    void setHeight(float unitHeight)
    {
        Vector3 globalPos = transform.TransformPoint(ceilingPos);

        //float newZ = unitHeight * globalPos56.z;
        float newZ = unitHeight * ceilingPos.z;

        transform.localPosition = new Vector3(0f, 0f, newZ );
        //Debug.Log("SET POSITION:  unit:" + unitHeight +  " CEILING_Z: " + ceilingPos.z + "  new z: " + newZ + "  position: " +  transform.position);
    }

    // OSC MULTI TOGGLE/BUTTON ITEM   
    // float_arg0: column   float_arg1: row    float_arg2: state
    public void set45( ArrayList args )   // expecting (float)index    (float)state <optional>
    {
        if (args.Count != 3)
        {
            Debug.Log("deflector.set45: missing arguments");
            return;
        }
        int rowCount = 3;  // this item has 1 rows
        
        float column = (float)args [0];
        float row = (float)args [1];
        float state =(float)args [2];
        
        float index = row - 1;
        index +=  rowCount * (column -1 );     

        if (state > 0f) set45(index);
    }

    //index values:  NW, W,SW,N,FLAT,S,NE,E,SE}; 
    public void set45(float index)
    {
        float x = 0;
        float y = 0;
        float z = 0;

        switch ((int) index)
        {
            case (int) tilt45states.E :
                y = -1;
                x = 1;
                z = 0;
                break;
            case (int) tilt45states.W :
                y = -1;
                x = -1;
                z = 0;
                break;
            case (int) tilt45states.FLAT :
                x = 0;
                y = 0;
                z = 0;
                reset();
                break;
            case (int) tilt45states.N :
                x = 0;
                y = -1;
                z = 1;
                break;
            case (int) tilt45states.NE :
                x = -1;
                y = 1;
                z = -1;
                break;
            case (int) tilt45states.SW :
                x = -1;
                y = -1;
                z = -1;
                break;
            case (int) tilt45states.NW :
                x = 1;
                y = 1;
                z = -1;
                break;
            case (int) tilt45states.SE :
                x = -1;
                y = 1;
                z = 1;
                break;
            case (int) tilt45states.S :
                x = 0;
                y = -1;
                z = -1;
                break;
         }

        Vector3 direction = new Vector3(x, y, z);
        transform.rotation = Quaternion.LookRotation(direction,Vector3.up);
    }

    // OSC MULTI TOGGLE/BUTTON ITEM   
    // float_arg0: column   float_arg1: row    float_arg2: state
    public void set90( ArrayList args )   // expecting (float)index    (float)state <optional>
    {
        if (args.Count != 3)
        {
            Debug.Log("deflector.set90: bad arg. count");
            return;
        }
 
        int rowCount = 1;  // this item has 8 rows
        
        float column = (float)args [0];
        float row = (float)args [1];
        float state =(float)args [2];
        
        float index = row - 1;
        index +=  rowCount * (column -1 );     
    
        if (state > 0f) set90(index);
    }
   
    //index values:   _0, _90, _135, _225
    public void set90(float index)
    {
        float x = 0;
        float y = 0;
        float z = 0;
        
        switch ((int) index)
        {
            case (int) tilt90states._0 :
                z = -90;
                x = 0;
                y = 0;
                break;
            case (int) tilt90states._90 :
                z = 0;
                x = -90;
                y = 0;
                break;
            case (int) tilt90states._135 :
                z = -90;
                x = 0;
                y = -45;
                break;
            case (int) tilt90states._225 :
                z = -90;
                x = 0;
                y = 45;
                break;
        }
        transform.rotation = Quaternion.Euler(x,y,z);
    }

//    public void setTilt(int index)
//    {
//        //transform.localRotation = Quaternion.Euler(pyr);
//    }
//

    private float heightReg = 0f;
	// Update is called once per frame
	void Update () 
    {
        if (Input.GetKeyDown(KeyCode.DownArrow))
        {
            transform.Rotate(Vector3.forward, 45f, Space.World);
        } else if (Input.GetKeyDown(KeyCode.UpArrow))
        {
            transform.Rotate(Vector3.forward, -45f, Space.World);
        } else if (Input.GetKeyDown(KeyCode.LeftArrow))
        {
            transform.Rotate(Vector3.up, 45f, Space.World);
        } else if (Input.GetKeyDown(KeyCode.RightArrow))
        {
            transform.Rotate(Vector3.up, -45f, Space.World);
        } else if (enableKeys) 
        {
            for (int i = 0; i <=  9; i++)
            {
                if (Input.GetKeyDown(KeyCode.Alpha0 + i))
                {
                    if (i == 0)
                    {
                        setHeight(1f);
                        set45((float)tilt45states.FLAT);
                    } else
                    {
                        float height = 1 - (2f * (9f - i) / 8f);
                        setHeight(height);
                    }
                }
            }
        }

	}

    private float ClampAngle(this float angle) {
        if(angle < 0f)
            return angle + (360f * (int) ((angle / 360f) + 1));
        else if(angle > 360f)
            return angle - (360f * (int) (angle / 360f));
        else
            return angle;
    }

    private float wrap180(float degrees)
    {
        if (degrees > 180)
            return (-1 * (360 - degrees));
        else
            return(degrees);
    }
}
