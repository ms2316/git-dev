#ifndef REFCOUNTER_H
#define REFCOUNTER_H

/*
 * Returns a hexadecimal hash of a commit by branch name
 * Returns NULL if it doesn't exist
 */
const char* get_hex_hash_by_bname(const char*);

#endif //REFCOUNTER_H
