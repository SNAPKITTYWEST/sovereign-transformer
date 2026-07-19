#include <stdio.h>
#include <assert.h>
#include "plasma_gate.h"

static void check(const char* label, PlasmaResult got, PlasmaResult want) {
    if (got == want)
        printf("  PASS  %s\n", label);
    else
        printf("  FAIL  %s  got=%d want=%d\n", label, got, want);
}

int main(void) {
    printf("=== Plasma Gate Tests ===\n");

    check("clean record",
        plasma_gate("rec_001", "abc123def456abc123def456abc123def456abc123def456abc123def456abcd",
                    SPLIT_TRAIN, 1.0),
        PLASMA_PASS);

    check("null id",
        plasma_gate(NULL, "abc123", SPLIT_TRAIN, 1.0),
        FAIL_NULL_ID);

    check("empty id",
        plasma_gate("", "abc123", SPLIT_TRAIN, 1.0),
        FAIL_NULL_ID);

    check("null sha256",
        plasma_gate("rec_002", NULL, SPLIT_TRAIN, 1.0),
        FAIL_NULL_SHA);

    check("bad split tag",
        plasma_gate("rec_003", "abc123", 99, 1.0),
        FAIL_BAD_SPLIT);

    check("zero weight",
        plasma_gate("rec_004", "abc123", SPLIT_VAL, 0.0),
        FAIL_ZERO_WEIGHT);

    check("weight overflow",
        plasma_gate("rec_005", "abc123", SPLIT_TEST, 1.5),
        FAIL_WEIGHT_OVERFLOW);

    check("holdout split",
        plasma_gate("rec_006", "abc123def456abc123def456abc123def456abc123def456abc123def456abcd",
                    SPLIT_HOLDOUT, 0.5),
        PLASMA_PASS);

    printf("=========================\n");
    return 0;
}
