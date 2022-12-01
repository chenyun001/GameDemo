/*
 * Tencent is pleased to support the open source community by making xLua available.
 * Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/
using UnityEngine;
using XLua;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.Profiling;
using System.Linq;
using System;
#if UNITY_EDITOR
using UnityEditor;
#endif

[System.Serializable]
public class Injection
{
    public string name;
    public UnityEngine.Object value;
}

public class LuaBehaviour : MonoBehaviour
{
    public TextAsset luaScript;
    public Injection[] bindVariables;

    //internal static LuaEnv luaEnv = new LuaEnv(); //all lua behaviour shared one luaenv only!
    internal static float lastGCTime = 0;
    internal const float GCInterval = 1;//1 second 

    private Action luaStart;
    private Action luaUpdate;
    private Action luaOnDestroy;

    public LuaTable scriptEnv;
    string ScriptName
    {
        get
        {
            return luaScript.name;
        }
    }


    void Awake()
    {
        if(LuaManager.LuaEnv == null)
        {
            LuaManager.Initialize();
        }
        scriptEnv = LuaManager.LuaEnv.NewTable();

        // 为每个脚本设置一个独立的环境，可一定程度上防止脚本间全局变量、函数冲突
        LuaTable meta = LuaManager.LuaEnv.NewTable();
        meta.Set("__index", LuaManager.LuaEnv.Global);//把Global（全局表）设置成该脚本的元表
        scriptEnv.SetMetaTable(meta);
        meta.Dispose();

        scriptEnv.Set("self", this);
        LuaManager.LuaEnv.DoString(luaScript.bytes,ScriptName,scriptEnv);
        foreach (var injection in bindVariables)
        {
            print(injection.name);
            scriptEnv.Set(injection.name, injection.value);
        }

        System.Action luaAwake = scriptEnv.Get<System.Action>("Awake");
        scriptEnv.Get("Start", out luaStart);
        scriptEnv.Get("Update", out luaUpdate);
        scriptEnv.Get("Ondestroy", out luaOnDestroy);

        if (luaAwake != null)
        {
            luaAwake();
        }
    }

    // Use this for initialization
    void Start()
    {
        if (luaStart != null)
        {
            luaStart();
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (luaUpdate != null)
        {
            luaUpdate();
        }
        if (Time.time - LuaBehaviour.lastGCTime > GCInterval)
        {
            LuaManager.LuaEnv.Tick();
            LuaBehaviour.lastGCTime = Time.time;
        }
    }

    void OnDestroy()
    {
        if (luaOnDestroy != null)
        {
            luaOnDestroy();
        }
        luaOnDestroy = null;
        luaUpdate = null;
        luaStart = null;
        scriptEnv.Dispose();
        bindVariables = null;
    }
}

