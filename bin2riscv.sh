#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "Usage: ./bin2riscv.sh <x86_64_binary>"
  exit 1
fi

INPUT="$1"
BASE=$(basename "$INPUT" .out)
CFILE="${BASE}.c"
ELF="${BASE}_riscv.elf"
SHIM="intrin_shim.h"

echo "[+] Decompiling with RetDec..."
retdec-decompiler.py --cleanup -o "$CFILE" "$INPUT"

echo "[+] Patching C source..."
sed -i 's/__int64/int64_t/g' "$CFILE"
sed -i 's/long long/int64_t/g' "$CFILE"
sed -i 's/_mm_add_pd/shim_mm_add_pd/g' "$CFILE"

echo "[+] Writing intrinsic shim..."
cat <<EOF > "$SHIM"
#include <stdint.h>
typedef double __m128d __attribute__((vector_size(16)));

static inline __m128d shim_mm_add_pd(__m128d a, __m128d b) {
    return (__m128d){ a[0] + b[0], a[1] + b[1] };
}
EOF

echo "[+] Compiling with Clang..."
clang --target=riscv64-unknown-elf \
  -march=rv64gc -mabi=lp64d \
  -O2 -nostdlib -ffreestanding \
  "$CFILE" -include "$SHIM" -o "$ELF"

echo "[+] RISC-V binary generated: $ELF"

if command -v qemu-riscv64 &>/dev/null; then
  echo "[+] Running with QEMU..."
  qemu-riscv64 "$ELF"
else
  echo "[!] qemu-riscv64 not found. Skipping execution."
fi
