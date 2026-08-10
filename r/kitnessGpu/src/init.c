#include <R.h>
#include <R_ext/Rdynload.h>
#include <Rinternals.h>

extern SEXP kitness_cuda_roundtrip(SEXP values);
extern SEXP kitness_cuda_compiled(void);

static const R_CallMethodDef call_methods[] = {
    {"kitness_cuda_roundtrip", (DL_FUNC) &kitness_cuda_roundtrip, 1},
    {"kitness_cuda_compiled", (DL_FUNC) &kitness_cuda_compiled, 0},
    {NULL, NULL, 0}
};

void R_init_kitnessGpu(DllInfo *dll)
{
    R_registerRoutines(dll, NULL, call_methods, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
