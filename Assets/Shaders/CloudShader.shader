Shader"Custom/CloudShader"
{
    Properties
    {
        _MainTex ("Cloud Texture", 2D) = "white" {}
        _FlowMap ("FlowMap", 2D) = "white" {}
        _Contrast ("Contrast", Range (20.0, 80.0)) = 50
        _CloudOpacity ("Cloud Opacity", Range (0.0, 1.0)) = 0.5
        _FlowSpeed ("Flow Speed", Float) = 0.01 // Add this line to control the speed of the cloud movement
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        Pass {
    Blend SrcAlpha
    OneMinusSrcAlpha
                ZTest
    LEqual

                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
    #include "UnityCG.cginc"

    uniform sampler2D _MainTex;
    uniform sampler2D _FlowMap;
    uniform float _Contrast; // adjusts contrast
    uniform float _CloudOpacity;
    uniform float _FlowSpeed; // Added this line

    struct v2f_interpolated
    {
        float4 pos : SV_POSITION;
        float2 texCoord : TEXCOORD0;
        float4 time : TEXCOORD1;
    };

    v2f_interpolated vert(appdata_full v)
    {
        v2f_interpolated o;
        o.texCoord.xy = v.texcoord.xy;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.time = _Time;
        return o;
    }

    half4 frag(v2f_interpolated i) : COLOR
    {
        float2 flow = tex2D(_FlowMap, i.texCoord).rg;
        flow = (flow * 2.0 - 1.0) * _FlowSpeed;

        float modulatedTime = fmod(i.time.y, 100.0) * _FlowSpeed;
                
        float2 offset = flow * modulatedTime;
        fixed4 cloudColor = tex2D(_MainTex, i.texCoord + offset);

        cloudColor.a = cloudColor.r * _CloudOpacity;

        return cloudColor;
    }
            ENDCG
        }    
    }
}
