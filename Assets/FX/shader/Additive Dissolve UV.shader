// Shader created with Shader Forge v1.38 
// Shader Forge (c) Freya Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:4674,x:32909,y:32704,varname:node_4674,prsc:2|emission-8789-OUT,alpha-9076-OUT;n:type:ShaderForge.SFN_Tex2d,id:2168,x:31981,y:32697,ptovrint:False,ptlb:Emission,ptin:_Emission,varname:node_2168,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-5946-OUT;n:type:ShaderForge.SFN_Multiply,id:8789,x:32675,y:32811,varname:node_8789,prsc:2|A-6998-OUT,B-4990-OUT,C-8545-RGB;n:type:ShaderForge.SFN_ValueProperty,id:4990,x:31981,y:33013,ptovrint:False,ptlb:glow,ptin:_glow,varname:node_4990,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Time,id:6864,x:31097,y:32783,varname:node_6864,prsc:2;n:type:ShaderForge.SFN_Multiply,id:421,x:31381,y:32777,varname:node_421,prsc:2|A-6864-T,B-98-OUT;n:type:ShaderForge.SFN_Multiply,id:7510,x:31381,y:32919,varname:node_7510,prsc:2|A-6864-T,B-3150-OUT;n:type:ShaderForge.SFN_ValueProperty,id:98,x:31109,y:32671,ptovrint:False,ptlb:U_speed,ptin:_U_speed,varname:node_98,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:3150,x:31097,y:32979,ptovrint:False,ptlb:V_speed,ptin:_V_speed,varname:_U_speed_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Append,id:2977,x:31604,y:32777,varname:node_2977,prsc:2|A-421-OUT,B-7510-OUT;n:type:ShaderForge.SFN_Add,id:5946,x:31802,y:32697,varname:node_5946,prsc:2|A-6571-UVOUT,B-2977-OUT;n:type:ShaderForge.SFN_TexCoord,id:6571,x:31604,y:32583,varname:node_6571,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Power,id:6998,x:32355,y:32704,varname:node_6998,prsc:2|VAL-2168-RGB,EXP-3268-OUT;n:type:ShaderForge.SFN_ValueProperty,id:3268,x:31981,y:32906,ptovrint:False,ptlb:Power,ptin:_Power,varname:node_3268,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_VertexColor,id:8545,x:31981,y:33076,varname:node_8545,prsc:2;n:type:ShaderForge.SFN_Multiply,id:9076,x:32675,y:32970,varname:node_9076,prsc:2|A-2168-A,B-8545-A;proporder:2168-98-3150-4990-3268;pass:END;sub:END;*/

Shader "ASE/Effect/Additive Dissolve UV" {
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
    FallBack "Diffuse"
   
}
