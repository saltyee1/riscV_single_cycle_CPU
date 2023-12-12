#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <svdpi.h>

#include "debug.h"

/* define service request type numbers */
#define ECALL_EXIT 0
#define ECALL_PUTCAR 1

void ecall(const svLogicVecVal *reg_a0, const svLogicVecVal *reg_a1, svLogic *halt) {
    int signal = reg_a0->aval;
    int content_in_reg_a1 = reg_a1->aval & 0xFF;
    Assert(signal == ECALL_EXIT || signal == ECALL_PUTCAR, "Unsupported service request type...");
    if (signal == ECALL_EXIT) {
        Assert(halt != NULL, "halt is NULL, cannot change the content of NULL ptr...");
        *halt = true;
    } else {
        fprintf(stdout, "%c", content_in_reg_a1);
    }
}

