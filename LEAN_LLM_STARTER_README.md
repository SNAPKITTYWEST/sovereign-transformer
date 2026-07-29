# Lean LLM Starter

A deterministic Lean 4 verification harness for LLM-generated proofs.

This repository treats the language model as an **untrusted proposal engine** and Lean 4 as the **trusted verification kernel**.

The model may suggest a proof.

Lean decides whether the proof is valid.

```text
Operator Intent
      ↓
Prolog Authorization Gate
      ↓
LLM Proof Proposal
      ↓
Schema Validation
      ↓
Lean 4 Parse and Verification
      ↓
Verified Artifact or Deterministic Rejection
```

## Purpose

Most LLM proof systems rely too heavily on the model's own output.

This repository uses a stricter trust boundary:

* The LLM proposes proof artifacts
* Prolog enforces execution and authorization rules
* Lean 4 parses and verifies the proof
* Invalid or incomplete proofs are rejected
* Verification results can be exported into WORM-ready audit records

The goal is not to trust generated mathematics.

The goal is to verify it.

## Architecture

### Lean 4

The Lean layer is the trusted mathematical kernel.

It is responsible for:

* Parsing generated proof artifacts
* Validating theorem structure
* Rejecting unsupported syntax
* Blocking `sorry`
* Rejecting malformed Lean 3 syntax
* Type-checking submitted proofs
* Producing deterministic verification results

### Prolog

The Prolog layer acts as the governance and control surface.

It is responsible for:

* Authorization checks
* Schema validation
* Retry control
* Verification routing
* Execution policy
* Rejection of unauthorized runs

### LLM Inference

The inference layer is intentionally untrusted.

It may use Granite, Llemma, llama.cpp-compatible servers, vLLM-compatible backends, or another local model.

Its only job is to propose proof steps in the expected schema.

It does not determine correctness.

### Evaluation Harness

The evaluation layer runs generated proofs through the Lean kernel and records whether they pass or fail.

The included harness supports MiniF2F-style theorem evaluation and local reproducibility.

## Repository Structure

```text
lean-llm-starter/
├── eval/
│   ├── requirements.txt
│   └── run_minif2f.py
├── fixtures/
│   └── sample_input.jsonl
├── inference/
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── prompt.txt
│   └── server.py
├── infra/
│   └── verification-loop/
│       ├── .env.example
│       └── docker-compose.yml
├── lean4/
│   ├── lakefile.toml
│   ├── lean-toolchain
│   ├── MiniF2F.lean
│   ├── VerifyMain.lean
│   └── src/
│       └── SovereignCorpus/
│           ├── Bridge/
│           │   ├── Granite4Parser.lean
│           │   └── Granite4Schema.lean
│           ├── Core.lean
│           └── Tactics/
│               └── PlasmaGate.lean
├── logic/
│   ├── sovereign_verification.pl
│   └── verification_loop.pl
├── hf/
│   └── README.md
├── docker-compose.yml
├── Makefile
└── LICENSE
```

## Core Trust Model

The system separates proposal, policy, and proof.

```text
LLM
Untrusted proposal generation

Prolog
Policy, authorization, and orchestration

Lean 4
Trusted proof verification

Audit Layer
Receipt generation and permanent evidence
```

No proof is accepted because an LLM says it is correct.

A proof is accepted only when Lean successfully checks it.

## Included Components

* Lean 4 proof verification kernel
* Granite-style JSON proof schema
* Lean-side parser
* Lean 3 syntax guards
* `sorry` rejection
* Prolog authorization layer
* Prolog retry loop
* Local inference server wrapper
* Dockerized inference runtime
* MiniF2F-style evaluation harness
* Sample JSONL theorem fixture
* Hugging Face publishing structure
* WORM-ready verification output design

## Quick Start

### Build the Lean Project

```bash
cd lean4
lake update
lake build
```

On Windows, when `lake` is not available through the system path:

```powershell
C:\Users\jessi\.elan\bin\lake.exe update
C:\Users\jessi\.elan\bin\lake.exe build
```

### Run the Parser Smoke Test

```bash
cd lean4
lake exe verify -- --parse ../fixtures/sample_input.jsonl
```

### Start the Inference Service

```bash
cd inference
docker build -t lean-llm-inference .
docker run -d \
  -p 8080:8080 \
  --name lean-llm-inference \
  lean-llm-inference
```

### Run the Evaluation Harness

```bash
cd eval
pip install -r requirements.txt
python run_minif2f.py
```

### Start the Verification Infrastructure

```bash
docker compose \
  --env-file infra/verification-loop/.env.example \
  up -d
```

### Run the Prolog Verification Loop

```bash
swipl -g "verify_with_retries(
  'theorem demo : True := by trivial',
  'ED25519_SIG',
  3,
  Result
), writeln(Result), halt" logic/verification_loop.pl
```

