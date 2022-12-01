Shader "Unlit/Npr_Chacter_Common"
{
    Properties
    {
        _Color("Color",Color)= (1,1,1,1)
        _AmbientColor("Ambient Color",Color) = (0.4,0.4,0.4,1)
        _MainTex ("Texture", 2D) = "white" {}
        _IlimTex("Ilm Textrue",2D) = "black" {}
        _WrapDiffuse("WrapDiffuse",range(0,1)) = 0.5
        _ShadeEdge0("ShadeEdge0",range(0,1)) = 0.925
        _ShadeEdge1("ShadeEdge1",range(0,1))= 1
        _SpecularColor("Specular Color",Color) = (0.9,0.9,0.9,1)
        _SpecularRange("Specular Range",range(0,1)) = 0.15
        _Glossiness("GLossiness",range(0.01,256)) = 8
        [HDR]_RimColor("Rim Amount",Color) = (1,1,1,1)
        _RimAmount("Rim Amount",Range(0,1)) = 0.042
        _RimThreshold("RimThreshold",range(0,10)) = 6
        _OutlineColor("Outline Color",Color) = (1,1,1,1)
        _Outline("Thick of Outline",range(0,5)) = 0.001
       [HDR]_EmisstionColor("Emisstion Color",Color) = (0,0,0,0)
    }
    SubShader
    {
        //Tags { "RenderType"="Opaque" }
        //LOD 100
        Tags
        {
            "LightMode" = "ForwardBase"
            "PassFlags" = "OnlyDirectional"
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;

            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 worldNormal:NORMAL;
                float2 uv : TEXCOORD0;
                //UNITY_FOG_COORDS(1)
                float3 viewDir : TEXCOORD1;
                SHADOW_COORDS(2)
            };

            sampler2D _MainTex;
            sampler2D _IlimTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = WorldSpaceViewDir(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv,_MainTex);
                TRANSFER_SHADOW(o);
                //UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            half4 _Color;
            half4 _AmbientColor;
            half _SpecularColor;
            float _WrapDiffuse,_ShadeEdge0,_ShadeEdge1;
            float _Glossiness,_SpecularRange;
            half4 _RimColor;
            float _RimAmount;
            float _RimThreshold;
            half4 _EmisstionColor;

            fixed4 frag (v2f i) : SV_Target
            {
                half4 color = tex2D(_MainTex,i.uv)*_Color;
                half4 ilmtex = tex2D(_IlimTex,i.uv);
                float3 normal = normalize(i.worldNormal);
                float3 viewDir = normalize(i.viewDir);
                float ndotl = max(0,dot(_WorldSpaceLightPos0,normal));
                float wrapLambert = (ndotl*_WrapDiffuse+1-_WrapDiffuse) + ilmtex.g;
                float shadow = SHADOW_ATTENUATION(i);
                float shadowStep = saturate(smoothstep(_ShadeEdge0,_ShadeEdge1,wrapLambert*shadow));
                half4 diffuse = lerp(_AmbientColor,_LightColor0,shadowStep);//float4(ShadeSH9(float4(normal,1)))

                float3 halfVector = normalize(_WorldSpaceLightPos0+viewDir);
                float ndoth = dot(normal,halfVector);
                float specularIntensity = pow(ndoth,_Glossiness)*ilmtex.r;
                float specularRange = step(_SpecularRange,specularIntensity+ilmtex.b);
                half4 specular = specularRange*_SpecularColor;
                float rimDot = pow(1-dot(viewDir,normal),_RimThreshold);
                float rimIntensity = rimDot*ndotl;
                rimIntensity = smoothstep(_RimAmount-0.01,_RimAmount+0.01,rimIntensity);
                half4 rim = rimIntensity*_RimColor;

                return (diffuse+rim+specular+_EmisstionColor*color.a)*color;
            }
            ENDCG
        }
        Pass
        {
           
            Tags{ "LightMode" = "ForwardBase" }

			Cull Front
			Zwrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			half _Outline;
			half4 _OutlineColor;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 vertColor : COLOR;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
			};


			v2f vert(a2v v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				o.pos = UnityObjectToClipPos(v.vertex.xyz);
				float3 normal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));
				float2 offset = TransformViewToProjection(normal.xy);
				o.pos.xy += offset * o.pos.z * _Outline;
				return o;
			}

			half4 frag(v2f i) : SV_TARGET
			{
				return _OutlineColor;
			}
			ENDCG
		


        }
    }
}
