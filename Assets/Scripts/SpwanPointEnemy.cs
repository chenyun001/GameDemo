using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class SpwanPointEnemy : MonoBehaviour
{
    public Transform Transform;
    public AnimationClip SpawnAnimation;
    public E_EnemyType EnemyType= E_EnemyType.None;
    public E_GameDifficulty GameDifficulty = E_GameDifficulty.Normal;
    // Start is called before the first frame update
    void Awake()
    {
        Transform = transform;
    }
    void Start()
    {
        enabled = false;
       
    }

    // Update is called once per frame
    void Update()
    {

    }
    void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawIcon(transform.position, "SpawnPoint.tif");
    }
}

