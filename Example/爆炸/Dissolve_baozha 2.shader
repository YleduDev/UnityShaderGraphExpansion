// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ASE_BayunShader/Dissolve_baozha2"
{
	Properties
	{
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("剔除模式", Float) = 0
		[Enum(AlphaBlend,10,Additive,1)]_Dst("材质模式", Float) = 10
		[Enum(Off,0,On,1)]_ZWriteMode("深度写入模式", Float) = 0
		[Enum(LessEqual,4,Always,8)]_ZTestMode("深度测试模式", Float) = 4
		_MainTex("主要纹理", 2D) = "white" {}
		[Enum(Right,0,Invert,1)]_OneMinus1("溶解纹理反向", Float) = 0
		[HDR]_R_C("R_C", Color) = (0.490566,0.2004046,0,1)
		[HDR]_G_C("G_C", Color) = (1,0.4286498,0,1)
		[HDR]_B_C("B_C", Color) = (0.490566,0.2004046,0,1)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha [_Dst]
		AlphaToMask Off
		Cull [_CullMode]
		ColorMask RGBA
		ZWrite [_ZWriteMode]
		ZTest [_ZTestMode]
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
			

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float _Dst;
			uniform float _ZWriteMode;
			uniform float _ZTestMode;
			uniform float _CullMode;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _R_C;
			uniform float _OneMinus1;
			uniform float4 _G_C;
			uniform float4 _B_C;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord2 = v.ase_texcoord1;
				o.ase_color = v.color;
				
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
				float4 tex2DNode5 = tex2D( _MainTex, uv_MainTex );
				float4 temp_output_425_0 = ( tex2DNode5.r * _R_C );
				float temp_output_1_0_g14 = tex2DNode5.a;
				float lerpResult3_g14 = lerp( temp_output_1_0_g14 , ( 1.0 - temp_output_1_0_g14 ) , _OneMinus1);
				float4 texCoord449 = i.ase_texcoord2;
				texCoord449.xy = i.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_11_0_g14 = texCoord449.w;
				float4 temp_output_404_0 = ( tex2DNode5.g * _G_C );
				float temp_output_1_0_g13 = tex2DNode5.a;
				float lerpResult3_g13 = lerp( temp_output_1_0_g13 , ( 1.0 - temp_output_1_0_g13 ) , _OneMinus1);
				float temp_output_11_0_g13 = texCoord449.w;
				float temp_output_1_0_g12 = tex2DNode5.a;
				float lerpResult3_g12 = lerp( temp_output_1_0_g12 , ( 1.0 - temp_output_1_0_g12 ) , _OneMinus1);
				float temp_output_11_0_g12 = texCoord449.w;
				float4 temp_output_414_0 = ( ( tex2DNode5.b * _B_C ) * saturate( ( ( ( ( lerpResult3_g12 + 1.0 ) - ( texCoord449.z * ( 1.0 + ( 1.0 - temp_output_11_0_g12 ) ) ) ) - temp_output_11_0_g12 ) / ( 1.0 - temp_output_11_0_g12 ) ) ) );
				float4 temp_output_413_0 = ( float4( (( temp_output_404_0 * (( temp_output_404_0 * saturate( ( ( ( ( lerpResult3_g13 + 1.0 ) - ( texCoord449.y * ( 1.0 + ( 1.0 - temp_output_11_0_g13 ) ) ) ) - temp_output_11_0_g13 ) / ( 1.0 - temp_output_11_0_g13 ) ) ) )).a )).rgb , 0.0 ) + ( temp_output_414_0 * ( 2.0 - (temp_output_414_0).a ) ) );
				
				
				finalColor = ( ( float4( (( temp_output_425_0 * (( temp_output_425_0 * saturate( ( ( ( ( lerpResult3_g14 + 1.0 ) - ( texCoord449.x * ( 1.0 + ( 1.0 - temp_output_11_0_g14 ) ) ) ) - temp_output_11_0_g14 ) / ( 1.0 - temp_output_11_0_g14 ) ) ) )).a )).rgb , 0.0 ) + ( temp_output_413_0 * ( 2.0 - (temp_output_413_0).a ) ) ) * i.ase_color );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
-21.6;131.2;1536;803;1424.163;2345.232;1.308055;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;449;-528.8964,-1288.319;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;405;-1547.719,-1984.7;Inherit;False;Property;_G_C;G_C;10;1;[HDR];Create;True;0;0;0;False;0;False;1,0.4286498,0,1;4.135785,1.882959,0.1513092,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;271;-2246.746,-1211.7;Inherit;False;Property;_OneMinus1;溶解纹理反向;5;1;[Enum];Create;False;0;2;Right;0;Invert;1;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-1677.772,-1576.25;Inherit;True;Property;_MainTex;主要纹理;4;0;Create;False;0;0;0;False;0;False;-1;None;a12c9d7c81fae8f419a3e010490518bc;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;412;-1756.889,-1164.224;Inherit;False;Property;_B_C;B_C;11;1;[HDR];Create;True;0;0;0;False;0;False;0.490566,0.2004046,0,1;0.2075472,0.02653985,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;404;-1235.032,-2013.001;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;411;-1248.582,-902.3029;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;438;-1044.337,-612.437;Inherit;True;Dissolve_软溶解;-1;;12;4621cb988475c8540b4d0d78c3ab9ce9;0;4;1;FLOAT;0;False;5;FLOAT;0;False;9;FLOAT;0;False;11;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;435;-898.6323,-1348.315;Inherit;False;Dissolve_软溶解;-1;;13;4621cb988475c8540b4d0d78c3ab9ce9;0;4;1;FLOAT;0;False;5;FLOAT;0;False;9;FLOAT;0;False;11;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;409;-954.7224,-1943.461;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;414;-659.7972,-689.5081;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;440;-675.276,-1947.593;Inherit;False;419;265;输出A，让颜色更加接近你想要的颜色;1;408;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ComponentMaskNode;408;-598.4409,-1886.515;Inherit;True;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;416;-484.7249,-266.3537;Inherit;False;Constant;_Float0;Float 0;18;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;421;-410.2433,-513.0195;Inherit;True;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;424;843.1721,-2207.994;Inherit;False;Property;_R_C;R_C;9;1;[HDR];Create;True;0;0;0;False;0;False;0.490566,0.2004046,0,1;5.992157,3.576471,2.196079,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;422;-197.3828,-2013.873;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;415;-38.61366,-467.3793;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;439;23.89371,-2054.517;Inherit;False;590.5341;246.432;不输出A是因为如果输出A则会让图半透的地方直接半透，甚至影响底层的图，所以直接不输出a;1;423;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;425;1131.612,-1977.975;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;436;919.3379,-1618.424;Inherit;False;Dissolve_软溶解;-1;;14;4621cb988475c8540b4d0d78c3ab9ce9;0;4;1;FLOAT;0;False;5;FLOAT;0;False;9;FLOAT;0;False;11;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;423;76.67004,-2009.895;Inherit;True;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;419;335.8629,-562.1048;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;426;1397.936,-1774.593;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;413;911.0554,-1128.193;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;428;1635.231,-1769.928;Inherit;True;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;432;1183.985,-955.0163;Inherit;True;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;433;1244.604,-703.7667;Inherit;False;Constant;_Float1;Float 1;18;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;427;1893.935,-1978.407;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;431;1582.832,-936.2328;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;434;1935.542,-1029.553;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;429;2151.688,-2020.471;Inherit;True;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;160;2891.67,-816.3558;Inherit;False;226;339;暴露在外面的枚举;4;13;9;10;12;;1,1,1,1;0;0
Node;AmplifyShaderEditor.VertexColorNode;450;2539.071,-1641.506;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;184;-3566.086,903.6936;Inherit;False;351.8325;246.3241;溶解纹理反向;3;183;181;182;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;430;2435.98,-1953.4;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;279;881.869,-1751.089;Inherit;False;Property;_Disslove3;R_RJ;12;0;Create;False;0;0;0;False;0;False;0;0.816;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;169;-3883.24,908.9355;Inherit;True;Property;_DissolveTex;溶解纹理;7;0;Create;False;0;0;0;False;0;False;-1;None;04a4a4d4f38eed44a81bf0be2eb0a34b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;13;2950.444,-774.357;Inherit;False;Property;_Dst;材质模式;1;1;[Enum];Create;False;0;2;AlphaBlend;10;Additive;1;0;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;215;-3350.789,1372.348;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;212;-3143.033,1167.516;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;183;-3549.098,1070.994;Inherit;False;Property;_OneMinus;溶解纹理反向;6;1;[Enum];Create;False;0;2;Right;0;Invert;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;216;-3174.531,957.8878;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;2951.188,-706.4206;Inherit;False;Property;_CullMode;剔除模式;0;1;[Enum];Create;False;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;2949.444,-559.3568;Inherit;False;Property;_ZTestMode;深度测试模式;3;1;[Enum];Create;False;0;2;LessEqual;4;Always;8;0;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;2948.444,-630.3569;Inherit;False;Property;_ZWriteMode;深度写入模式;2;1;[Enum];Create;False;0;2;Off;0;On;1;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;181;-3547.882,998.003;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;217;-2930.03,1120.688;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;272;-1226.939,-1415.229;Inherit;False;Property;_Disslove1;G_RJ;13;0;Create;False;0;0;0;False;0;False;0.6164021;0.869;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;273;-226.1701,-1225.882;Inherit;False;Property;_Hardness1;溶解软硬度;16;0;Create;False;0;0;0;False;0;False;0.4129481;0.608;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;451;2800.824,-1898.001;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;209;-3639.073,1243.927;Inherit;False;Property;_Hardness;溶解软硬度;15;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;182;-3359.218,940.5248;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;191;-2774.298,1213.218;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;277;-1728.216,-928.6572;Inherit;False;Property;_Disslove2;B_RJ;14;0;Create;False;0;0;0;False;0;False;0.6023573;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;214;-3189.395,1344.826;Inherit;False;2;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;188;-3597.297,1159.946;Inherit;False;Property;_Disslove;溶解;8;0;Create;False;0;0;0;False;0;False;0;0.5351878;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;2950.592,-1951.145;Float;False;True;-1;2;ASEMaterialInspector;100;1;ASE_BayunShader/Dissolve_baozha2;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;-1;10;True;13;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;0;True;9;True;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;2;True;10;True;7;True;12;True;True;0;False;159;0;False;160;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;404;0;5;2
WireConnection;404;1;405;0
WireConnection;411;0;5;3
WireConnection;411;1;412;0
WireConnection;438;1;5;4
WireConnection;438;5;271;0
WireConnection;438;9;449;3
WireConnection;438;11;449;4
WireConnection;435;1;5;4
WireConnection;435;5;271;0
WireConnection;435;9;449;2
WireConnection;435;11;449;4
WireConnection;409;0;404;0
WireConnection;409;1;435;0
WireConnection;414;0;411;0
WireConnection;414;1;438;0
WireConnection;408;0;409;0
WireConnection;421;0;414;0
WireConnection;422;0;404;0
WireConnection;422;1;408;0
WireConnection;415;0;416;0
WireConnection;415;1;421;0
WireConnection;425;0;5;1
WireConnection;425;1;424;0
WireConnection;436;1;5;4
WireConnection;436;5;271;0
WireConnection;436;9;449;1
WireConnection;436;11;449;4
WireConnection;423;0;422;0
WireConnection;419;0;414;0
WireConnection;419;1;415;0
WireConnection;426;0;425;0
WireConnection;426;1;436;0
WireConnection;413;0;423;0
WireConnection;413;1;419;0
WireConnection;428;0;426;0
WireConnection;432;0;413;0
WireConnection;427;0;425;0
WireConnection;427;1;428;0
WireConnection;431;0;433;0
WireConnection;431;1;432;0
WireConnection;434;0;413;0
WireConnection;434;1;431;0
WireConnection;429;0;427;0
WireConnection;430;0;429;0
WireConnection;430;1;434;0
WireConnection;215;0;209;0
WireConnection;212;0;188;0
WireConnection;212;1;214;0
WireConnection;216;0;182;0
WireConnection;181;0;169;1
WireConnection;217;0;216;0
WireConnection;217;1;212;0
WireConnection;451;0;430;0
WireConnection;451;1;450;0
WireConnection;182;0;169;1
WireConnection;182;1;181;0
WireConnection;182;2;183;0
WireConnection;191;0;217;0
WireConnection;191;1;209;0
WireConnection;214;1;215;0
WireConnection;2;0;451;0
ASEEND*/
//CHKSM=82E3272BEC7D912BC3DC7B25542D08BC61F7EBD7