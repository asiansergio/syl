#ifndef SYL_TIME_H
#define SYL_TIME_H

#ifdef __cplusplus
extern "C" {
#endif

// Platform-specific includes and types
#ifdef _WIN32
    #include <windows.h>
    typedef LARGE_INTEGER Timepoint;
#else
    #include <time.h>
    typedef struct timespec Timepoint;
#endif

void GetTime(Timepoint *T);
double TimeDiff(Timepoint *Start, Timepoint *End);

#ifdef __cplusplus
}
#endif

#endif /* SYL_TIME_H */
