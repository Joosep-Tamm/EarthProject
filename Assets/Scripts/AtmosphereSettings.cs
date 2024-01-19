using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;
using static UnityEngine.Mathf;

[CreateAssetMenu (menuName = "Celestial Body/Atmosphere")]
public class AtmosphereSettings : ScriptableObject {

	public Shader atmosphereShader;
	public int inScatteringPoints = 10;
	public int opticalDepthPoints = 10;
	public float densityFalloff = 4f;
    [Range(0, 1)]
    public float atmosphereScale = 1f;
    public Vector3 wavelengths = new Vector3 (700, 530, 440);
	public float scatteringStrength = 20;
    public float planetRadius;

	public void SetProperties (Material material, Vector3 cameraPosition, Vector3 dirFromPlanetToSun) {
		float scatterR = Pow(400 / wavelengths.x, 4) * scatteringStrength;
        float scatterG = Pow(400 / wavelengths.y, 4) * scatteringStrength;
        float scatterB = Pow(400 / wavelengths.z, 4) * scatteringStrength;
		Vector3 scatteringCoefficients = new Vector3(scatterR, scatterG, scatterB);

		material.SetVector("scatteringCoefficients", scatteringCoefficients);
		material.SetInt("numInScatteringPoints", inScatteringPoints);
        material.SetInt("numOpticalDepthPoints", opticalDepthPoints);
        material.SetFloat("atmosphereRadius", (1 + atmosphereScale) * planetRadius);
        material.SetFloat("planetRadius", planetRadius);
        material.SetFloat("densityFalloff", densityFalloff);
        material.SetVector("cameraPosition", cameraPosition);
        material.SetVector("dirToSun", dirFromPlanetToSun);
    }

}