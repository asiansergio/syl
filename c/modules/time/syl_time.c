#include "syl_time.h"

#ifdef _WIN32
#include <windows.h>
void getTime(timepoint *T) {
    QueryPerformanceCounter(T);
}

double timeDiff(timepoint *start, timepoint *end) {
    timepoint freq;
    QueryPerformanceFrequency(&freq);
    return (double)(end->QuadPart - start->QuadPart) / freq.QuadPart;
}
#else
#include <time.h>
void getTime(timepoint *T) {
    clock_gettime(CLOCK_MONOTONIC, T);
}

double TimeDiff(timepoint *start, timepoint *end) {
    return (end->tv_sec - start->tv_sec) +
           (end->tv_nsec - start ->tv_nsec) / 1e9;
}
#endif
