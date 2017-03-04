Shader "Unlit/Constant" {
	Properties {
		_ConstantColor("Opacity", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}

	SubShader {
		Tags {"IgnoreProjector"="True"}
		LOD 100
		
		ZWrite Off

		Pass {
			Lighting Off
			
			SetTexture [_MainTex] { 
				constantColor [_ConstantColor]
				combine constant * texture
			}
		}
	}
}
