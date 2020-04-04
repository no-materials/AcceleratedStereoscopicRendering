/*
 * Authors: Niko Wissmann
 */

#pragma once
#include "Falcor.h"
#include "FalcorExperimental.h"
#include "../DeferredRenderer.h"

using namespace Falcor;

class DebugOutput : public RenderPass, inherit_shared_from_this<RenderPass, DebugOutput>
{
public:
    using SharedPtr = std::shared_ptr<DebugOutput>;
    std::string getDesc(void) override { return "Shows selected GBuffer output texture."; }

    static SharedPtr create(const Dictionary& params = {});

    RenderPassReflection reflect() const override;
    void execute(RenderContext* pContext, const RenderData* pRenderData) override;
    void renderUI(Gui* pGui, const char* uiGroup) override;
    Dictionary getScriptingDictionary() const override;
    void onResize(uint32_t width, uint32_t height) override;
    void setScene(const std::shared_ptr<Scene>& pScene) override;

    DeferredRenderer* root;

private:
    DebugOutput() : RenderPass("DebugOutput") {}

    void initialize(const Dictionary& dict);

    // GUI
    enum : uint32_t
    {
        WorldSpacePosition = 1,
        WorldSpaceNormal,
        DiffuseMat,
        SpecularMat,
        LinearRoughness,
        DepthBuffer
    } mDebugMode = WorldSpacePosition;

    Scene::SharedPtr          mpScene;

    Fbo::SharedPtr              mpFbo;
    GraphicsVars::SharedPtr     mpVars;
    GraphicsProgram::SharedPtr  mpProgram;
    GraphicsState::SharedPtr    mpState;
    FullScreenPass::UniquePtr   mpPass;

    bool mIsInitialized = false;
};

