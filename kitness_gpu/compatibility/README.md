# Compatibility Backend Extension Point

This directory is reserved for future compatibility backend adapters.

Sprint 1 provides native Metal detection only. Future work can add adapters here for:

- OpenCL compatibility
- Vulkan compute
- CUDA when NVIDIA hardware and its SDK are available

Adapters must preserve the public `kitness_gpu.select_backend()` and `kitnessGpu::gpu_backend()` interfaces.
