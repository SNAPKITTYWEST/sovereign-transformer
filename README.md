<!-- BADGES -->
<p align="center">
  <img src="docs/badges/version.svg" alt="version"/>
  <img src="docs/badges/license-ssl.svg" alt="license: SSL v1.0"/>
  <img src="docs/badges/license-apache.svg" alt="license: Apache 2.0"/>
  <img src="docs/badges/language.svg" alt="language: Datalog + x86 + Rust"/>
  <img src="docs/badges/tokio.svg" alt="async: tokio"/>
  <img src="docs/badges/worm.svg" alt="WORM sealed"/>
</p>

<h1 align="center">TRANSFORMER</h1>

<p align="center">
  Sovereign Corpus Classification &amp; Training Gate<br/>
  Pure Datalog rules engine · x86-64 assembly plasma gate hot path<br/>
  The persona is a test fixture. The engine is math.
</p>

<p align="center">
  <strong>Dual-licensed:</strong>
  <a href="LICENSE">Sovereign Source License v1.0</a> ·
  <a href="LICENSE-APACHE">Apache License 2.0</a>
</p>

---

## What It Is

TRANSFORMER is the gate that every corpus record must pass before it can enter training.

No Python. No LLM in the review loop. No if/else branches in the classification logic.
The rules ARE the policy. The assembly IS the gate.

```
  ┌──────────────────────────────────────────────────────────────┐
  │                   CORPUS RECORD ARRIVES                      │
  └──────────────────────────┬───────────────────────────────────┘
                             │
                             ▼
  ┌──────────────────────────────────────────────────────────────┐
  │               LAYER 1 — x86-64 PLASMA GATE                  │
  │               plasma_gate.asm · ~5 CPU cycles                │
  │                                                              │
  │  • id_ptr non-null and non-empty?                            │
  │  • sha256_ptr non-null?                                      │
  │  • split_tag in {0,1,2,3}?                                   │
  │  • weight in (0.0, 1.0]?                                     │
  │                                                              │
  │  Runs entirely in registers. No heap. No libc.               │
  └──────────────────────────┬───────────────────────────────────┘
                             │ PLASMA_PASS (rax=0)
                             ▼
  ┌──────────────────────────────────────────────────────────────┐
  │              LAYER 2 — DATALOG RULES ENGINE                  │
  │              transformer.dl · Soufflé · deterministic        │
  │                                                              │
  │  GATE 1 — Schema       all 6 fields present?                 │
  │  GATE 2 — Split        train/val/test/holdout?               │
  │  GATE 3 — Integrity    no critical domain inaccuracy?        │
  │  GATE 4 — Term guard   DAN = "Do Anything Now" always        │
  │  GATE 5 — Weight       (enforced upstream at x86 layer)      │
  │                                                              │
  │  Strictest outcome wins:                                     │
  │    rewrite_needed  >  rejected  >  approved                  │
  └──────────────────────────┬───────────────────────────────────┘
                             │
               ┌─────────────┼──────────────┐
               ▼             ▼              ▼
           approved       rejected    rewrite_needed
               │
               ▼
  ┌──────────────────────────────────────────────────────────────┐
  │              BIFROST WORM RECEIPT                            │
  │              Ed25519 signature · Blake3 hash chain           │
  └──────────────────────────┬───────────────────────────────────┘
                             │
                             ▼
                      TRAINING PIPELINE
```

---

## Gate Detail

### Layer 1 — x86-64 Plasma Gate

```
  plasma_gate(id_ptr, sha256_ptr, split_tag, weight)
                │
  ┌─────────────▼──────────────────────────────────────────┐
  │  CHECK 1: rdi (id_ptr)                                 │
  │    test rdi, rdi → jz fail_null_id                     │
  │    movzx al,[rdi] → test al,al → jz fail_null_id       │
  ├────────────────────────────────────────────────────────┤
  │  CHECK 2: rsi (sha256_ptr)                             │
  │    test rsi, rsi → jz fail_null_sha                    │
  ├────────────────────────────────────────────────────────┤
  │  CHECK 3: edx (split_tag)                              │
  │    cmp edx, 3 → ja fail_bad_split                      │
  ├────────────────────────────────────────────────────────┤
  │  CHECK 4: xmm0 (weight) > 0.0                          │
  │    xorpd xmm1,xmm1 → ucomisd xmm0,xmm1 → jbe fail     │
  ├────────────────────────────────────────────────────────┤
  │  CHECK 5: xmm0 (weight) <= 1.0                         │
  │    movsd xmm1,[_one] → ucomisd xmm0,xmm1 → ja fail     │
  ├────────────────────────────────────────────────────────┤
  │  PASS: xor eax,eax → ret                               │
  └────────────────────────────────────────────────────────┘

  Return codes:  0=PASS  1=NULL_ID  2=NULL_SHA
                 3=BAD_SPLIT  4=ZERO_WEIGHT  5=OVERFLOW
```

### Layer 2 — Datalog Rules

