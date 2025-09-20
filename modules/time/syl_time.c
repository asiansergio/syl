#include "syl_time.h"

#ifdef _WIN32
#include <windows.h>
void GetTime(Timepoint *T)
{
    QueryPerformanceCounter(T);
}

double TimeDiff(Timepoint *Start, Timepoint *End)
{
    Timepoint Freq;
    QueryPerformanceFrequency(&Freq);
    return (double)(End->QuadPart - Start->QuadPart) / Freq.QuadPart;
}
#else
#include <time.h>
void GetTime(Timepoint *T)
{
    clock_gettime(CLOCK_MONOTONIC, T);
}

double TimeDiff(Timepoint *Start, Timepoint *End)
{
    return (End->tv_sec - Start->tv_sec) +
           (End->tv_nsec - Start ->tv_nsec) / 1e9;
}
#endif
