using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class CameraOffset : MonoBehaviour
{
    public Vector3 DefaultOffset = new Vector3(0,10,-5);
    GameObject Offset;
    Transform OffsetTransform;
    public Vector3 CameraPosition
    {
        get
        {
            return OffsetTransform.position + transform.position+new Vector3(0,4,-2.5f);
        }
    }


    void Awake()
    {
        Offset = new GameObject("CmaeraOffset");
        OffsetTransform = Offset.transform;
        OffsetTransform.position = OffsetTransform.TransformPoint(DefaultOffset);
    }
    // Start is called before the first frame update
    void Start()
    {

    }
    public void SetTarget()
    {

    }

    // Update is called once per frame
    void Update()
    {

    }
    void OnTriggerEnter(Collider other)
    {
        CameraTrigger cameraTrigger = other.GetComponent<CameraTrigger>();
        if (cameraTrigger == null)
            return;
        if (cameraTrigger.Times == 0)
        {
            Offset.transform.position = cameraTrigger.CameraOffset.localPosition;
        }
        List<Vector3> pos = new List<Vector3>();
        if (null == cameraTrigger.CameraOffset)
            pos.Add(DefaultOffset);
        else
            pos.Add(cameraTrigger.CameraOffset.localPosition);

        iTween.moveToBezier(Offset, cameraTrigger.Times, 0, pos);
    }
}

