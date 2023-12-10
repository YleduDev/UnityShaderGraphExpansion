// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "卡牌"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_MainIntensity("MainIntensity", Range( 0 , 10)) = 1
		_DissolveTex("DissolveTex", 2D) = "white" {}
		_Dissolve_progress("Dissolve_progress", Range( -0.1 , 1)) = 1
		_NoiseTex("NoiseTex", 2D) = "white" {}
		_NoiseColor("NoiseColor", Color) = (1,0,0.5117955,0)
		_NoiseIntensity("NoiseIntensity", Float) = 0
		[HDR]_AddColor("AddColor", Color) = (1,1,1,0)
		_EdgeTex("EdgeTex", 2D) = "white" {}
		_EdgeMask("EdgeMask", 2D) = "white" {}
		_EdgeIntensity("EdgeIntensity", Float) = 5
		_Edge_progress("Edge_progress", Range( -1 , 1)) = -0.1949682
		_GradientTex("GradientTex", 2D) = "white" {}
		_Gradient_Intensity("Gradient_Intensity", Float) = 0.1
		_Gradient_progress("Gradient_progress", Range( -1 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
		AlphaToMask Off
		Cull Off
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform sampler2D _EdgeMask;
			uniform float _Edge_progress;
			uniform sampler2D _EdgeTex;
			uniform float4 _EdgeTex_ST;
			uniform float4 _AddColor;
			uniform float _EdgeIntensity;
			uniform sampler2D _NoiseTex;
			uniform float4 _NoiseTex_ST;
			uniform float4 _NoiseColor;
			uniform float _NoiseIntensity;
			uniform float _Gradient_Intensity;
			uniform sampler2D _GradientTex;
			uniform float _Gradient_progress;
			uniform float _MainIntensity;
			uniform sampler2D _DissolveTex;
			uniform float4 _DissolveTex_ST;
			uniform float _Dissolve_progress;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 uv_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
				float2 texCoord25 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult26 = (float2(0.0 , _Edge_progress));
				float2 uv_EdgeTex = i.ase_texcoord1.xy * _EdgeTex_ST.xy + _EdgeTex_ST.zw;
				float4 temp_output_63_0 = ( ( ( tex2D( _EdgeMask, ( texCoord25 + appendResult26 ) ).r * tex2D( _EdgeTex, uv_EdgeTex ).r ) * _AddColor ) * _EdgeIntensity );
				float2 uv_NoiseTex = i.ase_texcoord1.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner3 = ( 1.0 * _Time.y * float2( 0,0.2 ) + uv_NoiseTex);
				float4 temp_cast_0 = (0.0).xxxx;
				float2 appendResult40 = (float2(0.0 , _Gradient_progress));
				float2 texCoord39 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 uv_DissolveTex = i.ase_texcoord1.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float4 appendResult19 = (float4(( tex2DNode1 + temp_output_63_0 + max( ( ( tex2D( _NoiseTex, panner3 ).r * _NoiseColor ) * _NoiseIntensity ) , temp_cast_0 ) + ( ( _Gradient_Intensity * tex2D( _GradientTex, ( appendResult40 + texCoord39 ) ) ) * _AddColor ) + ( ( pow( tex2DNode1.r , 0.5 ) * tex2DNode1 ) * _MainIntensity ) ).rgb , saturate( ( ( tex2DNode1.a * (temp_output_63_0).r ) + ( tex2DNode1.a * step( saturate( ( 1.0 - tex2D( _DissolveTex, uv_DissolveTex ).r ) ) , _Dissolve_progress ) ) ) )));
				
				
				finalColor = appendResult19;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
2560;348.6667;1920;1019;1957.803;83.04065;1.221002;True;False
Node;AmplifyShaderEditor.CommentaryNode;36;-3429.873,-277.3362;Inherit;False;2359.844;1025.134;裂缝光;13;66;63;32;64;30;31;29;28;27;25;26;24;23;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-3251.202,-125.7283;Inherit;False;Constant;_Float2;Float 2;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-3379.873,0.2458935;Inherit;False;Property;_Edge_progress;Edge_progress;11;0;Create;True;0;0;0;False;0;False;-0.1949682;-1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;26;-3005.09,-70.47898;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;25;-3069.828,-227.3361;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;27;-2813.227,-89.16257;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;34;-2218.914,1342.627;Inherit;False;1680.501;527.9282;加纹理;9;2;3;5;4;6;7;8;12;13;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;35;-1691.646,1931.438;Inherit;False;1159.448;479.0609;溶解;5;14;21;16;22;15;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;29;-2383.901,-113.6094;Inherit;True;Property;_EdgeMask;EdgeMask;9;0;Create;True;0;0;0;False;0;False;-1;503a4aa570b8c624c8eb847bb5fde804;7bea1a91cf97b284c98c829f3e10859c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;28;-3111.167,265.8763;Inherit;True;Property;_EdgeTex;EdgeTex;8;0;Create;True;0;0;0;False;0;False;-1;9c28ea7dca3c1814695572b7f10af2e8;9c28ea7dca3c1814695572b7f10af2e8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;37;-2857.943,938.4069;Inherit;False;Property;_Gradient_progress;Gradient_progress;14;0;Create;True;0;0;0;False;0;False;1;-1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;14;-1641.646,1981.439;Inherit;True;Property;_DissolveTex;DissolveTex;2;0;Create;True;0;0;0;False;0;False;-1;a8ec158d03b1a5a44afd07c110ee088c;a8ec158d03b1a5a44afd07c110ee088c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-2168.914,1417.564;Inherit;False;0;4;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;48;-2685.223,785.5827;Inherit;False;Constant;_Float1;Float 1;13;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-2060.428,272.2422;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;31;-2074.35,524.9703;Inherit;False;Property;_AddColor;AddColor;7;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;4.237095,1.06346,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;21;-1288.65,2009.814;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;40;-2483.16,867.6822;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;3;-1894.651,1420.732;Inherit;False;3;0;FLOAT2;0.5,0;False;2;FLOAT2;0,0.2;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;39;-2685.661,1044.3;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-1783.996,273.3691;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-1744.765,454.9589;Inherit;False;Property;_EdgeIntensity;EdgeIntensity;10;0;Create;True;0;0;0;False;0;False;5;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1055.127,-86.02296;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;0;False;-1;375b7a27abd79784695ea99c9ad73e6e;375b7a27abd79784695ea99c9ad73e6e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;57;-887.0552,-489.5573;Inherit;False;Constant;_Float4;Float 4;13;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1154.198,2294.5;Inherit;False;Property;_Dissolve_progress;Dissolve_progress;3;0;Create;True;0;0;0;False;0;False;1;1.1;-0.1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;5;-1643.876,1658.555;Inherit;False;Property;_NoiseColor;NoiseColor;5;0;Create;True;0;0;0;False;0;False;1,0,0.5117955,0;0.7075471,0.2459252,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-2300.061,1027.767;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;22;-1078.515,2011.073;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-1655.272,1392.627;Inherit;True;Property;_NoiseTex;NoiseTex;4;0;Create;True;0;0;0;False;0;False;-1;0549157e95d20e545a77def2bfd2fddb;0549157e95d20e545a77def2bfd2fddb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-1566.156,272.3769;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;56;-610.1364,-506.9733;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;15;-767.1976,2008.501;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-1221.934,1417.289;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1184.001,1702.857;Inherit;False;Property;_NoiseIntensity;NoiseIntensity;6;0;Create;True;0;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;43;-2058.989,1000.899;Inherit;True;Property;_GradientTex;GradientTex;12;0;Create;True;0;0;0;False;0;False;-1;503a4aa570b8c624c8eb847bb5fde804;0bdf5bf8c86cf0645861f844f02136d8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;42;-1955.62,908.0029;Inherit;False;Property;_Gradient_Intensity;Gradient_Intensity;13;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;66;-1376.956,498.4783;Inherit;False;True;False;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-884.5431,499.3771;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-451.8928,-185.8239;Inherit;False;Property;_MainIntensity;MainIntensity;1;0;Create;True;0;0;0;False;0;False;1;1.2;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-194.5453,651.3777;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-1630.827,979.7603;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-294.285,-392.1127;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-843.4118,1662.377;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-860.9942,1416.775;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;65;-6.714371,468.6373;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-1228.324,977.3898;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-133.8928,-295.8239;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;13;-690.4118,1416.377;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;68;178.9236,466.9921;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;9;80.3914,-56.41772;Inherit;False;5;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;19;379.1334,-64.83897;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;794.9576,-65.4552;Float;False;True;-1;2;ASEMaterialInspector;100;1;卡牌;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;2;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;26;0;23;0
WireConnection;26;1;24;0
WireConnection;27;0;25;0
WireConnection;27;1;26;0
WireConnection;29;1;27;0
WireConnection;30;0;29;1
WireConnection;30;1;28;1
WireConnection;21;0;14;1
WireConnection;40;0;48;0
WireConnection;40;1;37;0
WireConnection;3;0;2;0
WireConnection;32;0;30;0
WireConnection;32;1;31;0
WireConnection;41;0;40;0
WireConnection;41;1;39;0
WireConnection;22;0;21;0
WireConnection;4;1;3;0
WireConnection;63;0;32;0
WireConnection;63;1;64;0
WireConnection;56;0;1;1
WireConnection;56;1;57;0
WireConnection;15;0;22;0
WireConnection;15;1;16;0
WireConnection;6;0;4;1
WireConnection;6;1;5;0
WireConnection;43;1;41;0
WireConnection;66;0;63;0
WireConnection;69;0;1;4
WireConnection;69;1;66;0
WireConnection;20;0;1;4
WireConnection;20;1;15;0
WireConnection;44;0;42;0
WireConnection;44;1;43;0
WireConnection;59;0;56;0
WireConnection;59;1;1;0
WireConnection;8;0;6;0
WireConnection;8;1;7;0
WireConnection;65;0;69;0
WireConnection;65;1;20;0
WireConnection;45;0;44;0
WireConnection;45;1;31;0
WireConnection;61;0;59;0
WireConnection;61;1;62;0
WireConnection;13;0;8;0
WireConnection;13;1;12;0
WireConnection;68;0;65;0
WireConnection;9;0;1;0
WireConnection;9;1;63;0
WireConnection;9;2;13;0
WireConnection;9;3;45;0
WireConnection;9;4;61;0
WireConnection;19;0;9;0
WireConnection;19;3;68;0
WireConnection;0;0;19;0
ASEEND*/
//CHKSM=9B1739B45148EAE3527191CE7AA1353385B40C5D