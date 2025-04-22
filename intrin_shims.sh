#!/bin/bash

OUTFILE="intrin_shim.h"

echo "[+] Generating $OUTFILE ..."

cat <<'EOF' > "$OUTFILE"
#pragma once
#include <stdint.h>

// SIMD型（128bit）をRISC-Vで模倣
typedef double __m128d __attribute__((vector_size(16)));

// Intrinsics shim functions
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
EOF

echo "[✓] Generated shim header with 6 Intrinsics."
