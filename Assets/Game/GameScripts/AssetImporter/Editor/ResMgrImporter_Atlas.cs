/***************************************************
 * Data ： 2021/03/06
 * Author: chenyun
 * Description:  打图集工具和规则
***************************************************/
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.U2D;
using UnityEngine;
using UnityEngine.U2D;
using System.Collections.Generic;
using UnityEngine.UI;

public class ResMgrImporter_Atlas 
{
    public static void OnPreProcessTexture(string assetPath,TextureImporter texyreImporter)
    {
        Debug.Log("to do");
        if(assetPath.Contains("/Atlas/"))
        {
            string dir = Path.GetDirectoryName(assetPath);
            string atlasName = new DirectoryInfo(dir).Name;

        }
    }
  
    static HashSet<string> dirSet = new HashSet<string>();
    public static void OnPostprocessAllAssets(string[] importedAsset, string[] deletedAssets, string[] movedAssets, string[] movedFromAssetPaths)
    {
        
        List<string> paths = new List<string>();
        paths.AddRange(importedAsset);
        paths.AddRange(deletedAssets);
        paths.AddRange(movedFromAssetPaths);
        foreach(string assetPath in paths)
        {
            if (!assetPath.Contains("/Atlas/"))
                continue;
            if (Path.GetExtension(assetPath).ToLower() == ".spriteatlas")
                continue;
            if (Path.GetExtension(assetPath).ToLower() == ".meta")
                continue;
            dirSet.Add(Path.GetDirectoryName(assetPath));
        }
        
        foreach (string assetPath in movedAssets)
        {
            if (!assetPath.Contains("/Atlas/"))
                continue;
            if (Path.GetExtension(assetPath).ToLower() == ".spriteatlas")
                continue;
            AssetDatabase.ImportAsset(assetPath);
        }
        if (dirSet.Count >0)
        {
            string[] dirs = dirSet.ToArray();
            dirSet.Clear();
            DoImportAtlas(dirs);
        }
    }
    /// <summary>
    /// dirs 下的每个文件夹资源打成一个图集
    /// </summary>
    /// <param name="resPath"></param>
    private static void DoImportAtlas(string[] dirs)
    {
        foreach(string dir in dirs)
        {
            DirectoryInfo di = new DirectoryInfo(dir);
            if(!di.Exists)
            {
                continue;
            }
            List<Object> assets = FilterAssets(dir);
            if(assets.Count >0)
            {
                string dirName = di.Name;
                string atlasPath = AtlasPath(dir,dirName);
                SpriteAtlas atlas = GenerateAtlas();
                atlas.Add(assets.ToArray());
                if(AssetDatabase.DeleteAsset(atlasPath))
                {
                    Debug.Log(string.Format("Deleta Old Atlas:{0}",atlasPath));
                }
                AssetDatabase.CreateAsset(atlas,atlasPath);
                //设置atlas AssetBundleName 为atlasName
                //AssetImporter importer = AssetImporter.GetAtPath(atlasPath);
               //importer.assetBundleName = Path.GetFileNameWithoutExtension(atlasPath);
               //importer.SaveAndReimport();
            }
        }
    }
    static string AtlasPath(string resFolderPath,string dirName)
    {
        return resFolderPath + "\\" + dirName + ".spriteatlas";
    }
    
    static List<Object> FilterAssets(string folderPath)
    {
        List<Object> objects = new List<Object>();
        DefaultAsset folderAsset = AssetDatabase.LoadAssetAtPath(folderPath, typeof(DefaultAsset)) as DefaultAsset;
        if (Directory.Exists(folderPath))
        { 
            DirectoryInfo dir = new DirectoryInfo(folderPath);
            FileInfo[] files = dir.GetFiles("*", SearchOption.TopDirectoryOnly);
            foreach (var fi in files)
            {
                string spritePath = FullPath2Relative(fi.FullName);
                Sprite sp = AssetDatabase.LoadAssetAtPath<Sprite>(spritePath);
                if (sp != null)
                {
                    objects.Add(sp);
                }
                else
                {
                    Debug.Log("sdadasda dd" + spritePath);
                }
            }
        }
        return objects;
    }

    static string FullPath2Relative(string fullPath)
    {
        string relativePath = fullPath.Substring(fullPath.IndexOf("Assets"));
        relativePath = relativePath.Replace("\\", "/");
        return relativePath;
    }

    private static SpriteAtlas GenerateAtlas()
    {
        // 设置参数 可根据项目具体情况进行设置
        SpriteAtlasPackingSettings packSetting = new SpriteAtlasPackingSettings()
        {
            blockOffset = 1,
            enableRotation = false,
            enableTightPacking = false,
            padding = 2,
        };
        SpriteAtlasTextureSettings textureSetting = new SpriteAtlasTextureSettings()
        {
            readable = false,
            generateMipMaps = false,
            sRGB = true,
            filterMode = FilterMode.Bilinear,
        };
        SpriteAtlas atlas = new SpriteAtlas();
        atlas.SetPackingSettings(packSetting);
        atlas.SetTextureSettings(textureSetting);
        ApplyTexturePlatFormCompressSettingDefault(atlas);
        atlas.SetIncludeInBuild(true);
        atlas.SetIsVariant(false);
        return atlas;
    }
    private static void ApplyTexturePlatFormCompressSettingDefault(SpriteAtlas atlas)
    {
        TextureImporterPlatformSettings textureCompressDefault = new TextureImporterPlatformSettings();
        textureCompressDefault.overridden = false;
        textureCompressDefault.name = "DefaultTexturePlatform";
        textureCompressDefault.textureCompression = TextureImporterCompression.Compressed;
        textureCompressDefault.compressionQuality = 100;
        atlas.SetPlatformSettings(textureCompressDefault);

        TextureImporterPlatformSettings textureCompressIOS = new TextureImporterPlatformSettings();
        textureCompressIOS.name = "iPhone";
        textureCompressIOS.overridden = true;
        textureCompressIOS.textureCompression = TextureImporterCompression.Compressed;
        textureCompressIOS.format = TextureImporterFormat.ASTC_6x6;
        textureCompressIOS.compressionQuality = 100;
        atlas.SetPlatformSettings(textureCompressIOS);

        TextureImporterPlatformSettings textureCompressAndroid = new TextureImporterPlatformSettings();
        textureCompressAndroid.name = "Android";
        textureCompressAndroid.overridden = true;
        textureCompressAndroid.textureCompression = TextureImporterCompression.Compressed;
        textureCompressAndroid.format = TextureImporterFormat.ASTC_6x6;
        textureCompressAndroid.compressionQuality = 100;
        atlas.SetPlatformSettings(textureCompressAndroid);

    }


}