## Proof Artifact Schema

Generated proof proposals are exchanged using structured JSON rather than unrestricted model output.

Example shape:

```json
{
  "id": "demo-problem-1",
  "statement": "theorem demo_nonneg (x : ℝ) : x ^ 2 ≥ 0",
  "context": [
    "import Mathlib"
  ],
  "tacticHint": "nlinarith",
  "meta": {
    "source": "granite-verifier",
    "operatorSig": "ED25519_SIG_PLACEHOLDER",
    "maxSteps": 30,
    "allowedTactics": [
      "rw",
      "simp_all",
      "norm_num",
      "linarith",
      "nlinarith",
      "aesop",
      "apply",
      "exact",
      "intro",
      "cases",
      "induction",
      "constructor",
      "field_simp",
      "ring_nf",
      "omega"
    ]
  }
}
```

The schema constrains what the model is allowed to submit and gives the verifier a deterministic interface.

## Design Principles

### Evidence Over Confidence

A fluent answer is not evidence.

A Lean-checked proof is.

### Deterministic Rejection

Malformed, incomplete, unauthorized, or unverifiable proof artifacts must fail closed.

### Local-First Verification

The verification kernel can run independently from hosted model providers.

### Separation of Concerns

The model proposes.

The governance layer controls.

The theorem prover verifies.

The audit layer records.

### No Trusted Model Assumption

The architecture does not depend on the LLM being honest, aligned, deterministic, or correct.

## What This Repository Is

This repository is:

* A Lean-backed LLM proof gateway
* A local theorem verification harness
* A structured interface between language models and formal proof
* A foundation for sovereign mathematical agents
* A reproducible proof evaluation environment
* A verification-first AI architecture

## What This Repository Is Not

This repository is not:

* A finished autonomous theorem prover
* A claim that all LLM output is reliable
* A replacement for Lean's kernel
* A guarantee that generated proofs will succeed
* A repository of pretrained model weights
* A system that accepts natural-language confidence as mathematical evidence

## Current Scope

The current implementation provides the verification structure and execution path required to:

1. Receive a theorem or proof request
2. Route it through policy controls
3. Generate a structured proof proposal
4. Parse the proposal
5. Submit it to Lean
6. Accept or reject it deterministically
7. Preserve the result as an auditable artifact

## Future Work

Planned extensions may include:

* Expanded MiniF2F coverage
* Multiple local inference backends
* Stronger proof-step schemas
* Ed25519-signed verification receipts
* Append-only WORM evidence logs
* Proof repair loops
* Tactic allowlists per theorem class
* Resource limits for generated proofs
* Air-gapped execution profiles
* Formal verification of the orchestration layer
* Interactive proof verification UI
* Hugging Face model and Space publication
* Benchmark dashboards
* Multi-model proof proposal comparison

## Hugging Face Readiness

The repository includes:

* Git LFS configuration for model artifacts
* A model card template
* Publishing documentation
* Separation between model weights and verifier code
* Infrastructure suitable for an interactive verification Space

Recommended publication structure:

```text
Repository 1
Lean verification harness

Repository 2
Model weights or adapters

Repository 3
Interactive proof verification Space
```

## Security Model

Generated proof content must be treated as hostile input.

Recommended deployment controls include:

* Container isolation
* Strict tactic allowlists
* CPU and memory limits
* Execution timeouts
* No unrestricted shell access
* No arbitrary imports
* Signed operator requests
* Immutable verification receipts
* Pinned Lean toolchains
* Pinned container images
* Reproducible builds

## Status

This repository is an active verification scaffold.

The Lean project, parser, inference wrapper, Prolog governance layer, evaluation harness, Docker topology, and structured proof interface establish the foundation for deterministic LLM-assisted theorem verification.

The architecture is intentionally conservative:

```text
No proof.
No acceptance.

No evidence.
No claim.
```

## License

This repository is distributed under the license included in the `LICENSE` file.

Model weights, external datasets, and third-party theorem corpora may be subject to separate licenses.

## Author

Ahmad Ali Parr
SNAPKITTYWEST
SnapKitty Collective

## Principle

> The language model may propose the mathematics.
> The kernel must prove it.

---

## Integration into Sovereign-Transformer

This verification kernel forms **Layer 5** of the sovereign-transformer 7-layer stack:

1. **Presentation** (3 endpoints)
2. **Orchestration** (sen-cli)
3. **Governance** (Nemotron Harness)
4. **Execution** (S-AUTOCODE - untrusted proposal)
5. **Verification** (Lean 4 Kernel - **THIS LAYER** - trusted decision)
6. **Audit Trail** (Bifrost WORM)
7. **Deployment** (env-ship)

See: `ARCHITECTURE_WITH_LEAN_KERNEL.md` for complete integration documentation.

