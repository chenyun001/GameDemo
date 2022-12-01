using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;
using System;
public class ProgressControl : MonoBehaviour
{
    public Image Progress_contin;
    public Image Progress_continEx;
    public float hurtSpeed = 0.05f;
    // Start is called before the first frame update
    void Start()
    {

    }
    public static void To(float from, float to, float duration,
           Action<float> percentCallback,
           Action completeHandle)
    {
        var currentValue = from;
        DOTween.To(() => currentValue, value =>
        {
            currentValue = value;
            percentCallback?.Invoke(currentValue);
        }, to, duration).OnComplete(() => completeHandle?.Invoke());
    }

    public void UpdateProgress(float progress,float hurtSpeedEx =1.0f)
    {
        Progress_contin.fillAmount = progress;
        UpdateHpCo(progress, hurtSpeedEx);
        
    }

    void UpdateHpCo(float progress, float hurtSpeedEx)
    {
        Progress_contin.fillAmount = progress;
        if(Progress_continEx!=null)
        {
            var currentValue = Progress_continEx.fillAmount;
            var to = progress;
            DOTween.To(() => currentValue, value =>
            {
                currentValue = value;
                Progress_continEx.fillAmount = value;
            }, progress, hurtSpeedEx);
        }
    }
    // Update is called once per frame
    void Update()
    {
        
    }
}
