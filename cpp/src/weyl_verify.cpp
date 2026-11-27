// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alexander Stephen Donahue
//
// Strict ISO C++20 exact algebraic verifier across all four pillars of
// `weyl-magic-stabilizer-frontier`.

#include <array>
#include <cstdint>
#include <iostream>
#include <vector>

namespace {

struct GaussInt {
    std::int64_t re{0};
    std::int64_t im{0};

    constexpr GaussInt operator+(GaussInt o) const noexcept { return {re + o.re, im + o.im}; }
    constexpr GaussInt operator-(GaussInt o) const noexcept { return {re - o.re, im - o.im}; }
    constexpr GaussInt operator-() const noexcept { return {-re, -im}; }
    constexpr GaussInt operator*(GaussInt o) const noexcept {
        return {re * o.re - im * o.im, re * o.im + im * o.re};
    }
    constexpr GaussInt conj() const noexcept { return {re, -im}; }
    constexpr std::int64_t norm_sq() const noexcept { return re * re + im * im; }
    static constexpr GaussInt pow_i(std::size_t k) noexcept {
        switch (k % 4U) {
            case 0U: return {1, 0};
            case 1U: return {0, 1};
            case 2U: return {-1, 0};
            default: return {0, -1};
        }
    }
};

struct Zeta12 {
    std::int64_t a{0}, b{0}, c{0}, d{0};

    constexpr bool operator==(const Zeta12&) const noexcept = default;
    constexpr Zeta12 operator+(Zeta12 o) const noexcept { return {a + o.a, b + o.b, c + o.c, d + o.d}; }
    constexpr Zeta12 operator*(Zeta12 o) const noexcept {
        GaussInt x0{a, b}, x1{c, d}, y0{o.a, o.b}, y1{o.c, o.d};
        GaussInt p00 = x0 * y0, p11 = x1 * y1, p01 = x0 * y1, p10 = x1 * y0;
        GaussInt r0 = p00 - p11, r1 = (p01 + p10) - p11;
        return {r0.re, r0.im, r1.re, r1.im};
    }
    static constexpr Zeta12 pow_omega(std::size_t k) noexcept {
        switch (k % 3U) {
            case 0U: return {1, 0, 0, 0};
            case 1U: return {0, 0, 1, 0};
            default: return {-1, 0, -1, 0};
        }
    }
};

constexpr std::size_t verify_pcliff3_stabs() noexcept {
    std::array<Zeta12, 3> v{{{0, 0, 0, 0}, {5, 0, 0, 0}, {-3, -4, 0, 0}}};
    std::size_t count = 0;
    for (std::size_t a = 0; a < 3; ++a)
      for (std::size_t b = 0; b < 3; ++b)
        for (std::size_t c = 0; c < 3; ++c)
          for (std::size_t d = 0; d < 3; ++d) {
              if ((a * d + 2 * b * c) % 3 != 1) continue;
              std::array<Zeta12, 3> mv{};
              for (std::size_t y = 0; y < 3; ++y) {
                  Zeta12 s{};
                  for (std::size_t x = 0; x < 3; ++x) {
                      Zeta12 ent = (b == 0)
                          ? ((y == (a * x) % 3) ? Zeta12::pow_omega(2 * c * a * x * x) : Zeta12{})
                          : Zeta12::pow_omega(2 * b * (d * y * y + x * y + a * x * x));
                      s = s + ent * v[x];
                  }
                  mv[y] = s;
              }
              for (std::size_t p = 0; p < 3; ++p)
                for (std::size_t q = 0; q < 3; ++q) {
                    std::array<Zeta12, 3> w{};
                    for (std::size_t y = 0; y < 3; ++y) {
                        std::size_t x = (y + 3 - p) % 3;
                        w[y] = Zeta12::pow_omega(q * x) * mv[x];
                    }
                    if (v[0] * w[1] == v[1] * w[0] &&
                        v[0] * w[2] == v[2] * w[0] &&
                        v[1] * w[2] == v[2] * w[1]) {
                        ++count;
                    }
                }
          }
    return count;
}

constexpr std::int64_t verify_hoggar_s4() noexcept {
    constexpr std::array<GaussInt, 8> vh{{
        {1, 1}, {0, 0}, {-1, 0}, {1, 0}, {0, -1}, {-1, 0}, {0, 0}, {0, 0}
    }};
    std::int64_t s4 = 0;
    for (std::size_t a = 0; a < 8; ++a)
      for (std::size_t b = 0; b < 8; ++b) {
          GaussInt ov{};
          for (std::size_t x = 0; x < 8; ++x) {
              GaussInt term = vh[x].conj() * vh[x ^ a];
              std::size_t bits = x & b;
              std::size_t par = ((bits & 1U) + ((bits >> 1U) & 1U) + ((bits >> 2U) & 1U)) & 1U;
              ov = ov + (par == 0U ? term : -term);
          }
          std::int64_t n2 = ov.norm_sq();
          s4 += n2 * n2;
      }
    return s4;
}

constexpr std::int64_t verify_v44_s4() noexcept {
    constexpr std::array<GaussInt, 16> v44{{
        {8, 0}, {-1, 2}, {0, -4}, {7, 0},
        {0, -1}, {5, -4}, {-1, 1}, {-5, 5},
        {6, 0}, {7, 1}, {0, -2}, {1, 3},
        {0, 1}, {1, 2}, {1, 1}, {-3, -3}
    }};
    std::int64_t s4 = 0;
    for (std::size_t p1 = 0; p1 < 4; ++p1)
      for (std::size_t p2 = 0; p2 < 4; ++p2)
        for (std::size_t q1 = 0; q1 < 4; ++q1)
          for (std::size_t q2 = 0; q2 < 4; ++q2) {
              GaussInt ov{};
              for (std::size_t x1 = 0; x1 < 4; ++x1)
                for (std::size_t x2 = 0; x2 < 4; ++x2) {
                    std::size_t i1 = 4 * x1 + x2;
                    std::size_t i2 = 4 * ((x1 + p1) % 4) + ((x2 + p2) % 4);
                    ov = ov + v44[i1].conj() * (GaussInt::pow_i(q1 * x1 + q2 * x2) * v44[i2]);
                }
              std::int64_t n2 = ov.norm_sq();
              s4 += n2 * n2;
          }
    return s4;
}

// Compile-time C++20 constexpr proof checks!
static_assert(verify_pcliff3_stabs() == 3U, "Pillar I PCliff_3 stabilizer count must be 3");
static_assert(verify_hoggar_s4() == 2304, "Pillar III Hoggar S4 must be 2304");

} // namespace

