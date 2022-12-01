using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Text.RegularExpressions;
using System.IO;
using System;
namespace MyGame
{
    /// <summary>
    /// 已经加载的AssetBundle
    /// </summary>
    public class LoadedAssetBundle
    {
        public AssetBundle m_AssetBundle;
        public LoadedAssetBundle(AssetBundle bundle)
        {
            m_AssetBundle = bundle;

        }
    }
    /// <summary>
    /// 异步加载AssetBundle的任务类
    /// </summary>
    public class LoadTask
    {
        string m_BundleNamePath;
        AssetBundleCreateRequest m_RequestAB;
        public string BundleNamePath
        {
            get { return m_BundleNamePath; }
            set { m_BundleNamePath = value; }
        }
        public bool IsDone
        {
            get
            {
                return m_RequestAB != null && m_RequestAB.isDone;
            }
        }
        public AssetBundle AssetBundle
        {
            get
            {
                if(m_RequestAB!=null)
                {
                    return m_RequestAB.assetBundle;
                }
                return null;
            }
        }
        public LoadTask(string bunleNamePath)
        {
            m_BundleNamePath = bunleNamePath;
        }
        public bool Start()
        {
            string absPath = ResourceManager.STREAMING_ASSET_PATH + m_BundleNamePath;
            Debug.Log("absPath="+absPath);
            m_RequestAB = AssetBundle.LoadFromFileAsync(absPath);
            if (m_RequestAB != null)
                return true;
            return false;
        }
    }

