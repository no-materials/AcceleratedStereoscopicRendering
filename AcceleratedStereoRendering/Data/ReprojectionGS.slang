/*
 * Authors: Niko Wissmann
 */

cbuffer PerImageCBGeo
{
    float gThreshold;
};

struct VertexOutput
{
    float3 posW : POSW;
    float4 posH : SV_POSITION;
    float2 texC : TEXCRD;
    float occFlag : DOCCFLAG;
};

struct GeometryOut
{
    VertexOutput vsOut;
};

// ######
// Not used in final version
// ######
[maxvertexcount(3)]
void main(triangle VertexOutput input[3], inout TriangleStream<GeometryOut> outStream)
{
    GeometryOut gsOut;

    for (int i = 0; i < 3; i++)
    {
#ifdef _DISCARD_TRIANGLES
        if (input[i].occFlag > gThreshold)
            break;
#endif
        gsOut.vsOut = input[i];
        outStream.Append(gsOut);
    }
    outStream.RestartStrip();
}
