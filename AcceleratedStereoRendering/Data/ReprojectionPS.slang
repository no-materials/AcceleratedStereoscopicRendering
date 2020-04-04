/*
 * Authors: Niko Wissmann
 */

struct VertexOutput
{
    float3 posW : POSW;
    float4 posH : SV_POSITION;
    float2 texC : TEXCRD;
    float occFlag : DOCCFLAG;
};

cbuffer PerImageCBPixel
{
    float gThreshold;
    float3 gClearColor;
};

SamplerState gLinearSampler;
Texture2D gLeftEyeTex;

float4 main(VertexOutput vOut) : SV_TARGET
{
    float4 color;

#ifdef _PERFRAGMENT
    color = float4(gLeftEyeTex.SampleLevel(gLinearSampler, vOut.texC, 0).rgb, 1);
#endif
#ifdef _SHOWUVS
    color = float4(1, 1 , 1, 1);
#endif
#ifdef _SHOWDISOCCLUSION
        if (vOut.occFlag > gThreshold)
        {
            //color = float4(1, 0, 0, 0);
            color = float4(gLeftEyeTex.SampleLevel(gLinearSampler, vOut.texC, 0).rgb, 1);
        }
#else
    if (vOut.occFlag > gThreshold)
    {
        discard;
    }
    #endif

    return color;
}