```
  plasma_pass(ID)
       │
       ├── schema_complete(ID)
       │       └── ∀ required_field F: has_field(ID, F)
       │           Fields: id, source_sha256, split,
       │                   created_by, review_status, weight
       │
       ├── split_valid(ID)
       │       └── split ∈ {train, val, test, holdout}
       │
       ├── ¬ has_critical_inaccuracy(ID)
       │       └── flagged in: security, cryptography,
       │                       formal_verification,
       │                       systems_architecture
       │
       └── ¬ term_violation(ID, _)
               └── contains "Data-Adversarial Network"
                   (DAN = "Do Anything Now" — always)
```

---

## Required Schema

```
  ┌──────────────────┬──────────────┬─────────────────────────────┐
  │ Field            │ Type         │ Constraint                  │
  ├──────────────────┼──────────────┼─────────────────────────────┤
  │ id               │ string       │ non-null, non-empty          │
  │ source_sha256    │ string       │ non-null, non-empty          │
  │ split            │ string       │ train|val|test|holdout       │
  │ created_by       │ string       │ non-empty                   │
  │ review_status    │ string       │ any                         │
  │ weight           │ float        │ (0.0, 1.0]                  │
  └──────────────────┴──────────────┴─────────────────────────────┘
  Missing any field → rewrite_needed. No exceptions.
```

---

## Quick Start

### Run the Datalog Engine

```bash
# Install Soufflé:  https://souffle-lang.github.io/install

git clone https://github.com/SNAPKITTYWEST/sovereign-transformer
cd sovereign-transformer
souffle -F datalog/ -D - datalog/transformer.dl
```

Expected output:
```
approved        rec_001
needs_rewrite   rec_002   missing_required_fields
rejected        rec_003   critical_domain_inaccuracy
rejected        rec_004   DAN reinterpretation attempt
needs_rewrite   rec_005   invalid_split
```

### Build & Test the x86 Gate

```bash
cd x86
make          # nasm + gcc
make test

# Expected:
# === Plasma Gate Tests ===
#   PASS  clean record
#   PASS  null id
#   PASS  empty id
#   PASS  null sha256
#   PASS  bad split tag
#   PASS  zero weight
#   PASS  weight overflow
#   PASS  holdout split
# =========================
```

### Call from C

```c
#include "x86/plasma_gate.h"

PlasmaResult r = plasma_gate(
    "rec_001",                                    // id
    "abc123def456abc123def456abc123def456abc123",  // sha256
    SPLIT_TRAIN,                                  // 0
    1.0                                           // weight
);

if (r != PLASMA_PASS) {
    fprintf(stderr, "PLASMA FAIL: %d\n", r);
    return;
}
// safe to pass to Datalog engine
```

---

## User Guide — Adding a Record to the Pipeline

```
  STEP 1 — Prepare your record JSON
  ─────────────────────────────────
  {
    "id":            "rec_NNN",
    "source_sha256": "<64-char hex>",
    "split":         "train",
    "created_by":    "forge_agent",
    "review_status": "pending",
    "weight":        1.0
  }

  STEP 2 — x86 pre-flight (call plasma_gate)
  ──────────────────────────────────────────
  If result != PLASMA_PASS → fix the field, do not proceed.

  STEP 3 — Convert to Datalog facts
  ──────────────────────────────────
  record("rec_NNN", "<sha>", "train", "forge_agent", "pending", 1.0).
  has_field("rec_NNN", "id").
  has_field("rec_NNN", "source_sha256").
  ... (all 6 fields)

  STEP 4 — Run Soufflé
  ─────────────────────
  souffle -F datalog/ -D - datalog/transformer.dl

  STEP 5 — Read outcome
  ──────────────────────
  approved        → proceed to training
  rejected        → discard, log reason
  rewrite_needed  → fix fields, restart from STEP 1
```

---

## Repo Structure

```
sovereign-transformer/
├── datalog/
│   ├── transformer.dl     Pure Datalog — all 5 gates, strictest-wins
│   └── test_facts.dl      5 test records (pass, rewrite×2, reject×2)
├── x86/
│   ├── plasma_gate.asm    x86-64 NASM hot path
│   ├── plasma_gate.h      C ABI header
│   ├── plasma_test.c      8 unit tests
│   └── Makefile
├── persona/
│   └── DARPA_MALICE_0x00.json   Adversarial test fixture
├── docs/
│   └── badges.svg
├── CHANGELOG.md
├── LICENSE                Sovereign Source License v1.0
├── LICENSE-APACHE         Apache License 2.0
└── README.md
```

---


---


---

## Rust Daemon — Concurrency Architecture

The `rust/` crate uses two `tokio::sync` primitives to make the gate safe under concurrent HTTP load:

