/* SPDX-License-Identifier: Apache-2.0
 * Copyright (c) 2026 Alexander Stephen Donahue
 *
 * Seeded classical software QRNG stream (SplitMix64 seeding + xoshiro256** generator).
 * Explicitly classified as a deterministic classical software entropy mixer;
 * NO quantum hardware entropy is claimed.
 */

#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

static uint64_t rotl64(uint64_t x, int k) {
    return (x << k) | (x >> (64 - k));
}

static uint64_t next_u64(uint64_t s[4]) {
    uint64_t result = rotl64(s[1] * 5ULL, 7) * 9ULL;
    uint64_t t = s[1] << 17;
    s[2] ^= s[0];
    s[3] ^= s[1];
    s[1] ^= s[2];
    s[0] ^= s[3];
    s[2] ^= t;
    s[3] = rotl64(s[3], 45);
    return result;
}

int main(int argc, char **argv) {
    if (argc != 3) {
        fprintf(stderr, "Usage: qrng_mixer <seed_u64> <num_bytes>\n");
        return 2;
    }
    char *end = NULL;
    errno = 0;
    unsigned long long seed = strtoull(argv[1], &end, 10);
    if (errno || !*argv[1] || *end || *argv[1] == '-') return 2;
    unsigned long n = strtoul(argv[2], &end, 10);
    if (errno || !*argv[2] || *end || *argv[2] == '-' || n > 16777216UL) return 2;

    /* SplitMix64 seeding of xoshiro256** classical software mixer */
    uint64_t z = (uint64_t)seed ^ 0x5745594C4D414749ULL;
    uint64_t st[4];
    for (int i = 0; i < 4; ++i) {
        z += 0x9E3779B97F4A7C15ULL;
        uint64_t x = z;
        x = (x ^ (x >> 30)) * 0xBF58476D1CE4E5B9ULL;
        x = (x ^ (x >> 27)) * 0x94D049BB133111EBULL;
        st[i] = x ^ (x >> 31);
    }

    unsigned long rem = n;
    while (rem > 0UL) {
        uint64_t w = next_u64(st);
        for (int b = 0; b < 8 && rem > 0UL; ++b, --rem) {
            printf("%02x", (unsigned)((w >> (8 * b)) & 0xFFU));
        }
    }
    return 0;
}
