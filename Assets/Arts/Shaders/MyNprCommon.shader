Shader "Unlit/MyNprCommon"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _IlmTexture("IlmTexture", 2D) = "white" {}
        _OutlineWidth("Outline Width", Range(0.01, 10)) = 0.24
        _OutLineColor("OutLine Color", Color) = (0.5,0.5,0.5,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
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
}
