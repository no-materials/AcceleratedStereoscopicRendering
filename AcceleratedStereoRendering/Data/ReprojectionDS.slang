/*
 * Authors: Niko Wissmann
 */

import ShaderCommon;

SamplerState gLinearSampler;
Texture2D gDepthTex;

cbuffer PerImageCBDomain
{
    float4x4 gThirdPersonViewProj;
    float4x4 gInvRightEyeViewProj;
};

struct HS_Constant_Output
{
    float edges[4] : SV_TessFactor;
    float inside[2] : SV_InsideTessFactor;
};

struct HS_Output
{
    float3 posW : POSW;
    float4 posH : SV_POSITION;
    float2 texC : TEXCRD;
};

struct VertexOutput
{
    float3 posW : POSW;
    float4 posH : SV_POSITION;
    float2 texC : TEXCRD;
    float occFlag : DOCCFLAG;
};

[domain("quad")]
VertexOutput main(HS_Constant_Output input, float2 UV : SV_DomainLocation, const OutputPatch<HS_Output, 4> patch, uint patchId : SV_PrimitiveID)
{
    VertexOutput output;
    
    float3 topMidpoint = lerp(patch[0].posW, patch[1].posW, UV.x);
    float3 bottomMidpoint = lerp(patch[3].posW, patch[2].posW, UV.x);

    float2 topMidpointUV = lerp(patch[0].texC, patch[1].texC, UV.x);
    float2 bottomMidpointUV = lerp(patch[3].texC, patch[2].texC, UV.x);

    float4 posH = float4(lerp(topMidpoint, bottomMidpoint, UV.y), 1);
    output.texC = float2(lerp(topMidpointUV, bottomMidpointUV, UV.y));

    float z = clamp(gDepthTex.SampleLevel(gLinearSampler, output.texC.xy, 0).r, 0.000001, 0.99999); // clamp is needed to avoid flickering if quad grid does not cover any geometry

#ifdef _DEBUG_THIRDPERSON
    float4 posWH = mul(mul(mul(float4(posH.xy, z, posH.w), gCamera.reprojectionMat), gInvRightEyeViewProj), gThirdPersonViewProj);
#else
    float4 posWH = mul(float4(posH.xy, z, posH.w), gCamera.reprojectionMat);
#endif

    output.posW = posWH.xyz;
    output.posH = float4(posWH.xy, z, posWH.w);

    //output.posW = posH.xyz; // [Debug] screen quad (no reprojection)
    //output.posH = posH;

    float zLeft   = gDepthTex.SampleLevel(gLinearSampler, output.texC.xy, 0, int2(-1, 0)).r;
    float zRight  = gDepthTex.SampleLevel(gLinearSampler, output.texC.xy, 0, int2(1, 0)).r;
    //float zTop    = gDepthTex.SampleLevel(gLinearSampler, output.texC.xy, 0, int2(0, 1)).r;
    //float zBottom = gDepthTex.SampleLevel(gLinearSampler, output.texC.xy, 0, int2(0, -1)).r;
    //float zMiddle = gDepthTex.SampleLevel(gLinearSampler, output.texC.xy, 0, int2(0, 0)).r;

    output.occFlag = abs(2 * zLeft - 2 * zRight); // sobel operator
    //output.occFlag = 0;
    //output.occFlag = abs(-4 * zMiddle + zLeft + zRight + zTop + zBottom); // laplace operator 

    return output;
}
