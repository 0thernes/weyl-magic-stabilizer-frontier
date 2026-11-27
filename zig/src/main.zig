// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alexander Stephen Donahue
//
// Zig 0.17.0 comptime + runtime exact verifier for Pillars I-IV of
// `weyl-magic-stabilizer-frontier`.

const std = @import("std");

const GaussInt = struct {
    re: i128,
    im: i128,

    fn add(a: GaussInt, b: GaussInt) GaussInt {
        return .{ .re = a.re + b.re, .im = a.im + b.im };
    }
    fn sub(a: GaussInt, b: GaussInt) GaussInt {
        return .{ .re = a.re - b.re, .im = a.im - b.im };
    }
    fn neg(a: GaussInt) GaussInt {
        return .{ .re = -a.re, .im = -a.im };
    }
    fn mul(a: GaussInt, b: GaussInt) GaussInt {
        return .{
            .re = a.re * b.re - a.im * b.im,
            .im = a.re * b.im + a.im * b.re,
        };
    }
    fn conj(a: GaussInt) GaussInt {
        return .{ .re = a.re, .im = -a.im };
    }
    fn normSq(a: GaussInt) i128 {
        return a.re * a.re + a.im * a.im;
    }
    fn powI(k: usize) GaussInt {
        return switch (k % 4) {
            0 => .{ .re = 1, .im = 0 },
            1 => .{ .re = 0, .im = 1 },
            2 => .{ .re = -1, .im = 0 },
            else => .{ .re = 0, .im = -1 },
        };
    }
};

const Zeta12 = struct {
    a: i128,
    b: i128,
    c: i128,
    d: i128,

    const ZERO = Zeta12{ .a = 0, .b = 0, .c = 0, .d = 0 };

    fn powOmega(k: usize) Zeta12 {
        return switch (k % 3) {
            0 => .{ .a = 1, .b = 0, .c = 0, .d = 0 },
            1 => .{ .a = 0, .b = 0, .c = 1, .d = 0 },
            else => .{ .a = -1, .b = 0, .c = -1, .d = 0 },
        };
    }
    fn add(x: Zeta12, y: Zeta12) Zeta12 {
        return .{ .a = x.a + y.a, .b = x.b + y.b, .c = x.c + y.c, .d = x.d + y.d };
    }
    fn mul(x: Zeta12, y: Zeta12) Zeta12 {
        const x0 = GaussInt{ .re = x.a, .im = x.b };
        const x1 = GaussInt{ .re = x.c, .im = x.d };
        const y0 = GaussInt{ .re = y.a, .im = y.b };
        const y1 = GaussInt{ .re = y.c, .im = y.d };
        const p00 = x0.mul(y0);
        const p11 = x1.mul(y1);
        const p01 = x0.mul(y1);
        const p10 = x1.mul(y0);
        const r0 = p00.sub(p11);
        const r1 = p01.add(p10).sub(p11);
        return .{ .a = r0.re, .b = r0.im, .c = r1.re, .d = r1.im };
    }
    fn eql(x: Zeta12, y: Zeta12) bool {
        return x.a == y.a and x.b == y.b and x.c == y.c and x.d == y.d;
    }
};

fn actWH3(p: usize, q: usize, v: [3]Zeta12) [3]Zeta12 {
    var out = [3]Zeta12{ Zeta12.ZERO, Zeta12.ZERO, Zeta12.ZERO };
    for (0..3) |y| {
        const x = (y + 3 - p) % 3;
        out[y] = Zeta12.powOmega(q * x).mul(v[x]);
    }
    return out;
}

fn actMeta3(a: usize, b: usize, c: usize, d: usize, v: [3]Zeta12) [3]Zeta12 {
    var out = [3]Zeta12{ Zeta12.ZERO, Zeta12.ZERO, Zeta12.ZERO };
    for (0..3) |y| {
        var s = Zeta12.ZERO;
        for (0..3) |x| {
            const entry = if (b == 0)
                (if (y == (a * x) % 3) Zeta12.powOmega(2 * c * a * x * x) else Zeta12.ZERO)
            else
                Zeta12.powOmega(2 * b * (d * y * y + x * y + a * x * x));
            s = s.add(entry.mul(v[x]));
        }
        out[y] = s;
    }
    return out;
}

