// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "京沅/UvMove_add"
{
	 Properties {
        [HDR]_diffuse_color("diffuse_color", Color) = (1,1,1,1)
		[SingleLineTexture]_diffuse_texture("diffuse_texture", 2D) = "white" {}
		_diffuse_uv_tiling_move("diffuse_uv_tiling_move", Vector) = (1,1,0,0)
		[SingleLineTexture]_diffuse_mask("diffuse_mask", 2D) = "white" {}
		_mask_uv_tiling_move("mask_uv_tiling_move", Vector) = (1,1,0,0)
		_depth_intensty("depth_intensty", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
    }
    SubShader {
        Tags {
            "RenderType" = "Transparent" 
		 	"Queue" =  "Geometry+0"
            "IsEmissive" = "true"
			"RenderPipeline" = "UniversalPipeline"
        }
        LOD 100
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="UniversalForward"
            }
            Cull Off
            ZWrite Off
            Blend One One
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include  "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl" 
            #include "Packages/com.unity.render-pipelines.universal/Shaders/Utils/CopyDepthPass.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"
        
            #pragma multi_compile_fwdbase
            //#pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 4.5

            CBUFFER_START(UnityPerMaterial)
                uniform half4 _diffuse_color;
                uniform sampler2D _diffuse_mask;
                uniform half4 _mask_uv_tiling_move;
                uniform sampler2D _diffuse_texture;
                uniform half4 _diffuse_uv_tiling_move;
                uniform half _depth_intensty;
            CBUFFER_END
            //TEXTURE2D(_ParticleColor); SAMPLER(sampler_ParticleColor);
            //TEXTURE2D(_TextureDissolve); SAMPLER(sampler_TextureDissolve);

            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                 float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv_texcoord : TEXCOORD0;
                float4 screenPos:TEXCOORD1;
                 float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv_texcoord = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.screenPos = ComputeScreenPos(o.pos);
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                half2 appendResult147 = (half2(_mask_uv_tiling_move.x , _mask_uv_tiling_move.y));
                half2 appendResult144 = (half2(( _mask_uv_tiling_move.z * _Time.y ) , ( _mask_uv_tiling_move.w * _Time.y )));
                float2 uv_TexCoord142 = i.uv_texcoord * appendResult147 + appendResult144;
                half2 appendResult139 = (half2(_diffuse_uv_tiling_move.x , _diffuse_uv_tiling_move.y));
                half2 appendResult141 = (half2(( _diffuse_uv_tiling_move.z * _Time.y ) , ( _diffuse_uv_tiling_move.w * _Time.y )));
                float2 uv_TexCoord8 = i.uv_texcoord * appendResult139 + appendResult141;
                float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
                half4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
                ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
                float depth  =  SAMPLE(i.screenPos.xy);

                float screenDepth152 = LinearEyeDepth(depth,_ZBufferParams);
                half distanceDepth152 = abs( ( screenDepth152 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams) ) / ( _depth_intensty ) );
                half clampResult154 = clamp( distanceDepth152 , 0.0 , 1.0 );
                half3 Emission = ( i.vertexColor * i.vertexColor.a * _diffuse_color * ( tex2D( _diffuse_mask, uv_TexCoord142 ).r * tex2D( _diffuse_texture, uv_TexCoord8 ).r ) * clampResult154 ).rgb;
                half Alpha = 1;
                half4 finalRGBA = half4(Emission, Alpha);
                //half4 finalRGBA = half4(0,0,0,0);
                return finalRGBA;
            }
            ENDHLSL
        }
    }
    FallBack "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18000
575.3334;430.6667;1280;782;-1260.983;947.5129;1;True;True
Node;AmplifyShaderEditor.TimeNode;24;603.9275,-520.0663;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;148;643.7318,-1114.813;Inherit;False;Property;_mask_uv_tiling_move;mask_uv_tiling_move;5;0;Create;True;0;0;False;0;1,1,0,0;1,1,0.5,0.5;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;137;605.668,-710.8054;Inherit;False;Property;_diffuse_uv_tiling_move;diffuse_uv_tiling_move;3;0;Create;True;0;0;False;0;1,1,0,0;1,1,1,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TimeNode;143;629.7753,-928.177;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;145;882.832,-972.4121;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;138;856.9843,-564.3014;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;140;859.2841,-463.8014;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;146;885.1318,-871.9121;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;141;1053.284,-502.3013;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;139;1042.984,-684.1016;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;147;1068.832,-1092.212;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;144;1079.132,-910.412;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;142;1269.854,-1035.634;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;8;1259.401,-642.9175;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;155;1806.983,-409.0129;Inherit;False;Property;_depth_intensty;depth_intensty;6;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;152;2013.983,-434.013;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;1593.882,-662.0459;Inherit;True;Property;_diffuse_texture;diffuse_texture;2;1;[SingleLineTexture];Create;True;0;0;False;0;-1;1e1df230b8ea4c04580a7f418e2df1d7;cd72e5b4174841549839ee8236dcb256;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;17;1606.218,-912.8922;Inherit;True;Property;_diffuse_mask;diffuse_mask;4;1;[SingleLineTexture];Create;True;0;0;False;0;-1;None;82fbee61fc2bd564e8b08db5259c13ab;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;132;1986.625,-1132.942;Inherit;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;1997.91,-707.0471;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;82;1994.846,-923.0482;Inherit;False;Property;_diffuse_color;diffuse_color;1;1;[HDR];Create;True;0;0;False;0;1,1,1,1;0,0.1982068,1.720795,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;154;2299.983,-552.0129;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;2464.581,-947.9665;Inherit;False;5;5;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;19;2921.36,-984.5648;Half;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;京沅/UvMove_add;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;False;False;False;False;False;Off;2;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Transparent;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;4;1;False;-1;1;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;145;0;148;3
WireConnection;145;1;143;2
WireConnection;138;0;137;3
WireConnection;138;1;24;2
WireConnection;140;0;137;4
WireConnection;140;1;24;2
WireConnection;146;0;148;4
WireConnection;146;1;143;2
WireConnection;141;0;138;0
WireConnection;141;1;140;0
WireConnection;139;0;137;1
WireConnection;139;1;137;2
WireConnection;147;0;148;1
WireConnection;147;1;148;2
WireConnection;144;0;145;0
WireConnection;144;1;146;0
WireConnection;142;0;147;0
WireConnection;142;1;144;0
WireConnection;8;0;139;0
WireConnection;8;1;141;0
WireConnection;152;0;155;0
WireConnection;1;1;8;0
WireConnection;17;1;142;0
WireConnection;16;0;17;1
WireConnection;16;1;1;1
WireConnection;154;0;152;0
WireConnection;79;0;132;0
WireConnection;79;1;132;4
WireConnection;79;2;82;0
WireConnection;79;3;16;0
WireConnection;79;4;154;0
WireConnection;19;2;79;0
ASEEND*/
//CHKSM=1B5EB1FE208C01C36EB2B55D510DAC9EC8EE613A