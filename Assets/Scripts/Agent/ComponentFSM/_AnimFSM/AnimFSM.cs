using UnityEngine;
using System.Collections;
using System.Collections.Generic;
public abstract  class AnimFSM
{
    protected List<AnimState> AnimStates;
    protected AnimState  CurrentAnimState;
    protected AnimState NextAnimState;
    protected AnimState DefaultAnimState;

    protected Animation AnimEngine;
    protected Agent Owner;
    public AnimFSM(Animation _anims,Agent _owner)
    {
        AnimEngine = _anims;
        Owner = _owner;
        AnimStates = new List<AnimState>();
    }
    public virtual void Initialize()
    {
        CurrentAnimState = DefaultAnimState;
        CurrentAnimState.OnActivate(null);
        NextAnimState = null;
    }
    public void  Update()
    {
        if(CurrentAnimState.IsFinished())
        {
            CurrentAnimState.OnDeactivate();
            CurrentAnimState = DefaultAnimState;
            CurrentAnimState.OnActivate(null);
        }
        CurrentAnimState.Update();
    }
    public void Reset()
    {
        for(int i=0;i<AnimStates.Count;i++)
        {
            if(AnimStates[i].IsFinished()==false)
            {
                AnimStates[i].OnDeactivate();
                AnimStates[i].SetFinished(true);
            }

        }
    }
    public abstract void DoAction(AgentAction _action);
    protected void ProgressToNextStage(AgentAction _action)
    {
        if(NextAnimState!=null)
        {
            CurrentAnimState.Release();
            CurrentAnimState.OnDeactivate();
            CurrentAnimState = NextAnimState;
            CurrentAnimState.OnActivate(_action);
            NextAnimState = null;
        }
    }

}

