// Shader created with Shader Forge v1.38 
// Shader Forge (c) Freya Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:4674,x:32909,y:32704,varname:node_4674,prsc:2|emission-8789-OUT,alpha-9076-OUT;n:type:ShaderForge.SFN_Tex2d,id:2168,x:31981,y:32697,ptovrint:False,ptlb:Emission,ptin:_Emission,varname:node_2168,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-5946-OUT;n:type:ShaderForge.SFN_Multiply,id:8789,x:32675,y:32811,varname:node_8789,prsc:2|A-6998-OUT,B-4990-OUT,C-8545-RGB;n:type:ShaderForge.SFN_ValueProperty,id:4990,x:31981,y:33013,ptovrint:False,ptlb:glow,ptin:_glow,varname:node_4990,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Time,id:6864,x:31097,y:32783,varname:node_6864,prsc:2;n:type:ShaderForge.SFN_Multiply,id:421,x:31381,y:32777,varname:node_421,prsc:2|A-6864-T,B-98-OUT;n:type:ShaderForge.SFN_Multiply,id:7510,x:31381,y:32919,varname:node_7510,prsc:2|A-6864-T,B-3150-OUT;n:type:ShaderForge.SFN_ValueProperty,id:98,x:31109,y:32671,ptovrint:False,ptlb:U_speed,ptin:_U_speed,varname:node_98,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:3150,x:31097,y:32979,ptovrint:False,ptlb:V_speed,ptin:_V_speed,varname:_U_speed_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Append,id:2977,x:31604,y:32777,varname:node_2977,prsc:2|A-421-OUT,B-7510-OUT;n:type:ShaderForge.SFN_Add,id:5946,x:31802,y:32697,varname:node_5946,prsc:2|A-6571-UVOUT,B-2977-OUT;n:type:ShaderForge.SFN_TexCoord,id:6571,x:31604,y:32583,varname:node_6571,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Power,id:6998,x:32355,y:32704,varname:node_6998,prsc:2|VAL-2168-RGB,EXP-3268-OUT;n:type:ShaderForge.SFN_ValueProperty,id:3268,x:31981,y:32906,ptovrint:False,ptlb:Power,ptin:_Power,varname:node_3268,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_VertexColor,id:8545,x:31981,y:33076,varname:node_8545,prsc:2;n:type:ShaderForge.SFN_Multiply,id:9076,x:32675,y:32970,varname:node_9076,prsc:2|A-2168-A,B-8545-A;proporder:2168-98-3150-4990-3268;pass:END;sub:END;*/

Shader "ASE/Effect/Additive Dissolve UV" {
    Properties {
       _nv_move("nv_move", Vector) = (0,0,0,0)
		_BrushedMetalNormal("BrushedMetalNormal", 2D) = "bump" {}
		_mask_texture("mask_texture", 2D) = "white" {}
		_distort_int("distort_int", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
    }
    SubShader {
        Tags {
            "RenderType" = "Transparent" 
		 	"Queue" =  "Transparent+0"
            "IsEmissive" = "true"
            "IgnoreProjector" = "True"
			"RenderPipeline" = "UniversalPipeline"
        }
        LOD 100
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="UniversalForward"
            
            }
            Cull Off
            
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
                sampler2D _TerrainHeightmapTexture;//ASE Terrain Instancing
			    sampler2D _TerrainNormalmapTexture;//ASE Terrain Instancing
                float4 _TerrainPatchInstanceData；
                float4 _TerrainHeightmapRecipSize;//ASE Terrain Instancing
				float4 _TerrainHeightmapScale;//ASE Terrain Instancing
                UNITY_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
                uniform sampler2D _BrushedMetalNormal;
                uniform float2 _nv_move;
                uniform float4 _BrushedMetalNormal_ST;
                uniform float _distort_int;
                uniform sampler2D _mask_texture;
                uniform float4 _mask_texture_ST;
            
            CBUFFER_END
            //TEXTURE2D(_ParticleColor); SAMPLER(sampler_ParticleColor);
            //TEXTURE2D(_TextureDissolve); SAMPLER(sampler_TextureDissolve);
           

            inline float4 ASE_ComputeGrabScreenPos( float4 pos )
            {
                #if UNITY_UV_STARTS_AT_TOP
                float scale = -1.0;
                #else
                float scale = 1.0;
                #endif
                float4 o = pos;
                o.y = pos.w * 0.5f;
                o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
                return o;
            }

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

             inline float4 ASE_ComputeGrabScreenPos( float4 pos )
            {
                #if UNITY_UV_STARTS_AT_TOP
                float scale = -1.0;
                #else
                float scale = 1.0;
                #endif
                float4 o = pos;
                o.y = pos.w * 0.5f;
                o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
                return o;
            }

            void ApplyMeshModification( inout appdata_full v )
            {
                #if !defined(SHADER_API_D3D11_9X)
                    float2 patchVertex = v.vertex.xy;
                    float4 instanceData = UNITY_ACCESS_INSTANCED_PROP(Terrain, _TerrainPatchInstanceData);
                    
                    float4 uvscale = instanceData.z * _TerrainHeightmapRecipSize;
                    float4 uvoffset = instanceData.xyxy * uvscale;
                    uvoffset.xy += 0.5f * _TerrainHeightmapRecipSize.xy;
                    float2 sampleCoords = (patchVertex.xy * uvscale.xy + uvoffset.xy);
                    
                    float hm = UnpackHeightmap(tex2Dlod(_TerrainHeightmapTexture, float4(sampleCoords, 0, 0)));
                    v.vertex.xz = (patchVertex.xy + instanceData.xy) * _TerrainHeightmapScale.xz * instanceData.z;
                    v.vertex.y = hm * _TerrainHeightmapScale.y;
                    v.vertex.w = 1.0f;
                    
                    v.texcoord.xy = (patchVertex.xy * uvscale.zw + uvoffset.zw);
                    v.texcoord3 = v.texcoord2 = v.texcoord1 = v.texcoord;
                    
                    #ifdef TERRAIN_INSTANCED_PERPIXEL_NORMAL
                        v.normal = float3(0, 1, 0);
                        //data.tc.zw = sampleCoords;
                    #else
                        float3 nor = tex2Dlod(_TerrainNormalmapTexture, float4(sampleCoords, 0, 0)).xyz;
                        v.normal = 2.0f * nor - 1.0f;
                    #endif
                #endif
            }

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
   
}