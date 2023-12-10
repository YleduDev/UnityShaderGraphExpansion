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
		_EM_EdgeSize("发光边缘宽度", Float) = 0.1
		_EmColorInt("（表面）前发光强度", Float) = 2
		[HDR]_FrontColor("（表面）前发光颜色", Color) = (1,1,1,1)
		[HDR]_BackColor("（表面）背发光颜色", Color) = (1,1,1,1)
		_noiseMin("（表面）噪波最小阈值", Range( 0 , 1)) = 0.24
		_noisemax("（表面）噪波最大阈值", Range( 0 , 1)) = 0.56
		_VertexMin("噪波最小阈值（顶点）", Range( 0 , 1)) = 0.24
		_Vertemax("噪波最大阈值（顶点）", Range( 0 , 1)) = 0.56
		_VertexOffset_Max("顶点偏移最大阈值", Float) = 0.1
		_VertexOffset_MIN("顶点偏移最小阈值", Float) = -0.5
		_VertexEM_Int("（顶点偏移）发光强度", Float) = 2
		_VertexPower("（顶点透明度）power", Float) = 5
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
			#define ASE_NEEDS_VERT_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
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
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float _noiseMin;
			uniform float _noisemax;
			uniform float _NoiseSpeedX;
			uniform float _NoiseSpeedY;
			uniform float _NoiseNumber;
			uniform float _NoisePower;
			uniform float _VertexOffset_MIN;
			uniform float _VertexOffset_Max;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform float _Deothlerp;
			uniform float _VertexMin;
			uniform float _Vertemax;
			uniform float _VertexEM_Int;
			uniform float _VertexPower;
			uniform float _EmColorInt;
			uniform float4 _FrontColor;
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

				float2 texCoord276 = v.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_277_0 = step( texCoord276.x , 0.5 );
				float2 appendResult325 = (float2(_NoiseSpeedX , _NoiseSpeedY));
				float2 texCoord146 = v.ase_texcoord1.xy * float2( 2,1 ) + float2( 0,0 );
				float2 panner151 = ( 1.0 * _Time.y * appendResult325 + frac( texCoord146 ));
				float simplePerlin2D153 = snoise( panner151*_NoiseNumber );
				simplePerlin2D153 = simplePerlin2D153*0.5 + 0.5;
				float saferPower178 = max( simplePerlin2D153 , 0.0001 );
				float temp_output_178_0 = pow( saferPower178 , _NoisePower );
				float smoothstepResult176 = smoothstep( _noiseMin , _noisemax , temp_output_178_0);
				float NoiseEmMask274 = smoothstepResult176;
				
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord1 = screenPos;
				
				o.ase_texcoord2.xy = v.ase_texcoord1.xy;
				o.ase_color = v.color;
				o.ase_texcoord2.zw = v.ase_texcoord.xy;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = ( ( 1.0 - temp_output_277_0 ) * ( v.vertex.xyz * (_VertexOffset_MIN + (NoiseEmMask274 - 0.0) * (_VertexOffset_Max - _VertexOffset_MIN) / (1.0 - 0.0)) ) );
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
				float2 appendResult325 = (float2(_NoiseSpeedX , _NoiseSpeedY));
				float2 texCoord146 = i.ase_texcoord2.xy * float2( 2,1 ) + float2( 0,0 );
				float2 panner151 = ( 1.0 * _Time.y * appendResult325 + frac( texCoord146 ));
				float simplePerlin2D153 = snoise( panner151*_NoiseNumber );
				simplePerlin2D153 = simplePerlin2D153*0.5 + 0.5;
				float saferPower178 = max( simplePerlin2D153 , 0.0001 );
				float temp_output_178_0 = pow( saferPower178 , _NoisePower );
				float smoothstepResult218 = smoothstep( _VertexMin , _Vertemax , temp_output_178_0);
				float VertexOffsetMask286 = smoothstepResult218;
				float saferPower212 = max( i.ase_color.a , 0.0001 );
				float4 temp_cast_0 = (( VertexOffsetMask286 * _VertexEM_Int * pow( saferPower212 , _VertexPower ) )).xxxx;
				float2 texCoord248 = i.ase_texcoord2.zw * float2( 1,1 ) + float2( 0,0.1 );
				float2 appendResult261 = (float2(1.15 , 0.95));
				float smoothstepResult176 = smoothstep( _noiseMin , _noisemax , temp_output_178_0);
				float NoiseEmMask274 = smoothstepResult176;
				float2 temp_output_271_0 = ( appendResult261 * NoiseEmMask274 );
				float2 break266 = temp_output_271_0;
				float temp_output_2_0_g26 = 3.0;
				float cosSides12_g26 = cos( ( UNITY_PI / temp_output_2_0_g26 ) );
				float2 appendResult18_g26 = (float2(( break266.x * cosSides12_g26 ) , ( break266.y * cosSides12_g26 )));
				float2 break23_g26 = ( (texCoord248*2.0 + -1.0) / appendResult18_g26 );
				float polarCoords30_g26 = atan2( break23_g26.x , -break23_g26.y );
				float temp_output_52_0_g26 = ( 6.28318548202515 / temp_output_2_0_g26 );
				float2 appendResult25_g26 = (float2(break23_g26.x , -break23_g26.y));
				float2 finalUVs29_g26 = appendResult25_g26;
				float temp_output_44_0_g26 = ( cos( ( ( floor( ( 0.5 + ( polarCoords30_g26 / temp_output_52_0_g26 ) ) ) * temp_output_52_0_g26 ) - polarCoords30_g26 ) ) * length( finalUVs29_g26 ) );
				float2 temp_cast_1 = (_EM_EdgeSize).xx;
				float2 break264 = ( temp_output_271_0 - temp_cast_1 );
				float temp_output_2_0_g27 = 3.0;
				float cosSides12_g27 = cos( ( UNITY_PI / temp_output_2_0_g27 ) );
				float2 appendResult18_g27 = (float2(( break264.x * cosSides12_g27 ) , ( break264.y * cosSides12_g27 )));
				float2 break23_g27 = ( (texCoord248*2.0 + -1.0) / appendResult18_g27 );
				float polarCoords30_g27 = atan2( break23_g27.x , -break23_g27.y );
				float temp_output_52_0_g27 = ( 6.28318548202515 / temp_output_2_0_g27 );
				float2 appendResult25_g27 = (float2(break23_g27.x , -break23_g27.y));
				float2 finalUVs29_g27 = appendResult25_g27;
				float temp_output_44_0_g27 = ( cos( ( ( floor( ( 0.5 + ( polarCoords30_g27 / temp_output_52_0_g27 ) ) ) * temp_output_52_0_g27 ) - polarCoords30_g27 ) ) * length( finalUVs29_g27 ) );
				float EM_Edge273 = saturate( ( saturate( ( ( 1.0 - temp_output_44_0_g26 ) / fwidth( temp_output_44_0_g26 ) ) ) - saturate( ( ( 1.0 - temp_output_44_0_g27 ) / fwidth( temp_output_44_0_g27 ) ) ) ) );
				float4 switchResult181 = (((ase_vface>0)?(( _EmColorInt * _FrontColor * EM_Edge273 )):(( EM_Edge273 * _BackColor ))));
				float2 texCoord276 = i.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_277_0 = step( texCoord276.x , 0.5 );
				float4 lerpResult280 = lerp( temp_cast_0 , switchResult181 , temp_output_277_0);
				
				
				finalColor = ( distanceDepth214 * lerpResult280 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
2560;348.6667;1920;1019;-27.20715;-711.9349;2.12495;True;False
Node;AmplifyShaderEditor.CommentaryNode;287;1039.508,386.1157;Inherit;False;1957.515;681.9413;Comment;19;146;282;151;189;179;153;188;187;178;176;219;220;218;274;286;323;324;325;399;噪波遮罩;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;146;1080.508,432.1157;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;2,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;323;1078.088,545.8368;Inherit;False;Property;_NoiseSpeedX;噪波速度X;1;0;Create;False;0;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;324;1082.088,627.8368;Inherit;False;Property;_NoiseSpeedY;噪波速度Y;2;0;Create;False;0;0;0;False;0;False;0.1;-0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;282;1327.66,435.524;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;325;1315.088,550.8368;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;151;1481.212,453.4574;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;189;1441.551,632.7784;Inherit;False;Property;_NoiseNumber;噪波Scale;0;1;[IntRange];Create;False;0;0;0;False;0;False;1;2;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;179;2008.03,428.5479;Inherit;False;Property;_NoisePower;噪波Power;3;0;Create;False;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;153;1737.813,564.6789;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;187;2107.482,603.4155;Inherit;False;Property;_noiseMin;（表面）噪波最小阈值;8;0;Create;False;0;0;0;False;0;False;0.24;0.387;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;178;2217.578,504.6381;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;188;2105.238,711.4049;Inherit;False;Property;_noisemax;（表面）噪波最大阈值;9;0;Create;False;0;0;0;False;0;False;0.56;0.653;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;176;2498.668,585.7028;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.2;False;2;FLOAT;0.42;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;288;1084.787,1302.365;Inherit;False;1973.844;649.071;Comment;19;377;378;249;273;269;265;260;264;248;250;266;262;271;263;275;261;259;251;379;表面发光遮罩;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;274;2763.789,589.0811;Inherit;False;NoiseEmMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;259;1141.543,1617.436;Inherit;False;Constant;_Float12;Float 12;19;0;Create;True;0;0;0;False;0;False;0.95;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;251;1134.787,1505.777;Inherit;False;Constant;_Float11;Float 11;19;0;Create;True;0;0;0;False;0;False;1.15;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;261;1341.543,1547.436;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;275;1314.12,1704.704;Inherit;True;274;NoiseEmMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;271;1558.596,1655.568;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;263;1557.866,1796.767;Inherit;False;Property;_EM_EdgeSize;发光边缘宽度;4;0;Create;False;0;0;0;False;0;False;0.1;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;262;1749.543,1745.436;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;266;1753.757,1603.97;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TextureCoordinatesNode;248;1695.604,1351.065;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0.1;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;250;1742.304,1511.989;Inherit;False;Constant;_Float10;Float 10;19;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;264;1910.543,1744.436;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.FunctionNode;260;2058.543,1684.436;Inherit;True;Polygon;-1;;27;6906ef7087298c94c853d6753e182169;0;4;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;249;2081.467,1404.154;Inherit;True;Polygon;-1;;26;6906ef7087298c94c853d6753e182169;0;4;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;265;2382.073,1398.188;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;220;2104.623,934.8865;Inherit;False;Property;_Vertemax;噪波最大阈值（顶点）;11;0;Create;False;0;0;0;False;0;False;0.56;0.653;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;219;2106.868,829.897;Inherit;False;Property;_VertexMin;噪波最小阈值（顶点）;10;0;Create;False;0;0;0;False;0;False;0.24;0.387;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;269;2615.497,1401.479;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;218;2493.753,814.057;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.2;False;2;FLOAT;0.42;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;297;3062.476,397.4568;Inherit;False;888.0073;498.2217;Comment;8;185;183;181;186;272;184;191;401;表面发光颜色;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;296;3226.391,935.8555;Inherit;False;633.6084;347.7768;Comment;6;212;211;222;205;204;285;顶点偏移发光亮度;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;273;2803.632,1402.822;Inherit;False;EM_Edge;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;222;3260.508,1167.632;Inherit;False;Property;_VertexPower;（顶点透明度）power;15;0;Create;False;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;286;2755.023,844.3401;Inherit;False;VertexOffsetMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;185;3092.65,734.4384;Inherit;False;Property;_BackColor;（表面）背发光颜色;7;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;0,1,0.4468632,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;183;3263.252,455.3422;Inherit;False;Property;_FrontColor;（表面）前发光颜色;6;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;0.2588235,0.7331697,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;272;3099.833,653.6478;Inherit;False;273;EM_Edge;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;295;3242.252,1310.009;Inherit;False;542.0295;304;UVMask;2;277;276;UV遮罩（区分顶点和发光,范围不对就反相）;1,1,1,1;0;0
Node;AmplifyShaderEditor.VertexColorNode;211;3276.391,994.4716;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;191;3261.291,388.1928;Inherit;False;Property;_EmColorInt;（表面）前发光强度;5;0;Create;False;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;212;3501.636,1134.463;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;285;3454.792,985.8555;Inherit;False;286;VertexOffsetMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;3545.933,518.9603;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;204;3460.031,1056.916;Inherit;False;Property;_VertexEM_Int;（顶点偏移）发光强度;14;0;Create;False;0;0;0;False;0;False;2;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;283;3264.264,1776.865;Inherit;False;Property;_VertexOffset_MIN;顶点偏移最小阈值;13;0;Create;False;0;0;0;False;0;False;-0.5;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;284;3254.242,1680.937;Inherit;False;274;NoiseEmMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;298;3973.958,466.0681;Inherit;False;350;314.3813;Comment;2;214;215;深度（如果遇到模型穿插可用）;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;276;3292.252,1365.093;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;3533.477,720.8254;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;202;3263.718,1845.298;Inherit;False;Property;_VertexOffset_Max;顶点偏移最大阈值;12;0;Create;False;0;0;0;False;0;False;0.1;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;200;3521.547,1626.833;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;221;3523.687,1763.718;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.5;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwitchByFaceNode;181;3733.865,721.3954;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;277;3549.281,1360.009;Inherit;True;2;0;FLOAT;0.5;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;215;4023.958,516.068;Inherit;False;Property;_Deothlerp;深度过渡;16;0;Create;False;0;0;0;False;0;False;0;2;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;205;3698,1055.945;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;342;1051.238,2180.644;Inherit;False;2572.971;989.6399;Comment;31;373;366;341;374;339;338;340;337;336;335;334;331;381;333;332;362;365;370;368;367;369;391;392;394;395;396;397;398;330;400;402;第二套方案（贴图代替程序，精度较差但计算少）;0,1,0.09392524,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;198;3775.061,1657.839;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;280;4056.365,918.2095;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;281;3997.045,1340.958;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;214;4049.427,645.4493;Inherit;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;373;1406.902,2757.565;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;2,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;341;3366.221,2342.7;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;374;3284.195,2601.828;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;339;3172.106,2334.97;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;378;2415.077,1745.718;Inherit;False;Constant;_Float6;Float 6;21;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;400;3459.884,2596.513;Inherit;False;Em_Tex;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;368;1515.786,2866.636;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;401;3102.026,574.1645;Inherit;False;400;Em_Tex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;340;2379.938,2494.419;Inherit;True;Property;_Mask_Tex;Mask_Tex;18;0;Create;True;0;0;0;False;0;False;-1;0eb4d5af5eadfa449929317e6efa77f5;0eb4d5af5eadfa449929317e6efa77f5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;338;2946.723,2313.607;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;337;2696.728,2308.476;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.93;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;402;2315.979,2696.683;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;216;4235.879,914.1056;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;391;2246.075,2857.095;Inherit;False;NoiseTex;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;377;2577.077,1714.718;Inherit;True;Polygon;-1;;28;6906ef7087298c94c853d6753e182169;0;4;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;398;3306.125,2697.425;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;365;1711.786,2812.636;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;369;1344.786,3060.637;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;330;1062.44,2251.291;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;331;1303.01,2249.377;Inherit;True;5;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,1;False;3;FLOAT2;-5,-5;False;4;FLOAT2;6,6;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;396;1949.734,2605.638;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;278;4254.247,1459.036;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;336;2462.232,2229.012;Inherit;False;Property;_Em_Edge;Em_Edge;20;0;Create;True;0;0;0;False;0;False;0.75;0.76;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;392;1547.318,2353.532;Inherit;False;391;NoiseTex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;370;1536.786,2995.637;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;334;2066.559,2194.246;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TruncOpNode;394;2523.132,2698.337;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;397;2131.434,2544.639;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;399;1798.698,473.0125;Inherit;False;391;NoiseTex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;395;1760.634,2644.138;Inherit;False;Property;_MinClip;MinClip;23;0;Create;True;0;0;0;False;0;False;0.2;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;332;1499.993,2479.521;Inherit;False;Property;_EmTexSize;EmTexSize;19;0;Create;True;0;0;0;False;0;False;1;0.874;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;381;1877.393,2403.838;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;335;2366.014,2308.042;Inherit;True;Property;_Em_Tex;Em_Tex;17;0;Create;True;0;0;0;False;0;False;-1;6bbef7caa0c7a7b459bc5fe16e53caae;6bbef7caa0c7a7b459bc5fe16e53caae;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;366;1107.074,2878.712;Inherit;False;Property;_NoiseTexUVtiling;NoiseTexUVtiling;22;0;Create;True;0;0;0;False;0;False;1,1,0,0.1;1,1,0,0.1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;333;1852.997,2260.925;Inherit;False;Constant;_Vector1;Vector 1;1;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;367;1369.786,2962.637;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;393;2811.405,1726.533;Inherit;True;Property;_Mask_test;Mask_test;24;0;Create;True;0;0;0;False;0;False;-1;0eb4d5af5eadfa449929317e6efa77f5;0eb4d5af5eadfa449929317e6efa77f5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;362;1906.19,2819.554;Inherit;True;Property;_Noise_Tex;Noise_Tex;21;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;289;4673.611,1173.903;Float;False;True;-1;2;ASEMaterialInspector;100;1;FT/HUDUN_LOW;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;4;1;False;-1;1;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;2;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
Node;AmplifyShaderEditor.CommentaryNode;379;2342.077,1631.718;Inherit;False;700;304;Comment;0;如何贴合UV，可以调整其他变量，来适配右边UV贴图;0,1,0.1660659,1;0;0
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
WireConnection;260;1;248;0
WireConnection;260;2;250;0
WireConnection;260;3;264;0
WireConnection;260;4;264;1
WireConnection;249;1;248;0
WireConnection;249;2;250;0
WireConnection;249;3;266;0
WireConnection;249;4;266;1
WireConnection;265;0;249;0
WireConnection;265;1;260;0
WireConnection;269;0;265;0
WireConnection;218;0;178;0
WireConnection;218;1;219;0
WireConnection;218;2;220;0
WireConnection;273;0;269;0
WireConnection;286;0;218;0
WireConnection;212;0;211;4
WireConnection;212;1;222;0
WireConnection;184;0;191;0
WireConnection;184;1;183;0
WireConnection;184;2;272;0
WireConnection;186;0;272;0
WireConnection;186;1;185;0
WireConnection;221;0;284;0
WireConnection;221;3;283;0
WireConnection;221;4;202;0
WireConnection;181;0;184;0
WireConnection;181;1;186;0
WireConnection;277;0;276;1
WireConnection;205;0;285;0
WireConnection;205;1;204;0
WireConnection;205;2;212;0
WireConnection;198;0;200;0
WireConnection;198;1;221;0
WireConnection;280;0;205;0
WireConnection;280;1;181;0
WireConnection;280;2;277;0
WireConnection;281;0;277;0
WireConnection;214;0;215;0
WireConnection;341;0;339;0
WireConnection;341;1;374;0
WireConnection;341;2;398;0
WireConnection;374;0;340;1
WireConnection;339;0;338;0
WireConnection;400;0;341;0
WireConnection;368;0;366;1
WireConnection;368;1;366;2
WireConnection;340;1;334;0
WireConnection;338;0;337;0
WireConnection;337;0;335;1
WireConnection;337;1;336;0
WireConnection;402;0;397;0
WireConnection;216;0;214;0
WireConnection;216;1;280;0
WireConnection;391;0;362;1
WireConnection;377;2;378;0
WireConnection;398;0;394;0
WireConnection;365;0;373;0
WireConnection;365;1;368;0
WireConnection;365;2;370;0
WireConnection;331;0;330;0
WireConnection;396;1;395;0
WireConnection;278;0;281;0
WireConnection;278;1;198;0
WireConnection;370;0;367;0
WireConnection;370;1;369;0
WireConnection;334;0;331;0
WireConnection;334;1;333;0
WireConnection;334;2;332;0
WireConnection;394;0;402;0
WireConnection;397;0;332;0
WireConnection;397;1;396;0
WireConnection;381;0;392;0
WireConnection;381;1;332;0
WireConnection;335;1;334;0
WireConnection;367;0;366;3
WireConnection;367;1;366;4
WireConnection;362;1;365;0
WireConnection;289;0;216;0
WireConnection;289;1;278;0
ASEEND*/
//CHKSM=C8E78A13766EC18ABDDB46BE56140C22B95AD95F