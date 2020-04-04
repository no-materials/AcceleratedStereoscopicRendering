/*
 * Authors: Niko Wissmann
 */

import ShaderCommon;
import Shading;

// reconstruct shading data from G-buffer data
ShadingData reconstructShadingData(float3 camPosW, float3 posW, float3 normalW, float4 albedo, float4 specular)
{
    ShadingData sd = initShadingData();
    sd.posW = posW;
    sd.V = normalize(camPosW - posW);
    sd.N = normalW;
    sd.NdotV = dot(sd.N, sd.V);
    sd.linearRoughness = specular.a;
    sd.roughness = sd.linearRoughness * sd.linearRoughness;

    sd.diffuse = albedo.rgb;
    sd.opacity = albedo.a;
    sd.specular = specular.rgb;

    return sd;
}
