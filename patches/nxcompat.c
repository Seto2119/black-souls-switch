/*
 * nxcompat.c - Horizon OS compatibility shims for mkxp-z.
 *
 * Two things live here:
 *
 *  1. __wrap_fcntl / __wrap_realpath, pulled in with
 *     -Wl,--wrap=fcntl -Wl,--wrap=realpath. Both exist to keep Ruby's
 *     require() working on Horizon OS:
 *
 *       * libnx implements fcntl() only inside its socket layer; for a real
 *         file descriptor it answers ENOTSOCK. Ruby opens load files with
 *         O_NONBLOCK and then calls fcntl(F_GETFL) to clear it, so without
 *         this wrap every require() dies with
 *         "LoadError: Socket operation on non-socket".
 *
 *       * newlib's realpath() returns the canonical path *with* the device
 *         prefix ("sdmc:/switch/app/lib"). Ruby treats a path as absolute only
 *         when it starts with '/', so it re-prefixes the CWD and ends up
 *         opening "sdmc:/switch/app/sdmc:/switch/app/lib/set.rb". Stripping the
 *         device prefix here fixes that; newlib resolves device-less paths
 *         against the default device (the SD card in homebrew).
 *
 *  2. nxBootTrace(), a tiny append-only logger to sdmc:/mkxp-z-boot.log used by
 *     main.cpp before/while the RGSS thread spins up.
 */
#include <errno.h>
#include <fcntl.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>
#include <sys/stat.h>

/* Real symbols provided by newlib/libnx. */
int __real_fcntl(int fd, int cmd, ...);
char *__real_realpath(const char *path, char *resolved);

int __wrap_fcntl(int fd, int cmd, ...)
{
    va_list ap;
    uintptr_t arg;
    struct stat st;

    va_start(ap, cmd);
    arg = va_arg(ap, uintptr_t);
    va_end(ap);

    /* Sockets keep going to libnx; it is the only one that understands them. */
    if (fd >= 0 && fstat(fd, &st) == 0 && !S_ISSOCK(st.st_mode)) {
        switch (cmd) {
        case F_GETFD:
            return 0;
        case F_SETFD:
            return 0; /* no exec() on Horizon, FD_CLOEXEC is meaningless */
        case F_GETFL:
            return O_RDWR; /* the FS does not remember open flags */
        case F_SETFL:
            return 0; /* files never block */
        case F_DUPFD:
            return dup(fd);
        default:
            errno = EINVAL;
            return -1;
        }
    }

    return __real_fcntl(fd, cmd, arg);
}

char *__wrap_realpath(const char *path, char *resolved)
{
    char *r = __real_realpath(path, resolved);
    char *sep;
    size_t i;

    if (!r)
        return r;

    /* A device prefix is <name>:/ where <name> is alphanumeric. */
    sep = strchr(r, ':');
    if (!sep || sep == r || sep[1] != '/')
        return r;

    for (i = 0; r + i < sep; i++) {
        if (!isalnum((unsigned char)r[i]) && r[i] != '_' && r[i] != '-')
            return r;
    }

    memmove(r, sep + 1, strlen(sep + 1) + 1);
    return r;
}

void nxBootTrace(const char *msg)
{
    static FILE *log = NULL;

    if (!log)
        log = fopen("sdmc:/mkxp-z-boot.log", "a");
    if (!log)
        return;

    fprintf(log, "%s\n", msg);
    fflush(log);
}

/* Ruby must query the currently executing libnx thread, including RGSS and
 * pthread-backed fibers. A fabricated/default stack bound breaks both its
 * stack overflow checks and conservative GC scanning. */
#include <pthread.h>
#include <switch.h>
int pthread_getattr_np(pthread_t thread, pthread_attr_t *attr)
{
    if (!attr || !pthread_equal(thread, pthread_self()))
        return EINVAL;
    Thread *self = threadGetSelf();
    if (!self || !self->stack_mem || !self->stack_sz)
        return ENOENT;
    int result = pthread_attr_init(attr);
    if (result)
        return result;
    char detail[160];
    snprintf(detail, sizeof(detail), "Ruby stack bounds: base=%p size=%zu", self->stack_mem, self->stack_sz);
    nxBootTrace(detail);
    result = pthread_attr_setstack(attr, self->stack_mem, self->stack_sz);
    if (result)
        pthread_attr_destroy(attr);
    return result;
}
