using System.Collections;
using System.IO;
using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using System;
/// <summary>
/// 设置AB包名
/// </summary>
public class AssetBundleSetLabel
{
    //指定的需要打包的资源目录地址
    static string assetDir = Application.dataPath;
    //static string assetDir = Application.dataPath+"/Game/lua";
    static List<AssetBundleBuild> builds;
    static List<string> scenePaths = new List<string>();
    static MyGameBuildRule myGameBuildRule;
    [MenuItem("Build/SetAbLabel")]
    static void buildABInfo()
    {
        myGameBuildRule = new MyGameBuildRule();
        Caching.ClearCache();
        //刷新资源库
        AssetDatabase.Refresh();
        //清除所有的AssetBundleName
        ClearAssetBundlesName();
        Debug.Log("清除AB包........................................................");
        //设置指定路径下所有需要打包的assetbundlename
        Debug.Log("设置AB包........................................................");
        SetAssetBundlesName(assetDir);
        Debug.Log("设置AB包..................................结束......................");
       
        AssetDatabase.Refresh();
    }

    /// <summary>
    /// 设置所有在指定路径下的AssetBundleName
    /// </summary>
    static void SetAssetBundlesName(string _assetsPath)
    {
       // || StrContains(_assetsPath, "Sounds")
        if (StrContains(_assetsPath, "Xlua") || StrContains(_assetsPath, "Standard Assets") ||
         StrContains(_assetsPath, "Scripts") || StrContains(_assetsPath, "Plugins") ||
          StrContains(_assetsPath, "Gizmos") || StrContains(_assetsPath, "AssetBundles-Browser") ||
          StrContains(_assetsPath, "Demigiant") || StrContains(_assetsPath, "StreamingAssets") ||
          StrContains(_assetsPath, "SpineUnity") || StrContains(_assetsPath, "SpineUnityExamples")
           || StrContains(_assetsPath, "AssetBundles-Browser") 
           || StrContains(_assetsPath, "SpineSkeletons") || StrContains(_assetsPath, "Editor")
           || StrContains(_assetsPath, "Resources")|| StrContains(_assetsPath, "UHUDText"))
        {
            return;
        }
        //先获取指定路径下的所有Asset，包括子文件夹下的资源
        DirectoryInfo dir = new DirectoryInfo(_assetsPath);
        FileSystemInfo[] files = dir.GetFileSystemInfos(); //GetFileSystemInfos方法可以获取到指定目录下的所有文件以及子文件夹

        for (int i = 0; i < files.Length; i++)
        {
            if (files[i] is DirectoryInfo)  //如果是文件夹则递归处理
            {
                SetAssetBundlesName(files[i].FullName);
                continue;
            }
            if (files[i].Name.EndsWith(".meta") || files[i].Name.EndsWith(".cs")) //如果是文件的话，则设置AssetBundleName，并排除掉.meta文件
            {
                continue;

            }
            else if (files[i].Name.EndsWith(".unity"))
            {
                //scenePaths.Add(files[i].FullName);
                SetSecneABLabel(files[i].FullName);
            }
            else
            {
                SetABName(files[i].FullName);     //逐个设置AssetBundleName
            }
        }

    }
    /// <summary>
    /// 设置单个AssetBundle的Name
    /// </summary>
    ///<param name="filePath">
    static void SetABName(string assetPath)
    {
        string importerPath = "Assets" + assetPath.Substring(Application.dataPath.Length);  //这个路径必须是以Assets开始的路径
        //AssetBundleBuild assetBundle = new AssetBundleBuild();
        if (StrContains(assetPath, ".shader"))
        {
            AssetImporter importer = AssetImporter.GetAtPath(importerPath);
            if (importer != null)
            {
                importer.assetBundleName = "Assets/shader.bundle";
                importer.assetBundleVariant = "";
            }
        }
        else
        {
            AssetImporter importer = AssetImporter.GetAtPath(importerPath);
            Debug.Log(importer + "--------------------------------importer");
            if (importer != null)
            {
                string sub_folder_name = importerPath;
                int position = importerPath.LastIndexOf(@"\");
                if (position != -1)
                    sub_folder_name = importerPath.Substring(0, position);
                //Debug.Log("sub_folder_name========================" + sub_folder_name);
                //importer.assetBundleName = AssetBundleName.Replace('/', '_');
                string abName = myGameBuildRule.GetAssetABNameByAssetPath(importerPath);
                Debug.Log(abName+"------------------------------------abName");
                importer.assetBundleName = importerPath; // 以文件名打包
                //importer.assetBundleName = sub_folder_name+ ".assetbundle"; // 以文件夹名打包
                importer.assetBundleVariant = "";
            }
        }
    }
    static void SetSecneABLabel(string assetPath)
    {
        string importerPath = "Assets" + assetPath.Substring(Application.dataPath.Length);  //这个路径必须是以Assets开始的路径
        AssetImporter importer = AssetImporter.GetAtPath(importerPath);
        if (importer != null)
        {
            string sub_folder_name = importerPath;
            int position = importerPath.LastIndexOf(@".");
            if (position != -1)
                sub_folder_name = importerPath.Substring(0, position);
            Debug.Log("sub_folder_name========================" + sub_folder_name);
            importer.assetBundleName = sub_folder_name+ ".ab"; // 以文件夹名打包
            importer.assetBundleVariant = "";
        }
    }
    /// <summary>
    /// 清除所有的AssetBundleName，由于打包方法会将所有设置过AssetBundleName的资源打包，所以自动打包前需要清理
    /// </summary>
    static void ClearAssetBundlesName()
    {
        //获取所有的AssetBundle名称
        string[] abNames = AssetDatabase.GetAllAssetBundleNames();

        //强制删除所有AssetBundle名称
        for (int i = 0; i < abNames.Length; i++)
        {
            AssetDatabase.RemoveAssetBundleName(abNames[i], true);
        }
    }


    static void BuildPlayer(string[] scenePaths, string outPath, string sceneName)
    {
        string dir = outPath;
        if (Directory.Exists(dir) == false)
        {
            Directory.CreateDirectory(dir);
        }
        string[] path = scenePaths;
        BuildPipeline.BuildPlayer(path, outPath + "/" + sceneName + ".ab",
            BuildTarget.StandaloneWindows64, BuildOptions.BuildAdditionalStreamedScenes);
    }

    static void BuildPlayerAndroid(string[] scenePaths, string outPath, string sceneName)
    {
        string dir = outPath;
        if (Directory.Exists(dir) == false)
        {
            Directory.CreateDirectory(dir);
        }
        string[] path = scenePaths;
        BuildPipeline.BuildPlayer(path, outPath + "/" + sceneName + ".ab",
            BuildTarget.StandaloneWindows64, BuildOptions.BuildAdditionalStreamedScenes);
    }

    private static bool StrContains(string str, string value)
    {
        return str.IndexOf(value, System.StringComparison.OrdinalIgnoreCase) != -1;
    }
    // private static bool StrEndWith(string str, string value)
    // {
    //     return str.IndexOf(value, System.StringComparison.OrdinalIgnoreCase);
    // }
}