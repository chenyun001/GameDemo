using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class CameraTrigger : MonoBehaviour
{
    public Transform CameraOffset;

    public float Times=0.5f;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

    }
    void OnDrawGizmos()
    {
        if (CameraOffset == null)
            return;
        Gizmos.DrawSphere(transform.position,0.3f);
        Gizmos.DrawSphere(CameraOffset.position, 0.3f);
        Gizmos.DrawLine(transform.position, CameraOffset.position);
        BoxCollider collider = GetComponent<BoxCollider>();
        Gizmos.DrawWireCube(collider.center+transform.position,collider.size);
    }
}
