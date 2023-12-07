using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Experimental.GlobalIllumination;

public class Sun : MonoBehaviour
{
    private Transform tfLight;
    private Light sunLight;

    public void Start()
    {
        var goLight = GameObject.Find("Sun");
        if (goLight)
        {
            tfLight = goLight.transform;
            sunLight = goLight.GetComponent<Light>();
        }
    }

    public void Update()
    {
        if (tfLight)
        {
            GetComponent<Renderer>().material.SetVector("_LightPos", tfLight.position);
            GetComponent<Renderer>().material.SetVector("_LightDir", tfLight.forward);
        }
        if (sunLight != null)
        {
            GetComponent<Renderer>().material.SetFloat("_SpotAngle", sunLight.spotAngle);
            GetComponent<Renderer>().material.SetFloat("_Range", sunLight.range);
            GetComponent<Renderer>().material.SetFloat("_CloudOpacity", 0.5f);
        }
    }
}
