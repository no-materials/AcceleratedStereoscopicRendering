/*
 * Authors: Niko Wissmann, Martin Misiak
 */

import ShaderCommon;


RWStructuredBuffer<float> gDiffResult;

cbuffer PerImageCBHull
{
    float gThreshold;
    float gTessFactor;
    uint gQuadCountX;
};

struct HS_Input
{
    float3 posW : POSW;
    float quadId : QUADID;
    float4 posH : SV_POSITION;
    float2 texC : TEXCRD;
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

#ifdef _BINOCULAR_METRIC
float getTessellationFactor(float quadid)
{
    // Do I have to split myself?
    if (gDiffResult[(int) quadid] > gThreshold)
    {
        return gTessFactor;
    }
    // Do my neighbors split - so do I have, too?
    else
    {
        // left
        
        if (gDiffResult[((int) quadid) - 1] > gThreshold)
        {
            return gTessFactor;
        }
        // right
        else if (gDiffResult[((int) quadid) + 1] > gThreshold)
        {
            return gTessFactor;
        }
        // top
        else if (gDiffResult[((int) quadid) - gQuadCountX] > gThreshold)
        {
            return gTessFactor;
        }
        // bottom
        else if (gDiffResult[((int) quadid) + gQuadCountX] > gThreshold)
        {
            return gTessFactor;
        }
        

#ifdef _EIGHT_NEIGHBOR
        // top right 
        else if (gDiffResult[((int) quadid) - gQuadCountX + 1] > gThreshold)
        {
            return gTessFactor;
        }
        // top left  
        else if (gDiffResult[((int) quadid) - gQuadCountX - 1] > gThreshold)
        {
            return gTessFactor;
        }
        // bottom right 
        else if (gDiffResult[((int) quadid) + gQuadCountX + 1] > gThreshold)
        {
            return gTessFactor;
        }
        // bottom left
        else if (gDiffResult[((int) quadid) + gQuadCountX - 1] > gThreshold)
        {
            return gTessFactor;
        }
#endif
    }

    // I don't need to split myself
    return 1.0;
}
#else
float getTessellationFactor(float quadid)
{
    // Do I have to split myself?
    if (gDiffResult[(int) quadid] < gThreshold)
    {
        return gTessFactor;
    }
    // Do my neighbors split - so do I have, too?
    else
    {
        // left
        
        if (gDiffResult[((int) quadid) - 1] < gThreshold)
        {
            return gTessFactor;
        }
        // right
        else if (gDiffResult[((int) quadid) + 1] < gThreshold)
        {
            return gTessFactor;
        }
        // top
        else if (gDiffResult[((int) quadid) - gQuadCountX] < gThreshold)
        {
            return gTessFactor;
        }
        // bottom
        else if (gDiffResult[((int) quadid) + gQuadCountX] < gThreshold)
        {
            return gTessFactor;
        }
        

#ifdef _EIGHT_NEIGHBOR
        // top right 
        else if (gDiffResult[((int) quadid) - gQuadCountX + 1] < gThreshold)
        {
            return gTessFactor;
        }
        // top left  
        else if (gDiffResult[((int) quadid) - gQuadCountX - 1] < gThreshold)
        {
            return gTessFactor;
        }
        // bottom right 
        else if (gDiffResult[((int) quadid) + gQuadCountX + 1] < gThreshold)
        {
            return gTessFactor;
        }
        // bottom left
        else if (gDiffResult[((int) quadid) + gQuadCountX - 1] < gThreshold)
        {
            return gTessFactor;
        }
#endif
    }

    // I don't need to split myself
    return 1.0;
}
#endif

HS_Constant_Output HSConstant(InputPatch<HS_Input, 4> inputPatch)
{
    HS_Constant_Output output;

    float fac = getTessellationFactor(inputPatch[0].quadId); // workaround solution for missing patchID parameter (see Github issue)

    output.edges[0] = fac;
    output.edges[1] = fac;
    output.edges[2] = fac;
    output.edges[3] = fac;

    output.inside[0] = fac;
    output.inside[1] = fac;

    return output;
};

[domain("quad")]
[partitioning("integer")]
[outputtopology("triangle_cw")]
[outputcontrolpoints(4)]
[patchconstantfunc("HSConstant")]
HS_Output main(InputPatch<HS_Input, 4> inputPatch, uint pointId : SV_OutputControlPointID, uint patchId : SV_PrimitiveID)
{
    HS_Output output;
    output.posW = inputPatch[pointId].posW;
    output.posH = inputPatch[pointId].posH;
    output.texC = inputPatch[pointId].texC;
    return output;
}