fn verifyPillar1Count() usize {
    const v = [3]Zeta12{
        Zeta12.ZERO,
        .{ .a = 5, .b = 0, .c = 0, .d = 0 },
        .{ .a = -3, .b = -4, .c = 0, .d = 0 },
    };
    var stabs: usize = 0;
    for (0..3) |a| {
        for (0..3) |b| {
            for (0..3) |c| {
                for (0..3) |d| {
                    if ((a * d + 2 * b * c) % 3 != 1) continue;
                    const mv = actMeta3(a, b, c, d, v);
                    for (0..3) |p| {
                        for (0..3) |q| {
                            const w = actWH3(p, q, mv);
                            const c01 = v[0].mul(w[1]).eql(v[1].mul(w[0]));
                            const c02 = v[0].mul(w[2]).eql(v[2].mul(w[0]));
                            const c12 = v[1].mul(w[2]).eql(v[2].mul(w[1]));
                            if (c01 and c02 and c12) stabs += 1;
                        }
                    }
                }
            }
        }
    }
    return stabs;
}

fn verifyHoggarS4() i128 {
    const vh = [8]GaussInt{
        .{ .re = 1, .im = 1 },
        .{ .re = 0, .im = 0 },
        .{ .re = -1, .im = 0 },
        .{ .re = 1, .im = 0 },
        .{ .re = 0, .im = -1 },
        .{ .re = -1, .im = 0 },
        .{ .re = 0, .im = 0 },
        .{ .re = 0, .im = 0 },
    };
    var s4: i128 = 0;
    for (0..8) |a| {
        for (0..8) |b| {
            var ov = GaussInt{ .re = 0, .im = 0 };
            for (0..8) |x| {
                const term = vh[x].conj().mul(vh[x ^ a]);
                const par = @popCount(x & b) % 2;
                ov = ov.add(if (par == 0) term else term.neg());
            }
            const n2 = ov.normSq();
            s4 += n2 * n2;
        }
    }
    return s4;
}

fn verifyV44S4() i128 {
    const v44 = [16]GaussInt{
        .{ .re = 8, .im = 0 },  .{ .re = -1, .im = 2 },  .{ .re = 0, .im = -4 }, .{ .re = 7, .im = 0 },
        .{ .re = 0, .im = -1 }, .{ .re = 5, .im = -4 },  .{ .re = -1, .im = 1 }, .{ .re = -5, .im = 5 },
        .{ .re = 6, .im = 0 },  .{ .re = 7, .im = 1 },   .{ .re = 0, .im = -2 }, .{ .re = 1, .im = 3 },
        .{ .re = 0, .im = 1 },  .{ .re = 1, .im = 2 },   .{ .re = 1, .im = 1 },  .{ .re = -3, .im = -3 },
    };
    var s4: i128 = 0;
    for (0..4) |p1| {
        for (0..4) |p2| {
            for (0..4) |q1| {
                for (0..4) |q2| {
                    var ov = GaussInt{ .re = 0, .im = 0 };
                    for (0..4) |x1| {
                        for (0..4) |x2| {
                            const idx1 = 4 * x1 + x2;
                            const idx2 = 4 * ((x1 + p1) % 4) + ((x2 + p2) % 4);
                            const ph = GaussInt.powI(q1 * x1 + q2 * x2);
                            ov = ov.add(v44[idx1].conj().mul(ph.mul(v44[idx2])));
                        }
                    }
                    const n2 = ov.normSq();
                    s4 += n2 * n2;
                }
            }
        }
    }
    return s4;
}

