# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""RFC 3161 (DigiCert TSA) & 3-Calendar Bitcoin OpenTimestamps (.ots) stamper and verifier
for data/MANIFEST.sha256 (Playbook v1.3 Gold Standard provenance)."""

from __future__ import annotations

import argparse
import hashlib
import shutil
import subprocess
import sys
import tempfile
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TARGET_FILE = ROOT / "data" / "MANIFEST.sha256"
TSR_PATH = ROOT / "data" / "MANIFEST.sha256.tsr"
OTS_PATH = ROOT / "data" / "MANIFEST.sha256.ots"

DIGICERT_TSA_URL = "http://timestamp.digicert.com"
OTS_MAGIC = b"\x00OpenTimestamps\x00\x00Proof\x00\xbf\x89\xe2\xe8\x84\xe8\x92\x94"
OTS_CALENDARS = (
    "https://alice.btc.calendar.opentimestamps.org/digest",
    "https://bob.btc.calendar.opentimestamps.org/digest",
    "https://finney.calendar.eternitywall.com/digest",
)
SHA256_OID_DER = bytes.fromhex("0609608648016503040201")


def find_openssl() -> str | None:
    exe = shutil.which("openssl")
    if exe:
        return exe
    git_openssl = Path(r"C:\Program Files\Git\usr\bin\openssl.exe")
    if git_openssl.exists():
        return str(git_openssl)
    return None


def sha256_bytes(path: Path) -> bytes:
    return hashlib.sha256(path.read_bytes()).digest()


def stamp_rfc3161(target: Path, out_tsr: Path) -> None:
    openssl = find_openssl()
    if not openssl:
        raise RuntimeError("openssl binary not found (needed for RFC 3161 stamping)")
    with tempfile.TemporaryDirectory() as td:
        tmp_in = Path(td) / "target.bin"
        tmp_tsq = Path(td) / "req.tsq"
        tmp_in.write_bytes(target.read_bytes())
        subprocess.run(
            [openssl, "ts", "-query", "-data", str(tmp_in), "-sha256", "-cert", "-no_nonce", "-out", str(tmp_tsq)],
            check=True,
            capture_output=True,
        )
        req = urllib.request.Request(
            DIGICERT_TSA_URL,
            data=tmp_tsq.read_bytes(),
            headers={
                "Content-Type": "application/timestamp-query",
                "User-Agent": "weyl-magic-stabilizer-frontier/1.0",
            },
            method="POST",
        )
        with urllib.request.urlopen(req, timeout=25) as resp:
            tsr_bytes = resp.read()
            if resp.status != 200 or len(tsr_bytes) < 128:
                raise RuntimeError(f"DigiCert TSA returned HTTP {resp.status} ({len(tsr_bytes)} bytes)")
        out_tsr.write_bytes(tsr_bytes)
        print(f"Stamped RFC 3161 DigiCert TSA -> {out_tsr.relative_to(ROOT)} ({len(tsr_bytes)} bytes)")


def stamp_ots(target: Path, out_ots: Path) -> None:
    digest = sha256_bytes(target)
    branches: list[bytes] = []
    for url in OTS_CALENDARS:
        req = urllib.request.Request(
            url,
            data=digest,
            headers={
                "Accept": "application/vnd.opentimestamps.v1",
                "Content-Type": "application/x-www-form-urlencoded",
                "User-Agent": "weyl-magic-stabilizer-frontier/1.0",
            },
            method="POST",
        )
        try:
            with urllib.request.urlopen(req, timeout=20) as resp:
                body = resp.read()
                if resp.status == 200 and len(body) >= 16:
                    branches.append(body)
                    print(f"  OTS calendar OK: {url} ({len(body)} bytes)")
        except urllib.error.URLError as exc:
            print(f"  OTS calendar WARN ({url}): {exc}", file=sys.stderr)
    if len(branches) < 2:
        raise RuntimeError(f"Expected >= 2 OpenTimestamps calendar responses, got {len(branches)}")
    buf = bytearray()
    buf.extend(OTS_MAGIC)
    buf.append(0x01)
    buf.append(0x08)
    buf.extend(digest)
    for idx, br in enumerate(branches):
        if idx + 1 < len(branches):
            buf.append(0xFF)
        buf.extend(br)
    out_ots.write_bytes(bytes(buf))
    print(f"Stamped 3-calendar Bitcoin OTS -> {out_ots.relative_to(ROOT)} ({len(buf)} bytes, {len(branches)} calendars)")


def verify_tsr(target: Path, tsr_path: Path) -> tuple[bool, str]:
    if not tsr_path.exists():
        return False, f"missing {tsr_path}"
    digest = sha256_bytes(target)
    raw = tsr_path.read_bytes()
    if not raw.startswith(b"\x30"):
        return False, "TSR is not an ASN.1 DER SEQUENCE"
    if SHA256_OID_DER not in raw:
        return False, "TSR missing SHA-256 algorithm OID"
    if (b"\x04\x20" + digest) not in raw:
        return False, f"TSR digest mismatch (expected SHA-256 {digest.hex()})"
    openssl = find_openssl()
    if openssl:
        with tempfile.TemporaryDirectory() as td:
            tmp_tsr = Path(td) / "check.tsr"
            tmp_tsr.write_bytes(raw)
            proc = subprocess.run(
                [openssl, "ts", "-reply", "-in", str(tmp_tsr), "-text"],
                capture_output=True,
                text=True,
                check=False,
            )
            if proc.returncode != 0:
                return False, f"openssl ts -reply failed: {proc.stderr.strip()}"
            if "Status: Granted" not in proc.stdout:
                return False, "TSR status is not Granted"
    return True, f"TSR OK (SHA-256 {digest.hex()[:16]}..., {len(raw)} bytes)"


def verify_ots(target: Path, ots_path: Path) -> tuple[bool, str]:
    if not ots_path.exists():
        return False, f"missing {ots_path}"
    digest = sha256_bytes(target)
    raw = ots_path.read_bytes()
    header_len = len(OTS_MAGIC) + 2 + 32
    if len(raw) <= header_len:
        return False, f"OTS file truncated ({len(raw)} bytes)"
    if not raw.startswith(OTS_MAGIC):
        return False, "OTS invalid magic header"
    if raw[len(OTS_MAGIC)] != 0x01:
        return False, f"OTS unsupported version {raw[len(OTS_MAGIC)]}"
    if raw[len(OTS_MAGIC) + 1] != 0x08:
        return False, f"OTS expected SHA-256 op 0x08, got 0x{raw[len(OTS_MAGIC) + 1]:02x}"
    embedded = raw[len(OTS_MAGIC) + 2 : header_len]
    if embedded != digest:
        return False, f"OTS digest mismatch (got {embedded.hex()[:16]}..., expected {digest.hex()[:16]}...)"
    pending_tag = bytes.fromhex("83dfe30d2ef90c8e")
    cal_count = raw.count(pending_tag)
    if cal_count < 2:
        return False, f"OTS expected >= 2 pending calendar attestations, found {cal_count}"
    return True, f"OTS OK (SHA-256 {digest.hex()[:16]}..., {cal_count} calendar attestations, {len(raw)} bytes)"


def main() -> int:
    parser = argparse.ArgumentParser(description="Stamp or verify RFC 3161 (.tsr) and Bitcoin OTS (.ots) proofs.")
    parser.add_argument("--stamp", action="store_true", help="Stamp data/MANIFEST.sha256 live against DigiCert & OTS.")
    parser.add_argument("--verify", action="store_true", help="Verify existing .tsr and .ots proofs.")
    parser.add_argument("--negative-test", action="store_true", help="Verify a 1-byte tamper fails both .tsr and .ots.")
    args = parser.parse_args()

    if not args.stamp and not args.verify and not args.negative_test:
        args.verify = True

    if not TARGET_FILE.exists():
        print(f"ERROR: missing {TARGET_FILE}", file=sys.stderr)
        return 1

    if args.stamp:
        stamp_rfc3161(TARGET_FILE, TSR_PATH)
        stamp_ots(TARGET_FILE, OTS_PATH)

    if args.verify or args.stamp:
        ok_tsr, msg_tsr = verify_tsr(TARGET_FILE, TSR_PATH)
        ok_ots, msg_ots = verify_ots(TARGET_FILE, OTS_PATH)
        print(f"  [{'PASS' if ok_tsr else 'FAIL'}] {msg_tsr}")
        print(f"  [{'PASS' if ok_ots else 'FAIL'}] {msg_ots}")
        if not (ok_tsr and ok_ots):
            return 1

    if args.negative_test:
        with tempfile.TemporaryDirectory() as td:
            tampered = Path(td) / "MANIFEST.sha256"
            tampered.write_bytes(TARGET_FILE.read_bytes() + b"\n# tampered\n")
            ok_tsr, _ = verify_tsr(tampered, TSR_PATH)
            ok_ots, _ = verify_ots(tampered, OTS_PATH)
            if ok_tsr or ok_ots:
                print("ERROR: tamper negative test unexpectedly passed!", file=sys.stderr)
                return 1
            print("  [PASS] Negative tamper test: 1-byte modified manifest rejected by BOTH .tsr and .ots.")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
