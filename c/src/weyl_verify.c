/* SPDX-License-Identifier: Apache-2.0
 * Copyright (c) 2026 Alexander Stephen Donahue
 *
 * Strict ISO C11 verifier for Pillars I-IV of `weyl-magic-stabilizer-frontier`.
 * Links directly against bare-metal NASM x86-64 assembly (`asm/gf7_singer_kernel.asm`)
 * when compiled with `-DUSE_NASM_KERNEL`, and differential-tests every assembly kernel
 * call against pure C11 across 10,000 deterministic test vectors plus exhaustive
 * Q(5,2) (1,827 orbits) and Q(7,2) (1,546,218 orbits) distance certification!
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#ifdef USE_NASM_KERNEL
extern void gf_sub_mul_asm(uint8_t *dst, const uint8_t *src, size_t len, uint8_t factor, uint8_t p);
extern uint32_t gf_dot_mod_asm(const uint8_t *a, const uint8_t *b, size_t len, uint8_t p);
#endif

static void gf_sub_mul_c(uint8_t *dst, const uint8_t *src, size_t len, uint8_t factor, uint8_t p) {
    if (factor == 0U || len == 0U) return;
    for (size_t i = 0; i < len; ++i) {
        uint32_t prod = ((uint32_t)factor * (uint32_t)src[i]) % (uint32_t)p;
        uint32_t val = (uint32_t)dst[i] + (uint32_t)p - prod;
        if (val >= (uint32_t)p) val -= (uint32_t)p;
        dst[i] = (uint8_t)val;
    }
}

static uint32_t gf_dot_mod_c(const uint8_t *a, const uint8_t *b, size_t len, uint8_t p) {
    uint32_t acc = 0U;
    for (size_t i = 0; i < len; ++i) {
        acc += (uint32_t)a[i] * (uint32_t)b[i];
    }
    return acc % (uint32_t)p;
}

static uint8_t mod_inv_u8(uint8_t a, uint8_t p) {
    uint32_t res = 1U;
    uint32_t base = (uint32_t)a;
    uint32_t exp = (uint32_t)p - 2U;
    while (exp > 0U) {
        if ((exp & 1U) != 0U) res = (res * base) % (uint32_t)p;
        base = (base * base) % (uint32_t)p;
        exp >>= 1U;
    }
    return (uint8_t)res;
}

/* Differential test of NASM x86-64 assembly vs pure C11 over 10,000 deterministic vectors */
static bool verify_nasm_differential(void) {
#ifdef USE_NASM_KERNEL
    uint64_t rng = 0x20261126CAFEBABEULL;
    const uint8_t primes[4] = { 3U, 5U, 7U, 11U };
    for (int trial = 0; trial < 10000; ++trial) {
        rng = rng * 6364136223846793005ULL + 1442695040888963407ULL;
        uint8_t p = primes[rng & 3U];
        size_t len = (size_t)((rng >> 8U) % 64U) + 1U;
        uint8_t factor = (uint8_t)(((rng >> 16U) % (uint64_t)p));
        uint8_t a1[64], a2[64], b[64];
        for (size_t i = 0; i < len; ++i) {
            rng = rng * 6364136223846793005ULL + 1442695040888963407ULL;
            a1[i] = (uint8_t)((rng >> 24U) % (uint64_t)p);
            a2[i] = a1[i];
            b[i] = (uint8_t)((rng >> 32U) % (uint64_t)p);
        }
        uint32_t dc = gf_dot_mod_c(a1, b, len, p);
        uint32_t da = gf_dot_mod_asm(a1, b, len, p);
        if (dc != da) return false;
        gf_sub_mul_c(a1, b, len, factor, p);
        gf_sub_mul_asm(a2, b, len, factor, p);
        if (memcmp(a1, a2, len) != 0) return false;
    }
#endif
    return true;
}

/* GF(p^3) arithmetic */
typedef struct { uint32_t v[3]; } GFp3;

static GFp3 gfp3_mul(uint32_t p, const uint32_t c[3], GFp3 u, GFp3 v) {
    uint32_t r[5] = {0, 0, 0, 0, 0};
    for (int i = 0; i < 3; ++i)
        for (int j = 0; j < 3; ++j)
            r[i + j] = (r[i + j] + u.v[i] * v.v[j]) % p;
    for (int deg = 4; deg >= 3; --deg) {
        uint32_t coef = r[deg];
        if (coef != 0U) {
            for (int k = 0; k < 3; ++k)
                r[deg - 3 + k] = (r[deg - 3 + k] + p * p - (coef * c[k]) % p) % p;
            r[deg] = 0U;
        }
    }
    GFp3 out = {{r[0], r[1], r[2]}};
    return out;
}

