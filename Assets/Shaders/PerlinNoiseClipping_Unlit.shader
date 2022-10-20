Shader "Unlit/PerlinNoiseClipping_Unlit"
{
    Properties
    {
        _Color("Color", Color) = (1,0,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Cull Off // will render inside too

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "./shared/SimpleV2F.cginc"
            #include "./shared/PerlinNoise.cginc"

            fixed4 _Color;

            fixed4 frag (v2f IN) : SV_Target
            {
                float perlinNoise = perlin(IN.uv, 4, 4, _Time.z);
                clip(perlinNoise);

                return _Color * perlinNoise;
            }
            ENDCG
        }

        // shadow caster rendering pass, implemented manually
        // using macros from UnityCG.cginc
        // https://docs.unity3d.com/Manual/SL-VertexFragmentShaderExamples.html
        Pass
        {
            Tags {"LightMode"="ShadowCaster"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"
            #include "./shared/PerlinNoise.cginc"

            struct v2f {
                float4 uv: TEXCOORD0;
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.uv = v.texcoord;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f IN) : SV_Target
            {
                float perlinNoise = perlin(IN.uv, 4, 4, _Time.z);
                clip(perlinNoise);
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
}
