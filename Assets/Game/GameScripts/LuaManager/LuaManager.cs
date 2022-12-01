using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using XLua;

using LuaAPI = XLua.LuaDLL.Lua;
using RealStatePtr = System.IntPtr;
using LuaCsFunction = XLua.LuaDLL.lua_CSFunction;
using System.Reflection;
public class LuaManager : MonoBehaviour
{
    [System.Serializable]
    public class Injection
    {
        public string name;
        public GameObject value;
    }
    private static LuaManager instance;
    private static LuaEnv luaEnv;
    public static LuaManager Instance
    {
        get
        {
            return instance;
        }
        set
        {
            instance = value;
        }
    }
    public static LuaEnv LuaEnv
    {
        get
        {
            return luaEnv;
        }
        set
        {
            luaEnv = value;
        }
    }
    private void Awake()
    {
        instance = this;
    }
    public static void Initialize()
    {
        luaEnv = new LuaEnv();
    }
    public static void AddLoader(LuaEnv.CustomLoader loader)
    {
        luaEnv.AddLoader(loader);

    }
    void Update()
    {
        if(luaEnv!=null)
        {
            luaEnv.Tick();
        }
    }
    public static void Deinitialize()
    {
        if(luaEnv!=null)
        {
            luaEnv.Dispose();
            luaEnv = null;
        }
    }
    public void OnDestroy()
    {
        Deinitialize();
    }


}
