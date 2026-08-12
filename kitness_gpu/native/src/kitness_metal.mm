#include "../include/kitness_metal.h"

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <limits>

struct KitnessMetalSession {
    id<MTLDevice> device;
    id<MTLCommandQueue> queue;
    id<MTLComputePipelineState> pipeline;
};

namespace {

void set_error(char *message, size_t capacity, const char *detail) {
    if (message != nullptr && capacity > 0) {
        std::snprintf(message, capacity, "%s", detail);
    }
}

void set_error(char *message, size_t capacity, NSString *detail) {
    set_error(message, capacity, detail.UTF8String ?: "unknown Metal error");
}

}  // namespace

KitnessMetalSession *kitness_metal_session_open(
    const char *metallib_path,
    char *error_message,
    size_t error_message_capacity) {
    @autoreleasepool {
        if (metallib_path == nullptr || metallib_path[0] == '\0') {
            set_error(error_message, error_message_capacity, "invalid Metal library path");
            return nullptr;
        }

        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
        if (device == nil) {
            set_error(error_message, error_message_capacity, "no Metal device is available");
            return nullptr;
        }
        id<MTLCommandQueue> queue = [device newCommandQueue];
        if (queue == nil) {
            set_error(error_message, error_message_capacity, "Metal command queue allocation failed");
            return nullptr;
        }

        NSError *error = nil;
        NSURL *library_url = [NSURL fileURLWithPath:@(metallib_path)];
        id<MTLLibrary> library = [device newLibraryWithURL:library_url error:&error];
        if (library == nil) {
            set_error(error_message, error_message_capacity, error.localizedDescription);
            return nullptr;
        }
        id<MTLFunction> function = [library newFunctionWithName:@"vector_add"];
        if (function == nil) {
            set_error(error_message, error_message_capacity, "vector_add is missing from the metallib");
            return nullptr;
        }
        id<MTLComputePipelineState> pipeline =
            [device newComputePipelineStateWithFunction:function error:&error];
        if (pipeline == nil) {
            set_error(error_message, error_message_capacity, error.localizedDescription);
            return nullptr;
        }

        KitnessMetalSession *session = new KitnessMetalSession{device, queue, pipeline};
        if (error_message != nullptr && error_message_capacity > 0) {
            error_message[0] = '\0';
        }
        return session;
    }
}

void kitness_metal_session_close(KitnessMetalSession *session)
{
    delete session;
}

int kitness_metal_vector_add_with_session(
    KitnessMetalSession *session,
    const float *left,
    const float *right,
    float *output,
    size_t count,
    char *error_message,
    size_t error_message_capacity) {
    @autoreleasepool {
        if (session == nullptr || left == nullptr || right == nullptr || output == nullptr ||
            count == 0 || count > std::numeric_limits<NSUInteger>::max() / sizeof(float)) {
            set_error(error_message, error_message_capacity, "invalid Metal bridge arguments");
            return KITNESS_METAL_INVALID_ARGUMENT;
        }

        const NSUInteger byte_count = count * sizeof(float);
        id<MTLBuffer> left_buffer = [session->device newBufferWithBytes:left
                                                                   length:byte_count
                                                                  options:MTLResourceStorageModeShared];
        id<MTLBuffer> right_buffer = [session->device newBufferWithBytes:right
                                                                    length:byte_count
                                                                   options:MTLResourceStorageModeShared];
        id<MTLBuffer> output_buffer = [session->device newBufferWithLength:byte_count
                                                                       options:MTLResourceStorageModeShared];
        if (left_buffer == nil || right_buffer == nil || output_buffer == nil) {
            set_error(error_message, error_message_capacity, "Metal buffer allocation failed");
            return KITNESS_METAL_EXECUTION_ERROR;
        }

        id<MTLCommandBuffer> command_buffer = [session->queue commandBuffer];
        id<MTLComputeCommandEncoder> encoder = [command_buffer computeCommandEncoder];
        if (command_buffer == nil || encoder == nil) {
            set_error(error_message, error_message_capacity, "Metal command encoding failed");
            return KITNESS_METAL_EXECUTION_ERROR;
        }
        [encoder setComputePipelineState:session->pipeline];
        [encoder setBuffer:left_buffer offset:0 atIndex:0];
        [encoder setBuffer:right_buffer offset:0 atIndex:1];
        [encoder setBuffer:output_buffer offset:0 atIndex:2];
        const NSUInteger thread_count = static_cast<NSUInteger>(count);
        const NSUInteger group_width =
            std::min(thread_count, session->pipeline.maxTotalThreadsPerThreadgroup);
        [encoder dispatchThreads:MTLSizeMake(thread_count, 1, 1)
            threadsPerThreadgroup:MTLSizeMake(group_width, 1, 1)];
        [encoder endEncoding];
        [command_buffer commit];
        [command_buffer waitUntilCompleted];
        if (command_buffer.status != MTLCommandBufferStatusCompleted) {
            set_error(error_message, error_message_capacity, command_buffer.error.localizedDescription);
            return KITNESS_METAL_EXECUTION_ERROR;
        }
        std::memcpy(output, output_buffer.contents, byte_count);
        if (error_message != nullptr && error_message_capacity > 0) {
            error_message[0] = '\0';
        }
        return KITNESS_METAL_SUCCESS;
    }
}

int kitness_metal_vector_add(
    const float *left,
    const float *right,
    float *output,
    size_t count,
    const char *metallib_path,
    char *error_message,
    size_t error_message_capacity) {
    @autoreleasepool {
        if (left == nullptr || right == nullptr || output == nullptr ||
            metallib_path == nullptr || metallib_path[0] == '\0' || count == 0 ||
            count > std::numeric_limits<NSUInteger>::max() / sizeof(float)) {
            set_error(error_message, error_message_capacity, "invalid Metal bridge arguments");
            return KITNESS_METAL_INVALID_ARGUMENT;
        }

        if (MTLCreateSystemDefaultDevice() == nil) {
            set_error(error_message, error_message_capacity, "no Metal device is available");
            return KITNESS_METAL_DEVICE_UNAVAILABLE;
        }
        KitnessMetalSession *session =
            kitness_metal_session_open(metallib_path, error_message, error_message_capacity);
        if (session == nullptr) {
            return KITNESS_METAL_LIBRARY_ERROR;
        }
        const int status = kitness_metal_vector_add_with_session(
            session, left, right, output, count, error_message, error_message_capacity);
        kitness_metal_session_close(session);
        return status;
    }
}