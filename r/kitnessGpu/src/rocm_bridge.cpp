#include <R.h>
#include <Rinternals.h>
#include <hip/hip_runtime.h>

struct RocmTransfer {
    double *device_values;
    hipStream_t stream;
};

struct RocmSession {
    hipStream_t stream;
};

static const char *kRocmSessionTag = "kitness_rocm_session";

static RocmSession *get_session(SEXP session)
{
    if (TYPEOF(session) != EXTPTRSXP) {
        Rf_error("ROCm session must be an external pointer");
    }
    if (R_ExternalPtrTag(session) != Rf_install(kRocmSessionTag)) {
        Rf_error("Invalid ROCm session handle");
    }

    RocmSession *session_ptr = reinterpret_cast<RocmSession *>(R_ExternalPtrAddr(session));
    if (session_ptr == NULL) {
        Rf_error("ROCm session is closed");
    }
    return session_ptr;
}

static SEXP rocm_roundtrip_with_stream(SEXP values, hipStream_t stream)
{
    if (TYPEOF(values) != REALSXP) {
        Rf_error("ROCm round trip requires a numeric vector");
    }

    RocmTransfer transfer = {NULL, stream};
    const R_xlen_t length = XLENGTH(values);
    const size_t bytes = static_cast<size_t>(length) * sizeof(double);
    hipError_t status = hipSuccess;

    if (bytes > 0) {
        status = hipMalloc(reinterpret_cast<void **>(&transfer.device_values), bytes);
    }
    if (status == hipSuccess && bytes > 0) {
        status = hipMemcpyAsync(transfer.device_values, REAL(values), bytes,
                                hipMemcpyHostToDevice, transfer.stream);
    }

    SEXP result = PROTECT(Rf_allocVector(REALSXP, length));
    if (status == hipSuccess && bytes > 0) {
        status = hipMemcpyAsync(REAL(result), transfer.device_values, bytes,
                                hipMemcpyDeviceToHost, transfer.stream);
    }
    if (status == hipSuccess) {
        status = hipStreamSynchronize(transfer.stream);
    }

    if (transfer.device_values != NULL) {
        hipFree(transfer.device_values);
    }
    if (status != hipSuccess) {
        const char *message = hipGetErrorString(status);
        UNPROTECT(1);
        Rf_error("ROCm round trip failed: %s", message);
    }

    UNPROTECT(1);
    return result;
}

extern "C" SEXP kitness_rocm_compiled(void)
{
    return Rf_ScalarLogical(TRUE);
}

extern "C" SEXP kitness_rocm_roundtrip(SEXP values)
{
    hipStream_t stream = NULL;
    hipError_t status = hipStreamCreate(&stream);
    if (status != hipSuccess) {
        Rf_error("ROCm session create failed: %s", hipGetErrorString(status));
    }
    SEXP result = rocm_roundtrip_with_stream(values, stream);
    hipStreamDestroy(stream);
    return result;
}

extern "C" SEXP kitness_rocm_roundtrip_with_session(SEXP values, SEXP session)
{
    return rocm_roundtrip_with_stream(values, get_session(session)->stream);
}

extern "C" SEXP kitness_rocm_session_create(void)
{
    RocmSession *session = new RocmSession();
    hipError_t status = hipStreamCreate(&session->stream);
    if (status != hipSuccess) {
        delete session;
        Rf_error("ROCm session create failed: %s", hipGetErrorString(status));
    }
    SEXP handle = PROTECT(R_MakeExternalPtr(session, Rf_install(kRocmSessionTag), R_NilValue));
    UNPROTECT(1);
    return handle;
}

extern "C" SEXP kitness_rocm_session_destroy(SEXP session)
{
    if (TYPEOF(session) != EXTPTRSXP) {
        Rf_error("ROCm session must be an external pointer");
    }
    RocmSession *session_ptr = reinterpret_cast<RocmSession *>(R_ExternalPtrAddr(session));
    if (session_ptr == NULL) {
        return Rf_ScalarLogical(FALSE);
    }
    hipStreamDestroy(session_ptr->stream);
    delete session_ptr;
    R_ClearExternalPtr(session);
    return Rf_ScalarLogical(TRUE);
}

extern "C" SEXP kitness_rocm_session_is_active(SEXP session)
{
    return Rf_ScalarLogical(TYPEOF(session) == EXTPTRSXP && R_ExternalPtrAddr(session) != NULL);
}