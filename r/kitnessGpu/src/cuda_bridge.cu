#include <R.h>
#include <Rinternals.h>
#include <cuda_runtime.h>

struct CudaTransfer {
    double *device_values;
    cudaStream_t stream;
};

extern "C" SEXP kitness_cuda_compiled(void)
{
    return Rf_ScalarLogical(TRUE);
}

extern "C" SEXP kitness_cuda_roundtrip(SEXP values)
{
    if (TYPEOF(values) != REALSXP) {
        Rf_error("CUDA round trip requires a numeric vector");
    }

    CudaTransfer transfer = {NULL, NULL};
    const R_xlen_t length = XLENGTH(values);
    const size_t bytes = static_cast<size_t>(length) * sizeof(double);
    cudaError_t status = cudaStreamCreate(&transfer.stream);

    if (status == cudaSuccess && bytes > 0) {
        status = cudaMalloc(reinterpret_cast<void **>(&transfer.device_values), bytes);
    }
    if (status == cudaSuccess && bytes > 0) {
        status = cudaMemcpyAsync(
            transfer.device_values,
            REAL(values),
            bytes,
            cudaMemcpyHostToDevice,
            transfer.stream
        );
    }

    SEXP result = PROTECT(Rf_allocVector(REALSXP, length));
    if (status == cudaSuccess && bytes > 0) {
        status = cudaMemcpyAsync(
            REAL(result),
            transfer.device_values,
            bytes,
            cudaMemcpyDeviceToHost,
            transfer.stream
        );
    }
    if (status == cudaSuccess) {
        status = cudaStreamSynchronize(transfer.stream);
    }

    if (transfer.device_values != NULL) {
        cudaFree(transfer.device_values);
    }
    if (transfer.stream != NULL) {
        cudaStreamDestroy(transfer.stream);
    }

    if (status != cudaSuccess) {
        const char *message = cudaGetErrorString(status);
        UNPROTECT(1);
        Rf_error("CUDA round trip failed: %s", message);
    }

    UNPROTECT(1);
    return result;
}
