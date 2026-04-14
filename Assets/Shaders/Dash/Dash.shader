Shader "Custom/SunburstBG"
{
    Properties
    {
        _ColorA     ("Ray Color A",      Color)  = (0.91, 0.11, 0.55, 1)
        _ColorB     ("Ray Color B",      Color)  = (0.88, 0.88, 0.88, 1)
        _ColorC     ("Center Glow",      Color)  = (1,    1,    1,    1)
        _RayCount   ("Ray Count",        Float)  = 20
        _RotSpeed   ("Rotation Speed",   Float)  = 0.08
        _CenterSize ("Center White Rad", Float)  = 0.05
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" "Queue"="Background" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes { float4 posOS : POSITION; float2 uv : TEXCOORD0; };
            struct Varyings   { float4 posHCS : SV_POSITION; float2 uv : TEXCOORD0; };

            float4 _ColorA, _ColorB, _ColorC;
            float  _RayCount, _RotSpeed, _CenterSize;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.posHCS = TransformObjectToHClip(IN.posOS.xyz);
                OUT.uv     = IN.uv;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float2 uv  = IN.uv - 0.5;           // center
                float  r   = length(uv);             // distance from center

                // Polar angle, animated
                float angle = atan2(uv.y, uv.x);
                angle = (angle / 6.2832) + 0.5;     // 0–1
                angle = frac(angle + _Time.y * _RotSpeed);

                // Ray stripe pattern
                float ray = frac(angle * _RayCount);

                // 3-band pattern: thick color | medium gray | thin white
                float band = step(0.55, ray) * step(ray, 0.85) ;  // gray band
                float thin = step(0.88, ray);                       // white accent
                float main = 1.0 - step(0.55, ray);                // pink main

                float4 col = _ColorA * main + _ColorB * band + _ColorC * thin;

                // Soft center white glow
                float glow = 1.0 - smoothstep(0, _CenterSize, r);
                col = lerp(col, _ColorC, glow);

                // Soft edge vignette fade (optional)
                float edge = 1.0 - smoothstep(0.45, 0.5, r);
                col.a = edge;

                return col;
            }
            ENDHLSL
        }
    }
}