static GFp3 gfp3_pow(uint32_t p, const uint32_t c[3], GFp3 base, uint32_t exp) {
    GFp3 acc = {{1U, 0U, 0U}};
    while (exp > 0U) {
        if ((exp & 1U) != 0U) acc = gfp3_mul(p, c, acc, base);
        base = gfp3_mul(p, c, base, base);
        exp >>= 1U;
    }
    return acc;
}

/* Q(p, 2) Singer code structure & fast ASM-accelerated column echelon basis */
typedef struct {
    uint8_t p;
    size_t n;
    size_t rank;
    uint8_t cols_b[133][32];
    uint8_t cols_ma[133][32];
    uint8_t inv_tbl[16];
    bool line_witness_ok;
} SingerCodeC;

typedef struct {
    size_t dim;
    uint8_t vecs[16][32];
    uint8_t pivs[16];
} ColBasisC;

static bool col_basis_insert(ColBasisC *b, const uint8_t *col, size_t rank, uint8_t p, const uint8_t inv_tbl[16]) {
    uint8_t v[32];
    memcpy(v, col, rank);
    for (size_t i = 0; i < b->dim; ++i) {
        uint8_t f = v[b->pivs[i]];
        if (f != 0U) {
#ifdef USE_NASM_KERNEL
            gf_sub_mul_asm(v, b->vecs[i], rank, f, p);
#else
            gf_sub_mul_c(v, b->vecs[i], rank, f, p);
#endif
        }
    }
    size_t pr = rank;
    for (size_t r = 0; r < rank; ++r) {
        if (v[r] != 0U) { pr = r; break; }
    }
    if (pr == rank) return false;
    uint8_t inv = inv_tbl[v[pr]];
    for (size_t r = 0; r < rank; ++r) {
        v[r] = (uint8_t)(((uint32_t)v[r] * (uint32_t)inv) % (uint32_t)p);
    }
    memcpy(b->vecs[b->dim], v, rank);
    b->pivs[b->dim] = (uint8_t)pr;
    b->dim += 1U;
    return true;
}

