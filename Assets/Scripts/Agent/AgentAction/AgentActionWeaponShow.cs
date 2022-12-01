using UnityEngine;
using System.Collections;

public class AgentActionWeaponShow : AgentAction
{
    /// <summary>
    /// 武器是否显示.
    /// </summary>
    public bool Show = true;

    /// <summary>
    /// Initializes a new instance of the <see cref="AgentActonWeaponShow"/> class.
    /// </summary>
    public AgentActionWeaponShow() : base(AgentActionFactory.E_Type.E_WEAPON_SHOW)
    {
    }
}
