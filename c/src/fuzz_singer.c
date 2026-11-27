/* SPDX-License-Identifier: Apache-2.0
 * Copyright (c) 2026 Alexander Stephen Donahue
 *
 * Differential & memory-safety fuzzer for finite-field Singer elimination kernels
 * (supports both standalone deterministic fuzzing and libFuzzer `-DFUZZ_LIBFUZZER`).
 */

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void gf_sub_mul_ref(uint8_t *dst, const uint8_t *src, size_t len, uint8_t factor, uint8_t p) {
    if (factor == 0U || len == 0U || p < 2U) return;
    for (size_t i = 0; i < len; ++i) {
        uint32_t prod = ((uint32_t)factor * (uint32_t)src[i]) % (uint32_t)p;
        uint32_t val = ((uint32_t)dst[i] + (uint32_t)p - prod) % (uint32_t)p;
        dst[i] = (uint8_t)val;
    }
}

static void gf_sub_mul_fast(uint8_t *dst, const uint8_t *src, size_t len, uint8_t factor, uint8_t p) {
    if (factor == 0U || len == 0U || p < 2U) return;
    for (size_t i = 0; i < len; ++i) {
        uint32_t prod = ((uint32_t)factor * (uint32_t)src[i]) % (uint32_t)p;
        uint32_t val = (uint32_t)dst[i] + (uint32_t)p - prod;
        if (val >= (uint32_t)p) val -= (uint32_t)p;
        dst[i] = (uint8_t)val;
    }
}

int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    static const uint8_t primes[5] = { 2U, 3U, 5U, 7U, 11U };
    if (size < 4U) return 0;
    uint8_t p = primes[data[0] % 5U];
    uint8_t factor = (uint8_t)(data[1] % p);
    size_t len = (size_t)(data[2] % 64U) + 1U;
    uint8_t a1[64], a2[64], b[64];
    for (size_t i = 0; i < len; ++i) {
        uint8_t raw_a = data[(3U + 2U * i) % size];
        uint8_t raw_b = data[(4U + 2U * i) % size];
        a1[i] = (uint8_t)(raw_a % p);
        a2[i] = a1[i];
        b[i] = (uint8_t)(raw_b % p);
    }
    gf_sub_mul_ref(a1, b, len, factor, p);
    gf_sub_mul_fast(a2, b, len, factor, p);
    if (memcmp(a1, a2, len) != 0) abort();
    /* Invertibility check: adding back factor*b restores original mod p */
    uint8_t inv_factor = (factor == 0U) ? 0U : (uint8_t)(p - factor);
    gf_sub_mul_fast(a2, b, len, inv_factor, p);
    for (size_t i = 0; i < len; ++i) {
        uint8_t orig = (uint8_t)(data[(3U + 2U * i) % size] % p);
        if (a2[i] != orig) abort();
    }
    return 0;
}

#ifndef FUZZ_LIBFUZZER
int main(int argc, char **argv) {
    size_t iters = 100000U;
    if (argc >= 2) {
        long parsed = strtol(argv[1], NULL, 10);
        if (parsed > 0) iters = (size_t)parsed;
    }
    uint64_t rng = 0x51A7F00D20261126ULL;
    uint8_t buf[140];
    for (size_t t = 0; t < iters; ++t) {
        for (size_t i = 0; i < sizeof(buf); ++i) {
            rng = rng * 6364136223846793005ULL + 1442695040888963407ULL;
            buf[i] = (uint8_t)(rng >> 56U);
        }
        LLVMFuzzerTestOneInput(buf, sizeof(buf));
    }
    printf("{\"status\":\"PASS\",\"fuzzer\":\"standalone_and_libfuzzer\",\"iterations\":%zu}\n", iters);
    return 0;
}
#endif
