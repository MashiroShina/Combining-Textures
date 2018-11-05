Shader "Custom/Texture Splatting"
{
	Properties {
	_Tint ("Tint", Color) = (1, 1, 1, 1)
	_MainTex("Splat Map",2D)="white"{}
	[NoScaleOffset]_Texture1 ("Texture 1", 2D) = "white" {}
	[NoScaleOffset]_Texture2 ("Texture 2", 2D) = "white" {}
	[NoScaleOffset]_Texture3 ("Texture 3", 2D) = "white" {}
	[NoScaleOffset]_Texture4 ("Texture 4", 2D) = "white" {}
	}
	SubShader{
		Pass{
		CGPROGRAM
		#pragma vertex MyVertexProgram
		#pragma fragment MyFragmentProgram
		#include "UnityCG.cginc"

		float4 _Tint;
		sampler2D _MainTex;
		sampler2D _Texture1,_Texture2,_Texture3,_Texture4;
		float4 _MainTex_ST;

		struct VertexData {
		float4 position : POSITION;
		float2 uv : TEXCOORD0;
		};

		struct Interpolators {
		float4 position:SV_POSITION;
		float2 uv : TEXCOORD0;
		float2 uvSplat:TEXCOORD1;
		};

		Interpolators MyVertexProgram(VertexData v)
		{
		Interpolators i;
		i.position = UnityObjectToClipPos(v.position);
		i.uv = TRANSFORM_TEX(v.uv, _MainTex);
		i.uvSplat=v.uv;
		//i.uv = v.uv*_MainTex_ST.xy+_MainTex_ST.zw;  ==  TRANSFORM_TEX(v.uv, _MainTex);  
		//offset in zw, scale in xy
		return i;
		}

		float4 MyFragmentProgram(Interpolators i):SV_TARGET
		{
		float4 Splat=tex2D(_MainTex,i.uvSplat)*_Tint;
		float4 color=tex2D(_Texture1,i.uv)*Splat.r*_Tint
		+tex2D(_Texture2,i.uv)*Splat.g*_Tint
		+tex2D(_Texture3,i.uv)*Splat.b*_Tint
		+tex2D(_Texture4,i.uv)*(1-Splat.r-Splat.g-Splat.b)*_Tint;
		return color;
		//return float4(i.uv,1,1);
		//return float4(i.localPosition+0.5,1);////Because negative colors get clamped to zero, our sphere ends up rather dark. As the default sphere has an object-space radius of ½, the color channels end up somewhere between −½ and ½. We want to move them into the 0–1 range, which we can do by adding ½ to all channels.
		}
		
		ENDCG
		}
	
	}
}
