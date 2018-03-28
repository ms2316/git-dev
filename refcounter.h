#ifndef REFCOUNTER_H
#define REFCOUNTER_H

#include "pathspec.h"

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
int refcount_dec_gc(struct commit*);

/*
 * Delete object spcified by object_id
 * Returns 0 on success and non-zero otherwise
 */
int delete_object(struct object_id*);

#endif //REFCOUNTER_H
