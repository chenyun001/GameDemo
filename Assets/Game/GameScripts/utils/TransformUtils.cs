using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TransformUtils
{ 
    public static void RemoveChildFormParent(Transform parent,string childName )
    {
        var obj = parent.Find(childName).gameObject;
        if(obj!=null)
        {
            Debug.Log("is null...");
            GameObject.DestroyImmediate(obj);
        }else
        {
            Debug.Log("is null ");
        }
    }
}
