using UnityEngine;
using System.Collections;
using System.Collections.Generic;


public   class Mathfx
{
    public static Vector3  Hermite(Vector3 start,Vector3 end,float value)
    {
        return new Vector3(Hernite(start.x,end.x,value), Hernite(start.y, end.y, value), Hernite(start.z, end.z, value));
    }
    public static float Hernite(float start,float end,float value)
    {
        return Mathf.Lerp(start,end,value*value*(3.0f-2.0f*value));
    }

}

