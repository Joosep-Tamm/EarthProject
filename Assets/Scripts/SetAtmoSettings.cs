using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetAtmoSettings : MonoBehaviour
{
    public AtmosphereSettings AtmosphereSettings;
    private Vector3 cameraPosition;
    public GameObject sun;
    public GameObject earth;

    void Update()
    {
        Vector3 dirFromPlanetToSun = (sun.transform.position - earth.transform.position).normalized;
        cameraPosition = Camera.main.transform.position;
        AtmosphereSettings.SetProperties(GetComponent<CustomPostProcessing>().material, cameraPosition, dirFromPlanetToSun);
    }
}
