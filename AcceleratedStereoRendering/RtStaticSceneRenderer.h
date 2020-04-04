/*
 * Authors: Niko Wissmann
 */

#pragma once
#include "Experimental/Raytracing/RtScene.h"
#include "Experimental/Raytracing/RtProgramVars.h"
#include "Experimental/Raytracing/RtState.h"
#include "Graphics/Scene/SceneRenderer.h"

using namespace Falcor;

// Performance optimized RT renderer which avoids per-frame shader table updates 
class RtStaticSceneRenderer : public SceneRenderer, inherit_shared_from_this<SceneRenderer, RtStaticSceneRenderer>
{
public:
    using SharedPtr = std::shared_ptr<RtStaticSceneRenderer>;
    using SharedConstPtr = std::shared_ptr<const RtStaticSceneRenderer>;

    static SharedPtr create(RtScene::SharedPtr pScene);

    deprecate("3.3", "Ray dispatch now accepts depth as a parameter. Using the deprecated version will assume depth = 1.")
    void renderScene(RenderContext* pContext, std::shared_ptr<RtProgramVars> pRtVars, std::shared_ptr<RtState> pState, uvec2 targetDim, Camera* pCamera = nullptr);
    void renderScene(RenderContext* pContext, std::shared_ptr<RtProgramVars> pRtVars, std::shared_ptr<RtState> pState, uvec3 targetDim, Camera* pCamera = nullptr);

    bool mUpdateShaderState = true;
protected:
    RtStaticSceneRenderer(RtScene::SharedPtr pScene) : SceneRenderer(pScene) {}
    struct InstanceData
    {
        CurrentWorkingData currentData;
        uint32_t model;
        uint32_t modelInstance;
        uint32_t mesh;
        uint32_t meshInstance;
        uint32_t progId;
    };

    virtual void setPerFrameData(RtProgramVars* pRtVars, InstanceData& data);
    virtual bool setPerMeshInstanceData(const CurrentWorkingData& currentData, const Scene::ModelInstance* pModelInstance, const Model::MeshInstance* pMeshInstance, uint32_t drawInstanceID) override;
    virtual void setHitShaderData(RtProgramVars* pRtVars, InstanceData& data);
    virtual void setMissShaderData(RtProgramVars* pRtVars, InstanceData& data);
    virtual void setRayGenShaderData(RtProgramVars* pRtVars, InstanceData& data);
    virtual void setGlobalData(RtProgramVars* pRtVars, InstanceData& data);

    void initializeMeshBufferLocation(const ProgramReflection* pReflection);

    struct MeshBufferLocations
    {
        ParameterBlockReflection::BindLocation indices;
        ParameterBlockReflection::BindLocation normal;
        ParameterBlockReflection::BindLocation bitangent;
        ParameterBlockReflection::BindLocation position;
        ParameterBlockReflection::BindLocation prevPosition;
        ParameterBlockReflection::BindLocation texC;
        ParameterBlockReflection::BindLocation lightmapUVs;
    };
    MeshBufferLocations mMeshBufferLocations;
};