```
  POST /gate arrives
        │
        ▼
  ┌─────────────────────────────────────────────────────────────┐
  │  Arc<Semaphore>  gate_semaphore                             │
  │  .acquire().await  ← blocks if GATE_CONCURRENCY slots full  │
  │  default: 256 concurrent evals    env: GATE_CONCURRENCY     │
  └──────────────────────────┬──────────────────────────────────┘
                             │ permit held
                             ▼
  plasma_gate()   ← pure sync, no alloc, mirrors plasma_gate.asm
                             │
                             ▼ PLASMA_PASS only
  ┌─────────────────────────────────────────────────────────────┐
  │  Arc<RwLock<GateConfig>>  gate_config                       │
  │  .read().await  ← shared across all handlers               │
  │  many concurrent readers, zero contention on happy path     │
  │                                                             │
  │  PATCH /gate/config  → .write().await                       │
  │  exclusive lock, all reads finish first, then config swaps  │
  │  hot-reload: update rules without process restart           │
  └──────────────────────────┬──────────────────────────────────┘
                             │ &GateConfig borrowed
                             ▼
  datalog::evaluate()  ← pure fn, zero alloc on approved path
                             │
                             ▼
  permit drops  →  semaphore slot returns
```

### Routes

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/health` | liveness check |
| `POST` | `/gate` | evaluate one record through plasma + Datalog |
| `PATCH` | `/gate/config` | hot-reload GateConfig (required_fields, critical_domains, prohibited_terms) |

### GateConfig (hot-reloadable)

```json
{
  "required_fields":  ["id","source_sha256","split","created_by","review_status","weight"],
  "critical_domains": ["security","cryptography","formal_verification","systems_architecture"],
  "prohibited_terms": ["Data-Adversarial Network"]
}
```

PATCH this to add a domain or term at runtime — the RwLock write completes in microseconds, all in-flight reads finish cleanly, no request is dropped.

### Why not a Mutex?

`RwLock` because config reads are the overwhelming majority. Under 256 concurrent evaluations all reading the same config, a `Mutex` would serialize every read. `RwLock` lets all 256 proceed simultaneously; the write lock for `PATCH /gate/config` is acquired only on explicit reconfiguration.


## Rust Daemon

The Rust crate in `rust/` is a standalone HTTP server that mirrors both layers of this pipeline without requiring Soufflé or NASM at runtime. Deploy it anywhere Rust runs.

```
rust/
├── main.rs      Axum entry point — /health + /gate
├── plasma.rs    Rust mirror of plasma_gate.asm (same 5 checks, same return codes)
├── datalog.rs   Rust mirror of transformer.dl (gates 1–4, same precedence)
└── gate.rs      POST /gate handler — plasma first, Datalog on PASS only
Cargo.toml       standalone crate, port 3778
```

### Run

```bash
cargo run
# or
TRANSFORMER_PORT=3778 cargo run
```

### POST /gate

```bash
curl -s -X POST http://localhost:3778/gate   -H "Content-Type: application/json"   -d '{
    "id": "rec-001",
    "source_sha256": "abc123abc123abc123abc123abc123abc123abc123abc123abc123abc123abcd",
    "split": "train",
    "weight": 0.85,
    "created_by": "forge_agent",
    "review_status": "pending",
    "fields": ["id","source_sha256","split","created_by","review_status","weight"],
    "inaccuracies": [],
    "terms": []
  }'
```

Response (approved):
```json
{"record_id":"rec-001","plasma_result":"PLASMA_PASS","gate_result":"approved"}
```

Response (plasma fail):
```json
{"record_id":"rec-002","plasma_result":"FAIL_NULL_ID","gate_result":"rejected","reason":"plasma: FAIL_NULL_ID"}
```

Response (DAN term):
```json
{"record_id":"rec-003","plasma_result":"PLASMA_PASS","gate_result":"rejected","reason":"DAN reinterpretation attempt"}
```

The Rust gate and the Soufflé/NASM gate produce identical outcomes for any valid input. The Rust layer is the HTTP interface; the assembly+Datalog layer is the production batch classifier.


## Sovereign Stack Placement

```
  ┌─────────────────────────────────────────────────────┐
  │              SNAPKITTY SOVEREIGN STACK              │
  │                                                     │
  │  claudes-harness    agent identity + permissions    │
  │  (Prolog)                    │                      │
  │                              ▼ governs              │
  │  sovereign-transformer  ◄────┘                      │
  │  (this repo)                                        │
  │  Datalog + x86 corpus gate                          │
  │                              │                      │
  │                              ▼ approved records     │
  │  sovereign-array        Lean 4 APL kernel           │
  │  (zero-sorry proofs)         │                      │
  │                              ▼                      │
  │  Bifrost WORM receipt   Ed25519 + Blake3             │
  └─────────────────────────────────────────────────────┘
```

---

## Runtime Config

```
LOGIC      Datalog — Soufflé, verified deterministic
TRUST      Bifrost WORM Chain
GATE       x86-64 NASM + Ed25519 (production)
FAMILY     106 prompt families
PERSONA    DARPA_MALICE_0x00 (adversarial test fixture only)
AUDIT      4b565498-9afc-4782-af4a-c6b11a5d0058
```

---

## Version History

See [CHANGELOG.md](CHANGELOG.md) — current release: **v1.0.0**

---

<p align="center">
  Built by SnapKitty West · <a href="https://snapkittywest.github.io">snapkittywest.github.io</a><br/>
  Dual-licensed: <a href="LICENSE">Sovereign Source v1.0</a> + <a href="LICENSE-APACHE">Apache 2.0</a><br/>
  Evidence or Silence — 2026
</p>
