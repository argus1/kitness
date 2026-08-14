# Native Metal bridge

The native bridge exposes a stable C ABI from `include/kitness_metal.h`. Its
implementation is Objective-C++ so callers do not need to import Apple SDK
types or compile Objective-C source.

## Build

```sh
make -C kitness_gpu/native
make -C kitness_gpu/native test
```

The Makefile links `libkitness_metal.dylib` with `Foundation.framework` and
`Metal.framework`. It compiles each MSL source to an `.air` object with
`xcrun metal`, then combines the objects into `kitness.metallib` with
`xcrun metallib`.

## Metallib loading

The caller supplies an absolute or working-directory-relative metallib path to
`kitness_metal_vector_add`. The Objective-C++ bridge converts that path to an
`NSURL` and calls `newLibraryWithURL:error:`. This explicit resource path keeps
the bridge independent of whether a future binding packages the metallib in an
R package, Python wheel, application bundle, or command-line installation.

The build places both native artifacts in `kitness_gpu/native/build/`:

- `libkitness_metal.dylib`
- `kitness.metallib`

Bindings should resolve their installed resource directory and pass the full
path to `kitness.metallib`; they should not depend on the process working
directory.

## Buffer and command-buffer synchronization

The bridge selects `MTLResourceStorageModeShared` on unified-memory devices,
including Apple Silicon, so CPU and GPU access the same allocation without a
separate transfer. On devices without unified memory it uses managed buffers,
marks host-written inputs with `didModifyRange:`, and encodes a blit
`synchronizeResource:` for the output before waiting for completion. Output is
copied only after the command buffer reports a completed status.