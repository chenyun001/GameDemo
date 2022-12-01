using System.Collections;
using System.Collections.Generic;
using UnityEngine.EventSystems;
using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// EasyTouch控制类
/// </summary>
public class EasyTouch : ScrollRect
{
    public float recoveryTime = 0.5f;
    protected float mRadius;
    protected bool isOnEndDrag = false;
    protected Vector3 offsetVector3 = Vector3.zero;
    void Start()
    {
        inertia = false;
        movementType = MovementType.Unrestricted;
        mRadius = (transform as RectTransform).sizeDelta.x * 0.5f;
    }
    public override void OnScroll(PointerEventData data)
    {
        //base.OnScroll(data);
    }
    public override void OnDrag(PointerEventData eventData)
    {
        base.OnDrag(eventData);
        isOnEndDrag = false;
        var contentPostion = this.content.anchoredPosition;
        if(contentPostion.magnitude>mRadius)
        {
            contentPostion = contentPostion.normalized * mRadius;
            SetContentAnchoredPosition(contentPostion);
        }
    }
    public override void OnEndDrag(PointerEventData eventData)
    {
        base.OnEndDrag(eventData);
        if (!isOnEndDrag)
            isOnEndDrag = true;
    }
    void Update()
    {
        UpdateContent();
    }
    /// <summary>
    /// 遥感小球复位
    /// </summary>
    public void UpdateContent()
    {
        if(isOnEndDrag)
        {
            if (content.localPosition == Vector3.zero)
                isOnEndDrag = false;
            float x = Mathf.Lerp(content.localPosition.x,0.0f,recoveryTime);
            float y = Mathf.Lerp(content.localPosition.y, 0.0f, recoveryTime);
            content.localPosition = new Vector3(x, y, content.localPosition.z);
        }
        CalculateOffset();
    }
    /// <summary>
    /// 计算偏移量
    /// </summary>
    private void CalculateOffset()
    {
        if(isOnEndDrag)
        {
            offsetVector3 = new Vector3(0,0,0);
        }else
        {
            offsetVector3 = content.localPosition / mRadius;
        } 
       
    }
    /// <summary>
    /// 获取偏移量大小
    /// 偏移范围[-1,1]
    /// </summary>
    /// <returns></returns>
    public Vector3 GetOffsetVector3()
    {
        return offsetVector3;
    }

}
