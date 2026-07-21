#include <stdint.h>

// This translation unit intentionally contains no wrappers.
// The minizip C sources are linked into this dylib and export their original
// symbols (zipOpen64, zipOpenNewFileInZip64, zipWriteInFileInZip, zipCloseFileInZip,
// zipClose, unzOpen64, etc.) so the existing DarkSword dlsym(RTLD_DEFAULT, ...)
// calls can resolve them at runtime.

__attribute__((visibility("default")))
const char *FilzaMinizipShimVersion(void) {
    return "1.0.0";
}
