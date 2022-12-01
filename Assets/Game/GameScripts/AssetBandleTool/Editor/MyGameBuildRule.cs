using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class MyGameBuildRule 
{
    #region 保留的代码
    private const int DEFAULT_BY_DEPENDECY_THRESHOLD = 2;
    private string m_DefaultVariantName = "cn";
    public string DefaultVariantName
    {
        get { return m_DefaultVariantName; }
    }

    public List<string> BuildVariants
    {
        get
        {
            return new List<string>
            {
                m_DefaultVariantName
            };
        }
    }
    public string DefaultVariant
    {
        get
        {
            return m_DefaultVariantName;
        }
    }

    public List<string> ForceStripShaders
    {
        get
        {
            return new List<string>
            {
                "Standard",
                "Standard(Roughness setup)",
                "Standard(Specular setup)",
                "Skybox/Procedural",
                "Skybox/6 Sided",
                "Mobile/Skybox",
                "Particles/Standard Surface",
                "Particles/Additive",
                "Particles/Alpha Blended",
                "Particles/Anim Alpha Blended",
            };

        }
    }
    /// <summary>
    /// xlua编译生成中间层代码
    /// </summary>
    public void OnClearCode()
    {
        // CSObjectWrapEditor.Generator.ClearAll(); 
    }

    public void OnGenerateCode()
    {
        // CSObjectWrapEditor.Generator.ClearAll(); 
        // CSObjectWrapEditor.Generator.GenAll(); 
    }

    public void OnBuildPlayer()
    {
    }

    public void ValidateResourceLoading(string assetPath)
    {
        var assets = AssetDatabase.GetAssetPathsFromAssetBundle(assetPath);
        if (assets != null && assets.Length > 0)
        {
            return;
        }
        if (!IsExplicitAsset(assetPath))
        {
            Debug.Break();
            EditorUtility.DisplayDialog("异常", "不能加载“依赖目录”中的资源" + assetPath, "我错了");
            throw new System.InvalidOperationException(assetPath);

        }
    }
    private bool IsExplicitAsset(string path)
    {
        var assetBuildType = GetAssetBuildType(path);
        return assetBuildType.IsExplicit() || assetBuildType.IsExplictWithLabel();
    }

    private bool StrContains(string str, string value)
    {
        return str.IndexOf(value, System.StringComparison.OrdinalIgnoreCase) != -1;
    }
    private bool StrEndsWith(string str, string value)
    {
        return str.EndsWith(value, System.StringComparison.OrdinalIgnoreCase);
    }

    public AssetBuildType GetAssetBuildType(string assetPath)
    {
        AssetBuildType assetBuildType = AssetBuildType.Invalid();
        return assetBuildType;
    }
    #endregion


    /// <summary>
    /// 获取AB包名
    /// </summary>
    /// <param name="assetPath"></param>
    /// <returns></returns>
    public  string GetAssetABNameByAssetPath(string assetPath)
    {
        string abName = assetPath;
        //Debug.Log(assetPath + "assetPath=========================sub_folder_name");

        //if (assetPath.Contains("EnemyModel"))
        //{
        //    string tab = assetPath.
        //    Debug.Log(assetPath + "---is not null");
        //    string sub_folder_name = assetPath;
        //    int position = assetPath.LastIndexOf("EnemyModel");
        //    Debug.Log(position + "--------------------position////////////////// ");
        //    if (position != -1)
        //    {
        //        sub_folder_name = assetPath.Substring(0, position);
        //        position = sub_folder_name.LastIndexOf(@"/");
        //        sub_folder_name = sub_folder_name.Substring(0, position);
        //        Debug.Log(sub_folder_name + "sub_xxxxxxfolder_name");
        //    }
        //}
        //else
        //{
        //    Debug.Log(assetPath.Contains(@"Assets/Arts/EnemyModel/") + "---is not null");
        //}
        return abName;
    }

    #region Rule
    private AssetBuildType CheckAtlasAssets(string path)
    {
        if (StrContains(path, "Assets/Arts/UI/Atlas/pinchmakeup"))
        {
            return AssetBuildType.Ignore();
        }
        if (StrContains(path, "/Atlas/"))
        {
            int pos1 = path.LastIndexOf('/');
            int pos2 = path.LastIndexOf('/', pos1 - 1);
            string assetName = path.Substring(pos1 + 1, pos1 - pos2 - 1);
            string bundleNmae = path.Substring(0, pos1 + 1) + assetName + ".asset";
            if (System.IO.File.Exists(bundleNmae))
            {
                return AssetBuildType.ExplictWithLabel(bundleNmae);
            }
            else
            {
                return AssetBuildType.Ignore();
            }
        }
        return AssetBuildType.Invalid();
    }

    private AssetBuildType CheckUIAssets(string path)
    {
        if (StrContains(path, "Assets/Arts/UI/Img"))
        {
            if (StrEndsWith(path, ".jpg") || StrEndsWith(path, ".png"))
            {
                return AssetBuildType.Explict();
            }
            else
            {
                return AssetBuildType.Ignore();
            }
        }
        return AssetBuildType.Invalid();
    }
    private AssetBuildType CheckEffectAssets(string path)
    {
        if (StrContains(path, "Assets/Arts/Effects"))
        {
            if (StrContains(path, "/Prefabs/") && StrEndsWith(path, ".prefab"))
            {
                return AssetBuildType.Explict();
            }
            else
            {
                return AssetBuildType.Ignore();
            }
        }
        return AssetBuildType.Invalid();

    }
    //AssetBuildType IBuildRule.GteAssetBuildType(string assetPath)
    //{
    //    throw new System.NotImplementedException();
    //}

    //void IBuildRule.OnBuildAssetBundle()
    //{
    //    throw new System.NotImplementedException();
    //}

    #endregion


}
