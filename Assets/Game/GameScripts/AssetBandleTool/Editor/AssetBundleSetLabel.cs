using System.Collections;
using System.IO;
using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using System;
/// <summary>
/// ����AB����
/// </summary>
public class AssetBundleSetLabel
{
    //ָ������Ҫ�������ԴĿ¼��ַ
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
        //ˢ����Դ��
        AssetDatabase.Refresh();
        //������е�AssetBundleName
        ClearAssetBundlesName();
        Debug.Log("���AB��........................................................");
        //����ָ��·����������Ҫ�����assetbundlename
        Debug.Log("����AB��........................................................");
        SetAssetBundlesName(assetDir);
        Debug.Log("����AB��..................................����......................");
       
        AssetDatabase.Refresh();
    }

    /// <summary>
    /// ����������ָ��·���µ�AssetBundleName
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
        //�Ȼ�ȡָ��·���µ�����Asset���������ļ����µ���Դ
        DirectoryInfo dir = new DirectoryInfo(_assetsPath);
        FileSystemInfo[] files = dir.GetFileSystemInfos(); //GetFileSystemInfos�������Ի�ȡ��ָ��Ŀ¼�µ������ļ��Լ����ļ���

        for (int i = 0; i < files.Length; i++)
        {
            if (files[i] is DirectoryInfo)  //������ļ�����ݹ鴦��
            {
                SetAssetBundlesName(files[i].FullName);
                continue;
            }
            if (files[i].Name.EndsWith(".meta") || files[i].Name.EndsWith(".cs")) //������ļ��Ļ���������AssetBundleName�����ų���.meta�ļ�
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
                SetABName(files[i].FullName);     //�������AssetBundleName
            }
        }

    }
    /// <summary>
    /// ���õ���AssetBundle��Name
    /// </summary>
    ///<param name="filePath">
    static void SetABName(string assetPath)
    {
        string importerPath = "Assets" + assetPath.Substring(Application.dataPath.Length);  //���·����������Assets��ʼ��·��
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
                importer.assetBundleName = importerPath; // ���ļ������
                //importer.assetBundleName = sub_folder_name+ ".assetbundle"; // ���ļ��������
                importer.assetBundleVariant = "";
            }
        }
    }
    static void SetSecneABLabel(string assetPath)
    {
        string importerPath = "Assets" + assetPath.Substring(Application.dataPath.Length);  //���·����������Assets��ʼ��·��
        AssetImporter importer = AssetImporter.GetAtPath(importerPath);
        if (importer != null)
        {
            string sub_folder_name = importerPath;
            int position = importerPath.LastIndexOf(@".");
            if (position != -1)
                sub_folder_name = importerPath.Substring(0, position);
            Debug.Log("sub_folder_name========================" + sub_folder_name);
            importer.assetBundleName = sub_folder_name+ ".ab"; // ���ļ��������
            importer.assetBundleVariant = "";
        }
    }
    /// <summary>
    /// ������е�AssetBundleName�����ڴ�������Ὣ�������ù�AssetBundleName����Դ����������Զ����ǰ��Ҫ����
    /// </summary>
    static void ClearAssetBundlesName()
    {
        //��ȡ���е�AssetBundle����
        string[] abNames = AssetDatabase.GetAllAssetBundleNames();

        //ǿ��ɾ������AssetBundle����
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