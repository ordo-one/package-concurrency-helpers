#ifndef CONCURRENCY_HELPER_PAUSE_SHIMS_HEADER_INCLUDED
#define CONCURRENCY_HELPER_PAUSE_SHIMS_HEADER_INCLUDED 1

static inline __attribute__((__always_inline__))
void _concurrency_helpers_pause(void)
{
#if defined(__x86_64__) || defined(_M_X64) || defined(i386) || defined(__i386__) || defined(__i386) || defined(_M_IX86)
    // https://gcc.gnu.org/onlinedocs/gcc/x86-Built-in-Functions.html#x86-Built-in-Functions
    __builtin_ia32_pause();
#elif defined(__aarch64__) || defined(_M_ARM64)
    // ARM manual suggests "YIELD" instruction as a "NOP" in spin-loops ...
    // https://developer.arm.com/documentation/dui0473/m/arm-and-thumb-instructions/yield
    //__asm__ __volatile__("yield"::);
    // .. but Rust guys found ISB to be a better alternative:
    //  - https://stackoverflow.com/questions/70810121/why-does-hintspin-loop-use-isb-on-aarch64
    //  - https://github.com/rust-lang/rust/commit/c064b6560b7ce0adeb9bbf5d7dcf12b1acb0c807
    //  - https://developer.arm.com/documentation/ddi0596/2021-06/Base-Instructions/ISB--Instruction-Synchronization-Barrier-
    __asm__ __volatile__("isb"::);
#else
#   error "Unknown CPU architecture"
#endif
}

#endif
