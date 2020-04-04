/*
 * Authors: Niko Wissmann
 */

#pragma once
#include "Falcor.h"
#include "FalcorExperimental.h"
#include "StereoCameraController.h"

// Override all base texture with rainbow test texture to visualize Mip-Levels
#define _USERAINBOW 0

using namespace Falcor;

class DeferredRenderer : public Renderer
{
public:

    // defines which render target is rendered next (left/right <=> 0/1)
    static uint32_t gStereoTarget;

    void onLoad(SampleCallbacks* pSample, RenderContext* pRenderContext) override;
    void onFrameRender(SampleCallbacks* pSample, RenderContext* pRenderContext, const Fbo::SharedPtr& pTargetFbo) override;
    void onShutdown(SampleCallbacks* pSample) override;
    void onResizeSwapChain(SampleCallbacks* pSample, uint32_t width, uint32_t height) override;
    bool onKeyEvent(SampleCallbacks* pSample, const KeyboardEvent& keyEvent) override;
    bool onMouseEvent(SampleCallbacks* pSample, const MouseEvent& mouseEvent) override;
    void onDataReload(SampleCallbacks* pSample) override;
    void onGuiRender(SampleCallbacks* pSample, Gui* pGui) override;

    void onClickResize();
    void resetFixedTime();

    float getZ0();

    bool sidebyside = true;

private:

    static const std::string skStartupScene;

    enum : uint32_t
    {
        RenderToScreen = 1,
        RenderToHMD
    } mRenderMode = RenderToScreen;

    enum : uint32_t
    {
        Both = 1,
        Left,
        Right
    } mOutputImage = Both;

    SampleCallbacks* mpSample;
    RenderGraph::SharedPtr mpGraph;
    StereoCameraController mCamController;
    HmdCameraController mHMDCamController;
    bool mbAltPressed = false;
    Fbo::SharedPtr mpHMDFbo;
    VRSystem* mpVrSystem;
    Texture::SharedPtr mpRainbowTex;

    uint32_t stereoCamIndex = 0;

    bool mUseFXAA = false;
    std::string mLeftOutput = "ToneMapping_Left.dst";
    std::string mRightOutput = "ToneMapping_Right.dst";
    bool mVRrunning = false;
    bool mUseReprojection = true ;
    bool mCropOutput = false;
    bool mUseCameraPath = false;

    void loadScene(SampleCallbacks* pSample, const std::string& filename);
    void updateValues();
    void initVR(Fbo* pTargetFbo);
    void applyCameraPathState();

    // Plain Stereo
    void renderToScreenSimple(SampleCallbacks * pSample, RenderContext * pRenderContext, const Fbo::SharedPtr & pTargetFbo);
    void renderToHMDSimple(SampleCallbacks * pSample, RenderContext * pRenderContext, const Fbo::SharedPtr & pTargetFbo);

    // Reprojection Pass
    void renderToScreenReprojected(SampleCallbacks * pSample, RenderContext * pRenderContext, const Fbo::SharedPtr & pTargetFbo);
    void renderToHMDReprojected(SampleCallbacks * pSample, RenderContext * pRenderContext, const Fbo::SharedPtr & pTargetFbo);

    std::string getSolutionDirectory();

    // Fixed update and helper vars for performance measurement
    void startMeasurement();
    void stopMeasurement();
    bool mUseFixedUpdate = false;
    float mFixedSpeed = 1.0f;
    double mFixedFrameTime = 0.0;
    int32_t mFrameCount = 0;
    bool mFixedRunning = true;
    int32_t mNumCyclesToRun = 5;
    int32_t mNumCycles = 0;
    bool mMeasurementRunning = false;
    int32_t mLightCount = 0;
};

