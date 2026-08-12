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

typedef struct KitnessMetalSession KitnessMetalSession;

KitnessMetalSession *kitness_metal_session_open(
    const char *metallib_path,
    char *error_message,
    size_t error_message_capacity);

void kitness_metal_session_close(KitnessMetalSession *session);

int kitness_metal_vector_add_with_session(
    KitnessMetalSession *session,
    const float *left,
    const float *right,
    float *output,
    size_t count,
    char *error_message,
    size_t error_message_capacity);

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