    /// <summary>
    /// 异步从AssetBundle中加载资源的状态
    /// </summary>
    public enum LoadState
    {
        waitAssetBundle,//等待 AssetBundle加载
        WaitMainAsset,//等待资源加载
        AllDone,//所有资源加载完成
    }
    /// <summary>
    /// 资源加载行动基类
    /// </summary>
    public abstract class LoadOperation : IEnumerator
    {
        protected string m_BundleName;
        protected LoadState m_State;
        protected UnityEngine.Object m_Asset;
        protected System.Action<UnityEngine.Object> m_CallBack;
        public string BundleName
        {
            get
            {
                return m_BundleName;
            }
            set { m_BundleName = value; }
        }
        public LoadState State
        {
            get
            {
                return m_State;
            }
            set
            {
                m_State = value;
            }
        }
        public void SetCallBack(System.Action<UnityEngine.Object> callBack)
        {
            
            m_CallBack = callBack;

        }
        public void FireCallBack()
        {
            if(m_CallBack != null)
            {

                try
                {
                    m_CallBack(m_Asset);
                }
                catch(System.Exception e)
                {
                    //todo 打印错误日志
                }
                m_CallBack = null;
            }
        }
        public bool IsAlllDone()
        {
            return m_State == LoadState.AllDone;
        }
        public object Current
        {
            get
            {
                return null;
            }
        }
        public bool MoveNext()
        {
            return !IsAlllDone();
        }
        public void Reset()
        {

        }
        public void Unload()
        {

        }
        public void Preserve()
        {

        }
        abstract internal bool Update();


    }
    /// <summary>
    /// 加载资源Asset
    /// </summary>
    public class  LoadAssetOperation:LoadOperation
    {
        //从AB包中加载资源
        AssetBundleRequest m_RequestAsset;
        string m_AssetName;
        System.Type m_Type;
        LoadedAssetBundle m_Bundle;
        internal LoadAssetOperation(UnityEngine.Object obj,string bundleName,string assetName,System.Type type)
        {
            m_Asset = obj;
            m_RequestAsset = null;
            m_BundleName = null;
            m_AssetName = null;
            m_Type = type;
            m_State = LoadState.AllDone;
        }
        internal LoadAssetOperation(string bundleName,string assetName,System.Type type)
        {
            m_Asset = null;
            m_RequestAsset = null;
            m_BundleName = bundleName;
            m_AssetName = ResourceManager.GetLastPartNameOfPath(assetName);
            m_Type = type;
            m_State = LoadState.waitAssetBundle;

        }
        internal LoadAssetOperation(string name,System.Type type):this(name,name,type)//指向构造函数
        {

        }
        internal override bool Update()
        {
            //throw new NotImplementedException();
            bool isDone = false;
            if(m_State== LoadState.waitAssetBundle)
            {
                m_Bundle = ResourceManager.GetLoadedAssetBundleWithDependencies(m_BundleName);
                if(m_Bundle!=null)
                {
                    if(m_Bundle.m_AssetBundle == null)
                    {
                        m_State = LoadState.AllDone;
                    }
                    else
                    {
                        if(!ResourceManager.IsUnloadingUnusedAssets)
                        {
                            m_RequestAsset = m_Bundle.m_AssetBundle.LoadAssetAsync(m_AssetName,m_Type);
                            m_State = LoadState.WaitMainAsset;
                        }
                    }
                }
            }
            if(m_State==LoadState.WaitMainAsset)
            {
                if(m_RequestAsset.isDone)
                {
                    m_Asset = m_RequestAsset.asset;
                    m_State = LoadState.AllDone;
                    m_Bundle = null;
                    m_RequestAsset = null;
                }
            }
            if(m_State == LoadState.AllDone && m_CallBack!=null)
            {
                isDone = true;
            }
            return isDone;
        }
    }
    /// <summary>
    /// 加载场景资源的类
    /// </summary>
    public class LoadLevelOperation : LoadOperation
    {
        AsyncOperation m_AsyncOperation = null;
        public AsyncOperation AsyncOperation
        {
            get
            {
                return m_AsyncOperation;
            }
        }
        bool m_IsAdditive;
        //加载速度
        public float progerss
        {
            get
            {
                if(m_State == LoadState.AllDone)
                {
                    return 1.0f;
                }else
                {
                    return m_AsyncOperation == null ? 0.0f : m_AsyncOperation.progress;

                }
            }
        }
        public LoadLevelOperation(AsyncOperation op)
        {
            m_AsyncOperation = op;
            m_State = LoadState.WaitMainAsset;
        }
        public  LoadLevelOperation(string name, bool isAdditive)
        {
            m_BundleName = name;
            m_IsAdditive = isAdditive;
        }
        internal override bool Update()
        {
            bool isDone = false;
            if(m_State == LoadState.waitAssetBundle)
            {
                Debug.Log("m_bundleName=...."+m_BundleName);
                LoadedAssetBundle bundle = ResourceManager.GetLoadedAssetBundleWithDependencies(m_BundleName);
                if(bundle != null)
                {
                    Debug.Log("m_bundleName=...." + m_BundleName);
                    if(bundle.m_AssetBundle==null)
                    {
                        Debug.Log("m_bundleName=...." + m_BundleName);
                        m_State = LoadState.AllDone;
                    }
                    else
                    {
                        if(!ResourceManager.IsUnloadingUnusedAssets)
                        {
                            string sceneName = ResourceManager.GetLastPartNameOfPath(m_BundleName);
                            string[] strTpl = sceneName.Split('.');
                            sceneName = strTpl[0];
                            m_AsyncOperation = UnityEngine.SceneManagement.SceneManager.LoadSceneAsync(sceneName,
                                m_IsAdditive ? UnityEngine.SceneManagement.LoadSceneMode.Additive:UnityEngine.SceneManagement.LoadSceneMode.Single);
                            m_AsyncOperation.allowSceneActivation = false;
                            m_State = LoadState.WaitMainAsset;
                        }

                    }
                }

            }
            if(m_State == LoadState.WaitMainAsset)
            {

                if(m_AsyncOperation.progress >= 0.9f)
                {
                    Debug.Log("m_AsyncOperation.progress>=0.9"+m_AsyncOperation.progress);
                    m_AsyncOperation.allowSceneActivation = true;
                }
                if(m_AsyncOperation.isDone)
                {
                    Debug.Log("m_AsyncOperation.isDone");
                    m_AsyncOperation = null;
                    m_State = LoadState.AllDone;
                }

            }
            if(m_State == LoadState.AllDone &&m_CallBack != null)
            {
                isDone = true;
            }
            return isDone;
        }
    }
    /// <summary>
    /// AB包资源加载与管理
    /// </summary>
    public class ResourceManager : MonoBehaviour
    {
        private static GameObject m_GameObject;
        public static string platformName =
#if UNITY_EDITOR || UNITY_STANDALONE_WIN
            "PC";
#elif UNITY_ANDROID
       "Android";
#elif UNITY_IPHONE
     "IOS";
#endif
        //是否在unity编辑器中使用Ab
        public static bool IsOnUnityEditerUseAB = false;
        public static string STREAMING_ASSET_PATH =
#if UNITY_EDITOR
            Path.Combine( Application.streamingAssetsPath + "/VFS/", platformName+"/main/") ;
#else
#if UNITY_ANDROID
            Path.Combine(Application.streamingAssetsPath + "/VFS/", platformName+"/main/") ;
            //Application.streamingAssetsPath+"/VFS/"+platformName+"/main/";
#elif UNITY_EDITOR_WIN
             Path.Combine(Application.streamingAssetsPath + "/VFS/", platformName+"/main/") ;
#elif UNITY_IPHONE || UNITY_IOS
            Path.Combine(  Application.streamingAssetsPath + "/VFS/", platformName+"/main/") ;
#else
             Path.Combine(Application.streamingAssetsPath + "/VFS/", platformName+"/main/") ;
#endif
#endif

