#include <R.h>
#include <Rinternals.h>

SEXP kitness_cuda_compiled(void)
{
    return Rf_ScalarLogical(FALSE);
}

SEXP kitness_cuda_session_create(void)
{
    Rf_error("CUDA native bridge unavailable: install with nvcc on PATH");
    return R_NilValue;
}

SEXP kitness_cuda_session_destroy(SEXP session)
{
    (void) session;
    return Rf_ScalarLogical(FALSE);
}

SEXP kitness_cuda_session_is_active(SEXP session)
{
    (void) session;
    return Rf_ScalarLogical(FALSE);
}

SEXP kitness_cuda_roundtrip(SEXP values)
{
    (void) values;
    Rf_error("CUDA native bridge unavailable: install with nvcc on PATH");
    return R_NilValue;
}

SEXP kitness_cuda_roundtrip_with_session(SEXP values, SEXP session)
{
    (void) values;
    (void) session;
    Rf_error("CUDA native bridge unavailable: install with nvcc on PATH");
    return R_NilValue;
}
