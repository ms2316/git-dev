#ifndef REFCOUNTER_H
#define REFCOUNTER_H

#include "cache.h"
#include "commit.h"
#include "pathspec.h"

#define PROCESS_PARENTS 1

static struct pathspec pathspec;
/*
 * Returns a hexadecimal hash of a commit by branch name
 * Returns NULL if it doesn't exist
 */
const char* get_hex_hash_by_bname(const char*);

/*
 * Runs reference counting GC cascading deletions
 * Returns 0 on success and non-zero otherwise
 */
int refcount_gc(struct commit*, unsigned int);

/*
 * Initialize reference count of the new commit
 * and all of it's underlying objects(if necessary)
 * Returns 0 on success and non-zero otherwise
 */
int init_commit_refcount(struct commit*);

#endif //REFCOUNTER_H
