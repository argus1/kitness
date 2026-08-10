#include <R.h>
#include <Rinternals.h>

SEXP kitness_cuda_compiled(void)
{
    return Rf_ScalarLogical(FALSE);
}

SEXP kitness_cuda_roundtrip(SEXP values)
{
    (void) values;
    Rf_error("CUDA native bridge unavailable: install with nvcc on PATH");
    return R_NilValue;
}
