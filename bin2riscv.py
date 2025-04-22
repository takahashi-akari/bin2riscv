# bin2riscv.py : MVP CLI tool to convert x86_64 binary to RISC-V ELF

import subprocess
import os
import sys
import shutil

INPUT_BINARY = sys.argv[1] if len(sys.argv) > 1 else None
if not INPUT_BINARY or not os.path.exists(INPUT_BINARY):
    print("Usage: python bin2riscv.py <x86_64_binary>")
    sys.exit(1)

BASE_NAME = os.path.splitext(os.path.basename(INPUT_BINARY))[0]
C_FILE = f"{BASE_NAME}.c"
RISC_ELF = f"{BASE_NAME}_riscv.elf"
SHIM_FILE = "intrin_shim.h"

# 1. Decompile with RetDec
print("[+] Decompiling with RetDec...")
subprocess.run(["retdec-decompiler.py", "--cleanup", "-o", C_FILE, INPUT_BINARY], check=True)

# 2. Patch the C file for portability
print("[+] Patching C source for portability...")
with open(C_FILE, "r") as f:
    code = f.read()

code = code.replace("__int64", "int64_t").replace("long long", "int64_t")
code = code.replace("_mm_add_pd", "shim_mm_add_pd")
code = code.replace("_mm_sub_pd", "shim_mm_sub_pd")
code = code.replace("_mm_mul_pd", "shim_mm_mul_pd")
code = code.replace("_mm_div_pd", "shim_mm_div_pd")
code = code.replace("_mm_set1_pd", "shim_mm_set1_pd")
code = code.replace("_mm_cmpeq_pd", "shim_mm_cmpeq_pd")

with open(C_FILE, "w") as f:
    f.write(code)

# 3. Generate shim header
print("[+] Generating intrinsics shim...")
with open(SHIM_FILE, "w") as f:
    f.write('''
#pragma once
#include <stdint.h>
typedef double __m128d __attribute__((vector_size(16)));

static inline __m128d shim_mm_add_pd(__m128d a, __m128d b) {
    return (__m128d){ a[0] + b[0], a[1] + b[1] };
}

static inline __m128d shim_mm_sub_pd(__m128d a, __m128d b) {
    return (__m128d){ a[0] - b[0], a[1] - b[1] };
}

static inline __m128d shim_mm_mul_pd(__m128d a, __m128d b) {
    return (__m128d){ a[0] * b[0], a[1] * b[1] };
}

static inline __m128d shim_mm_div_pd(__m128d a, __m128d b) {
    return (__m128d){ a[0] / b[0], a[1] / b[1] };
}

static inline __m128d shim_mm_set1_pd(double x) {
    return (__m128d){ x, x };
}

static inline __m128d shim_mm_cmpeq_pd(__m128d a, __m128d b) {
    return (__m128d){
        (a[0] == b[0]) ? -1.0 : 0.0,
        (a[1] == b[1]) ? -1.0 : 0.0
    };
}
''')

# 4. Compile to RISC-V ELF
print("[+] Compiling to RISC-V ELF with Clang...")
subprocess.run([
    "clang", "--target=riscv64-unknown-elf",
    "-march=rv64gc", "-mabi=lp64d",
    "-O2", "-nostdlib", "-ffreestanding",
    C_FILE, "-include", SHIM_FILE,
    "-o", RISC_ELF
], check=True)

# 5. (Optional) Run with QEMU
if shutil.which("qemu-riscv64"):
    print("[+] Running on QEMU (optional)...")
    subprocess.run(["qemu-riscv64", RISC_ELF])
else:
    print("[!] qemu-riscv64 not found. Skipping execution.")

print(f"[✓] Done! RISC-V ELF: {RISC_ELF}")
