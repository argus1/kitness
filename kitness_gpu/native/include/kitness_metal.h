#ifndef KITNESS_METAL_H
#define KITNESS_METAL_H

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

enum KitnessMetalStatus {
    KITNESS_METAL_SUCCESS = 0,
    KITNESS_METAL_INVALID_ARGUMENT = 1,
    KITNESS_METAL_DEVICE_UNAVAILABLE = 2,
    KITNESS_METAL_LIBRARY_ERROR = 3,
    KITNESS_METAL_EXECUTION_ERROR = 4
};

int kitness_metal_vector_add(
    const float *left,
    const float *right,
    float *output,
    size_t count,
    const char *metallib_path,
    char *error_message,
    size_t error_message_capacity);

#ifdef __cplusplus
}
#endif

#endif