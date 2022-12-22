using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.AddressableAssets;
using UnityEngine.UI;
using MyGame;
#if UNITY_EDITOR
using UnityEditor;
#endif
/// <summary>
/// 进入游戏初始化场景
/// </summary>
public class SceneInit : MonoBehaviour
{
    public Transform ScreenRoot;
    public Transform ResourceManagerObj;
    public Transform Title_Node;
    /// <summary>
    /// 创建管理类并且让其不被销毁
    /// </summary>
    /// <param name="managerName"></param>
    /// <returns></returns>
    GameObject SetNameAndDontDestroy(string managerName)
    {
        GameObject tmpObj = new GameObject();
        tmpObj.transform.name = managerName;
        DontDestroyOnLoad(tmpObj);
        return tmpObj;
    }
    /// <summary>
    /// 后面加载资源更新要用
    /// </summary>
    public static Action onBeforeEnterGame;
    // Start is called before the first frame update
    void Start()
    {
        
        ResourceManager.Initialize();
        ResUpdateFinish();
        DontDestroyOnLoad(ScreenRoot);
    }
    private void EnterGameScene()
    {
        if(onBeforeEnterGame!=null)
        {
            onBeforeEnterGame();
        }
      
        Addressables.LoadSceneAsync("InitScene.unity", LoadSceneMode.Single, true);
        AssetsManager.Instance.GetAsset<GameObject>("UpdateManager.prefab", (GameObject go, object[] param) =>
            {
                Instantiate(go, ScreenRoot);
            }
        );

        //ResourceManager.LoadLevelAsync("Assets/Game/Scenes/InitScene", false,null);
        //ResourceManager.LoadAssetAsync("Assets/Game/Prefabs/UI/UICommon/UpdateManager.prefab", typeof(GameObject), (obj) =>
        //{
        //    Instantiate(obj, ScreenRoot);
        //    //DontDestroyOnLoad(obj);
        //});
    }
    public void ResUpdateFinish()
    {
        EnterGameScene();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
