#pragma once
#include <stdint.h>

// Return codes from plasma_gate()
typedef enum {
    PLASMA_PASS          = 0,
    FAIL_NULL_ID         = 1,
    FAIL_NULL_SHA        = 2,
    FAIL_BAD_SPLIT       = 3,
    FAIL_ZERO_WEIGHT     = 4,
    FAIL_WEIGHT_OVERFLOW = 5,
} PlasmaResult;

// Split tag encoding (matches x86 plasma_gate split_tag range 0..3)
typedef enum {
    SPLIT_TRAIN   = 0,
    SPLIT_VAL     = 1,
    SPLIT_TEST    = 2,
    SPLIT_HOLDOUT = 3,
} SplitTag;

// Hot-path gate — runs before Datalog engine
// Returns PLASMA_PASS (0) or a FAIL_* code
extern PlasmaResult plasma_gate(
    const char* id_ptr,
    const char* sha256_ptr,
    uint32_t    split_tag,
    double      weight
);

// WORM hash chaining stub — calls real Blake3 in production
extern void bifrost_chain_stub(
    const uint8_t prev_hash[32],
    const char*   record_id,
    uint8_t       out_hash[32]
);
