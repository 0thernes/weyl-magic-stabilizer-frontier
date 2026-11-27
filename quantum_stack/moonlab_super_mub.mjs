// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alexander Stephen Donahue
//
// Pinned Moonlab WASM gate-level + projective-measurement verification of Pillar III:
//   1. Prepares the 2-qubit MUB-optimal magic state CS|++> (M_2 = ln(16/7)) via native
//      Moonlab {H, Rz, CNOT} gates and computes all 16 Pauli expectations via basis rotation.
//   2. Loads the exact 3-qubit Hoggar Super-MUB fiducial (M_2 = ln(9/2) > ln(64/15)) into
//      Moonlab's statebuffer, verifies all 64 Pauli expectations (|<psi|P|psi>|^2 = 1/9
//      for all 63 non-identity Paulis) via native {H, S^dag, CNOT} basis rotations, and
//      executes 4,096 seeded classical-mixer projective measurement shots.
//   NOTE: QRNG stream is a deterministic classical SplitMix64 + xoshiro256** software mixer;
//   NO hardware quantum entropy is claimed.

import { createRequire } from 'node:module';
import { execFileSync } from 'node:child_process';
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { createHash } from 'node:crypto';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const require = createRequire(import.meta.url);
const M = await require(path.join(root, 'third_party/moonlab/moonlab.js'))({
  print: () => {},
  printErr: () => {},
});

const seed = Number(process.argv[2] ?? 20261126);
if (!Number.isInteger(seed) || seed < 0) {
  throw new Error(`Invalid non-negative integer seed: ${process.argv[2]}`);
}
const qrngBin = path.join(root, 'build', process.platform === 'win32' ? 'qrng_mixer.exe' : 'qrng_mixer');
const qrngBytes = Buffer.from(execFileSync(qrngBin, [String(seed), '65536'], { maxBuffer: 512000 }).toString(), 'hex');
let cursor = 0;
let gateCount = 0;
function u32() {
  const r = qrngBytes.readUInt32LE(cursor);
  cursor += 4;
  return r;
}
function unit() {
  return (u32() >>> 8) / 16777216;
}
function assert(cond, msg) {
  if (!cond) throw new Error(msg);
}

function initState(nQubits) {
  const p = M._malloc(256);
  M.HEAPU8.fill(0, p, p + 256);
  assert(M._quantum_state_init(p, nQubits) === 0, 'moonlab init failed');
  return p;
}
function freeState(p) {
  M._quantum_state_free(p);
  M._free(p);
}
function cloneState(p) {
  const q = M._malloc(256);
  M.HEAPU8.fill(0, q, q + 256);
  assert(M._quantum_state_clone(q, p) === 0, 'moonlab clone failed');
  return q;
}
function gate(name, ...args) {
  M[name](...args);
  gateCount++;
}

// Rotate Pauli word (over {I,X,Y,Z}^n) to Z on target qubit t
function rotatePauli(p, word) {
  let t = -1;
  for (let q = 0; q < word.length; q++) {
    if (word[q] === 'I') continue;
    if (t < 0) t = q;
    if (word[q] === 'Y') gate('_gate_s_dagger', p, q);
    if (word[q] === 'X' || word[q] === 'Y') gate('_gate_hadamard', p, q);
  }
  for (let q = 0; q < word.length; q++) {
    if (q !== t && word[q] !== 'I') gate('_gate_cnot', p, q, t);
  }
  return t;
}

function pauliExpectation(p, word) {
  if (/^I+$/.test(word)) return 1.0;
  const q = cloneState(p);
  const t = rotatePauli(q, word);
  const e = M._measurement_expectation_z(q, t);
  freeState(q);
  return e;
}

function allPauliWords(n) {
  const chars = ['I', 'X', 'Y', 'Z'];
  let words = [''];
  for (let i = 0; i < n; i++) {
    words = words.flatMap((w) => chars.map((c) => w + c));
  }
  return words;
}

function getAmps(p, dim) {
  const b = M.HEAPU32[(p + 8) >> 2] >> 3;
  return Array.from({ length: dim }, (_, i) => [M.HEAPF64[b + 2 * i], M.HEAPF64[b + 2 * i + 1]]);
}

function setAmpsNormalized(p, rawAmps) {
  const norm = Math.sqrt(rawAmps.reduce((s, [r, im]) => s + r * r + im * im, 0));
  const b = M.HEAPU32[(p + 8) >> 2] >> 3;
  for (let i = 0; i < rawAmps.length; i++) {
    M.HEAPF64[b + 2 * i] = rawAmps[i][0] / norm;
    M.HEAPF64[b + 2 * i + 1] = rawAmps[i][1] / norm;
  }
}

