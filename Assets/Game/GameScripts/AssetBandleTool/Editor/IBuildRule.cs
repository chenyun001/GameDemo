
using System.Collections.Generic;

#if  UNITY_EDITOR

public struct AssetBuildType
{
    private enum BuildTypeInternal
    {
        /// <summary>
        /// 无效类型
        /// </summary>
        Invalid,
        /// <summary>
        /// 忽略走unity默认规则
        /// </summary>
        Ignore,
        /// <summary>
        /// 单独打包
        /// </summary>
        Explict,
        /// <summary>
        /// 依赖打包，设置阀值只有当小于阀值时才冗余打包，否则冗余打包。
        /// </summary>
        ByDependency,
        /// <summary>
        /// 显示指定AB包名称
        /// </summary>
        ExplictWithLabel,

    }
    private BuildTypeInternal m_BuildType;
    private int m_RedundantThreshold;
    private string m_LabelName;

    public static AssetBuildType Invalid()
    {
        return new AssetBuildType()
        {
            m_BuildType = BuildTypeInternal.Invalid
        };

    }
    public static AssetBuildType Ignore()
    {
        return new AssetBuildType()
        {
            m_BuildType = BuildTypeInternal.Ignore
        };

    }

    public static AssetBuildType Explict()
    {
        return new AssetBuildType()
        {
            m_BuildType = BuildTypeInternal.Explict
        };
    }
    public static AssetBuildType ByDependency(int count)
    {
        return new AssetBuildType()
        {
            m_BuildType = BuildTypeInternal.ByDependency,
            m_RedundantThreshold = count
        };
    }
    public static AssetBuildType ExplictWithLabel(string labelName)
    {
        return new AssetBuildType()
        {
            m_BuildType = BuildTypeInternal.ExplictWithLabel,
            m_LabelName = labelName
        };
    }
    public override bool Equals(object obj)
    {
        return obj is AssetBuildType;
        //return obj is AssetBuildType &&this == (AssetBuildType) obj;
    }
    public override int GetHashCode()
    {
        return m_BuildType.GetHashCode() ^ m_RedundantThreshold.GetHashCode() ^ (m_LabelName != null ? m_LabelName.GetHashCode() : 0);
    }

    //public static bool operator == (AssetBuildType lhs, AssetBuildType rhs)
    //{
    //    return lhs.m_BuildType == rhs.m_BuildType
    //        && lhs.m_RedundantThreshold == rhs.m_RedundantThreshold
    //        && lhs.m_LabelName == rhs.m_LabelName;
    //}

    //public static bool opeerator != (AssetBuildType lhs, AssetBuildType rhs)
    //{
    //       return !(lhs == rhs);
    //}

    public override string ToString()
    {
        return m_BuildType.ToString();
    }

    internal string LabelName { get { return m_LabelName; } }
    internal int RedundantThreshols { get { return m_RedundantThreshold; } }
    internal bool IsInvalid() { return m_BuildType == BuildTypeInternal.Invalid; }
    internal bool IsIgnore() { return m_BuildType == BuildTypeInternal.Ignore; }
    internal bool IsExplicit() { return m_BuildType == BuildTypeInternal.Explict; }
    internal bool IsByDependency() { return m_BuildType == BuildTypeInternal.ByDependency; }
    internal bool IsExplictWithLabel() { return m_BuildType == BuildTypeInternal.ExplictWithLabel; }
  




}

public interface IBuildRule
{
    /// <summary>
    /// 项目默认的语言变种名称，一般是Cn
    /// </summary>
    string DefaultVariant { get; }
    /// <summary>
    /// 构建AssetBundle 过程中 需要裁减掉的shader列表 要是没裁减掉打到包里面 在运行时会产生很多相同的 shader类
    ///  在构建AssetBundle 前将列表中的Shader 临时加入到AlwaysInclude中
    ///  在构建player前将列表中的shader从AlwaysInclude中移除
    ///  这样AssetBundle和Player中都不包括列表中的Shader了
    ///  一般用于处理unity默认引入内部的Shader的情况， 如 FBX会默认引入Standard
    /// </summary>
    List<string> ForceStripShaders { get; }

    /// <summary>
    /// 返回某个资源的构建规则
    /// </summary>
    /// <param name="assetPath"></param>
    /// <returns></returns>
    AssetBuildType GteAssetBuildType(string assetPath);
    /// <summary>
    /// 用于构建Player前处理代码的生成
    /// </summary>
    void OnGenerateCode();
    /// <summary>
    /// 用于构建player后清理生成的代码
    /// </summary>
    void OnClearCode();
    /// <summary>
    /// 构建player回掉
    /// </summary>
    void OnBuildPlayer();
    /// <summary>
    /// 构建AssetBundle 回掉
    /// </summary>
    void OnBuildAssetBundle();

}
#endif

