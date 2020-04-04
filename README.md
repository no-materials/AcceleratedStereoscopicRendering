# Accelerated Stereo Rendering with Hybrid Reprojection-Based Rasterization and Adaptive Ray-Tracing
Source code for the publication by
Niko Wißmann, Martin Mišiak, Arnulph Fuhrmann, Marc Erich Latoschik
In: Proceedings of 27th IEEE Virtual Reality Conference (VR ’20), Atlanta, USA, to be published.

Prerequisites
------------------------
The projects prerequisites are the same as for the said Falcor version. See [here](https://github.com/MartinMisiak/Falcor/blob/AcceleratedStereoRendering_Falcor_3_2_2/Falcor_3_2.md)
A raytracing enabled GPU is required.

Building The Project
---------------
Currently only tested on 64-bit Windows 10. 
Simply download the project and open Falcor.sln in Visual Studio 2017. Select AcceleratedStereoRendering as your startup project. Use the 64-bit D3D12 builds (Debug or Release) to build.
