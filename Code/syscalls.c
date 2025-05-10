#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <stdint.h>

/* Symbols from linker */
extern char _end;
extern char _heap_end;

static char *heap_ptr = NULL;

/* sbrk: extend heap */
void *_sbrk(ptrdiff_t incr)
{
    char *prev_heap_ptr;

    if (heap_ptr == NULL)
    {
        heap_ptr = &_end;
    }

    prev_heap_ptr = heap_ptr;

    if ((heap_ptr + incr) > &_heap_end)
    {
        errno = ENOMEM;
        return (void *)-1;
    }

    heap_ptr += incr;
    return (void *)prev_heap_ptr;
}

/* stdout/stderr write */
int _write(int file, const void *ptr, size_t len)
{
    (void)file;
    return len;
}

/* stdin read */
int _read(int file, void *ptr, size_t len)
{
    (void)file;
    (void)ptr;
    (void)len;
    return 0;
}

/* file positioning (no filesystem) */
int _lseek(int file, int ptr, int dir)
{
    (void)file;
    (void)ptr;
    (void)dir;
    return 0;
}

/* file close (no filesystem) */
int _close(int file)
{
    (void)file;
    return -1;
}

/* file stats (report character device) */
int _fstat(int file, struct stat *st)
{
    (void)file;
    st->st_mode = S_IFCHR;
    return 0;
}

/* isatty (for stdout/stderr) */
int _isatty(int file)
{
    (void)file;
    return 1;
}
