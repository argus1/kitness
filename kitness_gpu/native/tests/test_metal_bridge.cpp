#include "../include/kitness_metal.h"

#include <cmath>
#include <cstdio>
#include <cstring>

static int test_rejects_empty_workload() {
    float value = 1.0F;
    char error_message[256] = {};

    const int status = kitness_metal_vector_add(
        &value,
        &value,
        &value,
        0,
        "unused.metallib",
        error_message,
        sizeof(error_message));

    if (status != KITNESS_METAL_INVALID_ARGUMENT ||
        std::strcmp(error_message, "invalid Metal bridge arguments") != 0) {
        std::fprintf(stderr, "empty workload was not rejected\n");
        return 1;
    }

    return 0;
}

int main(int argc, char **argv) {
    if (argc != 2) {
        std::fprintf(stderr, "usage: %s /path/to/kitness.metallib\n", argv[0]);
        return 2;
    }

    if (test_rejects_empty_workload() != 0) {
        return 1;
    }

    const float left[] = {1.5F, -2.0F, 0.25F};
    const float right[] = {2.5F, 0.5F, 4.75F};
    const float expected[] = {4.0F, -1.5F, 5.0F};
    float output[] = {0.0F, 0.0F, 0.0F};
    char error_message[256] = {};

    KitnessMetalSession *session = kitness_metal_session_open(
        argv[1], error_message, sizeof(error_message));
    if (session == nullptr) {
        std::fprintf(stderr, "Metal session open failed: %s\n", error_message);
        return 1;
    }

    const int status = kitness_metal_vector_add_with_session(
        session,
        left,
        right,
        output,
        3,
        error_message,
        sizeof(error_message));

    if (status != KITNESS_METAL_SUCCESS) {
        std::fprintf(stderr, "Metal bridge failed: %s\n", error_message);
        kitness_metal_session_close(session);
        return 1;
    }

    for (int index = 0; index < 3; ++index) {
        if (std::fabs(output[index] - expected[index]) > 0.0001F) {
            std::fprintf(
                stderr,
                "output[%d] was %.4f, expected %.4f\n",
                index,
                output[index],
                expected[index]);
            kitness_metal_session_close(session);
            return 1;
        }
    }

    kitness_metal_session_close(session);
    return 0;
}