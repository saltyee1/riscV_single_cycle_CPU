#include <assert.h>
#include <dlfcn.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <svdpi.h>

#include "../user/debug.h"
#include "log.h"

/* dynamic linking functions from emulator for DiffTest */
void (*ref_difftest_init)(void) = NULL;
void (*ref_difftest_get_regs)(void *buf) = NULL;
void (*ref_difftest_set_regs)(const void *regs_from_dut) = NULL;
void (*ref_difftest_memcpy_from_dut)(uint32_t addr, const void *buf, size_t size) = NULL;
void (*ref_difftest_step)(void) = NULL;

/* static global varibles */
static void *handle = NULL;
static uint32_t ref_regs[32] = {};
static uint32_t dut_regs[32] = {};
static uint8_t *ptr_dut_MEM = NULL;
static bool has_gotton_dut_regs = false;

static bool check_regs(void);

void difftest_init(const char *so_file_name) {
    /* load shared lib, which is emulator here */
    handle = dlopen(so_file_name, RTLD_LAZY);
    /* loading symbols in shared lib */
    ref_difftest_init = dlsym(handle, "difftest_init");
    assert(ref_difftest_init);
    ref_difftest_get_regs = dlsym(handle, "difftest_get_regs");
    assert(ref_difftest_get_regs);
    ref_difftest_set_regs = dlsym(handle, "difftest_set_regs");
    assert(ref_difftest_set_regs);
    ref_difftest_memcpy_from_dut = dlsym(handle, "difftest_memcpy_from_dut");
    assert(ref_difftest_memcpy_from_dut);
    ref_difftest_step = dlsym(handle, "difftest_step");
    assert(ref_difftest_step);

    /* innitialize difftest of emulator */
    ref_difftest_init();
}

void difftest_get_regs(const svLogicVecVal *regFile) {
    Assert(regFile != NULL, "difftest_get_regs error! Pointer regFile is NULL...");
    uint32_t temp_regs[32] = {};
    for (int i = 0; i < 32; i++) {
        temp_regs[i] = regFile[i].aval;
    }
    memcpy(dut_regs, temp_regs, sizeof(uint32_t) * 32);
    has_gotton_dut_regs = true;
}

void difftest_set_regs(void) {
    Assert(has_gotton_dut_regs, "difftest_set_regs error! Has not gotten registers from dut...");
    ref_difftest_set_regs(dut_regs);
    has_gotton_dut_regs = false;
}

void difftest_memcpy_from_dut(const svLogicVecVal *dut_MEM) {
    /* transfer and save SystemVerilgo type to C type */
    ptr_dut_MEM = malloc(sizeof(uint8_t) * 0x10000);
    assert(ptr_dut_MEM);
    for (int i = 0; i < 0x10000; i++) {
        ptr_dut_MEM[i] = (uint8_t)(dut_MEM[i].aval & 0xFF);
    }
    /* copy memory content from dut to ref */
    ref_difftest_memcpy_from_dut(0, ptr_dut_MEM, 0x10000);
    /* de-allocate temp buffer */
    free(ptr_dut_MEM);
}

void difftest_step(svBit *success_flag) {
    /* used to record register file from emulator and dut */
    /* get reference state from emulator */
    ref_difftest_step();
    ref_difftest_get_regs(&ref_regs);

    /* dut will call difftest_get_regs() to get status of dut */
    /* dut call... */
    Assert(has_gotton_dut_regs, "difftest_step error! Has not gotton registers from dut...");

    /* perform registers checking */
    bool temp_flag = check_regs();
    *success_flag = temp_flag;

    /* reset flags */
    has_gotton_dut_regs = false;
}

void difftest_end(void) {
    /* close dynamically link lib */
    dlclose(handle);
}

static bool check_regs(void) {
    /* compare every registers in register file of both emu and dut */
    for (int i = 0; i < 32; i++) {
        if (ref_regs[i] != dut_regs[i]) {
            LOG_ERROR("Difftest check registers error...");
            LOG_ERROR("Register %d got different values on dur and ref. Dut: %x and Ref: %x", i, dut_regs[i],
                      ref_regs[i]);
            return false;
        }
    }
    return true;
}

