// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "京沅/dissolve"
{
	Properties {
        [Toggle(_SWITCH_BY_FACE_SWICTH_ON)] _switch_by_face_swicth("switch_by_face_swicth", Float) = 0
		[HDR]_back_color("back_color", Color) = (0,0,0,0)
		[HDR]_front_color("front_color", Color) = (0,0,0,0)
		[Toggle(_DISSOLVE_EDGE_SWITCH_ON)] _dissolve_edge_switch("dissolve_edge_switch", Float) = 0
		_edge_width("edge_width", Float) = 0
		[HDR]_edge_color("edge_color", Color) = (0,0,0,0)
		[HDR]_diffuse_color02("diffuse_color02", Color) = (1,1,1,1)
		_dissolve_soflt("dissolve_soflt", Float) = 1
		[HDR]_diffuse_color01("diffuse_color01", Color) = (1,1,1,1)
		_diffuse_texture("diffuse_texture", 2D) = "white" {}
		_diffuse_mask("diffuse_mask", 2D) = "white" {}
		_rongjie_tex("rongjie_tex", 2D) = "white" {}
		_rongjie_maks("rongjie_maks", 2D) = "white" {}
		[HideInInspector] _tex4coord2( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
    }
    SubShader {
        Tags {
            "RenderType" = "Transparent" 
		 	"Queue" = "Geometry+0" 
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
            Blend SrcAlpha One , SrcAlpha One
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            #pragma multi_compile_fwdbase
            //#pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 4.5

            CBUFFER_START(UnityPerMaterial)
                uniform float4 _diffuse_color01;
                uniform sampler2D _diffuse_mask;
                uniform float4 _diffuse_mask_ST;
                uniform sampler2D _diffuse_texture;
                uniform float4 _edge_color;
                uniform float4 _diffuse_color02;
                uniform float _edge_width;
                uniform sampler2D _rongjie_maks;
                uniform float4 _rongjie_maks_ST;
                uniform sampler2D _rongjie_tex;
                uniform float4 _rongjie_tex_ST;
                uniform float _dissolve_soflt;
                uniform float4 _front_color;
                uniform float4 _back_color;
            CBUFFER_END

            //TEXTURE2D(_ParticleColor); SAMPLER(sampler_ParticleColor);
            //TEXTURE2D(_TextureDissolve); SAMPLER(sampler_TextureDissolve);

            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
                float4 texcoord1: TEXCOORD1;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv_texcoord : TEXCOORD0;
                float4 uv2_tex4coord2 : TEXCOORD1;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv_texcoord = v.texcoord0;
                o.uv2_tex4coord2 = v.texcoord1;
                o.vertexColor = v.vertexColor;
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float2 uv_diffuse_mask = i.uv_texcoord * _diffuse_mask_ST.xy + _diffuse_mask_ST.zw;
                float2 _diffuse_uv_tiling = float2(1,1);
                float2 appendResult178 = (float2(_diffuse_uv_tiling.x , _diffuse_uv_tiling.y));
                float2 appendResult103 = (float2(i.uv2_tex4coord2.x , i.uv2_tex4coord2.y));
                float2 uv_TexCoord96 = i.uv_texcoord * appendResult178 + appendResult103;
                float temp_output_16_0 = ( tex2D( _diffuse_mask, uv_diffuse_mask ).r * tex2D( _diffuse_texture, uv_TexCoord96 ).r );
                float4 temp_output_79_0 = ( i.vertexColor * _diffuse_color01 * temp_output_16_0 );
                float2 uv_rongjie_maks = i.uv_texcoord * _rongjie_maks_ST.xy + _rongjie_maks_ST.zw;
                float2 uv_rongjie_tex = i.uv_texcoord * _rongjie_tex_ST.xy + _rongjie_tex_ST.zw;
                float temp_output_88_0 = ( tex2D( _rongjie_maks, uv_rongjie_maks ).r * tex2D( _rongjie_tex, uv_rongjie_tex ).r );
                float clampResult86 = clamp( ( ( ( _edge_width * temp_output_88_0 ) - i.uv2_tex4coord2.z ) * _dissolve_soflt ) , 0.0 , 1.0 );
                float4 lerpResult71 = lerp( _diffuse_color02 , temp_output_79_0 , clampResult86);
                float clampResult84 = clamp( ( _dissolve_soflt * ( temp_output_88_0 - i.uv2_tex4coord2.z ) ) , 0.0 , 1.0 );
                float4 lerpResult180 = lerp( _edge_color , lerpResult71 , clampResult84);
                #ifdef _DISSOLVE_EDGE_SWITCH_ON
                    float4 staticSwitch148 = ( i.vertexColor * lerpResult180 );
                #else
                    float4 staticSwitch148 = temp_output_79_0;
                #endif
                float4 switchResult161 = (((facing>0)?(_front_color):(_back_color)));
                #ifdef _SWITCH_BY_FACE_SWICTH_ON
                    float4 staticSwitch165 = ( staticSwitch148 * switchResult161 );
                #else
                    float4 staticSwitch165 = staticSwitch148;
                #endif
                half3 Emission = staticSwitch165.rgb;
                half Alpha = ( temp_output_16_0 * clampResult84 * i.vertexColor.a );

                half4 finalRGBA = half4(Emission, Alpha);
                return finalRGBA;
            }
            ENDHLSL
        }
    }
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18000
575.3334;430.6667;1280;782;-137.681;1511.53;2.21749;True;True
Node;AmplifyShaderEditor.TextureCoordinatesNode;102;-521.3809,-600.8063;Inherit;True;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;177;-515.5526,-785.8628;Inherit;False;Constant;_diffuse_uv_tiling;diffuse_uv_tiling;13;0;Create;True;0;0;False;0;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;94;-17.54262,15.12221;Inherit;False;1944.214;544.2446;rongjie;10;84;68;65;69;104;88;63;89;77;78;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;63;56.20673,318.4182;Inherit;True;Property;_rongjie_tex;rongjie_tex;11;0;Create;True;0;0;False;0;-1;None;82fbee61fc2bd564e8b08db5259c13ab;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;89;70.56715,113.3091;Inherit;True;Property;_rongjie_maks;rongjie_maks;12;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;178;-256.1927,-733.1628;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;103;-266.052,-569.203;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;409.8187,232.7102;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;96;-69.4912,-713.9253;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;78;370.2367,66.67139;Inherit;False;Property;_edge_width;edge_width;4;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;104;694.1162,107.6758;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;570.0561,41.1587;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;17;188.4415,-922.2115;Inherit;True;Property;_diffuse_mask;diffuse_mask;10;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;186.5946,-727.6711;Inherit;True;Property;_diffuse_texture;diffuse_texture;9;0;Create;True;0;0;False;0;-1;1e1df230b8ea4c04580a7f418e2df1d7;60a20fec9e2587843b1f53c95f957608;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;95;665.8962,-383.8418;Inherit;False;998.0394;381.6959;liangbian;3;87;86;70;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;69;966.6188,67.00662;Inherit;False;Property;_dissolve_soflt;dissolve_soflt;7;0;Create;True;0;0;False;0;1;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;82;548.3042,-1001.22;Inherit;False;Property;_diffuse_color01;diffuse_color01;8;1;[HDR];Create;True;0;0;False;0;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;70;932.4044,-245.6438;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;182;540.7906,-1258.382;Inherit;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;559.3766,-811.7094;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;855.9979,-975.4065;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;65;1003.849,249.1555;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;1189.355,-294.0723;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;171;1040.336,-818.3276;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;86;1416.041,-293.3408;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;90;1176.21,-1028.444;Inherit;False;Property;_diffuse_color02;diffuse_color02;6;1;[HDR];Create;True;0;0;False;0;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;1265.366,187.935;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;71;1470.17,-897.9065;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;84;1531.563,173.9742;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;181;1517.143,-1088.325;Inherit;False;Property;_edge_color;edge_color;5;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;115;1845.476,-1183.425;Inherit;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;170;998.2849,-1181.598;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;180;1907.502,-915.6187;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;163;2234.535,-890.3409;Inherit;False;Property;_front_color;front_color;2;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;164;2229.005,-708.4509;Inherit;False;Property;_back_color;back_color;1;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;179;2209.495,-1247.977;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;2111.845,-1108.341;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwitchByFaceNode;161;2505.957,-809.7637;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;148;2348.287,-1143.743;Inherit;False;Property;_dissolve_edge_switch;dissolve_edge_switch;3;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;162;2701.575,-905.7634;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;175;1860.423,-120.3115;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;169;2225.989,-145.554;Inherit;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;165;2865.934,-963.3576;Inherit;False;Property;_switch_by_face_swicth;switch_by_face_swicth;0;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;2606.017,-261.8215;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;19;3227.769,-992.8363;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;京沅/dissolve;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;False;False;False;False;False;Off;2;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Transparent;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;13;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;178;0;177;1
WireConnection;178;1;177;2
WireConnection;103;0;102;1
WireConnection;103;1;102;2
WireConnection;88;0;89;1
WireConnection;88;1;63;1
WireConnection;96;0;178;0
WireConnection;96;1;103;0
WireConnection;77;0;78;0
WireConnection;77;1;88;0
WireConnection;1;1;96;0
WireConnection;70;0;77;0
WireConnection;70;1;104;3
WireConnection;16;0;17;1
WireConnection;16;1;1;1
WireConnection;79;0;182;0
WireConnection;79;1;82;0
WireConnection;79;2;16;0
WireConnection;65;0;88;0
WireConnection;65;1;104;3
WireConnection;87;0;70;0
WireConnection;87;1;69;0
WireConnection;171;0;79;0
WireConnection;86;0;87;0
WireConnection;68;0;69;0
WireConnection;68;1;65;0
WireConnection;71;0;90;0
WireConnection;71;1;171;0
WireConnection;71;2;86;0
WireConnection;84;0;68;0
WireConnection;170;0;79;0
WireConnection;180;0;181;0
WireConnection;180;1;71;0
WireConnection;180;2;84;0
WireConnection;179;0;170;0
WireConnection;116;0;115;0
WireConnection;116;1;180;0
WireConnection;161;0;163;0
WireConnection;161;1;164;0
WireConnection;148;1;179;0
WireConnection;148;0;116;0
WireConnection;162;0;148;0
WireConnection;162;1;161;0
WireConnection;175;0;84;0
WireConnection;165;1;148;0
WireConnection;165;0;162;0
WireConnection;67;0;16;0
WireConnection;67;1;175;0
WireConnection;67;2;169;4
WireConnection;19;2;165;0
WireConnection;19;9;67;0
ASEEND*/
//CHKSM=3C6FCD0B64EF4060CB6D6F422DF9EA6B433AD4E5