#include <R.h>
#include <Rinternals.h>

SEXP kitness_metal_compiled(void)
{
    return Rf_ScalarLogical(FALSE);
}

SEXP kitness_metal_roundtrip(SEXP values, SEXP metallib_path)
{
    (void) values;
    (void) metallib_path;
    Rf_error("Metal native bridge unavailable: install on macOS with the Metal toolchain");
    return R_NilValue;
}