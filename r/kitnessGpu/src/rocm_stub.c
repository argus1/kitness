#include <R.h>
#include <Rinternals.h>

SEXP kitness_rocm_compiled(void) { return Rf_ScalarLogical(FALSE); }
SEXP kitness_rocm_session_create(void) {
    Rf_error("ROCm native bridge unavailable: install with hipcc on PATH");
    return R_NilValue;
}
SEXP kitness_rocm_session_destroy(SEXP session) { (void) session; return Rf_ScalarLogical(FALSE); }
SEXP kitness_rocm_session_is_active(SEXP session) { (void) session; return Rf_ScalarLogical(FALSE); }
SEXP kitness_rocm_roundtrip(SEXP values) {
    (void) values;
    Rf_error("ROCm native bridge unavailable: install with hipcc on PATH");
    return R_NilValue;
}
SEXP kitness_rocm_roundtrip_with_session(SEXP values, SEXP session) {
    (void) values;
    (void) session;
    Rf_error("ROCm native bridge unavailable: install with hipcc on PATH");
    return R_NilValue;
}