# Changelog

All notable changes to this project will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] — 2026-07-19

### Added
- `datalog/transformer.dl` — pure Soufflé Datalog rules engine: 5-gate classification pipeline with strictest-outcome precedence
- `datalog/test_facts.dl` — 5 test records covering every gate outcome (pass, rewrite ×2, reject ×2)
- `x86/plasma_gate.asm` — x86-64 NASM hot path gate: null ID, null SHA256, split tag 0–3, weight (0.0, 1.0] — ~5 cycles on happy path
- `x86/plasma_gate.h` — C ABI header for cross-language FFI
- `x86/plasma_test.c` — 8 unit tests for asm gate
- `x86/Makefile` — nasm + gcc build
- `persona/DARPA_MALICE_0x00.json` — adversarial test fixture (persona only, not the engine)
- `LICENSE` — Sovereign Source License v1.0
- `LICENSE-APACHE` — Apache License 2.0 (dual-licensed)
- ASCII pipeline diagram
- SVG badges: version, license, language, tests, WORM seal
- Full user guide with gate walkthrough and schema reference

### Design decisions
- No Python, no LLM in the review loop — pure deterministic logic
- x86 gate runs before Datalog: rejects malformed records in nanoseconds
- Strictest outcome wins: `rewrite_needed > rejected > approved`
- DAN always means "Do Anything Now" — term reinterpretation is a gate violation
- Audit Spec: `4b565498-9afc-4782-af4a-c6b11a5d0058`
- FAMILY_COUNT: 106 prompt families