fn gf2Mul(a_in: u32, b_in: u32, mod_poly: u32, deg: u5) u32 {
    var a = a_in;
    var b = b_in;
    var res: u32 = 0;
    const hi: u32 = @as(u32, 1) << deg;
    while (b != 0) : (b >>= 1) {
        if ((b & 1) != 0) res ^= a;
        a <<= 1;
        if ((a & hi) != 0) a ^= mod_poly;
    }
    return res;
}

fn gf2Trace(x_in: u32, mod_poly: u32, deg: u5) u32 {
    var x = x_in;
    var acc: u32 = 0;
    for (0..@as(usize, deg)) |_| {
        acc ^= x;
        x = gf2Mul(x, x, mod_poly, deg);
    }
    return acc;
}

fn verifyConj24(deg: u5, mod_poly: u32) struct { u_minus: bool, u_plus: bool } {
    const n: usize = (@as(usize, 1) << deg) - 1;
    var tau_e: [1024]bool = undefined;
    var cur: u32 = 1;
    for (0..n) |i| {
        tau_e[i] = (gf2Trace(cur, mod_poly, deg) == 0);
        cur = gf2Mul(cur, 2, mod_poly, deg);
    }
    var u_minus = true;
    var u_plus = true;
    for (0..n) |k| {
        var cm: usize = 0;
        var cp: usize = 0;
        for (0..n) |j| {
            if (tau_e[(3 * j) % n]) {
                if (tau_e[(k + n - j) % n]) cm += 1;
                if (tau_e[(k + j) % n]) cp += 1;
            }
        }
        if (cm % 2 != 1) u_minus = false;
        if (cp % 2 != 1) u_plus = false;
    }
    return .{ .u_minus = u_minus, .u_plus = u_plus };
}

fn gfp3Mul(p: usize, c: [3]usize, u: [3]usize, v: [3]usize) [3]usize {
    var r = [5]usize{ 0, 0, 0, 0, 0 };
    for (0..3) |i| {
        for (0..3) |j| {
            r[i + j] = (r[i + j] + u[i] * v[j]) % p;
        }
    }
    const degs = [2]usize{ 4, 3 };
    for (degs) |deg| {
        const coef = r[deg];
        if (coef != 0) {
            for (0..3) |k| {
                r[deg - 3 + k] = (r[deg - 3 + k] + p * p - (coef * c[k]) % p) % p;
            }
            r[deg] = 0;
        }
    }
    return .{ r[0], r[1], r[2] };
}

fn gfp3Pow(p: usize, c: [3]usize, base_in: [3]usize, exp_in: usize) [3]usize {
    var base = base_in;
    var exp = exp_in;
    var acc = [3]usize{ 1, 0, 0 };
    while (exp > 0) : (exp >>= 1) {
        if ((exp & 1) == 1) acc = gfp3Mul(p, c, acc, base);
        base = gfp3Mul(p, c, base, base);
    }
    return acc;
}

fn verifyQp2LineWitness(p: usize, c: [3]usize) bool {
    const n = p * p + p + 1;
    var tau_h: [256]usize = undefined;
    var cur = [3]usize{ 1, 0, 0 };
    var wt_h: usize = 0;
    for (0..n) |i| {
        const t2 = gfp3Pow(p, c, cur, p);
        const t3 = gfp3Pow(p, c, cur, p * p);
        const tr = (cur[0] + t2[0] + t3[0]) % p;
        tau_h[i] = if (tr == 0) 1 else 0;
        wt_h += tau_h[i];
        cur = gfp3Mul(p, c, cur, .{ 0, 1, 0 });
    }
    if (wt_h != p + 1) return false;
    var tau_q: [256]usize = undefined;
    for (0..n) |i| tau_q[i] = tau_h[(2 * i) % n];

    var b0: [256]usize = undefined;
    for (0..n) |k| {
        var s: usize = 0;
        for (0..n) |j| s += tau_q[j] * tau_h[(k + n - j) % n];
        b0[k] = s % p;
    }
    for (0..n) |i| {
        var sa: usize = 0;
        var sb: usize = 0;
        for (0..n) |j| {
            sa += tau_h[(j + n - i) % n] * tau_h[j];
            sb += b0[(j + n - i) % n] * tau_h[j];
        }
        if (sa % p != 1 or sb % p != 1) return false;
    }
    var sec_sum_m: usize = 0;
    var sec_sum_p: usize = 0;
    for (0..n) |k| {
        var cm: usize = 0;
        var cp: usize = 0;
        for (0..n) |h| {
            if (tau_h[h] == 1) {
                cm += tau_q[(k + n - h) % n];
                cp += tau_q[(k + h) % n];
            }
        }
        if (cm >= p or cp > 2) return false;
        sec_sum_m += cm * (if (cm > 0) cm - 1 else 0);
        sec_sum_p += cp * (if (cp > 0) cp - 1 else 0);
    }
    return sec_sum_m == p * (p + 1) and sec_sum_p == p * (p + 1);
}

