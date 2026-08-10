#include <metal_stdlib>

using namespace metal;

kernel void vector_add(
    device const float *left [[buffer(0)]],
    device const float *right [[buffer(1)]],
    device float *output [[buffer(2)]],
    uint index [[thread_position_in_grid]]) {
    output[index] = left[index] + right[index];
}