static bool build_singer_c(uint8_t p, const uint32_t c[3], SingerCodeC *out) {
    if (p < 3U || p >= 16U) return false;
    memset(out, 0, sizeof(*out));
    out->p = p;
    size_t n = (size_t)p * (size_t)p + (size_t)p + 1U;
    out->n = n;
    for (uint8_t a = 1U; a < p; ++a) out->inv_tbl[a] = mod_inv_u8(a, p);

    uint8_t tau_h[133], tau_q[133], b0[133];
    GFp3 cur = {{1U, 0U, 0U}};
    GFp3 gen = {{0U, 1U, 0U}};
    size_t wt_h = 0;
    for (size_t i = 0; i < n; ++i) {
        GFp3 t2 = gfp3_pow(p, c, cur, p);
        GFp3 t3 = gfp3_pow(p, c, cur, (uint32_t)p * (uint32_t)p);
        uint32_t tr = (cur.v[0] + t2.v[0] + t3.v[0]) % (uint32_t)p;
        tau_h[i] = (tr == 0U) ? 1U : 0U;
        wt_h += tau_h[i];
        cur = gfp3_mul(p, c, cur, gen);
    }
    for (size_t i = 0; i < n; ++i) tau_q[i] = tau_h[(2U * i) % n];
    for (size_t k = 0; k < n; ++k) {
        uint32_t s = 0;
        for (size_t j = 0; j < n; ++j) s += (uint32_t)tau_q[j] * (uint32_t)tau_h[(k + n - j) % n];
        b0[k] = (uint8_t)(s % (uint32_t)p);
    }
    /* Verify line witness using NASM/C dot product */
    bool ok = (wt_h == (size_t)p + 1U);
    uint8_t row_a[133], row_b[133];
    for (size_t i = 0; i < n; ++i) {
        for (size_t j = 0; j < n; ++j) {
            row_a[j] = tau_h[(j + n - i) % n];
            row_b[j] = b0[(j + n - i) % n];
        }
#ifdef USE_NASM_KERNEL
        uint32_t sa = gf_dot_mod_asm(row_a, tau_h, n, p);
        uint32_t sb = gf_dot_mod_asm(row_b, tau_h, n, p);
#else
        uint32_t sa = gf_dot_mod_c(row_a, tau_h, n, p);
        uint32_t sb = gf_dot_mod_c(row_b, tau_h, n, p);
#endif
        if (sa != 1U || sb != 1U) ok = false;
    }
    size_t sec_sum = 0;
    for (size_t k = 0; k < n; ++k) {
        size_t cm = 0, cp = 0;
        for (size_t h = 0; h < n; ++h) {
            if (tau_h[h] != 0U) {
                cm += tau_q[(k + n - h) % n];
                cp += tau_q[(k + h) % n];
            }
        }
        if (cm >= (size_t)p || cp > 2U) ok = false;
        sec_sum += cm * (cm > 0U ? cm - 1U : 0U);
    }
    if (sec_sum != (size_t)p * ((size_t)p + 1U)) ok = false;
    out->line_witness_ok = ok;

    if (n > 60U) {
        out->rank = ((size_t)p * ((size_t)p + 1U)) / 2U + 1U;
        return ok;
    }

    /* Extract exact independent rows of (B | -A) mod p */
    uint8_t mat[60][120];
    uint8_t basis[32][120];
    size_t pivs[32];
    size_t indep_rows[32];
    size_t rk = 0;
    for (size_t i = 0; i < n; ++i) {
        for (size_t j = 0; j < n; ++j) {
            mat[i][j] = b0[(j + n - i) % n];
            uint8_t aij = tau_h[(j + n - i) % n];
            mat[i][n + j] = (aij == 0U) ? 0U : (uint8_t)(p - aij);
        }
        uint8_t row[120];
        memcpy(row, mat[i], 2U * n);
        for (size_t k = 0; k < rk; ++k) {
            uint8_t f = row[pivs[k]];
            if (f != 0U) gf_sub_mul_c(row, basis[k], 2U * n, f, p);
        }
        size_t pc = 2U * n;
        for (size_t j = 0; j < 2U * n; ++j) {
            if (row[j] != 0U) { pc = j; break; }
        }
        if (pc < 2U * n) {
            uint8_t inv = out->inv_tbl[row[pc]];
            for (size_t j = pc; j < 2U * n; ++j) {
                row[j] = (uint8_t)(((uint32_t)row[j] * (uint32_t)inv) % (uint32_t)p);
            }
            memcpy(basis[rk], row, 2U * n);
            pivs[rk] = pc;
            indep_rows[rk] = i;
            rk += 1U;
        }
    }
    out->rank = rk;
    for (size_t r = 0; r < rk; ++r) {
        for (size_t j = 0; j < n; ++j) {
            out->cols_b[j][r] = mat[indep_rows[r]][j];
            out->cols_ma[j][r] = mat[indep_rows[r]][n + j];
        }
    }
    return ok;
}

static bool is_canonical_orbit_c(const size_t *s, size_t w, size_t n, size_t p) {
    size_t frob[3] = { 1U, p % n, (p * p) % n };
    size_t tmp[8];
    for (int fi = 0; fi < 3; ++fi) {
        size_t m = frob[fi];
        for (size_t ai = 0; ai < w; ++ai) {
            size_t anchor = s[ai];
            for (size_t idx = 0; idx < w; ++idx) {
                tmp[idx] = (((s[idx] + n - anchor) % n) * m) % n;
            }
            /* Insertion sort w <= 8 */
            for (size_t i = 1; i < w; ++i) {
                size_t key = tmp[i];
                size_t j = i;
                while (j > 0U && tmp[j - 1U] > key) {
                    tmp[j] = tmp[j - 1U];
                    --j;
                }
                tmp[j] = key;
            }
            for (size_t i = 0; i < w; ++i) {
                if (tmp[i] < s[i]) return false;
                if (tmp[i] > s[i]) break;
            }
        }
    }
    return true;
}

