#include "syl_time.h"
#include <stdio.h>
#include <assert.h>

#ifdef _WIN32
#include <windows.h>
#define SleepMs(ms) Sleep(ms)
#else
#include <unistd.h>
#define SleepMs(ms) usleep((ms) * 1000)
#endif

int
main() {
    printf("Testing syl_time module...\n");

    // Test 1: GetTime doesn't crash
    Timepoint T1, T2;
    GetTime(&T1);
    printf("✓ GetTime works\n");

    // Test 2: TimeDiff with immediate calls
    GetTime(&T2);
    double Diff = TimeDiff(&T1, &T2);
    assert(Diff >= 0.0);
    printf("✓ TimeDiff returns non-negative value: %f seconds\n", Diff);

    // Test 3: TimeDiff with measurable delay
    GetTime(&T1);
    SleepMs(10); // 10ms delay
    GetTime(&T2);
    Diff = TimeDiff(&T1, &T2);
    assert(Diff > 0.0);
    assert(Diff < 1.0); // Should be much less than 1 second
    printf("✓ TimeDiff measures delay correctly: %f seconds\n", Diff);

    printf("All tests passed!\n");
    return 0;
}
