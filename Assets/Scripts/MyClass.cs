using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyClass 
{
    static MyClass _instance;
    public static MyClass Instance
    {
        get 
        { 
            if(_instance == null)
            {
                _instance = new MyClass();
            }
            return _instance;
        }
    }
    public void Test()
    {

    }
}
