# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Exact Python reference oracle for Weyl-Heisenberg magic, Clifford stabilizers,
and projective-geometry Singer qudit codes (Pillars I-IV)."""

from .oracle import (
    run_full_audit,
    verify_pillar1,
    verify_pillar2,
    verify_pillar3,
    verify_pillar4,
)

__all__ = [
    "run_full_audit",
    "verify_pillar1",
    "verify_pillar2",
    "verify_pillar3",
    "verify_pillar4",
]
__version__ = "1.0.0"
