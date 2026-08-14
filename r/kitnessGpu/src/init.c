#include <R.h>
#include <R_ext/Rdynload.h>
#include <Rinternals.h>

extern SEXP kitness_cuda_roundtrip(SEXP values);
extern SEXP kitness_cuda_roundtrip_with_session(SEXP values, SEXP session);
extern SEXP kitness_cuda_compiled(void);
extern SEXP kitness_cuda_session_create(void);
extern SEXP kitness_cuda_session_destroy(SEXP session);
extern SEXP kitness_cuda_session_is_active(SEXP session);
extern SEXP kitness_metal_compiled(void);
extern SEXP kitness_metal_roundtrip(SEXP values, SEXP metallib_path);

static const R_CallMethodDef call_methods[] = {
    {"kitness_cuda_roundtrip", (DL_FUNC) &kitness_cuda_roundtrip, 1},
    {"kitness_cuda_roundtrip_with_session", (DL_FUNC) &kitness_cuda_roundtrip_with_session, 2},
    {"kitness_cuda_compiled", (DL_FUNC) &kitness_cuda_compiled, 0},
    {"kitness_cuda_session_create", (DL_FUNC) &kitness_cuda_session_create, 0},
    {"kitness_cuda_session_destroy", (DL_FUNC) &kitness_cuda_session_destroy, 1},
    {"kitness_cuda_session_is_active", (DL_FUNC) &kitness_cuda_session_is_active, 1},
    {"kitness_metal_compiled", (DL_FUNC) &kitness_metal_compiled, 0},
    {"kitness_metal_roundtrip", (DL_FUNC) &kitness_metal_roundtrip, 2},
    {NULL, NULL, 0}
};

void R_init_kitnessGpu(DllInfo *dll)
{
    R_registerRoutines(dll, NULL, call_methods, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