int main() {
    const std::size_t p1 = verify_pcliff3_stabs();
    const std::int64_t h_s4 = verify_hoggar_s4();
    const std::int64_t v44_s4 = verify_v44_s4();
    const std::uint64_t norm4 = static_cast<std::uint64_t>(354ULL) * 354ULL * 354ULL * 354ULL;
    const bool v44_beats =
        static_cast<std::uint64_t>(256ULL) * static_cast<std::uint64_t>(v44_s4) <
        static_cast<std::uint64_t>(31ULL) * 16ULL * norm4;

    // Verify Conjecture 24 non-divisibility universally for m = 3..20
    bool conj24_arith = true;
    for (unsigned m = 3; m <= 20; ++m) {
        std::uint64_t mod = (1ULL << m) - 1ULL;
        for (unsigned r = 0; r < m; ++r) {
            std::uint64_t e_minus = 3ULL * (1ULL << r) - 1ULL;
            if (e_minus % mod == 0ULL) conj24_arith = false;
            std::uint64_t e_plus = 3ULL * (1ULL << r) + 1ULL;
            if (m >= 4 && e_plus % mod == 0ULL) conj24_arith = false;
        }
    }
    if (p1 != 3U || h_s4 != 2304 || !v44_beats || !conj24_arith) {
        return 1;
    }
    std::cout << "{\"status\":\"PASS\",\"engine\":\"cpp20-constexpr\","
              << "\"p1_stabs\":" << p1 << ",\"hoggar_s4\":" << h_s4
              << ",\"v44_s4\":" << v44_s4 << ",\"v44_beats_mub\":" << (v44_beats ? "true" : "false")
              << ",\"conj24_arith_m3_to_m20_ok\":" << (conj24_arith ? "true" : "false") << "}\n";
    return 0;
}
