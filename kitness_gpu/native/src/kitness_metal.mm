#include "../include/kitness_metal.h"

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <limits>

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

        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
        if (device == nil) {
            set_error(error_message, error_message_capacity, "no Metal device is available");
            return KITNESS_METAL_DEVICE_UNAVAILABLE;
        }

        NSError *error = nil;
        NSURL *library_url = [NSURL fileURLWithPath:@(metallib_path)];
        id<MTLLibrary> library = [device newLibraryWithURL:library_url error:&error];
        if (library == nil) {
            set_error(error_message, error_message_capacity, error.localizedDescription);
            return KITNESS_METAL_LIBRARY_ERROR;
        }

        id<MTLFunction> function = [library newFunctionWithName:@"vector_add"];
        if (function == nil) {
            set_error(error_message, error_message_capacity, "vector_add is missing from the metallib");
            return KITNESS_METAL_LIBRARY_ERROR;
        }

        id<MTLComputePipelineState> pipeline =
            [device newComputePipelineStateWithFunction:function error:&error];
        if (pipeline == nil) {
            set_error(error_message, error_message_capacity, error.localizedDescription);
            return KITNESS_METAL_EXECUTION_ERROR;
        }

        const NSUInteger byte_count = count * sizeof(float);
        id<MTLBuffer> left_buffer = [device newBufferWithBytes:left
                                                       length:byte_count
                                                      options:MTLResourceStorageModeShared];
        id<MTLBuffer> right_buffer = [device newBufferWithBytes:right
                                                        length:byte_count
                                                       options:MTLResourceStorageModeShared];
        id<MTLBuffer> output_buffer = [device newBufferWithLength:byte_count
                                                          options:MTLResourceStorageModeShared];
        id<MTLCommandQueue> queue = [device newCommandQueue];
        if (left_buffer == nil || right_buffer == nil || output_buffer == nil || queue == nil) {
            set_error(error_message, error_message_capacity, "Metal resource allocation failed");
            return KITNESS_METAL_EXECUTION_ERROR;
        }

        id<MTLCommandBuffer> command_buffer = [queue commandBuffer];
        id<MTLComputeCommandEncoder> encoder = [command_buffer computeCommandEncoder];
        if (command_buffer == nil || encoder == nil) {
            set_error(error_message, error_message_capacity, "Metal command encoding failed");
            return KITNESS_METAL_EXECUTION_ERROR;
        }

        [encoder setComputePipelineState:pipeline];
        [encoder setBuffer:left_buffer offset:0 atIndex:0];
        [encoder setBuffer:right_buffer offset:0 atIndex:1];
        [encoder setBuffer:output_buffer offset:0 atIndex:2];

        const NSUInteger thread_count = static_cast<NSUInteger>(count);
        const NSUInteger group_width =
            std::min(thread_count, pipeline.maxTotalThreadsPerThreadgroup);
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