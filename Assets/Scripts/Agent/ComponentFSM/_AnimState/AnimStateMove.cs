using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class AnimStateMove : AnimState
{
    AgentActionMove Action;
    float MaxSpeed;
    Quaternion StartRotation = new Quaternion();
    Quaternion FinalRotation = new Quaternion();
    float RotationProgress;
    public AnimStateMove(Animation _anims, Agent _owner):base(_anims,_owner)
    {

    }
    public override void OnActivate(AgentAction _action)
    {
        base.OnActivate(_action);
        //todo: paly Animation
        PlayAnim(GetMotionType());
    }
    public override void OnDeactivate()
    {
        Debug.Log("AgentActionMove Is OnDeactivate");
        Owner.BlackBoard.MotionType = E_MotionType.None;
        if (null!=Action)
        {
            Action.SetSuccess();
            Action = null;
        }
        Owner.BlackBoard.Speed = 0;
        base.OnDeactivate();
    }
    public override void Update()
    {
        if(Action.IsActive()==false)
        {
            Release();
            return;
        }
        MaxSpeed =Mathf.Max(Owner.BlackBoard.MaxRunSpeed,Owner.BlackBoard.MaxWalkSpeed*Owner.BlackBoard.MoveSpeedModifier)  ;
        RotationProgress += Owner.BlackBoard.RotationSmooth * Time.deltaTime;
        RotationProgress = Mathf.Min(RotationProgress,1);
        float curSmooth = Owner.BlackBoard.SpeedSmooth * Time.deltaTime;
        Quaternion q = Quaternion.Slerp(StartRotation,FinalRotation,RotationProgress);
        //if (Quaternion.Angle(q, FinalRotation) > 40.0f)
        //    return;
        Owner.Transform.rotation = q;
        Owner.BlackBoard.Speed = Mathf.Lerp(Owner.BlackBoard.Speed, MaxSpeed, curSmooth);
        Owner.BlackBoard.MoveDir = Owner.BlackBoard.DesiredDirection;
        if (Move(Owner.BlackBoard.MoveDir * Owner.BlackBoard.Speed * Time.deltaTime))
            Release();
        E_MotionType motion = GetMotionType();
        if(Owner.BlackBoard.MotionType!= motion)
        {
            PlayAnim(GetMotionType());
        }
        
    }
    public override bool HandleNewAction(AgentAction _action)
    {
        if(_action is AgentActionMove)
        {
            if (null != Action)
                Action.SetSuccess();
            SetFinished(false);
            Initialize(_action);
            return true;
        }
        if(_action is AgentActionWeaponShow)
        {
            _action.SetSuccess();
            //todo: paly Animation
            PlayAnim(GetMotionType());
            return true;
        }
        if(_action is AgentActionIdle)
        {
            _action.SetSuccess();
            SetFinished(true);
        }
        return false;
    }
    protected override void Initialize(AgentAction _action)
    {
        base.Initialize(_action);
        Action = _action as AgentActionMove;
        StartRotation = Owner.Transform.rotation;
        FinalRotation.SetLookRotation(Owner.BlackBoard.DesiredDirection);
        RotationProgress = 0;
    }
    private void PlayAnim(E_MotionType _motionType)
    {
        Owner.BlackBoard.MotionType = _motionType;
        //CrossFade(Owner.AnimSet.GetMoveAnim(),0.2f);
        CrossFade(Owner.AnimSet.GetMoveAnim(Owner.BlackBoard.MotionType, E_MoveType.Forward, Owner.BlackBoard.WeaponSelected, Owner.BlackBoard.WeaponState), 0.2f);
    }
    private E_MotionType GetMotionType()
    {
        if (Owner.BlackBoard.Speed > Owner.BlackBoard.MaxRunSpeed * 1.5f)
            return E_MotionType.Sprint;
        else if (Owner.BlackBoard.Speed > Owner.BlackBoard.MaxWalkSpeed * 1.5f)
            return E_MotionType.Run;
        return E_MotionType.Walk;

    }
}

