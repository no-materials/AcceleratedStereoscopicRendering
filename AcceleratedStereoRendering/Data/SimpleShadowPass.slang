/*
 * Authors: Niko Wissmann
 */

import DefaultVS;
import ShaderCommon;

struct PS_Input
{
    float4 posH : SV_POSITION;
};

PS_Input vs(VertexIn vIn)
{
    PS_Input psOut;
    float4x4 worldMat = getWorldMat(vIn);
    float4 posW = mul(vIn.pos, worldMat);
    psOut.posH = mul(posW, gCamera.viewProjMat);

    return psOut;
}

void ps(PS_Input psIn) : SV_TARGET
{
}
