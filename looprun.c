#define _POSIX_C_SOURCE 199309L

#include <errno.h>
#include <spawn.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <time.h>

#define NS_IN_S 1000000000L

void timespec_diff(struct timespec start, struct timespec end,
                   struct timespec *out)
{
    if (end.tv_nsec < start.tv_nsec) {
        out->tv_sec = end.tv_sec - start.tv_sec - 1;
        out->tv_nsec = NS_IN_S + end.tv_nsec - start.tv_nsec;
    } else {
        out->tv_sec = end.tv_sec - start.tv_sec;
        out->tv_nsec = end.tv_nsec - start.tv_nsec;
    }
}

uint64_t timespec2ns(struct timespec t)
{
    uint64_t res = t.tv_sec;
    res *= NS_IN_S;
    res += t.tv_nsec;
    return res;
}

void ns2timespec(uint64_t t, struct timespec *out)
{
    out->tv_nsec = t % NS_IN_S;
    out->tv_sec = t / NS_IN_S;
}

void timespec_div(struct timespec dividend, long divisor,
                  struct timespec *out)
{
    uint64_t t = timespec2ns(dividend);
    t /= divisor;
    ns2timespec(t, out);
}

int main(int argc, char **argv, char **envp)
{
    int rc, erc, status;
    long cycles;
    pid_t pid;
    bool timing = true;
    struct timespec before, after, elapsed, per_cycle;
    const char *prg = argv[3];

    if (argc < 4) {
        fprintf(stderr, "needs 3+ params: ret cycles cmd [params]\n");
        exit(EXIT_FAILURE);
    }

    errno = 0;
    erc = strtol(argv[1], NULL, 10);
    if (errno != 0) {
        perror("strtol erc");
        exit(EXIT_FAILURE);
    }

    errno = 0;
    cycles = strtol(argv[2], NULL, 10);
    if (errno != 0) {
        perror("strtol cycles");
        exit(EXIT_FAILURE);
    }

    /* negative number of cycles used for warmup */
    if (cycles < 0) {
        timing = false;
        cycles = -cycles;
    }

    if (clock_gettime(CLOCK_REALTIME, &before) < 0) {
        perror("clock_gettime");
        exit(EXIT_FAILURE);
    }

    for (long i = 0; i < cycles; i++) {
        rc = posix_spawn(&pid, prg, NULL, NULL, argv + 3, envp);
        if (rc != 0) {
            perror("posix_spawnp");
            exit(EXIT_FAILURE);
        }

        rc = waitpid(pid, &status, 0);
        if (rc < 0) {
            perror("waitpid");
            exit(EXIT_FAILURE);
        }

        rc = WEXITSTATUS(status);
        if (rc != erc) {
            fprintf(stderr, "%s returned %i != %i during iteration %li\n",
                    prg, rc, erc, i);
            exit(EXIT_FAILURE);
        }
    }

    rc = clock_gettime(CLOCK_REALTIME, &after);
    if (rc < 0) {
        perror("clock_gettime");
        exit(EXIT_FAILURE);
    }

    if (timing) {
        timespec_diff(before, after, &elapsed);
        timespec_div(elapsed, cycles, &per_cycle);

        /* yeah that should be stdout but fudge it */
        rc = fprintf(stderr,
                     "%3i.%09li * %6li = %5i.%09li\n",
                     (int) (per_cycle.tv_sec), per_cycle.tv_nsec,
                     cycles, (int) (elapsed.tv_sec), elapsed.tv_nsec);
        if (rc < 0)
            exit(EXIT_FAILURE);
    }
    return(EXIT_SUCCESS);
}