static void dfs_cert_c(size_t depth, size_t w_target, size_t start, size_t cur[8],
                       const ColBasisC *basis, const SingerCodeC *code,
                       size_t max_s1, uint64_t *orbits, uint64_t *deps) {
    size_t n = code->n;
    size_t rem = w_target - depth;
    size_t upper = (depth == 1U && max_s1 < n - rem) ? max_s1 : (n - rem);
    if (depth == w_target - 1U) {
        size_t leaf_upper = (n - cur[1] < upper) ? (n - cur[1]) : upper;
        for (size_t idx = start; idx <= leaf_upper; ++idx) {
            if (idx - cur[depth - 1U] < cur[1]) continue;
            cur[depth] = idx;
            if (!is_canonical_orbit_c(cur, w_target, n, code->p)) continue;
            *orbits += 1ULL;
            ColBasisC b = *basis;
            if (!col_basis_insert(&b, code->cols_b[idx], code->rank, code->p, code->inv_tbl) ||
                !col_basis_insert(&b, code->cols_ma[idx], code->rank, code->p, code->inv_tbl)) {
                *deps += 1ULL;
            }
        }
        return;
    }
    for (size_t idx = start; idx <= upper; ++idx) {
        if (depth >= 2U && idx - cur[depth - 1U] < cur[1]) continue;
        if (depth >= 2U && idx + (rem - 1U) * cur[1] > n - cur[1]) break;
        cur[depth] = idx;
        ColBasisC next_b = *basis;
        if (!col_basis_insert(&next_b, code->cols_b[idx], code->rank, code->p, code->inv_tbl) ||
            !col_basis_insert(&next_b, code->cols_ma[idx], code->rank, code->p, code->inv_tbl)) {
            *deps += 1ULL;
            continue;
        }
        dfs_cert_c(depth + 1U, w_target, idx + 1U, cur, &next_b, code, max_s1, orbits, deps);
    }
}

static void certify_c(const SingerCodeC *code, size_t w_target, uint64_t *orbits, uint64_t *deps) {
    *orbits = 0ULL;
    *deps = 0ULL;
    if (code->rank > 32U || w_target == 0U || w_target > 8U) {
        *deps = 1ULL;
        return;
    }
    ColBasisC base0;
    memset(&base0, 0, sizeof(base0));
    if (!col_basis_insert(&base0, code->cols_b[0], code->rank, code->p, code->inv_tbl) ||
        !col_basis_insert(&base0, code->cols_ma[0], code->rank, code->p, code->inv_tbl)) {
        *deps = 1ULL;
        return;
    }
    size_t cur[8] = {0};
    dfs_cert_c(1U, w_target, 1U, cur, &base0, code, code->n / w_target, orbits, deps);
}

int main(int argc, char **argv) {
    bool run_q7 = true;
    for (int i = 1; i < argc; ++i) {
        if (strcmp(argv[i], "--fast") == 0) run_q7 = false;
    }
    if (!verify_nasm_differential()) {
        fprintf(stderr, "FAIL: NASM differential test mismatch!\n");
        return 1;
    }

    SingerCodeC q3, q5, q7, q11;
    const uint32_t c3[3] = {1U, 0U, 2U};
    const uint32_t c5[3] = {2U, 0U, 1U};
    const uint32_t c7[3] = {2U, 1U, 1U};
    const uint32_t c11[3] = {3U, 0U, 1U};
    bool w_ok = build_singer_c(3U, c3, &q3) && build_singer_c(5U, c5, &q5) &&
                build_singer_c(7U, c7, &q7) && build_singer_c(11U, c11, &q11);
    if (!w_ok) {
        fprintf(stderr, "FAIL: Singer Q(p,2) line witness failed\n");
        return 2;
    }

    uint64_t orb5 = 0, dep5 = 0;
    certify_c(&q5, 5U, &orb5, &dep5);
    uint64_t orb7 = 0, dep7 = 0;
    if (run_q7) certify_c(&q7, 7U, &orb7, &dep7);

    if (orb5 != 1827ULL || dep5 != 0ULL) {
        fprintf(stderr, "FAIL: Q(5,2) exhaustive cert mismatch\n");
        return 3;
    }
    if (run_q7 && (orb7 != 1546218ULL || dep7 != 0ULL)) {
        fprintf(stderr, "FAIL: Q(7,2) exhaustive cert mismatch\n");
        return 4;
    }

#ifdef USE_NASM_KERNEL
    const char *kernel = "c11+nasm-x86_64";
    const char *nasm_diff_val = "true";
#else
    const char *kernel = "c11-pure";
    const char *nasm_diff_val = "null";
#endif
    printf("{\"status\":\"PASS\",\"engine\":\"%s\",\"nasm_diff_10k_ok\":%s,"
           "\"qp2_witnesses_ok\":true,\"q5_orbits\":%llu,\"q5_deps\":%llu,"
           "\"q7_orbits\":%llu,\"q7_deps\":%llu}\n",
           kernel, nasm_diff_val, (unsigned long long)orb5, (unsigned long long)dep5,
           (unsigned long long)orb7, (unsigned long long)dep7);
    return 0;
}
