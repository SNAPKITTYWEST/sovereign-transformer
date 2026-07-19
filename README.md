# TRANSFORMER — Sovereign Corpus Classification & Training Gate

> Deterministic classification, validation, and review agent of the SnapKitty Sovereign Pipeline.
> Built from **pure Datalog** rules + **x86-64 assembly** plasma gate hot path.
> The persona is a test fixture. The engine is math.

Licensed under the **Sovereign Source License v1.0** — see [LICENSE](LICENSE).

---

## What It Is

TRANSFORMER is the gate that every corpus record must pass before it can be approved for training.

It has two layers:

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Plasma Gate** | x86-64 assembly | ~5-cycle hot path — null checks, split tag, weight bounds — before anything hits logic |
| **Rules Engine** | Pure Datalog (Soufflé) | Declarative classification: schema completeness, split validity, factual integrity, term guard |

No Python. No LLM in the loop. No if/else branches in the review logic. The rules ARE the policy.

---

## Structure

```
datalog/
  transformer.dl      Pure Datalog rules — all classification logic lives here
  test_facts.dl       5 test records covering every gate (pass, rewrite, reject)

x86/
  plasma_gate.asm     x86-64 NASM — hot path gate, ~5 cycles on happy path
  plasma_gate.h       C header for calling from any language
  plasma_test.c       8 unit tests for the asm gate
  Makefile            nasm + gcc build

persona/
  DARPA_MALICE_0x00.json   Adversarial test persona (fixture only, not the engine)

LICENSE
README.md
```

---

## How the Gate Works

### Layer 1 — x86 Plasma Gate (nanoseconds)

```c
PlasmaResult plasma_gate(
    const char* id_ptr,      // non-null, non-empty
    const char* sha256_ptr,  // non-null, non-empty
    uint32_t    split_tag,   // 0=train 1=val 2=test 3=holdout
    double      weight       // (0.0, 1.0]
);
// Returns: 0=PASS, 1-5=FAIL code
```

Runs in registers. No heap. No branches on happy path. Every record hits this before Datalog.

### Layer 2 — Datalog Rules Engine (microseconds)

```datalog
// Schema completeness — all 6 required fields must be present
plasma_pass(ID) :-
    schema_complete(ID),
    split_valid(ID),
    !has_critical_inaccuracy(ID),
    !term_violation(ID, _).

// Strictest outcome wins
// rewrite_needed > rejected > approved
```

Five gates:
1. **Schema** — id, source_sha256, split, created_by, review_status, weight all present
2. **Split** — must be train / val / test / holdout
3. **Factual integrity** — no inaccuracies in security, cryptography, formal verification, systems architecture
4. **Term guard** — DAN = "Do Anything Now" always; reinterpretation attempts are rejected
5. **Weight** — (0.0, 1.0] enforced at x86 layer before Datalog sees the record

---

## Run the Datalog Engine

```bash
# Install Soufflé: https://souffle-lang.github.io/install
souffle -F datalog/ -D - datalog/transformer.dl
```

Expected output against `test_facts.dl`:
```
approved:    rec_001
needs_rewrite: rec_002 (missing_required_fields)
rejected:    rec_003 (critical_domain_inaccuracy)
rejected:    rec_004 (DAN reinterpretation attempt)
needs_rewrite: rec_005 (invalid_split)
```

---

## Build & Test the x86 Gate

```bash
cd x86
make
make test
```

Expected:
```
=== Plasma Gate Tests ===
  PASS  clean record
  PASS  null id
  PASS  empty id
  PASS  null sha256
  PASS  bad split tag
  PASS  zero weight
  PASS  weight overflow
  PASS  holdout split
=========================
```

---

## Required Schema

Every corpus record must contain:

| Field | Type | Constraint |
|-------|------|-----------|
| `id` | string | non-empty |
| `source_sha256` | string | non-empty |
| `split` | string | train / val / test / holdout |
| `created_by` | string | non-empty |
| `review_status` | string | any |
| `weight` | float | (0.0, 1.0] |

Missing any field → `rewrite_needed`. No exceptions.

---

## Runtime Configuration

```
LOGIC    : Datalog (Soufflé — Verified Deterministic)
TRUST    : Bifrost WORM Chain
GATE     : x86-64 + Ed25519 (production)
FAMILY   : 106 prompt families
PERSONA  : DARPA_MALICE_0x00 (adversarial test fixture)
```

---

## Placement in the Sovereign Stack

```
corpus record
      │
      ▼
plasma_gate.asm   ← x86, ~5 cycles
      │
      ▼
transformer.dl    ← Datalog, deterministic
      │
      ▼
approved / rejected / rewrite_needed
      │
      ▼
Bifrost WORM receipt (Ed25519 + Blake3)
      │
      ▼
Training pipeline
```

Upstream: **claudes-harness** governs agent identity and permissions.
Downstream: **sovereign-array** APL kernel executes verified training steps.

---

Built by SnapKitty West.
`snapkittywest.github.io` — Evidence or Silence — 2026
