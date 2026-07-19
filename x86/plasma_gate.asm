; ═══════════════════════════════════════════════════════════════
; PLASMA GATE — x86-64 hot path
; Validates a corpus record header in registers before it ever
; reaches the Datalog engine. Catches null IDs and zero-weight
; records in ~5 cycles — no heap, no branches on happy path.
;
; Calling convention: System V AMD64 ABI
;
; plasma_gate(id_ptr, sha256_ptr, split_tag, weight_bits)
;   rdi = id_ptr       (const char* — must be non-null, non-empty)
;   rsi = sha256_ptr   (const char* — must be non-null, len == 64)
;   rdx = split_tag    (uint32_t   — must be in {0,1,2,3})
;   xmm0 = weight      (double     — must be in (0.0, 1.0])
;
; Returns:
;   rax = 0   PLASMA_PASS
;   rax = 1   FAIL_NULL_ID
;   rax = 2   FAIL_NULL_SHA
;   rax = 3   FAIL_BAD_SPLIT
;   rax = 4   FAIL_ZERO_WEIGHT
;   rax = 5   FAIL_WEIGHT_OVERFLOW
; ═══════════════════════════════════════════════════════════════

section .text
global plasma_gate

; Error codes
%define PLASMA_PASS          0
%define FAIL_NULL_ID         1
%define FAIL_NULL_SHA        2
%define FAIL_BAD_SPLIT       3
%define FAIL_ZERO_WEIGHT     4
%define FAIL_WEIGHT_OVERFLOW 5

; Valid split tags: 0=train 1=val 2=test 3=holdout
%define MAX_SPLIT_TAG        3

plasma_gate:
    ; ── CHECK 1: id_ptr must be non-null and non-empty ──────────
    test    rdi, rdi
    jz      .fail_null_id

    movzx   eax, byte [rdi]        ; first char of id string
    test    al, al
    jz      .fail_null_id

    ; ── CHECK 2: sha256_ptr must be non-null ────────────────────
    test    rsi, rsi
    jz      .fail_null_sha

    movzx   eax, byte [rsi]
    test    al, al
    jz      .fail_null_sha

    ; ── CHECK 3: split_tag must be 0..3 ─────────────────────────
    cmp     edx, MAX_SPLIT_TAG
    ja      .fail_bad_split

    ; ── CHECK 4: weight must be > 0.0 ───────────────────────────
    xorpd   xmm1, xmm1             ; xmm1 = 0.0
    ucomisd xmm0, xmm1
    jbe     .fail_zero_weight      ; weight <= 0.0

    ; ── CHECK 5: weight must be <= 1.0 ──────────────────────────
    movsd   xmm1, [rel _one]
    ucomisd xmm0, xmm1
    ja      .fail_weight_overflow  ; weight > 1.0

    ; ── PASS ────────────────────────────────────────────────────
    xor     eax, eax               ; rax = PLASMA_PASS
    ret

.fail_null_id:
    mov     eax, FAIL_NULL_ID
    ret

.fail_null_sha:
    mov     eax, FAIL_NULL_SHA
    ret

.fail_bad_split:
    mov     eax, FAIL_BAD_SPLIT
    ret

.fail_zero_weight:
    mov     eax, FAIL_ZERO_WEIGHT
    ret

.fail_weight_overflow:
    mov     eax, FAIL_WEIGHT_OVERFLOW
    ret

section .rodata
_one:   dq  1.0                    ; IEEE 754 double 1.0


; ═══════════════════════════════════════════════════════════════
; BIFROST HASH STUB — chain audit hash into running WORM log
;
; bifrost_chain(prev_hash_ptr, record_id_ptr, out_hash_ptr)
;   rdi = prev_hash_ptr  (uint8_t[32] — Blake3 of previous step)
;   rsi = record_id_ptr  (const char*)
;   rdx = out_hash_ptr   (uint8_t[32] — write result here)
;
; Real impl calls into libblake3 via C ABI.
; This stub writes a sentinel so the Datalog layer can detect
; whether Bifrost was invoked before approving a record.
; ═══════════════════════════════════════════════════════════════

global bifrost_chain_stub

bifrost_chain_stub:
    ; Write sentinel 0xBF to first byte of out_hash
    mov     byte [rdx], 0xBF
    ; Zero the remaining 31 bytes
    xor     eax, eax
    mov     ecx, 31
    lea     rdi, [rdx + 1]
    rep stosb
    ret