// 1. Prepare exact 2-qubit MUB-optimal magic state CS|++> = (1, 1, 1, i)/2 (exact M_2 = ln(16/7))
//    via native Moonlab {H, Rz, CNOT} gates: Controlled-S = T_0 * T_1 * CNOT(0,1) * T^\dag_1 * CNOT(0,1).
const st2 = initState(2);
gate('_gate_hadamard', st2, 0);
gate('_gate_hadamard', st2, 1);
// Controlled-S = T_0 * T_1 * CNOT(0,1) * T^\dag_1 * CNOT(0,1)
gate('_gate_rz', st2, 0, Math.PI / 4);
gate('_gate_rz', st2, 1, Math.PI / 4);
gate('_gate_cnot', st2, 0, 1);
gate('_gate_rz', st2, 1, -Math.PI / 4);
gate('_gate_cnot', st2, 0, 1);
let s4_2q = 0;
for (const w of allPauliWords(2)) {
  const e = pauliExpectation(st2, w);
  s4_2q += e ** 4;
}
const m2_2q = -Math.log(s4_2q / 4.0);
freeState(st2);

// 2. 3-qubit Hoggar Super-MUB state vHoggar = (1+i, 0, -1, 1, -i, -1, 0, 0) / sqrt(6)
//    Load into Moonlab 3-qubit state, verify ALL 64 Pauli expectations via native Moonlab gate rotations!
const st3 = initState(3);
setAmpsNormalized(st3, [
  [1, 1],
  [0, 0],
  [-1, 0],
  [1, 0],
  [0, -1],
  [-1, 0],
  [0, 0],
  [0, 0],
]);
let s4_3q = 0;
let maxNonIdErr = 0;
for (const w of allPauliWords(3)) {
  const e = pauliExpectation(st3, w);
  const e2 = e * e;
  s4_3q += e2 * e2;
  if (w !== 'III') {
    maxNonIdErr = Math.max(maxNonIdErr, Math.abs(e2 - 1.0 / 9.0));
  }
}
const m2_3q = -Math.log(s4_3q / 8.0);
const m2_3q_exact = Math.log(9.0 / 2.0);
const m2_3q_mub = Math.log(64.0 / 15.0);

// Execute 4,096 seeded classical-mixer projective measurements on rotated Pauli 'XYZ' to check Born statistics
let plusCount = 0;
const shots = 4096;
for (let s = 0; s < shots; s++) {
  const q = cloneState(st3);
  const t = rotatePauli(q, 'XYZ');
  const bit = M._measurement_single_qubit(q, t, unit());
  if (bit === 0) plusCount++;
  freeState(q);
}
const empExp = (2 * plusCount - shots) / shots;
const exactExp = pauliExpectation(st3, 'XYZ');
freeState(st3);

assert(Math.abs(m2_2q - Math.log(16.0 / 7.0)) < 1e-11, `2q CS|++> M_2 mismatch: ${m2_2q}`);
assert(maxNonIdErr < 1e-12, `3q Hoggar equiangular error too large: ${maxNonIdErr}`);
assert(Math.abs(m2_3q - m2_3q_exact) < 1e-12, `3q Hoggar M_2 mismatch: ${m2_3q}`);
assert(m2_3q > m2_3q_mub + 0.05, '3q Hoggar must strictly beat 3-qubit MUB ceiling');
assert(Math.abs(empExp - exactExp) < 0.09, `Born sampling drift too large: ${empExp} vs ${exactExp}`);

const report = {
  status: 'PASS',
  engine: 'Pinned Tsotchke Moonlab WASM classical simulator',
  wasm_sha256: createHash('sha256')
    .update(readFileSync(path.join(root, 'third_party/moonlab/moonlab.wasm')))
    .digest('hex'),
  two_qubit_cs_plus_m2: m2_2q,
  two_qubit_mub_exact_ln_16_7: Math.log(16.0 / 7.0),
  three_qubit_hoggar_m2: m2_3q,
  three_qubit_hoggar_exact_ln_9_2: m2_3q_exact,
  three_qubit_mub_ceiling_ln_64_15: m2_3q_mub,
  three_qubit_super_mub_margin: m2_3q - m2_3q_mub,
  three_qubit_max_sic_equiangular_err: maxNonIdErr,
  moonlab_gate_calls: gateCount,
  qrng_shots_xyz: shots,
  qrng_empirical_exp_xyz: empExp,
  moonlab_exact_exp_xyz: exactExp,
  qrng_classification: 'Seeded classical xoshiro256**/SplitMix64 software mixer; no quantum hardware entropy claimed',
  qrng_seed: seed,
  qrng_sha256: createHash('sha256').update(qrngBytes).digest('hex'),
};

mkdirSync(path.join(root, 'results'), { recursive: true });
writeFileSync(path.join(root, 'results/moonlab_super_mub.json'), JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify(report));
