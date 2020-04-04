/*
 * Authors: Niko Wissmann
 */

#pragma once
#include "Falcor.h"
#include "FalcorExperimental.h"

using namespace Falcor;

// Main lighting pass after the G-buffer
class Lighting : public RenderPass, inherit_shared_from_this<RenderPass, Lighting>
{
public:

    using SharedPtr = std::shared_ptr<Lighting>;
    std::string getDesc(void) override { return "Deferred Light Pass"; }

    static SharedPtr create(const Dictionary& params = {});

    RenderPassReflection reflect() const override;
    void execute(RenderContext* pContext, const RenderData* pRenderData) override;
    void renderUI(Gui* pGui, const char* uiGroup) override;
    Dictionary getScriptingDictionary() const override;
    void onResize(uint32_t width, uint32_t height) override;
    void setScene(const std::shared_ptr<Scene>& pScene) override;

    static size_t sLightArrayOffset;
    static size_t sLightCountOffset;
    static size_t sCameraDataOffset;

    Camera::SharedPtr mpLightCamera;
    Sampler::SharedPtr          mpLinearComparisonSampler;
    float                       mBias = 0.01f;
    int32_t                     mPCFKernelSize = 4;

private:
    Lighting() : RenderPass("Lighting") {}

    void initialize(const Dictionary& dict);
    void updateVariableOffsets(const ProgramReflection* pReflector);
    void setPerFrameData(const GraphicsVars* pVars);
    void setDefine(std::string pName, bool flag);

    Scene::SharedPtr          mpScene;
    SkyBox::SharedPtr         mpSkyBox;

    Fbo::SharedPtr              mpFbo;
    GraphicsVars::SharedPtr     mpVars;
    GraphicsState::SharedPtr    mpState;
    FullScreenPass::UniquePtr   mpPass;

    bool mIsInitialized = false;
    bool mbShowBRDF = false;
    bool mbRenderSkybox = false;
};

