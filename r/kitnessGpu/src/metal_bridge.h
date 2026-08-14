#ifndef KITNESS_GPU_METAL_BRIDGE_H
#define KITNESS_GPU_METAL_BRIDGE_H

#include <stddef.h>

int kitness_metal_vector_add(
    const float *left,
    const float *right,
    float *output,
    size_t count,
    const char *metallib_path,
    char *error_message,
    size_t error_message_capacity);

#endif