/*
 * Authors: Niko Wissmann
 */

#pragma once
#include "Falcor.h"
#include "../DeferredRenderer.h"

using namespace Falcor;

// Very basic and simple shadow class that provies one shadow map for the primary light source
class SimpleShadowPass : public RenderPass, inherit_shared_from_this<RenderPass, SimpleShadowPass>
{
public:
    using SharedPtr = std::shared_ptr<SimpleShadowPass>;

    static SharedPtr create(const Dictionary& dict = {});

    RenderPassReflection reflect() const override;
    void execute(RenderContext* pContext, const RenderData* pRenderData) override;
    void renderUI(Gui* pGui, const char* uiGroup) override;
    Dictionary getScriptingDictionary() const override;
    void onResize(uint32_t width, uint32_t height) override;
    void setScene(const std::shared_ptr<Scene>& pScene) override;
    std::string getDesc(void) override { return "Shadow Pass"; }

    DeferredRenderer* mpMainRenderObject;
    Camera::SharedPtr                       mpLightCamera;

private:
    SimpleShadowPass();

    void createShadowMatrix(const DirectionalLight* pLight, glm::mat4& shadowVP);
    void compareLightDirections();

    GraphicsState::SharedPtr                mpGraphicsState;
    Scene::SharedPtr                        mpScene;
    SceneRenderer::SharedPtr                mpSceneRenderer;
    Fbo::SharedPtr                          mpFbo;

    glm::mat4                               mShadowMat;
    float                                   mAABRadiusPadding = 0;
    int32_t                                 mShadowMapSize = 2048;
    bool                                    mbEnableShadows = true;

    DirectionalLight::SharedPtr             mpDirectionalLight;
    glm::vec3                               mLastLightDirW;
    bool                                    mbShadowMatDirty = false;

    // Rasterization resources
    struct
    {
        GraphicsState::SharedPtr pState;
        GraphicsProgram::SharedPtr pProgram;
        GraphicsVars::SharedPtr pVars;
    } mRaster;
};

