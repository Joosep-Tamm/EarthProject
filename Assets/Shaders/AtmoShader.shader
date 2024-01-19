Shader "Hidden/AtmoShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "../Includes/UnityCG.cginc"
            #include "../Includes/Math.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 viewVector : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f output;
                output.pos = UnityObjectToClipPos(v.vertex);
                output.uv = v.uv;
                float3 viewVector = mul(unity_CameraInvProjection, float4(v.uv.xy * 2 - 1, 0, -1));
                output.viewVector = mul(unity_CameraToWorld, float4(viewVector, 0));
                return output;
            }

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
    
            float3 dirToSun;

            float3 planetCentre;
            float atmosphereRadius;
            float planetRadius;
    
            // Parameters
            int numInScatteringPoints;
            int numOpticalDepthPoints;
            float intensity;
            float4 scatteringCoefficients;
            float ditherStrength;
            float ditherScale;
            float densityFalloff;
            float3 cameraPosition;
    
            float densityAtPoint(float3 densitySamplePoint)
            {
                float heightAboveSurface = length(densitySamplePoint - planetCentre) - planetRadius;
                float height01 = heightAboveSurface / (atmosphereRadius - planetRadius);
                float localDensity = exp(-height01 * densityFalloff) * (1 - height01);
                return localDensity;
            }
			
            float opticalDepth(float3 rayOrigin, float3 rayDir, float rayLength)
            {
                float3 densitySamplePoint = rayOrigin;
                float stepSize = rayLength / (numOpticalDepthPoints - 1);
                float opticalDepth = 0;

                for (int i = 0; i < numOpticalDepthPoints; i++)
                {
                    float localDensity = densityAtPoint(densitySamplePoint);
                    opticalDepth += localDensity * stepSize;
                    densitySamplePoint += rayDir * stepSize;
                }
                return opticalDepth;
            }
    
            float3 calculateLight(float3 rayOrigin, float3 rayDir, float rayLength, float3 originalCol)
            {
                float3 inScatterPoint = rayOrigin;
                float stepSize = rayLength / (numInScatteringPoints - 1);
                float3 inScatteredLight = 0;
                float viewRayOpticalDepth = 0;

                for (int i = 0; i < numInScatteringPoints; i++)
                {
                    float sunRayLength = raySphere(planetCentre, atmosphereRadius, inScatterPoint, dirToSun).y;
                    float sunRayOpticalDepth = opticalDepth(inScatterPoint, dirToSun, sunRayLength);
                    viewRayOpticalDepth = opticalDepth(inScatterPoint, -rayDir, stepSize * i);
                    float3 transmittance = exp(-(sunRayOpticalDepth + viewRayOpticalDepth) * scatteringCoefficients);
                    float localDensity = densityAtPoint(inScatterPoint);
					
                    inScatteredLight += localDensity * transmittance * scatteringCoefficients * stepSize;
                    inScatterPoint += rayDir * stepSize;
                }
                float originalColTransmittance = exp(-viewRayOpticalDepth);
                return originalCol * originalColTransmittance + inScatteredLight;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 originalCol = tex2D(_MainTex, i.uv);
                float sceneDepthNonLinear = tex2D(_CameraDepthTexture, i.uv);
                float sceneDepth = LinearEyeDepth(sceneDepthNonLinear) * length(i.viewVector);
                
                float3 rayOrigin = cameraPosition;
                float3 rayDir = normalize(i.viewVector);
    
                float2 hitInfo = raySphere(planetCentre, atmosphereRadius, rayOrigin, rayDir);
                float dstToAtmosphere = hitInfo.x;
                float dstThroughAtmosphere = min(hitInfo.y, sceneDepth - dstToAtmosphere);

                if (abs(dstThroughAtmosphere) > 0)
                {
                    const float epsilon = 0.0001;
                    float3 pointInAtmosphere = rayOrigin + rayDir * dstToAtmosphere;
                    float3 light = calculateLight(pointInAtmosphere, rayDir, dstThroughAtmosphere - epsilon * 2, originalCol);
                    return float4(light, 0);
                }
                return originalCol;
            }
            ENDCG
        }
    }
}
