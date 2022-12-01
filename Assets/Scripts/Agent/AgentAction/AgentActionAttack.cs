using UnityEngine;
using System.Collections;
using System.Collections.Generic;
/// <summary>
/// 攻击
/// </summary>
public  class AgentActionAttack:AgentAction
{
    public Agent Target;
    public AnimAttackData Data;
    public E_AttackType AttackType;
    public Vector3 AttackDir;
    public bool IsHit = false;
   
    public bool Hit;
    //攻击是否完成
    public bool AttackPhaseDone;
    public AgentActionAttack():base(AgentActionFactory.E_Type.E_ATTACK)
    {

    }
    public override void Reset()
    {
        base.Reset();
        Target = null;
        IsHit = false;
        Hit = false;
        Data = null;
        AttackPhaseDone = false;
        AttackType = E_AttackType.None;
    }
    public override string ToString()
    {
        string stNoTarget = (Target != null) ? Target.name : "No Target";
        return "[AgentActionAttack]"+ stNoTarget+" " +AttackType.ToString()+" "+Status.ToString();
    }
}

