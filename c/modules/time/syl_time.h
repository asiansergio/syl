#ifndef SYL_TIME_H
#define SYL_TIME_H

#ifdef __cplusplus
extern "C" {
#endif

// Platform-specific includes and types
#ifdef _WIN32
    #include <windows.h>
    typedef LARGE_INTEGER timepoint;
#else
    #include <time.h>
    typedef struct timespec timepoint;
#endif

void getTime(timepoint *T);
double timeDiff(timepoint *Start, timepoint *End);

#ifdef __cplusplus
}
#endif

#endif /* SYL_TIME_H */
