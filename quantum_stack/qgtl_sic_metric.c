/* SPDX-License-Identifier: Apache-2.0
 * Copyright (c) 2026 Alexander Stephen Donahue
 *
 * Compiled QGTL C (`third_party/qgtl/src/quantum_geometric/distributed/differential_geometry.c`)
 * verification of the exact Quantum Geometric Tensor (Fubini-Study metric + Berry curvature)
 * along the Pillar I non-Clifford-stabilizer d=3 WH-SIC circle:
 *   |psi(theta, phi)> = (0, cos(phi), -sin(phi) * exp(i*theta))
 * At the WH-SIC circle phi = pi/4 (including the Pythagorean (3,4,5) witness at theta = atan2(4,3)):
 *   g_{theta,theta} = 1/4,  g_{phi,phi} = 1,  g_{theta,phi} = 0,  |Omega_{theta,phi}| = sin(2*phi) = 1.0
 *   (exact Bloch-sphere monopole Berry curvature on the 2D joint eigenspace span(e_1, e_2)).
 * Also checks an off-circle complex 2-parameter deformation (alpha = pi/6, theta) with |Omega| = sqrt(3)/4!
 */

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include "quantum_geometric/distributed/differential_geometry.h"

int main(void) {
    diffgeo_engine_t *engine = diffgeo_engine_create();
    if (!engine) {
        fprintf(stderr, "FAIL: diffgeo_engine_create() returned NULL\n");
        return 1;
    }

    const double theta = atan2(4.0, 3.0); /* Exact (3,4,5) rational SIC witness */
    const double phi = 0.78539816339744830962; /* pi / 4 */
    const double cp = cos(phi), sp = sin(phi);
    const double ct = cos(theta), st = sin(theta);

    /* |psi(theta, phi)> = (0, cos(phi), -sin(phi)*exp(i*theta)) in C^3 */
    const ComplexDouble state[3] = {
        { 0.0, 0.0 },
        { cp,  0.0 },
        { -sp * ct, -sp * st }
    };
    /* Parameter derivatives: param 0 = d/d(theta), param 1 = d/d(phi) */
    const ComplexDouble derivs[6] = {
        /* d|psi>/dtheta = (0, 0, -i * sin(phi) * exp(i*theta)) = (0, 0, sp*st - i*sp*ct) */
        { 0.0, 0.0 },
        { 0.0, 0.0 },
        { sp * st, -sp * ct },
        /* d|psi>/dphi = (0, -sin(phi), -cos(phi)*exp(i*theta)) */
        { 0.0, 0.0 },
        { -sp, 0.0 },
        { -cp * ct, -cp * st }
    };

    double metric[4] = {0.0, 0.0, 0.0, 0.0};
    double curv[4]   = {0.0, 0.0, 0.0, 0.0};

    bool ok_m = diffgeo_compute_fubini_study(engine, state, 3, derivs, 2, metric);
    bool ok_c = diffgeo_compute_berry_curvature(engine, state, 3, derivs, 2, curv);

    /* Also check 2-parameter complex deformation with non-zero Berry curvature:
     * |psi_alpha(theta, alpha)> = (sin(alpha), cos(alpha)/sqrt(2), -cos(alpha)*exp(i*theta)/sqrt(2))
     * Here d/dtheta has <psi|d_theta psi> = -i/2 * cos^2(alpha), so
     * Omega_{alpha, theta} = -2 Im <d_alpha psi | d_theta psi> = -2 * sin(alpha)*cos(alpha)/2?
     * Check: d_alpha psi = (cos(a), -sin(a)/sqrt2, sin(a)*exp(i*theta)/sqrt2),
     * d_theta psi = (0, 0, -i*cos(a)*exp(i*theta)/sqrt2),
     * <d_alpha psi | d_theta psi> = -i * sin(a)*cos(a)/2 -> Berry curvature F_{0,1} = -sin(2*a)/2! */
    const double alpha = 0.52359877559829887308; /* pi / 6 => sin(2*alpha) = sqrt(3)/2 */
    const double ca = cos(alpha), sa = sin(alpha);
    const double invs2 = 0.70710678118654752440;
    const ComplexDouble state2[3] = {
        { sa, 0.0 },
        { ca * invs2, 0.0 },
        { -ca * invs2 * ct, -ca * invs2 * st }
    };
    const ComplexDouble derivs2[6] = {
        /* param 0: d/dalpha */
        { ca, 0.0 },
        { -sa * invs2, 0.0 },
        { sa * invs2 * ct, sa * invs2 * st },
        /* param 1: d/dtheta */
        { 0.0, 0.0 },
        { 0.0, 0.0 },
        { ca * invs2 * st, -ca * invs2 * ct }
    };
    double metric2[4] = {0.0, 0.0, 0.0, 0.0};
    double curv2[4]   = {0.0, 0.0, 0.0, 0.0};
    bool ok_m2 = diffgeo_compute_fubini_study(engine, state2, 3, derivs2, 2, metric2);
    bool ok_c2 = diffgeo_compute_berry_curvature(engine, state2, 3, derivs2, 2, curv2);

    diffgeo_engine_destroy(engine);

    double err_gtt = fabs(metric[0] - 0.25);
    double err_gpp = fabs(metric[3] - 1.0);
    double err_gtp = fabs(metric[1]);
    /* On |psi(theta, phi)> = (0, cos(phi), -sin(phi)*e^{i*theta}), the 2D subspace span(e1,e2)
     * carries the exact Bloch-sphere Berry curvature |Omega_{theta,phi}| = sin(2*phi) = 1.0 at phi=pi/4! */
    double err_curv_circle = fabs(fabs(curv[1]) - 1.0);
    double expected_berry = sin(2.0 * alpha) * 0.5; /* magnitude sqrt(3)/4 = 0.433012701892219 */
    double err_berry = fabs(fabs(curv2[1]) - expected_berry);

    if (!ok_m || !ok_c || !ok_m2 || !ok_c2 || err_gtt > 1e-12 || err_gpp > 1e-12 || err_gtp > 1e-12 ||
        err_curv_circle > 1e-12 || err_berry > 1e-12) {
        fprintf(stderr, "FAIL: QGTL metric/curvature mismatch: g=(%.15f,%.15f,%.15f,%.15f) F=(%.15f,%.15f)\n",
                metric[0], metric[1], metric[2], metric[3], curv[1], curv2[1]);
        return 2;
    }

    printf("{\"status\":\"PASS\",\"engine\":\"Pinned QGTL C differential_geometry.c\","
           "\"sic_circle_g_tt\":%.15f,\"sic_circle_g_pp\":%.15f,\"sic_circle_g_tp\":%.15e,"
           "\"sic_circle_err_g_tt\":%.3e,\"sic_circle_berry_01\":%.15f,\"sic_circle_berry_err\":%.3e,"
           "\"off_circle_berry_01\":%.15f,\"off_circle_expected_mag\":%.15f,\"off_circle_berry_err\":%.3e}\n",
           metric[0], metric[3], metric[1], err_gtt, curv[1], err_curv_circle, curv2[1], expected_berry, err_berry);
    return 0;
}