        /// <summary>
        /// 释放不需要的资源
        /// </summary>
        static AsyncOperation unLoadUnusedAssetsAsyncOperation = null;
        /// <summary>
        /// 判断是否有不需要的资源正在被释放
        /// </summary>
        public static bool IsUnloadingUnusedAssets
        {
            get { return unLoadUnusedAssetsAsyncOperation != null; }
        }
        /// <summary>
        /// https://www.sipspf.org.cn/publish/main/index.html
        /// </summary>
        static bool m_NeedUnloadUnusedAssets = false;
        /// <summary>
        /// Mainfest
        /// </summary>
        static AssetBundleManifest AssetBundleManifest = null;
        /// <summary>
        /// 存储已加载的AB
        /// </summary>
        static List<LoadedAssetBundle> m_LoadedAssetBundles = new List<LoadedAssetBundle>();
        /// <summary>
        /// 正在加载AB包的任务表
        /// </summary>
        static List<LoadTask> m_LoadingTasks = new List<LoadTask>();
        /// <summary>
        /// 正在加载资源的Asset的行动表
        /// </summary>
        static List<LoadOperation> m_LoadingOperations = new List<LoadOperation>();
        /// <summary>
        /// ab包加载依赖
        /// </summary>
        static Dictionary<string, string[]> m_Dependencies = new Dictionary<string, string[]>();
        public static void Initialize()
        {
            if(m_GameObject != null)
            {
                return;
            }
            if(IsOnUnityEditerUseAB)
            {
                Debug.Log("STREAMING_ASSET_PATH"+STREAMING_ASSET_PATH);
              
            }
            m_GameObject = new GameObject("ResourceManager", typeof(ResourceManager));
            DontDestroyOnLoad(m_GameObject);
            DoClear(true);

        }
        public static void DeInitialize()
        {
            if(m_GameObject==null)
            {
                return;
            }
            if(AssetBundleManifest!=null)
            {
                Resources.UnloadAsset(AssetBundleManifest);
                AssetBundleManifest = null;
            }
            DoClear(true);
            Destroy(m_GameObject);
            m_GameObject = null;

        }
        static void FinishTask()
        {
            foreach(var task in m_LoadingTasks)
            {
                OnAssetBundleLoaded(task.BundleNamePath,task.AssetBundle);
            }
            m_LoadingTasks.Clear();
        }
        static void DoClear(bool unloadAllLoadedObjects)
        {
            if(unloadAllLoadedObjects)
            {
                foreach(var item in m_LoadedAssetBundles)
                {
                    if(item.m_AssetBundle != null)
                    {
                        item.m_AssetBundle.Unload(true);
                    }
                }
            }
            else
            {
                foreach(var item in m_LoadedAssetBundles)
                {
                    if(item.m_AssetBundle != null)
                    {
                        item.m_AssetBundle.Unload(false);
                    }
                }
            }
            m_LoadedAssetBundles.Clear();
            m_LoadingOperations.Clear();
            m_Dependencies.Clear();
        }
        private void OnDestroy()
        {
            DeInitialize();
        }
        private void Update()
        {
            for(int i = 0;i<m_LoadingTasks.Count;)
            {
                LoadTask task = m_LoadingTasks[i];
                if(task.IsDone)
                {
                    m_LoadingTasks.RemoveAt(i);
                    OnAssetBundleLoaded(task.BundleNamePath,task.AssetBundle);
                }
                else
                {
                    i++;
                }
            }
            for(int i = 0;i<m_LoadingOperations.Count;)
            {
                
                var operation = m_LoadingOperations[i];
                if(operation.Update())
                {
                    m_LoadingOperations.RemoveAt(i);

                    operation.FireCallBack();
                }
                else
                {
                    i++;
                }
            }
            CheckUnLoadUnusedTask();
        }
        /// <summary>
        /// 获取路径中最后一部分的名称（文件名或文件夹名）
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        public static string GetLastPartNameOfPath(string path)
        {
            //截取最后一部分名称，名称的末尾可能带有多个斜杆（/）或反斜杆（\）
            var pattern = @"[^/\\]+[/\\]*$";
            var match = Regex.Match(path,pattern);
            var name = match.Value;
            //
            pattern = @"[^/\\]+";
            match = Regex.Match(name, pattern);
            name = match.Value;
            return name;
        }
        /// <summary>
        /// 加载Ab
        /// </summary>
        /// <param name="assetBundlePath"></param>
        /// <returns></returns>
        static AssetBundle LoadAssetBundle(string assetBundlePath)
        {
            return AssetBundle.LoadFromFile(STREAMING_ASSET_PATH+assetBundlePath);
        }
        /// <summary>
        /// 从本地文件中加载AssetBundleManifest对象
        /// </summary>
        protected static void LoadAssetBundleManifest()
        {
            if(AssetBundleManifest == null)
            {
                string assetbundlePath = STREAMING_ASSET_PATH+ "main";
                Debug.Log("assetbundlePath"+assetbundlePath);
                var rootAb = AssetBundle.LoadFromFile(assetbundlePath);
                AssetBundleManifest = rootAb.LoadAsset<AssetBundleManifest>("AssetBundleManifest");
                rootAb.Unload(false);
            }
        }
        /// <summary>
        /// 同步加载AB
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        protected static LoadedAssetBundle LoadAssetBundleSync(string path)
        {
            if(string.IsNullOrEmpty(path))
            {
                return null;
            }
            LoadedAssetBundle bundle = null;
            string bundleName = path;
            bundle = GetAssetBundleInList(m_LoadedAssetBundles,bundleName);
            if(bundle != null)
            {
                return bundle;
            }
            LoadDependencies(path,false);
            bundle = LoadAssetBundleInternal(path,false);
            return bundle;
        }
        /// <summary>
        /// 异步加载Ab
        /// </summary>
        /// <param name="path"></param>
        protected static void LoadAssetBundleAsync(string path)
        {
            if(string.IsNullOrEmpty(path))
            {
                return;
            }
            LoadedAssetBundle bundle = null;
            string bundleName = path;
            bundle = GetAssetBundleInList(m_LoadedAssetBundles,bundleName);
            if(bundle != null)
            {
                return;
            }
            LoadDependencies(path,true);
            LoadAssetBundleInternal(path, true);
        }
        /// <summary>
        /// 加载依赖的AB
        /// </summary>
        /// <param name="name"></param>
        /// <param name="async"></param>
        protected static void LoadDependencies(string name,bool async)
        {
            string[] dependcies = null;
            if(m_Dependencies.ContainsKey(name))
            {
                dependcies = m_Dependencies[name];
            }
            if(dependcies == null)
            {
                dependcies = AssetBundleManifest.GetAllDependencies(name);
                m_Dependencies.Add(name,dependcies);
            }
            for(int i = 0;i<dependcies.Length;i++)
            {
                LoadAssetBundleInternal(dependcies[i], async);
            }
        }
        internal static LoadedAssetBundle GetLoadedAssetBundleWithDependencies(string name)
        {
            LoadedAssetBundle bundle = null;
            bundle = GetAssetBundleInList(m_LoadedAssetBundles,name);
            if(bundle == null)
            {
                return null;
            }
            string[] dependencies = null;
            if(!m_Dependencies.ContainsKey(name))
            {
                return bundle;
            }else
            {
                dependencies = m_Dependencies[name];
            }
            foreach(var depend in dependencies)
            {
                if(string.IsNullOrEmpty(depend))
                {
                    continue;
                }
                LoadedAssetBundle dependentBundle;
                dependentBundle = GetAssetBundleInList(m_LoadedAssetBundles,depend);
                if (dependentBundle == null)
                    return null;
            }
            return bundle;
        }
        protected static LoadedAssetBundle LoadAssetBundleInternal(string path,bool async)
        {
            LoadedAssetBundle bundle = null;
            string bundleName = path;
            bundle = GetAssetBundleInList(m_LoadedAssetBundles, bundleName);
            if(bundle != null)
            {
                return bundle;
            }
            if(async == true)
            {
                //todo 还需要判断一下是不是加载任务中了
                LoadTask task = new LoadTask(path);
                if(!task.Start())
                {
                    OnAssetBundleLoaded(path,null);
                    return null;
                }else
                {
                    Debug.Log("Start Task fail,path="+path);
                }
                m_LoadingTasks.Add(task);
                return null;
            }else
            {
                AssetBundle assetBundle;
                assetBundle = LoadAssetBundle(path);
                if(assetBundle==null)
                {
                    return null;
                }
                return OnAssetBundleLoaded(path, assetBundle);
            }
        }
        /// <summary>
        /// 已经加载成功的AB并存到m_LoadedAssetBundles中
        /// </summary>
        /// <param name="path"></param>
        /// <param name="assetBundle"></param>
        /// <returns></returns>
        static LoadedAssetBundle OnAssetBundleLoaded(string path,AssetBundle assetBundle)
        {
            LoadedAssetBundle bundle = null;
            string bundleName = path;
            bundle = GetAssetBundleInList(m_LoadedAssetBundles,bundleName);
            if(bundle!=null)
            {
                return bundle;
            }
            if(string.IsNullOrEmpty(assetBundle.name))
            {
                assetBundle.name = path;
            }
            bundle = new LoadedAssetBundle(assetBundle);
            m_LoadedAssetBundles.Add(bundle);
            return bundle;
        }
        /// <summary>
        /// 已经加载的AB包中获取ab
        /// </summary>
        /// <param name="list"></param>
        /// <param name="bundleName"></param>
        /// <returns></returns>
        public static LoadedAssetBundle GetAssetBundleInList(List<LoadedAssetBundle> list,string bundleName)
        {
            string name = bundleName;
            for(int i= 0;i<list.Count;i++)
            {
                if(list[i].m_AssetBundle.name.ToLower() == name.ToLower())
                {
                    return list[i];
                }
            }
            return null;

        }
#region LoadAsset 资源加载
        /// <summary>
        /// 同步加载Asset
        /// </summary>
        /// <param name="assetPath"></param>
        /// <param name="type"></param>
        /// <returns></returns>
        public static UnityEngine.Object LoadAsset(string assetPath,System.Type type)
        {
            assetPath = assetPath.ToLower();
#if UNITY_EDITOR
            if (IsOnUnityEditerUseAB==false)
            {
                return AssetDatabase.LoadAssetAtPath(assetPath,type);
            }
#endif
            string bundleName = GetLastPartNameOfPath(assetPath);
            LoadAssetBundleManifest();
            LoadedAssetBundle bundle = null;
            bundle = LoadAssetBundleSync(assetPath);
            if(bundle != null)
            {
                return bundle.m_AssetBundle.LoadAsset(bundleName,type);
            }
            return null;
        }
        public static LoadAssetOperation LoadAssetAsync(string assetPath,System.Type type,System.Action<UnityEngine.Object> callback = null)
        {
            LoadAssetOperation operation;
            assetPath = assetPath.ToLower();
#if UNITY_EDITOR
            if (IsOnUnityEditerUseAB == false)
            {
                UnityEngine.Object obj = AssetDatabase.LoadAssetAtPath(assetPath,type);
                operation = new LoadAssetOperation(obj, assetPath, assetPath, type);
                operation.SetCallBack(callback);
                m_LoadingOperations.Add(operation);
                return operation;
            }
#endif
            Debug.Log("assetPath........................" + assetPath);
            LoadAssetBundleManifest();
            LoadAssetBundleSync(assetPath);
            operation = new LoadAssetOperation(assetPath,type);
            operation.SetCallBack(callback);
            m_LoadingOperations.Add(operation);
            return operation;
        }
        /// <summary>
        /// 异步加载场景
        /// </summary>
        /// <param name="assetpath"></param>
        /// <param name="isAdditive"></param>
        /// <param name="callback"></param>
        /// <returns></returns>
        public static LoadLevelOperation LoadLevelAsync(string assetPath,bool isAdditive,System.Action<UnityEngine.Object> callback = null)
        {
            LoadLevelOperation operation;
#if UNITY_ANDROID
            assetPath = assetPath.ToLower();
#endif
#if UNITY_EDITOR
            if (IsOnUnityEditerUseAB== false)
            {
                assetPath = assetPath + ".unity";
                AsyncOperation asyncOp = null;
                if (isAdditive)
                    asyncOp = EditorApplication.LoadLevelAdditiveAsyncInPlayMode(assetPath);
                else
                    asyncOp = EditorApplication.LoadLevelAsyncInPlayMode(assetPath);
                operation = new LoadLevelOperation(asyncOp);
                operation.SetCallBack(callback);
                m_LoadingOperations.Add(operation);
                return operation;

            }
#endif
            assetPath = assetPath + ".ab";
            LoadAssetBundleManifest();
            LoadAssetBundleSync(assetPath);
            operation = new LoadLevelOperation(assetPath,isAdditive);
            operation.SetCallBack(callback);
            m_LoadingOperations.Add(operation);
            return operation;

        }
#endregion

#region 资源释放
        public static void UnloadUnusedAssets()
        {
            m_NeedUnloadUnusedAssets = true;
        }
        /// <summary>
        /// 不需要的资源释放
        /// </summary>
        private static void CheckUnLoadUnusedTask()
        {
            if(IsUnloadingUnusedAssets)
            {
                if(unLoadUnusedAssetsAsyncOperation.isDone)
                {
                    unLoadUnusedAssetsAsyncOperation = null;
                }
            }else
            {
                if(m_NeedUnloadUnusedAssets && m_LoadingOperations.Count == 0)
                {
                    unLoadUnusedAssetsAsyncOperation = Resources.UnloadUnusedAssets();
                    m_NeedUnloadUnusedAssets = false;
                }
            }

        }
#endregion
       
    }

}


