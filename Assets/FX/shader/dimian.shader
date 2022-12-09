// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "LYJ/dimian"
{
	Properties
	{
		_diffus_Texture("diffus_Texture ", 2D) = "white" {}
		_opacity_Texture("opacity_Texture ", 2D) = "white" {}
		_difuuse_Color("difuuse_Color ", Color) = (1,1,1,1)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags {
            "RenderType" = "Transparent" 
		 	"Queue" = "Geometry+0" 
			"RenderPipeline" = "UniversalPipeline"
        }
        LOD 100
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="UniversalForward"
            }
            Cull Off
		    Blend SrcAlpha OneMinusSrcAlpha
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            #pragma multi_compile_fwdbase
            //#pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 4.5

            CBUFFER_START(UnityPerMaterial)
                uniform sampler2D _diffus_Texture;
                uniform float4 _diffus_Texture_ST;
                uniform float4 _difuuse_Color;
                uniform sampler2D _opacity_Texture;
                uniform float4 _opacity_Texture_ST;
            CBUFFER_END

            //TEXTURE2D(_ParticleColor); SAMPLER(sampler_ParticleColor);
            //TEXTURE2D(_TextureDissolve); SAMPLER(sampler_TextureDissolve);

            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv_texcoord : TEXCOORD0;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv_texcoord = v.texcoord0;
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
               
                float2 uv_diffus_Texture = i.uv_texcoord * _diffus_Texture_ST.xy + _diffus_Texture_ST.zw;
                half3 Albedo = ( tex2D( _diffus_Texture, uv_diffus_Texture ) * _difuuse_Color ).rgb;
                float2 uv_opacity_Texture = i.uv_texcoord * _opacity_Texture_ST.xy + _opacity_Texture_ST.zw;
                half Alpha = tex2D( _opacity_Texture, uv_opacity_Texture ).r;

                half4 finalRGBA = half4(Albedo, Alpha);
                return finalRGBA;
            }
            ENDHLSL
        }


		// CGPROGRAM
		// #pragma surface surf Standard keepalpha fullforwardshadows 
		// ENDCG
		// Pass
		// {
		// 	Name "ShadowCaster"
		// 	Tags{ "LightMode" = "ShadowCaster" }
		// 	ZWrite On
		// 	CGPROGRAM
		// 	#pragma vertex vert
		// 	#pragma fragment frag
		// 	#pragma target 3.0
		// 	#pragma multi_compile_shadowcaster
		// 	#pragma multi_compile UNITY_PASS_SHADOWCASTER
		// 	#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
		// 	#include "HLSLSupport.cginc"
		// 	#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
		// 		#define CAN_SKIP_VPOS
		// 	#endif
		// 	#include "UnityCG.cginc"
		// 	#include "Lighting.cginc"
		// 	#include "UnityPBSLighting.cginc"
		// 	sampler3D _DitherMaskLOD;
		// 	struct v2f
		// 	{
		// 		V2F_SHADOW_CASTER;
		// 		float2 customPack1 : TEXCOORD1;
		// 		float3 worldPos : TEXCOORD2;
		// 		UNITY_VERTEX_INPUT_INSTANCE_ID
		// 		UNITY_VERTEX_OUTPUT_STEREO
		// 	};
		// 	v2f vert( appdata_full v )
		// 	{
		// 		v2f o;
		// 		UNITY_SETUP_INSTANCE_ID( v );
		// 		UNITY_INITIALIZE_OUTPUT( v2f, o );
		// 		UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
		// 		UNITY_TRANSFER_INSTANCE_ID( v, o );
		// 		Input customInputData;
		// 		float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
		// 		half3 worldNormal = UnityObjectToWorldNormal( v.normal );
		// 		o.customPack1.xy = customInputData.uv_texcoord;
		// 		o.customPack1.xy = v.texcoord;
		// 		o.worldPos = worldPos;
		// 		TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
		// 		return o;
		// 	}
		// 	half4 frag( v2f IN
		// 	#if !defined( CAN_SKIP_VPOS )
		// 	, UNITY_VPOS_TYPE vpos : VPOS
		// 	#endif
		// 	) : SV_Target
		// 	{
		// 		UNITY_SETUP_INSTANCE_ID( IN );
		// 		Input surfIN;
		// 		UNITY_INITIALIZE_OUTPUT( Input, surfIN );
		// 		surfIN.uv_texcoord = IN.customPack1.xy;
		// 		float3 worldPos = IN.worldPos;
		// 		half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
		// 		SurfaceOutputStandard o;
		// 		UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
		// 		surf( surfIN, o );
		// 		#if defined( CAN_SKIP_VPOS )
		// 		float2 vpos = IN.pos;
		// 		#endif
		// 		half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
		// 		clip( alphaRef - 0.01 );
		// 		SHADOW_CASTER_FRAGMENT( IN )
		// 	}
		// 	ENDCG
		// }
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18000
2599;63;1920;1307;1334;492;1;True;True
Node;AmplifyShaderEditor.SamplerNode;1;-595,-343.5;Inherit;True;Property;_diffus_Texture;diffus_Texture ;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;4;-585,-150.5;Inherit;False;Property;_difuuse_Color;difuuse_Color ;3;0;Create;True;0;0;False;0;1,1,1,1;0.08490563,0.08490563,0.08490563,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-181,-262.5;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;2;-565,60.5;Inherit;True;Property;_opacity_Texture;opacity_Texture ;2;0;Create;True;0;0;False;0;-1;e5e2816b4ff6f0548879e90369c2dd55;e5e2816b4ff6f0548879e90369c2dd55;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;30,-280;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;LYJ/dimian;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;0;1;0
WireConnection;3;1;4;0
WireConnection;0;0;3;0
WireConnection;0;9;2;1
ASEEND*/
//CHKSM=A269891EBAFA8BDD521DBDB2289CF164C2DE4415