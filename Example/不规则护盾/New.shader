// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FT/HUDUN_LOW"
{
	Properties
	{
		[IntRange]_NoiseNumber("噪波Scale", Range( 1 , 10)) = 1
		_NoiseSpeedX("噪波速度X", Float) = 0
		_NoiseSpeedY("噪波速度Y", Float) = 0.1
		_NoisePower("噪波Power", Float) = 1
		_EM_EdgeSize("发光边缘宽度", Range( 0 , 1)) = 0.1
		_EmColorInt("（表面）前发光强度", Float) = 2
		[HDR]_FrontColor("（表面）前发光颜色", Color) = (1,1,1,1)
		[HDR]_BackColor("（表面）背发光颜色", Color) = (1,1,1,1)
		_noiseMin("（表面）噪波最小阈值", Range( 0 , 1)) = 0.24
		_noisemax("（表面）噪波最大阈值", Range( 0 , 1)) = 0.56
		_Deothlerp("深度过渡", Range( 0 , 100)) = 0

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend One One
		AlphaToMask Off
		Cull Off
		ColorMask RGBA
		ZWrite Off
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform float _Deothlerp;
			uniform float _EmColorInt;
			uniform float4 _FrontColor;
			uniform float _noiseMin;
			uniform float _noisemax;
			uniform float _NoiseSpeedX;
			uniform float _NoiseSpeedY;
			uniform float _NoiseNumber;
			uniform float _NoisePower;
			uniform float _EM_EdgeSize;
			uniform float4 _BackColor;
			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord1 = screenPos;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord2.zw = v.ase_texcoord1.xy;
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
			
			fixed4 frag (v2f i , half ase_vface : VFACE) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float4 screenPos = i.ase_texcoord1;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth214 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
				float distanceDepth214 = saturate( abs( ( screenDepth214 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _Deothlerp ) ) );
				float2 texCoord248 = i.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0.115 );
				float2 appendResult261 = (float2(1.18 , 0.97));
				float2 appendResult325 = (float2(_NoiseSpeedX , _NoiseSpeedY));
				float2 texCoord146 = i.ase_texcoord2.zw * float2( 2,1 ) + float2( 0,0 );
				float2 panner151 = ( 1.0 * _Time.y * appendResult325 + frac( texCoord146 ));
				float simplePerlin2D153 = snoise( panner151*_NoiseNumber );
				simplePerlin2D153 = simplePerlin2D153*0.5 + 0.5;
				float saferPower178 = max( simplePerlin2D153 , 0.0001 );
				float temp_output_178_0 = pow( saferPower178 , _NoisePower );
				float smoothstepResult176 = smoothstep( _noiseMin , _noisemax , temp_output_178_0);
				float NoiseEmMask274 = smoothstepResult176;
				float2 temp_output_271_0 = ( appendResult261 * NoiseEmMask274 );
				float2 break266 = temp_output_271_0;
				float temp_output_2_0_g28 = 3.0;
				float cosSides12_g28 = cos( ( UNITY_PI / temp_output_2_0_g28 ) );
				float2 appendResult18_g28 = (float2(( break266.x * cosSides12_g28 ) , ( break266.y * cosSides12_g28 )));
				float2 break23_g28 = ( (texCoord248*2.0 + -1.0) / appendResult18_g28 );
				float polarCoords30_g28 = atan2( break23_g28.x , -break23_g28.y );
				float temp_output_52_0_g28 = ( 6.28318548202515 / temp_output_2_0_g28 );
				float2 appendResult25_g28 = (float2(break23_g28.x , -break23_g28.y));
				float2 finalUVs29_g28 = appendResult25_g28;
				float temp_output_44_0_g28 = ( cos( ( ( floor( ( 0.5 + ( polarCoords30_g28 / temp_output_52_0_g28 ) ) ) * temp_output_52_0_g28 ) - polarCoords30_g28 ) ) * length( finalUVs29_g28 ) );
				float2 temp_cast_0 = (_EM_EdgeSize).xx;
				float2 break264 = ( temp_output_271_0 - temp_cast_0 );
				float temp_output_2_0_g29 = 3.0;
				float cosSides12_g29 = cos( ( UNITY_PI / temp_output_2_0_g29 ) );
				float2 appendResult18_g29 = (float2(( break264.x * cosSides12_g29 ) , ( break264.y * cosSides12_g29 )));
				float2 break23_g29 = ( (texCoord248*2.0 + -1.0) / appendResult18_g29 );
				float polarCoords30_g29 = atan2( break23_g29.x , -break23_g29.y );
				float temp_output_52_0_g29 = ( 6.28318548202515 / temp_output_2_0_g29 );
				float2 appendResult25_g29 = (float2(break23_g29.x , -break23_g29.y));
				float2 finalUVs29_g29 = appendResult25_g29;
				float temp_output_44_0_g29 = ( cos( ( ( floor( ( 0.5 + ( polarCoords30_g29 / temp_output_52_0_g29 ) ) ) * temp_output_52_0_g29 ) - polarCoords30_g29 ) ) * length( finalUVs29_g29 ) );
				float EM_Edge273 = saturate( ( saturate( ( ( 1.0 - temp_output_44_0_g28 ) / fwidth( temp_output_44_0_g28 ) ) ) - saturate( ( ( 1.0 - temp_output_44_0_g29 ) / fwidth( temp_output_44_0_g29 ) ) ) ) );
				float4 switchResult181 = (((ase_vface>0)?(( _EmColorInt * _FrontColor * EM_Edge273 )):(( EM_Edge273 * _BackColor ))));
				
				
				finalColor = ( distanceDepth214 * switchResult181 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
495.3333;72.66667;1654;951;-891.0327;-817.3317;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;287;1029.848,186.7464;Inherit;False;1957.515;681.9413;Comment;18;146;282;151;189;179;153;188;187;178;176;219;220;218;274;286;323;324;325;噪波遮罩;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;323;1068.428,346.4676;Inherit;False;Property;_NoiseSpeedX;噪波速度X;1;0;Create;False;0;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;324;1072.428,428.4676;Inherit;False;Property;_NoiseSpeedY;噪波速度Y;2;0;Create;False;0;0;0;False;0;False;0.1;-0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;146;1070.848,232.7464;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;2,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FractNode;282;1318,236.1547;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;325;1305.428,351.4676;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;189;1431.891,433.4091;Inherit;False;Property;_NoiseNumber;噪波Scale;0;1;[IntRange];Create;False;0;0;0;False;0;False;1;2;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;151;1471.552,254.0881;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;153;1728.153,365.3097;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;179;1998.37,229.1786;Inherit;False;Property;_NoisePower;噪波Power;3;0;Create;False;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;188;2095.578,512.0356;Inherit;False;Property;_noisemax;（表面）噪波最大阈值;9;0;Create;False;0;0;0;False;0;False;0.56;0.653;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;187;2097.822,404.0463;Inherit;False;Property;_noiseMin;（表面）噪波最小阈值;8;0;Create;False;0;0;0;False;0;False;0.24;0.387;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;178;2207.918,305.269;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;176;2489.008,386.3336;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.2;False;2;FLOAT;0.42;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;288;1029.454,929.593;Inherit;False;1973.844;649.071;Comment;16;249;273;269;265;260;264;248;250;266;262;271;263;275;261;259;251;表面发光遮罩;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;274;2754.129,389.7119;Inherit;False;NoiseEmMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;251;1079.454,1133.005;Inherit;False;Constant;_Float11;Float 11;19;0;Create;True;0;0;0;False;0;False;1.18;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;259;1086.21,1244.664;Inherit;False;Constant;_Float12;Float 12;19;0;Create;True;0;0;0;False;0;False;0.97;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;275;1258.787,1331.932;Inherit;True;274;NoiseEmMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;261;1286.21,1174.664;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;263;1546.196,1500.984;Inherit;False;Property;_EM_EdgeSize;发光边缘宽度;4;0;Create;False;0;0;0;False;0;False;0.1;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;271;1503.263,1281.785;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;262;1719.699,1373.642;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;266;1725.424,1235.198;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TextureCoordinatesNode;248;1640.271,975.7769;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0.115;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;264;1855.21,1371.664;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;250;1686.971,1139.217;Inherit;False;Constant;_Float10;Float 10;19;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;249;2026.134,1031.382;Inherit;True;Polygon;-1;;28;6906ef7087298c94c853d6753e182169;0;4;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;260;2003.21,1311.664;Inherit;True;Polygon;-1;;29;6906ef7087298c94c853d6753e182169;0;4;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;265;2326.74,1025.416;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;269;2560.164,1028.707;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;297;3090.531,1012.45;Inherit;False;940.4285;547.7305;Comment;7;181;186;184;191;185;272;183;表面发光颜色;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;273;2748.299,1030.05;Inherit;False;EM_Edge;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;183;3223.648,1129.834;Inherit;False;Property;_FrontColor;（表面）前发光颜色;6;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;0.3333478,1.225278,1.720795,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;191;3246.414,1047.435;Inherit;False;Property;_EmColorInt;（表面）前发光强度;5;0;Create;False;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;185;3119.5,1386.771;Inherit;False;Property;_BackColor;（表面）背发光颜色;7;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;0,2.996078,1.34902,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;272;3125.479,1295.14;Inherit;False;273;EM_Edge;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;298;3342.928,672.1363;Inherit;False;350;314.3813;Comment;2;214;215;深度（如果遇到模型穿插可用）;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;3522.988,1364.726;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;3573.988,1133.953;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;215;3392.928,722.1364;Inherit;False;Property;_Deothlerp;深度过渡;12;0;Create;False;0;0;0;False;0;False;0;2;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;379;1117.47,2070.112;Inherit;False;755;357;Comment;4;411;410;378;377;如何贴合UV，可以调整其他变量，来适配右边UV贴图;0,1,0.1660659,1;0;0
Node;AmplifyShaderEditor.DepthFade;214;3418.397,851.5177;Inherit;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwitchByFaceNode;181;3761.92,1336.388;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;378;1169.47,2137.111;Inherit;False;Constant;_Float6;Float 6;21;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;413;1137.346,1868.64;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0.115;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;409;1959.936,2140.408;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;218;2484.093,614.6876;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.2;False;2;FLOAT;0.42;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;216;3916.664,848.4305;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;219;2097.208,630.5275;Inherit;False;Property;_VertexMin;噪波最小阈值（顶点）;10;0;Create;False;0;0;0;False;0;False;0.24;0.387;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;412;2247.934,2141.407;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;286;2745.363,644.9706;Inherit;False;VertexOffsetMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;377;1386.47,2163.111;Inherit;True;Polygon;-1;;30;6906ef7087298c94c853d6753e182169;0;4;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;410;1172.937,2233.114;Inherit;False;Constant;_Float0;Float 0;18;0;Create;True;0;0;0;False;0;False;1.18;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;411;1176.066,2302.05;Inherit;False;Constant;_Float1;Float 1;18;0;Create;True;0;0;0;False;0;False;0.97;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;393;1561.854,1698.827;Inherit;True;Property;_Mask_test;Mask_test;13;0;Create;True;0;0;0;False;0;False;-1;0eb4d5af5eadfa449929317e6efa77f5;0eb4d5af5eadfa449929317e6efa77f5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;220;2094.963,735.517;Inherit;False;Property;_Vertemax;噪波最大阈值（顶点）;11;0;Create;False;0;0;0;False;0;False;0.56;0.653;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;289;4242.095,847.2545;Float;False;True;-1;2;ASEMaterialInspector;100;1;FT/HUDUN_LOW;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;4;1;False;-1;1;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;2;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;282;0;146;0
WireConnection;325;0;323;0
WireConnection;325;1;324;0
WireConnection;151;0;282;0
WireConnection;151;2;325;0
WireConnection;153;0;151;0
WireConnection;153;1;189;0
WireConnection;178;0;153;0
WireConnection;178;1;179;0
WireConnection;176;0;178;0
WireConnection;176;1;187;0
WireConnection;176;2;188;0
WireConnection;274;0;176;0
WireConnection;261;0;251;0
WireConnection;261;1;259;0
WireConnection;271;0;261;0
WireConnection;271;1;275;0
WireConnection;262;0;271;0
WireConnection;262;1;263;0
WireConnection;266;0;271;0
WireConnection;264;0;262;0
WireConnection;249;1;248;0
WireConnection;249;2;250;0
WireConnection;249;3;266;0
WireConnection;249;4;266;1
WireConnection;260;1;248;0
WireConnection;260;2;250;0
WireConnection;260;3;264;0
WireConnection;260;4;264;1
WireConnection;265;0;249;0
WireConnection;265;1;260;0
WireConnection;269;0;265;0
WireConnection;273;0;269;0
WireConnection;186;0;272;0
WireConnection;186;1;185;0
WireConnection;184;0;191;0
WireConnection;184;1;183;0
WireConnection;184;2;272;0
WireConnection;214;0;215;0
WireConnection;181;0;184;0
WireConnection;181;1;186;0
WireConnection;409;0;393;1
WireConnection;409;1;377;0
WireConnection;218;0;178;0
WireConnection;218;1;219;0
WireConnection;218;2;220;0
WireConnection;216;0;214;0
WireConnection;216;1;181;0
WireConnection;412;0;409;0
WireConnection;286;0;218;0
WireConnection;377;1;413;0
WireConnection;377;2;378;0
WireConnection;377;3;410;0
WireConnection;377;4;411;0
WireConnection;289;0;216;0
ASEEND*/
//CHKSM=D1D0ADB61A306A1E9F874BA1199C831ED2881344