using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
public class BaseGameZone : MonoBehaviour,IEDable
{
    /// <summary>
    /// 当前关卡里面的怪物数量
    /// </summary>
    protected List<Agent> _enemys=new List<Agent>();
    public List<Agent> Enemies
    {
        get
        {
            return _enemys;
        }
    }
    public void  AddEnemy(Agent enemy)
    {
        _enemys.Add(enemy);
    }
    /// <summary>
    /// 激活关卡
    /// </summary>
    public virtual void Enable()
    {
        gameObject.SetActive(true);
    }
    /// <summary>
    /// 注销掉关卡
    /// </summary>
    public virtual void  Disable()
    {
        gameObject.SetActive(false);
    }
    /// <summary>
    /// 关卡重置
    /// </summary>
    public virtual void Reset()
    {
        //停止所有的协程
        StopAllCoroutines();
        //清理创建的怪物
        for(int i=_enemys.Count-1;i>=0;i--)
        {
            //销毁怪物 或者放回缓存
        }
        //清理死亡模型数据 放回缓存
    }
    /// <summary>
    /// 设置关卡进度
    /// </summary>
    public virtual void SetInProgress()
    {

    }
    /// <summary>
    /// 在范围内获取交互物体
    /// </summary>
    /// <param name="center"></param>
    /// <param name="maxLen"></param>
    /// <returns></returns>
    public virtual InteractionGameObject GetNearestInteractionObject(Vector3 center,float maxLen)
    {
        return null;
    }
    /// <summary>
    /// 是否在交互范围内
    /// </summary>
    /// <param name="center"></param>
    /// <param name="maxLen"></param>
    /// <returns></returns>
    public virtual bool IsInteractionObjectInRange(Vector3 center,float maxLen)
    {
        return false;
    }
    /// <summary>
    /// 攻击可破坏物体
    /// </summary>
    /// <param name="attecker"></param>
    public virtual void BreakBreakableObjects(Agent attecker)
    {

    }
    //攻击受击相关
    public bool IsEnemyInRange(Vector3 center,float maxLen)
    {
        for(int i=0;i<_enemys.Count;i++)
        {
            Agent a = _enemys[i];
            //todo死亡就跳过

            //否则就计算
            if((a.Position-center).sqrMagnitude < maxLen*maxLen)
            {
                return true;
            } 
        }
        return false;
    }
    /// <summary>
    /// 获取指定方向最近活着的怪物
    /// </summary>
    /// <param name="agent"></param>
    /// <param name="direction"></param>
    /// <param name="maxRadius"></param>
    /// <returns></returns>
    public Agent GetNearestAliveEnemy(Agent agent,E_Direction direction,float maxRadius)
    {
        return null;
    }
    /// <summary>
    /// 获取指定范围内指定类型的怪物
    /// </summary>
    /// <param name="center">指定中心</param>
    /// <param name="maxRadius">范围半径</param>
    /// <param name="enemyType">怪物类型</param>
    /// <returns></returns>
    public Agent GetNearestAliveEnemy(Vector3 center, float radius,E_EnemyType enemyType)
    {
        return null;
    }
    /// <summary>
    /// 获取指定两个点之间最近的怪物
    /// </summary>
    /// <param name="start">开始位置</param>
    /// <param name="end">结束位置</param>
    /// <param name="radius">半径大小</param>
    /// <returns></returns>
    public Agent GetNearestAliveEnemy(Vector3 start,Vector3 end, float radius)
    {
        return null;
    }


}