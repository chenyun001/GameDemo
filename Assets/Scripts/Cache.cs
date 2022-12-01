using System;
using UnityEngine;
using System.Collections;
/// <summary>
/// Cache.
/// </summary>
public class Cache
{
    //资源对象
    [SerializeField]
    protected GameObject Prefab;

    //同屏最大数量
    public int MaxCount = 5;

    //在使用中的layer标记
    protected const int cache_inuse = 20;
    //未使用的layer标记
    protected const int cache_free = 21;

    /// <summary>
    /// Hide the specified enemy.
    /// </summary>
    /// <param name="enemy">Enemy.</param>
    protected virtual IEnumerator Hide(GameObject enemy, float delay = 0.5f)
    {
        enemy.SetActive(false);
        yield return new WaitForSeconds(Mathf.Abs(delay));
        enemy.layer = cache_free;
    }

    /// <summary>
    /// Init this instance.
    /// </summary>
    public virtual void Init()
    {
        //MyClass.Instance.Test();
    }

    /// <summary>
    /// Return the specified enemy.
    /// </summary>
    /// <param name="enemy">Enemy.</param>
    public virtual bool Return(GameObject enemy)
    {
        return false;
    }

    public virtual void Destroy()
    {
        //GameObject.Destroy(Prefab);
    }
}


