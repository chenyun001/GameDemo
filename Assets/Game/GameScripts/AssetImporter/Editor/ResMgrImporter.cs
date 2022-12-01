/***************************************************
 * Data ： 2021/03/06
 * Author: chenyun
 * Description:  资源导入管理类 
***************************************************/
using UnityEngine;
using UnityEditor;
using System.IO;
using System.Linq;
using UnityEngine.UI;
using System.Collections;
using System.Collections.Generic;

public class ResMgrImporter : AssetPostprocessor
{
#if UNITY_EDITOR_WIN

    public void OnPreprocessTexture()
    {
        TextureImporter impor = this.assetImporter as TextureImporter;
    }
#endif
    private static HashSet<string> m_delayedAssets = new HashSet<string>();
#if UNITY_EDITOR_WIN
    public static void OnPostprocessAllAssets(string[] importedAsset, string[] deletedAssets, string[] movedAssets, string[] movedFromAssetPaths)
    {
        bool addFlag = false;
        for(int i=0;i<importedAsset.Length;i++)
        {
            addFlag = m_delayedAssets.Add(importedAsset[i])||addFlag;

        }
        for(int i=0;i<movedAssets.Length;i++)
        {
            addFlag = m_delayedAssets.Add(movedAssets[i])||addFlag;
        }
        if(addFlag || deletedAssets.Length > 0 || movedFromAssetPaths.Length>0)
        {
            m_delayedAssets.Clear();
            addFlag = false;
            ResMgrImporter_Atlas.OnPostprocessAllAssets(importedAsset,deletedAssets,movedAssets,movedFromAssetPaths);

        }
      
    }

#endif

}
