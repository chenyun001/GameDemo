using System.Collections.Generic;
using System.IO;
using System.Threading;
using UnityEditor;
using UnityEditor.AddressableAssets;
using UnityEditor.AddressableAssets.GUI;
using UnityEditor.AddressableAssets.Settings;
using UnityEditor.AddressableAssets.Settings.GroupSchemas;
using UnityEngine;

public class SingleSourceAddressableEditor : Editor
{
    [MenuItem("Assets/CreateAsset/EveryChildFolders")]
    public static void CreateFolders()
    {
        string folderPath = GetActiveFolderPath();
        DirectoryInfo directory = new DirectoryInfo(GetActiveFolderPath());

        Dictionary<string, string> groupMap = new Dictionary<string, string>();
        EditorUtility.DisplayProgressBar("CreateGroups","Start",0);

        foreach (var dir in directory.GetDirectories())
        {
            var group = FindOrCreateGroup(dir.Name);

            groupMap.Add(dir.Name,folderPath+"/"+dir.Name);
            
        }
        foreach (var path in groupMap.Values)
        {
           var thread = new Thread(new ThreadStart(CreateEntryByPath));

            CreateEntryByPath(path);
        }
        
        EditorUtility.ClearProgressBar();
        
    }

    private static void CreateEntryByPath()
    {
        
        
    }

    public static void CreateEntryByPath(string path)
    {
        var dir = new DirectoryInfo(path);
        var group = FindOrCreateGroup(dir.Name);
        foreach (var file in dir.GetFiles())
        {
            
            if (!file.Name.Contains(".meta") && !file.Name.StartsWith("."))
            {
                var entry= AddressableAssetSettingsDefaultObject.Settings.CreateOrMoveEntry(
                    AssetDatabase.AssetPathToGUID(path+ "/" + file.Name), group);
                entry.address = file.Name;
            }
        }
    }

    public static AddressableAssetGroup FindOrCreateGroup(string name)
    {
        var group = AddressableAssetSettingsDefaultObject.Settings.FindGroup(name);
        if (group == null)
        {
            AddressableAssetSettingsDefaultObject.Settings.CreateGroup(name, false, false, false, null,
                typeof(ContentUpdateGroupSchema), typeof(BundledAssetGroupSchema));
        }

        return group;
    }

    [MenuItem("Assets/CreateAsset/Files")]
    public static void CreateFile()
    {
        string folderPath = GetActiveFolderPath();
        DirectoryInfo directoryInfo = new DirectoryInfo(folderPath);
        FindOrCreateGroup(directoryInfo.Name);
        // ThreadPool.QueueUserWorkItem();
        CreateEntryByPath(folderPath);
    }

    public static string GetActiveFolderPath()
    {
        var path = "Assets";

        foreach (var obj in Selection.GetFiltered(typeof(UnityEngine.Object), SelectionMode.Assets))
        {
            path = AssetDatabase.GetAssetPath(obj);
            if (!string.IsNullOrEmpty(path) && File.Exists(path))
            {
                path = Path.GetDirectoryName(path);
                break;
            }
        }

        return path;
    }
}