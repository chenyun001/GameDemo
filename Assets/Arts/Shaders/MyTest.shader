// ����3 ���չ�ʽ
// tex * Ce * Pe * Weight + (tex * Csky * Pdif + Csky * Cspec * Pspec) * (1 - Weight)
// �� �Է��� * Weight + ��������� + ����߹⣩* (1 - Weight)
Shader "MyShader/mihoyo/bh3"
{
    Properties
    {
        // ������ͼ
        _MainTex("Main Texture", 2D) = "white" {}
        // ������ͼ
        _LightTex("Light Map Texture", 2D) = "white" {}
        //_LightShadowRange("Shadow Range", Range(0, 1)) = 0.5
        // Ȩ��
        _Weight("Weight", Range(0, 1)) = 0.5
        // �Է������
        _Emission("Emission", Range(0, 1)) = 1
        _EmissionColor("Emission Color", Color) = (1,1,1,1)
        //_EmissionBloomFactor("Emission Bloom Factor", Range(0, 1)) = 0.9
        // ��������������������
        _DiffuseColor("Diffuse Color", Color) = (1,1,1,1)
        _FirstShadowColor("1st Shadow Color", Color) = (0.8,0.8,0.8,1)
        _FirstShadowLine("1st Shadow Line", Range(0, 1)) = 0.5
        _SecondShadowColor("2nd Shadow Color", Color) = (0.5,0.5,0.5,1)
        _SecondShadowLine("2nd Shadow Line", Range(0, 1)) = 0.2
        //_ThirdShadowColor("3rd Shadow Color", Color) = (0.2,0.2,0.2,1)
        // �߹����
        _SpecularColor("Specular Color", Color) = (1,1,1,1)
        _SpecularLine("Specular Line", Range(0, 1)) = 0.5
        _Gloss("_Gloss", Range(1, 255)) = 8
        // ���
        _OutLineColor("Outline Color", Color) = (0,0,0,0)
        _OutLineWidth("Outline Width", Range(0, 100)) = 50
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _LightTex;
            float4 _LightTex_ST;
            float _LightShadowRange;
            float _Weight;
            float _Emission;
            fixed4 _EmissionColor;
            float _EmissionBloomFactor;
            fixed4 _DiffuseColor;
            fixed4 _FirstShadowColor;
            float _FirstShadowLine;
            fixed4 _SecondShadowColor;
            float _SecondShadowLine;
            //fixed4 _ThirdShadowColor;
            fixed4 _SpecularColor;
            float _SpecularLine;
            float _Gloss;
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
                float4 texcoord : TEXCOORD0;
                fixed4 color : COLOR;
            };
            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed3 worldNormal : TEXCOORD0;
                fixed3 worldPos : TEXCOORD1;
                fixed4 uv : TEXCOORD2;
                fixed4 vertColor : TEXCOORD3;
            };
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = normalize(mul(unity_ObjectToWorld, v.vertex).xyz);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _LightTex);
                o.vertColor = v.color;
                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                // ����
                fixed3 worldNormal = normalize(i.worldNormal);
                // ����
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                // ���
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                //
                fixed3 worldHalfDir = normalize(worldLightDir + worldViewDir);

                // ��������ģ��
                float halfLambert = dot(worldNormal, worldLightDir) * 0.5 + 0.5;
                fixed4 mainTex = tex2D(_MainTex, i.uv.xy);  // ����ɫ
                fixed4 lightTex = tex2D(_LightTex, i.uv.zw); // ������ͼ
                // ������
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * mainTex.rgb;
                // �����Է���
                fixed3 emission;
                emission.rgb = mainTex.rgb * _Emission * _EmissionColor.rgb;
                // ����������
                fixed3 diffuse = fixed3(0,0,0);
                float diffuseMask = lightTex.g;
                if (diffuseMask > 0.1) 
                {
                    float firstMask = diffuseMask > 0.5 ? diffuseMask * 1.2 - 0.1 : diffuseMask * 1.25 - 0.125;
                    bool isLight = (firstMask + halfLambert) * 0.5 > _FirstShadowLine;
                    diffuse = isLight ? mainTex.rgb : mainTex.rgb * _FirstShadowColor.rgb;
                 }
                else 
                {
                    bool isFirst = (diffuseMask + halfLambert) * 0.5 > _SecondShadowLine;
                    diffuse = isFirst ? mainTex.rgb * _FirstShadowColor.rgb : mainTex.rgb * _SecondShadowColor.rgb;
                }
                diffuse *= _DiffuseColor.rgb * _LightColor0.rgb;

                // ����߹�
                float specularLight = pow(max(0, dot(worldNormal, worldHalfDir)), _Gloss);
                float3 specular = float3(0, 0, 0);
                if (lightTex.g != 1 && lightTex.r != 1) {
                    if ((specularLight + lightTex.b) > 1.0) {
                        if (halfLambert > _SpecularLine) {
                            specular = lightTex.b * _SpecularColor.rgb;
                        }
                    }
                }
                specular *= _LightColor0.rgb;

                // ������ɫ
                fixed4 color = fixed4(_Weight * emission + (1 - _Weight) * (diffuse + specular), 1);
                // _Weight * emission + ( 1 - _Weight) * color
                return  color;
            }
         ENDCG
        }

        Pass
        {        // outline ��������
                Tags {"LightMode" = "ForwardBase"}
                //�ü����棬ֻ������
                Cull Front
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
                half _OutlineWidth;
                half4 _OutLineColor;
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
                };
                v2f vert(a2v v)
                {
                    v2f o;
                    UNITY_INITIALIZE_OUTPUT(v2f, o);
                    //�������ŷ��߷�������
                    //������ɫ���滻���´���
                    float4 pos = UnityObjectToClipPos(v.vertex);
                    //������ռ䷨��
                    float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.tangent.xyz);
                    //�����߱任��NDC�ռ䣬ͶӰ�ռ�*W����
                    float3 ndcNormal = normalize(TransformViewToProjection(viewNormal.xyz)) * pos.w;

                    // �����ü������Ͻ�λ�õĶ���任���۲�ռ�
                    //unity_CameraInvProjection��������������UNITY_NEAR_CLIP_VALUE������ֵ��DX��0��OpenGL-1.0;_ProjectionParams.y�����������
                    float4 nearUpperRight = mul(unity_CameraInvProjection, float4(1, 1, UNITY_NEAR_CLIP_VALUE, _ProjectionParams.y));
                    //�����Ļ��߱�
                    float aspect = abs(nearUpperRight.y / nearUpperRight.x);
                    ndcNormal.x *= aspect;

                    //xy����������
                    pos.xy += 0.01 * _OutlineWidth * ndcNormal.xy * v.vertColor.a;
                    o.pos = pos;
                    return o;
                }
                half4 frag(v2f i) : SV_TARGET
                {
                    return half4(_OutLineColor.rgb * i.vertColor.rgb, 0);
                }
                ENDCG
        }
    }
    Fallback "VertexLit"
}

