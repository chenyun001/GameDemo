using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.IO;
using MyGame;

#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.SceneManagement;
#endif
/// <summary>
/// 进游戏一些重要的初始化可以在这里面做
/// </summary>
public class GameEntry : MonoBehaviour
{
#if UNITY_EDITOR
    [MenuItem("MyGame/PlayModeUseStartupScene",true)]
    static bool ValidatePlayModeUseStartupScene()
    {
        Menu.SetChecked("MyGame/PlayModeUseStartupScene", EditorSceneManager.playModeStartScene !=null);
        return !EditorApplication.isPlaying;
    }
    [MenuItem("MyGame/PlayModeUseStartupScene",false,1)]
    static void UpdatePlayModeUseStartupScene()
    {
        if(Menu.GetChecked("MyGame/PlayModeUseStartupScene"))
        {
            EditorSceneManager.playModeStartScene = null;
        }
        else
        {
            SceneAsset scene = AssetDatabase.LoadAssetAtPath<SceneAsset>(EditorBuildSettings.scenes[0].path);
            EditorSceneManager.playModeStartScene = scene;
        }
    }
#endif
    static string LUA_PATH = "assets/game/lua/";
    [RuntimeInitializeOnLoadMethod]
    static void  InitializeOnLoad()
    {
        SceneInit.onBeforeEnterGame = OnBeforeEnterGame;
    }
    /// <summary>
    /// 
    /// </summary>
    static void OnBeforeEnterGame()
    {
        print("LuaManager.Initialize..........");
        LuaManager.Initialize();
        LuaManager.AddLoader((ref string filenmae) =>
        {
            if (filenmae[0] == '@')
            {
                filenmae = filenmae.Substring(1).Replace(".", "/").ToLower() + "/txt";

            }
            else
            {
                filenmae = LUA_PATH + filenmae.Replace(".", "/").ToLower() + ".txt";

            }
            Debug.Log("Load lua model , model filename:=" + filenmae);
            TextAsset script = ResourceManager.LoadAsset(filenmae, typeof(TextAsset)) as TextAsset;
            if (script != null)
            {
                return script.bytes;
            }
            return null;
        });
        LuaManager.LuaEnv.DoString("require(\"main/init\")");
    }

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
