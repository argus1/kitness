#include "metal_bridge.h"

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

#include <R.h>
#include <Rinternals.h>

#undef error

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <cstdint>
#include <limits>

namespace {

void set_error(char *message, size_t capacity, const char *detail) {
    if (message != nullptr && capacity > 0) {
        std::snprintf(message, capacity, "%s", detail != nullptr ? detail : "unknown Metal error");
    }
}

void set_error(char *message, size_t capacity, NSString *detail) {
    set_error(message, capacity, detail.UTF8String);
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
            return 1;
        }

        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
        if (device == nil) {
            set_error(error_message, error_message_capacity, "no Metal device is available");
            return 2;
        }

        NSError *error = nil;
        NSURL *library_url = [NSURL fileURLWithPath:@(metallib_path)];
        id<MTLLibrary> library = [device newLibraryWithURL:library_url error:&error];
        if (library == nil) {
            set_error(error_message, error_message_capacity, error.localizedDescription);
            return 3;
        }

        id<MTLFunction> function = [library newFunctionWithName:@"vector_add"];
        id<MTLComputePipelineState> pipeline =
            function == nil ? nil : [device newComputePipelineStateWithFunction:function error:&error];
        if (pipeline == nil) {
            if (function == nil) {
                set_error(error_message, error_message_capacity, "vector_add is missing from the metallib");
            } else {
                set_error(error_message, error_message_capacity, error.localizedDescription);
            }
            return 3;
        }

        const NSUInteger byte_count = count * sizeof(float);
        const MTLResourceOptions storage_options = device.hasUnifiedMemory
            ? MTLResourceStorageModeShared
            : MTLResourceStorageModeManaged;
        id<MTLBuffer> left_buffer = [device newBufferWithBytes:left length:byte_count options:storage_options];
        id<MTLBuffer> right_buffer = [device newBufferWithBytes:right length:byte_count options:storage_options];
        id<MTLBuffer> output_buffer = [device newBufferWithLength:byte_count options:storage_options];
        id<MTLCommandQueue> queue = [device newCommandQueue];
        if (left_buffer == nil || right_buffer == nil || output_buffer == nil || queue == nil) {
            set_error(error_message, error_message_capacity, "Metal resource allocation failed");
            return 4;
        }

        if (storage_options == MTLResourceStorageModeManaged) {
            [left_buffer didModifyRange:NSMakeRange(0, byte_count)];
            [right_buffer didModifyRange:NSMakeRange(0, byte_count)];
        }

        id<MTLCommandBuffer> command_buffer = [queue commandBuffer];
        id<MTLComputeCommandEncoder> encoder = command_buffer == nil ? nil : [command_buffer computeCommandEncoder];
        if (encoder == nil) {
            set_error(error_message, error_message_capacity, "Metal command encoding failed");
            return 4;
        }

        [encoder setComputePipelineState:pipeline];
        [encoder setBuffer:left_buffer offset:0 atIndex:0];
        [encoder setBuffer:right_buffer offset:0 atIndex:1];
        [encoder setBuffer:output_buffer offset:0 atIndex:2];
        const NSUInteger thread_count = static_cast<NSUInteger>(count);
        const NSUInteger group_width = std::min(thread_count, pipeline.maxTotalThreadsPerThreadgroup);
        [encoder dispatchThreads:MTLSizeMake(thread_count, 1, 1)
            threadsPerThreadgroup:MTLSizeMake(group_width, 1, 1)];
        [encoder endEncoding];

        if (storage_options == MTLResourceStorageModeManaged) {
            id<MTLBlitCommandEncoder> blit_encoder = [command_buffer blitCommandEncoder];
            if (blit_encoder == nil) {
                set_error(error_message, error_message_capacity, "Metal synchronization encoding failed");
                return 4;
            }
            [blit_encoder synchronizeResource:output_buffer];
            [blit_encoder endEncoding];
        }

        [command_buffer commit];
        [command_buffer waitUntilCompleted];
        if (command_buffer.status != MTLCommandBufferStatusCompleted) {
            set_error(error_message, error_message_capacity, command_buffer.error.localizedDescription);
            return 4;
        }

        std::memcpy(output, output_buffer.contents, byte_count);
        set_error(error_message, error_message_capacity, "");
        return 0;
    }
}

extern "C" SEXP kitness_metal_compiled(void)
{
    return Rf_ScalarLogical(TRUE);
}

extern "C" SEXP kitness_metal_roundtrip(SEXP values, SEXP metallib_path)
{
    if (TYPEOF(values) != REALSXP || XLENGTH(values) == 0 ||
        TYPEOF(metallib_path) != STRSXP || XLENGTH(metallib_path) != 1 ||
        STRING_ELT(metallib_path, 0) == NA_STRING) {
        Rf_error("Metal round-trip requires a non-empty numeric vector and metallib path");
    }

    R_xlen_t count = XLENGTH(values);
    if ((uint64_t) count > (uint64_t) std::numeric_limits<size_t>::max()) {
        Rf_error("Metal round-trip vector is too large");
    }

    SEXP result = PROTECT(Rf_allocVector(REALSXP, count));
    float *left = (float *) R_alloc((size_t) count, sizeof(float));
    float *right = (float *) R_alloc((size_t) count, sizeof(float));
    float *output = (float *) R_alloc((size_t) count, sizeof(float));
    for (R_xlen_t index = 0; index < count; ++index) {
        left[index] = static_cast<float>(REAL(values)[index]);
        right[index] = 0.0F;
    }

    char error_message[256] = {};
    int status = kitness_metal_vector_add(
        left, right, output, (size_t) count,
        CHAR(STRING_ELT(metallib_path, 0)), error_message, sizeof(error_message));
    if (status != 0) {
        UNPROTECT(1);
        Rf_error("Metal round-trip failed: %s", error_message);
    }
    for (R_xlen_t index = 0; index < count; ++index) {
        REAL(result)[index] = output[index];
    }
    UNPROTECT(1);
    return result;
}