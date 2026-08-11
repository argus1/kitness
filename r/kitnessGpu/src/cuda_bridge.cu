#include <R.h>
#include <Rinternals.h>
#include <cuda_runtime.h>

struct CudaTransfer {
    double *device_values;
    cudaStream_t stream;
};

struct CudaSession {
    cudaStream_t stream;
};

static const char *kCudaSessionTag = "kitness_cuda_session";

static CudaSession *get_session(SEXP session)
{
    if (TYPEOF(session) != EXTPTRSXP) {
        Rf_error("CUDA session must be an external pointer");
    }
    if (R_ExternalPtrTag(session) != Rf_install(kCudaSessionTag)) {
        Rf_error("Invalid CUDA session handle");
    }

    CudaSession *session_ptr = reinterpret_cast<CudaSession *>(R_ExternalPtrAddr(session));
    if (session_ptr == NULL) {
        Rf_error("CUDA session is closed");
    }
    return session_ptr;
}

static SEXP cuda_roundtrip_with_stream(SEXP values, cudaStream_t stream)
{
    if (TYPEOF(values) != REALSXP) {
        Rf_error("CUDA round trip requires a numeric vector");
    }

    CudaTransfer transfer = {NULL, stream};
    const R_xlen_t length = XLENGTH(values);
    const size_t bytes = static_cast<size_t>(length) * sizeof(double);
    cudaError_t status = cudaSuccess;

    if (bytes > 0) {
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

    if (status != cudaSuccess) {
        const char *message = cudaGetErrorString(status);
        UNPROTECT(1);
        Rf_error("CUDA round trip failed: %s", message);
    }

    UNPROTECT(1);
    return result;
}

extern "C" SEXP kitness_cuda_compiled(void)
{
    return Rf_ScalarLogical(TRUE);
}

extern "C" SEXP kitness_cuda_roundtrip(SEXP values)
{
    cudaStream_t stream = NULL;
    cudaError_t status = cudaStreamCreate(&stream);
    if (status != cudaSuccess) {
        Rf_error("CUDA session create failed: %s", cudaGetErrorString(status));
    }

    SEXP result = R_NilValue;
    result = cuda_roundtrip_with_stream(values, stream);
    cudaStreamDestroy(stream);
    return result;
}

extern "C" SEXP kitness_cuda_roundtrip_with_session(SEXP values, SEXP session)
{
    CudaSession *session_ptr = get_session(session);
    return cuda_roundtrip_with_stream(values, session_ptr->stream);
}

extern "C" SEXP kitness_cuda_session_create(void)
{
    CudaSession *session = new CudaSession();
    cudaError_t status = cudaStreamCreate(&session->stream);
    if (status != cudaSuccess) {
        delete session;
        Rf_error("CUDA session create failed: %s", cudaGetErrorString(status));
    }

    SEXP handle = PROTECT(R_MakeExternalPtr(session, Rf_install(kCudaSessionTag), R_NilValue));
    UNPROTECT(1);
    return handle;
}

extern "C" SEXP kitness_cuda_session_destroy(SEXP session)
{
    if (TYPEOF(session) != EXTPTRSXP) {
        Rf_error("CUDA session must be an external pointer");
    }

    CudaSession *session_ptr = reinterpret_cast<CudaSession *>(R_ExternalPtrAddr(session));
    if (session_ptr == NULL) {
        return Rf_ScalarLogical(FALSE);
    }

    cudaStreamDestroy(session_ptr->stream);
    delete session_ptr;
    R_ClearExternalPtr(session);
    return Rf_ScalarLogical(TRUE);
}

extern "C" SEXP kitness_cuda_session_is_active(SEXP session)
{
    if (TYPEOF(session) != EXTPTRSXP) {
        return Rf_ScalarLogical(FALSE);
    }
    return Rf_ScalarLogical(R_ExternalPtrAddr(session) != NULL);
}
