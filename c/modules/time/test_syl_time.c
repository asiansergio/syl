#include "syl_time.h"
#include <stdio.h>
#include <assert.h>

#ifdef _WIN32
#include <windows.h>
#define sleepMs(ms) Sleep(ms)
#else
#include <unistd.h>
#define sleepMs(ms) usleep((ms) * 1000)
#endif

int
main() {
    printf("Testing syl_time module...\n");

    // Test 1: GetTime doesn't crash
    timepoint T1, T2;
    getTime(&T1);
    printf("✓ GetTime works\n");

    // Test 2: TimeDiff with immediate calls
    getTime(&T2);
    double diff = timeDiff(&T1, &T2);
    assert(diff >= 0.0);
    printf("✓ TimeDiff returns non-negative value: %f seconds\n", diff);

    // Test 3: TimeDiff with measurable delay
    getTime(&T1);
    sleepMs(10); // 10ms delay
    getTime(&T2);
    diff = timeDiff(&T1, &T2);
    assert(diff > 0.0);
    assert(diff < 1.0); // Should be much less than 1 second
    printf("✓ TimeDiff measures delay correctly: %f seconds\n", diff);

    printf("All tests passed!\n");
    return 0;
}
