// Shader by VFX_LYP

Shader "LYP_FX/Cel_Shader" {
    Properties {
        _BaseTex ("BaseTex", 2D) = "white" {}
        [HDR]_BaseTexColor ("BaseTexColor", Color) = (1,1,1,1)
        _ILMTex ("ILMTex", 2D) = "white" {}
        _ShadowRange ("ShadowRange", Range(0, 1)) = 1
        _ShadowPower ("ShadowPower", Range(0, 1)) = 0.8
        _SpecularRange ("SpecularRange", Range(0.5, 1)) = 0.998
        _SpecularPower ("SpecularPower", Range(0, 1)) = 0.88
        [HDR]_OutlineColor ("OutlineColor", Color) = (0.5019608,0.5019608,0.5019608,1)
        _OutlineWidth ("OutlineWidth", Range(0, 10)) =1
        _EmissionTex ("EmissionTex", 2D) = "white" {}
        [HDR]_EmissionColor ("EmissionColor", Color) = (0,0,0,0)
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "RenderType"="Opaque"
        }
        // 老的描边
        //Pass {
        //    Name "Outline"
        //    Tags {
        //    }
        //    Cull Front
        //    
        //    CGPROGRAM
        //    #pragma vertex vert
        //    #pragma fragment frag
        //    #include "UnityCG.cginc"
        //    #pragma fragmentoption ARB_precision_hint_fastest
        //    #pragma multi_compile_shadowcaster
        //    #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal d3d11_9x 
        //    #pragma target 3.0
        //    uniform float4 _LightColor0;
        //    uniform sampler2D _BaseTex; uniform float4 _BaseTex_ST;
        //    uniform float _OutlineWidth;
        //    uniform float4 _OutlineColor;
        //    struct VertexInput {
        //        float4 vertex : POSITION;
        //        float3 normal : NORMAL;
        //        float2 texcoord0 : TEXCOORD0;
        //        float4 tangent : TANGENT;
        //    };
        //    struct VertexOutput {
        //        float4 pos : SV_POSITION;
        //        float2 uv0 : TEXCOORD0;
        //    };
        //    VertexOutput vert (VertexInput v) {
        //        VertexOutput o = (VertexOutput)0;
        //        o.uv0 = v.texcoord0;
        //       /* float3 lightColor = _LightColor0.rgb;*/
        //        o.pos = UnityObjectToClipPos( float4(v.vertex.xyz + v.normal*_OutlineWidth*0.1,1) );
        //        return o;
        //    }
        //    float4 frag(VertexOutput i) : COLOR {
        //        float3 lightColor = _LightColor0.rgb;
        //        float4 _BaseTex_var = tex2D(_BaseTex,TRANSFORM_TEX(i.uv0, _BaseTex));
        //        return fixed4(((_BaseTex_var.rgb*_OutlineColor.rgb)*_LightColor0.rgb),0);
        //    }
        //    ENDCG
        //}
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal d3d11_9x 
            #pragma target 3.0
            uniform float _ShadowRange;
            uniform float _SpecularRange;
            uniform sampler2D _BaseTex; uniform float4 _BaseTex_ST;
            uniform float _ShadowPower;
            uniform float _SpecularPower;
            uniform sampler2D _ILMTex; uniform float4 _ILMTex_ST;
            uniform float4 _BaseTexColor;
            uniform sampler2D _EmissionTex; uniform float4 _EmissionTex_ST;
            uniform float4 _EmissionColor;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
////// Lighting:
                float attenuation = 1;
////// Emissive:
                float4 _EmissionTex_var = tex2D(_EmissionTex,TRANSFORM_TEX(i.uv0, _EmissionTex));
                float3 emissive = (_EmissionColor.rgb*_EmissionColor.a*_EmissionTex_var.rgb*_EmissionTex_var.a);
                float4 N_01 = tex2D(_ILMTex,TRANSFORM_TEX(i.uv0, _ILMTex));
                float4 _BaseTex_var = tex2D(_BaseTex,TRANSFORM_TEX(i.uv0, _BaseTex));
                float3 N_02 = saturate(( (_BaseTex_var.rgb*_BaseTexColor.rgb) > 0.5 ? (1.0-(1.0-2.0*((_BaseTex_var.rgb*_BaseTexColor.rgb)-0.5))*(1.0-N_01.g)) : (2.0*(_BaseTex_var.rgb*_BaseTexColor.rgb)*N_01.g) ));
                float4 N_03 = tex2D(_ILMTex,TRANSFORM_TEX(i.uv0, _ILMTex));
                float N_04 = step((max(0,dot(lightDirection,normalDirection))-(0.5-N_03.g)),_ShadowRange);
                float N_05 = step(_ShadowRange,(max(0,dot(lightDirection,normalDirection))-(0.5-N_03.g)));
                float N_06 = 0.0;
                float DiffuseIf = lerp((N_04*N_06)+(N_05*1.0),N_06,N_04*N_05);
                float3 Diffuse = (N_02*DiffuseIf);
                float4 N_07 = tex2D(_ILMTex,TRANSFORM_TEX(i.uv0, _ILMTex));
                float N_08 = step(saturate(pow(max(0,dot(viewDirection,normalDirection)),N_07.r)),_SpecularRange);
                float N_09 = step(_SpecularRange,saturate(pow(max(0,dot(viewDirection,normalDirection)),N_07.r)));
                float N_10 = 0.0;
                float N_11 = step((lerp((N_08*N_10)+(N_09*1.0),N_10,N_08*N_09)*N_07.b),0.1);
                float N_12 = step(0.1,(lerp((N_08*N_10)+(N_09*1.0),N_10,N_08*N_09)*N_07.b));
                float N_13 = 0.0;
                float3 finalColor = emissive + (((Diffuse+((N_02*_ShadowPower)*(1.0 - DiffuseIf)))+(DiffuseIf*((Diffuse*_SpecularPower)*lerp((N_11*N_13)+(N_12*1.0),N_13,N_11*N_12))))*_LightColor0.rgb*attenuation);
                return fixed4(finalColor,1);
            }
            ENDCG
        }
        Pass {
            Name "Meta"
            Tags {
                "LightMode"="Meta"
            }
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "UnityMetaPass.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal d3d11_9x 
            #pragma target 3.0
            uniform sampler2D _EmissionTex; uniform float4 _EmissionTex_ST;
            uniform float4 _EmissionColor;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
                float2 texcoord2 : TEXCOORD2;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityMetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord2.xy, unity_LightmapST, unity_DynamicLightmapST );
                return o;
            }
            float4 frag(VertexOutput i) : SV_Target {
                UnityMetaInput o;
                UNITY_INITIALIZE_OUTPUT( UnityMetaInput, o );
                
                float4 _EmissionTex_var = tex2D(_EmissionTex,TRANSFORM_TEX(i.uv0, _EmissionTex));
                o.Emission = (_EmissionColor.rgb*_EmissionColor.a*_EmissionTex_var.rgb*_EmissionTex_var.a);
                
                float3 diffColor = float3(0,0,0);
                o.Albedo = diffColor;
                
                return UnityMetaFragment( o );
            }
            ENDCG
        }
        //新的描边
        Pass
        {   // outline 外轮廓线
            Tags {"LightMode" = "ForwardBase"}
            //裁剪正面，只画背面
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            half _OutlineWidth;
            half4 _OutLineColor;
            uniform sampler2D _BaseTex; uniform float4 _BaseTex_ST;
            uniform float4 _LightColor0;
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float4 vertColor : COLOR;
                float4 tangent : TANGENT;
            };
            struct v2f
            {
                float4 vertColor : TEXCOORD0;
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD1;
            };
            v2f vert(a2v v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                o.uv0 = v.uv;
                //顶点沿着法线方向外扩
                //顶点着色器替换以下代码
                float4 pos = UnityObjectToClipPos(v.vertex);
                //摄像机空间法线
                float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.tangent.xyz);
                //将法线变换到NDC空间，投影空间*W分量
                float3 ndcNormal = normalize(TransformViewToProjection(viewNormal.xyz)) * pos.w;

                // 将近裁剪面右上角位置的顶点变换到观察空间
                //unity_CameraInvProjection摄像机矩阵逆矩阵，UNITY_NEAR_CLIP_VALUE近截面值，DX：0，OpenGL-1.0;_ProjectionParams.y摄像机近截面
                float4 nearUpperRight = mul(unity_CameraInvProjection, float4(1, 1, UNITY_NEAR_CLIP_VALUE, _ProjectionParams.y));
                //求得屏幕宽高比
                float aspect = abs(nearUpperRight.y / nearUpperRight.x);
                ndcNormal.x *= aspect;

                //xy两方向外扩
                pos.xy += 0.01 * _OutlineWidth * ndcNormal.xy * v.vertColor.a;
                o.pos = pos;
                return o;
            }
            half4 frag(v2f i) : SV_TARGET
            {
                float4 _BaseTex_var = tex2D(_BaseTex,TRANSFORM_TEX(i.uv0, _BaseTex));

                return half4(_BaseTex_var*_OutLineColor.rgb * i.vertColor.rgb* _LightColor0.rgb, 0);
            }
            ENDCG
        }


    }
    FallBack "Legacy Shaders/Diffuse"
}