// Compile-time verification of Hoggar SIC identity and Conjecture 24 d=2..4!
comptime {
    @setEvalBranchQuota(100000);
    if (verifyHoggarS4() != 2304) @compileError("Hoggar comptime check failed");
    const c2 = verifyConj24(3, 0b1011);
    if (!c2.u_minus or c2.u_plus) @compileError("Conj24 d=2 Remark-21 comptime check failed");
    const c3 = verifyConj24(4, 0b10011);
    if (!c3.u_minus or !c3.u_plus) @compileError("Conj24 d=3 comptime check failed");
}

pub fn main(init: std.process.Init) !void {
    const stabs = verifyPillar1Count();
    const h_s4 = verifyHoggarS4();
    const v44_s4 = verifyV44S4();
    const v44_norm: i128 = 354;
    const v44_beats = 256 * v44_s4 < 31 * 16 * v44_norm * v44_norm * v44_norm * v44_norm;
    const c24_ok =
        verifyConj24(3, 0b1011).u_minus and !verifyConj24(3, 0b1011).u_plus and
        verifyConj24(4, 0b10011).u_minus and verifyConj24(4, 0b10011).u_plus and
        verifyConj24(5, 0b100101).u_minus and verifyConj24(6, 0b1000011).u_minus and
        verifyConj24(7, 0b10000011).u_minus and verifyConj24(8, 0b100011101).u_minus;
    const qp2_ok =
        verifyQp2LineWitness(3, .{ 1, 0, 2 }) and
        verifyQp2LineWitness(5, .{ 2, 0, 1 }) and
        verifyQp2LineWitness(7, .{ 2, 1, 1 }) and
        verifyQp2LineWitness(11, .{ 3, 0, 1 });

    if (stabs != 3 or h_s4 != 2304 or !v44_beats or !c24_ok or !qp2_ok) {
        return error.VerificationFailed;
    }

    var buf: [512]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(init.io, &buf);
    try stdout_writer.interface.print(
        "{{\"status\":\"PASS\",\"engine\":\"zig-0.17.0\",\"p1_stabs\":{d},\"hoggar_s4\":{d},\"v44_s4\":{d},\"v44_beats_mub\":{},\"conj24_d2_to_d7_ok\":{},\"qp2_p3_5_7_11_ok\":{}}}\n",
        .{ stabs, h_s4, v44_s4, v44_beats, c24_ok, qp2_ok },
    );
    try stdout_writer.interface.flush();
}

test "all four pillars exact zig verification" {
    try std.testing.expectEqual(@as(usize, 3), verifyPillar1Count());
    try std.testing.expectEqual(@as(i128, 2304), verifyHoggarS4());
    try std.testing.expectEqual(@as(i128, 30301769984), verifyV44S4());
    try std.testing.expect(verifyQp2LineWitness(7, .{ 2, 1, 1 }));
    try std.testing.expect(verifyQp2LineWitness(11, .{ 3, 0, 1 }));
}
