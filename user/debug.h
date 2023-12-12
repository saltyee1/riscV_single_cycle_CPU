#ifndef __DEBUG__
#define __DEBUG__

#include <assert.h>
#include <stdio.h>

#define Assert(cond, format, ...)                                                                                      \
    if (!(cond)) {                                                                                                     \
        do {                                                                                                           \
            fprintf(stderr, format, ##__VA_ARGS__);                                                                    \
            assert(cond);                                                                                              \
        } while (0);                                                                                                   \
    }

#endif

