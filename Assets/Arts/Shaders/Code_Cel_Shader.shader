//Shader by VFX_LYP
Shader "LYP_FX/Code_Cel_Shader" //名称路径
{
	Properties //材质球面板属性
	{
		_BaseTex("BaseTex", 2D) = "white" {} //底贴图
		[HDR]_BaseTexColor("BaseTexColor", Color) = (1,1,1,0)
		_ILMTex("ILMTex", 2D) = "white" {} //ILM贴图
		_EmissionTex("EmissionTex", 2D) = "white" {} //自发光贴图
		[HDR]_EmissionColor("EmissionColor", Color) = (0,0,0,0)
		_ShadowRange("ShadowRange", Range(0 , 1)) = 0
		_ShadowPower("ShadowPower", Range(0 , 1)) = 0.8
		_SpecularRange("SpecularRange", Range(0.5 , 1)) = 0.998
		_SpecularPower("SpecularPower", Range(0 , 1)) = 0.88
		_OutLineWidth("OutLine Width", Range(0 , 1)) = 0.002
		[HDR]_OutLineColor("OutLine Color", Color) = (0,0,0,0)
		[HideInInspector] _texcoord("", 2D) = "white" {}
		[HideInInspector] __dirty("", Int) = 1
	}

		SubShader //子Shader
		{
			//-----------------------外描边
			Tags{ }
			ZWrite On
			Cull Front
			CGPROGRAM //编译语言
			#pragma target 3.0
			#pragma surface outlineSurf Outline nofog  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc 
			void outlineVertexDataFunc(inout appdata_full v, out Input o)
			{
				UNITY_INITIALIZE_OUTPUT(Input, o);//初始化值（必须）
				float outlineVar = _OutLineWidth;
				v.vertex.xyz += (v.normal * outlineVar)*0.008;
			}
			inline half4 LightingOutline(SurfaceOutput s, half3 lightDir, half atten) { return half4 (0,0,0, s.Alpha); }
			void outlineSurf(Input i, inout SurfaceOutput o)
			{
				#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
				float4 ase_lightColor = 0;
				#else //aselc
				float4 ase_lightColor = _LightColor0;
				#endif //aselc
				float2 uv_BaseTex = i.uv_texcoord * _BaseTex_ST.xy + _BaseTex_ST.zw;
				float4 tex2DN_01 = tex2D(_BaseTex, uv_BaseTex); //默认采用底贴图颜色
				o.Emission = (ase_lightColor * tex2DN_01 * 1 * _OutLineColor).rgb;
			}
			ENDCG
			//-----------------------外描边
			
				//-----------------------自定义光照逻辑
				Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  } //渲染事件
				Cull Back //只渲染正面
				ZWrite On //深度渲染开启
				CGINCLUDE //整合代码 内部类
				//----引用工具类
				#include "UnityPBSLighting.cginc"
				#include "UnityCG.cginc"
				#include "UnityShaderVariables.cginc"
				#include "Lighting.cginc"
				//----引用工具类
				#pragma target 3.0
				struct Input //输入结构体
				{
					float2 uv_texcoord;
					float3 worldPos;
					float3 worldNormal;
					float3 viewDir;
				};

				struct SurfaceOutputCustomLightingCustom //输出结构体
				{
					half3 Albedo;
					half3 Normal;
					half3 Emission;

					//没用的删掉

					half Alpha;
					Input SurfInput;
					UnityGIInput GIData;
				};

				//自定义可调控参数
				uniform float4 _EmissionColor;
				uniform sampler2D _EmissionTex;
				uniform float4 _EmissionTex_ST;
				uniform sampler2D _ILMTex;
				uniform float4 _ILMTex_ST;
				uniform float4 _BaseTexColor;
				uniform sampler2D _BaseTex;
				uniform float4 _BaseTex_ST;
				uniform float _ShadowRange;
				uniform float _ShadowPower;
				uniform float _SpecularPower;
				uniform float _SpecularRange;
				uniform float _OutLineWidth;
				uniform float4 _OutLineColor;

				void vertexDataFunc(inout appdata_full v, out Input o)
				{
					UNITY_INITIALIZE_OUTPUT(Input, o);
					v.vertex.xyz += 0;
				}

				inline half4 LightingStandardCustomLighting(inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi) //自定义光照系统（第三步
				{
					//需要做处理的数据
					UnityGIInput data = s.GIData;
					Input i = s.SurfInput; //使用64行参数
					half4 c = 0; //最终输出颜色
					//很多Pass都会经过这个函数，优化尽量少用判断，如if else
					#ifdef UNITY_PASS_FORWARDBASE
					//-------------------获取衰减值
					float ase_lightAtten = data.atten; //从GI对象里面获取到衰减值
					if (_LightColor0.a == 0) //A通道是光源强度（0既无衰减
					ase_lightAtten = 0;
					#else
					float3 ase_lightAttenRGB = gi.light.color / ((_LightColor0.rgb) + 0.000001); //+0.000001以防除以0导致Bug
					float ase_lightAtten = max(max(ase_lightAttenRGB.r, ase_lightAttenRGB.g), ase_lightAttenRGB.b); //利用比对通道强度值获取衰减值
					#endif
					//-------------------获取衰减值
					//-------------------处理混合阴影
					#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
					half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
					float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
					float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
					ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
					#endif
					//-------------------处理混合阴影
					float2 uv_ILMTex = i.uv_texcoord * _ILMTex_ST.xy + _ILMTex_ST.zw;
					float4 temp_cast_1 = (tex2D(_ILMTex, uv_ILMTex).g).xxxx;
					float2 uv_BaseTex = i.uv_texcoord * _BaseTex_ST.xy + _BaseTex_ST.zw;
					float4 tex2DN_01 = tex2D(_BaseTex, uv_BaseTex);
					float4 blendOpSrc48 = temp_cast_1;
					float4 blendOpDest48 = (_BaseTexColor * tex2DN_01);
					float4 temp_output_48_0 = (saturate(((blendOpDest48 > 0.5) ? (1.0 - 2.0 * (1.0 - blendOpDest48) * (1.0 - blendOpSrc48)) : (2.0 * blendOpDest48 * blendOpSrc48))));
					float3 ase_worldPos = i.worldPos; //世界坐标空间下的顶点位置
					#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
					float3 ase_worldlightDir = 0;
					#else //aseld
					float3 ase_worldlightDir = normalize(UnityWorldSpaceLightDir(ase_worldPos)); //得到世界坐标下的光线方向
					#endif //aseld
					float3 ase_worldNormal = i.worldNormal;
					float dotResult13 = dot(ase_worldlightDir , ase_worldNormal);
					float ifLocalVar38 = 0;
					if ((dotResult13 - (0.5 - tex2D(_ILMTex, uv_ILMTex).g)) <= _ShadowRange)
						ifLocalVar38 = 0.0;
					else
						ifLocalVar38 = 1.0;
					float DiffuseIf43 = ifLocalVar38;
					float4 Diffuse51 = (temp_output_48_0 * DiffuseIf43);
					float dotResult17 = dot(ase_worldNormal , i.viewDir);
					float4 tex2DN_02 = tex2D(_ILMTex, uv_ILMTex);
					float clampResult21 = clamp(pow(dotResult17 , tex2DN_02.r) , 0.0 , 1.0);
					float ifLocalVar24 = 0;
					if (clampResult21 > _SpecularRange)
						ifLocalVar24 = 1.0;
					else if (clampResult21 == _SpecularRange)
						ifLocalVar24 = 0.0;
					float ifLocalVar30 = 0;
					if ((ifLocalVar24 * tex2DN_02.b) <= 0.1)
						ifLocalVar30 = 0.0;
					else
						ifLocalVar30 = 1.0;
					//---------------首先直接就获取光源颜色
					#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
					float4 ase_lightColor = 0;
					#else //aselc
					float4 ase_lightColor = _LightColor0;
					#endif //aselc
					//---------------首先直接就获取光源颜色
					c.rgb = (((Diffuse51 + ((temp_output_48_0 * _ShadowPower) * (1.0 - DiffuseIf43))) + (DiffuseIf43 * ((Diffuse51 * _SpecularPower) * ifLocalVar30))) * ase_lightColor * ase_lightAtten).rgb;
					c.a = 1;
					return c;
				}

				inline void LightingStandardCustomLighting_GI(inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi) //第二步
				{
					s.GIData = data;
				}

				void surf(Input i , inout SurfaceOutputCustomLightingCustom o) //第一步
				{
					o.SurfInput = i;
					float2 uv_EmissionTex = i.uv_texcoord * _EmissionTex_ST.xy + _EmissionTex_ST.zw;
					float4 tex2DN_03 = tex2D(_EmissionTex, uv_EmissionTex);
					o.Emission = (_EmissionColor * _EmissionColor.a * tex2DN_03 * tex2DN_03.a).rgb;
				}

				ENDCG
				CGPROGRAM
				#pragma exclude_renderers xbox360 xboxone ps4 psp2 n3ds wiiu 
				#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 

				ENDCG
				Pass
				{
					Name "ShadowCaster"
					Tags{ "LightMode" = "ShadowCaster" }
					ZWrite On
					CGPROGRAM
					#pragma vertex vert
					#pragma fragment frag
					#pragma target 3.0
					#pragma multi_compile_shadowcaster
					#pragma multi_compile UNITY_PASS_SHADOWCASTER
					#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
					#include "HLSLSupport.cginc"
					#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
						#define CAN_SKIP_VPOS
					#endif
					#include "UnityCG.cginc"
					#include "Lighting.cginc"
					#include "UnityPBSLighting.cginc"
					struct v2f
					{
						V2F_SHADOW_CASTER;
						float2 customPack1 : TEXCOORD1;
						float3 worldPos : TEXCOORD2;
						float3 worldNormal : TEXCOORD3;
						UNITY_VERTEX_INPUT_INSTANCE_ID
					};
					v2f vert(appdata_full v)
					{
						v2f o;
						UNITY_SETUP_INSTANCE_ID(v);
						UNITY_INITIALIZE_OUTPUT(v2f, o);
						UNITY_TRANSFER_INSTANCE_ID(v, o);
						Input customInputData;
						vertexDataFunc(v, customInputData);
						float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
						half3 worldNormal = UnityObjectToWorldNormal(v.normal);
						o.worldNormal = worldNormal;
						o.customPack1.xy = customInputData.uv_texcoord;
						o.customPack1.xy = v.texcoord;
						o.worldPos = worldPos;
						TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
						return o;
					}
					half4 frag(v2f IN
					#if !defined( CAN_SKIP_VPOS )
					, UNITY_VPOS_TYPE vpos : VPOS
					#endif
					) : SV_Target
					{
						UNITY_SETUP_INSTANCE_ID(IN);
						Input surfIN;
						UNITY_INITIALIZE_OUTPUT(Input, surfIN);
						surfIN.uv_texcoord = IN.customPack1.xy;
						float3 worldPos = IN.worldPos;
						half3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
						surfIN.viewDir = worldViewDir;
						surfIN.worldPos = worldPos;
						surfIN.worldNormal = IN.worldNormal;
						SurfaceOutputCustomLightingCustom o;
						UNITY_INITIALIZE_OUTPUT(SurfaceOutputCustomLightingCustom, o)
						surf(surfIN, o);
						#if defined( CAN_SKIP_VPOS )
						float2 vpos = IN.pos;
						#endif
						SHADOW_CASTER_FRAGMENT(IN)
					}
					ENDCG
				}
			
					

		}
			Fallback "Diffuse"
}
