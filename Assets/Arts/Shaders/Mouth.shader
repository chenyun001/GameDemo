// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/Demo-SequenceAnimation"
{
	Properties
	{
	_MainTex("Sequence Frame Image", 2D) = "white" {} // ����֡��������
	_Color("Color Tint", Color) = (1, 1, 1, 1)   // ��ɫ
	_HorizontalAmount("Horizontal Amount", float) = 4 // ����
	_VerticalAmount("Vertical Amount", float) = 4  // ����
	_Speed("Speed", Range(1, 100)) = 30 // �����ٶ�
	}

		SubShader
	{
		// ��������֡ͼ��ͨ��������͸��ͨ������˿��Ա�������һ����͸������
		// ����������ʹ�ð�͸���ġ����䡱����������SubShader ��ǩ������Queue ��RenderType ���ó�Transparent��
		//��IgnoreProjector ����ΪTrue
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True"}
		LOD 100

		Pass
		{
		Tags{"LightMode" = "ForwardBase"}

		// ��������֡ͼ��ͨ����͸������������Ҫ����Pass �����״̬������Ⱦ͸��Ч��
		// ��Pass �У�����ʹ��Blend ���������������û��ģʽ��ͬʱ�ر������д��
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag

		#include "UnityCG.cginc"

		struct appdata
		{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
		};

		struct v2f
		{
		float2 uv : TEXCOORD0;
		float4 vertex : SV_POSITION;
		};

		sampler2D _MainTex;
		float4 _MainTex_ST;
		fixed4 _Color;
		float _HorizontalAmount;
		float _VerticalAmount;
		float _Speed;

		v2f vert(appdata v)
		{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		return o;
		}

		fixed4 frag(v2f i) : SV_Target
		{
		float time = floor(_Time.y * _Speed);   //��������ʱ��
		float row = floor(time / _HorizontalAmount); // �ڼ���ͼƬ �����������ܶ�Ӧ������
		float column = time - row * _HorizontalAmount; // �ڼ���ͼƬ

		//ÿ�θ��µ���
	   // float offserX = 1.0 / _HorizontalAmount; 
	   // float offserY = 1.0 / _VerticalAmount;
	   // half2 uv = float2(i.uv.x * offsetX, i.uv.y*offsetY);

		//������ʾ��ͼƬ������Ӧ�еĴ�С ����һ���ؼ�֡ͼ��Ĵ�С��
		half2 uv = float2(i.uv.x / _HorizontalAmount, i.uv.y / _VerticalAmount); // �ȼ�������3��

		//���淽����Ȼ���ܺ�����֡����һһ��Ӧ�����Է�������֡������ִ��˳��
		uv.x += column / _HorizontalAmount; // ��������֡
		uv.y -= row / _VerticalAmount;  //�ȼ���uv.y += 1.0 - row / _VerticalAmount; 

		// sample the texture
		fixed4 col = tex2D(_MainTex, uv);
		//col.rgb *= _Color.rgb;   // ����������ɫ
		return col;
		}
		ENDCG
		}
	}
}