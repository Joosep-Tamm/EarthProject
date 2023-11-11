using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Light : MonoBehaviour
{
    private Transform tfLight;

    public void Start()
    {
        var goLight = GameObject.Find("Sun");
        if (goLight) tfLight = goLight.transform;
    }

    public void Update()
    {
        if (tfLight)
        {
            GetComponent<Renderer>().material.SetVector("_LightPos", tfLight.position);
            GetComponent<Renderer>().material.SetVector("_LightDir", tfLight.forward);
        }
    }
}
