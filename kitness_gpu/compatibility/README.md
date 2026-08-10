# Compatibility Backend Extension Point

This directory is reserved for future compatibility backend adapters.

Sprint 1 provides runtime CUDA and Metal detection through the shared backend
selection contract. Future work can add adapters here for:

- OpenCL compatibility
- Vulkan compute
- native CUDA bridge integration when NVIDIA SDK toolchain support is installed

Adapters must preserve the public `kitness_gpu.select_backend()` and `kitnessGpu::gpu_backend()` interfaces.
