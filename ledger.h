#ifndef LEDGER_H
#define LEDGER_H

/*
 * Returns number of references of an object with given key.
 * -1 is returned if the key DNE or in case of DB related issues.
 */
int get_ref_count(const char* _key);

/*
 * Returns 1 if ref count of an object with given key is zero, 0 otherwise.
 */
int is_garbage(const char* _key);

/*
 * Increment number of references to an object with given key.
 * New entry is added with ref count equal to 1 if the key is not present.
 * Non-zero(error) is returned if DB related issues arise.
 */
int inc_ref_count(const char* _key);

/*
 * Decrement number of references to an object.
 * When trying to decrement ref count which is zero, ref count stays zero.
 * Non-zero(error) is returned if DB related issues arise or the key DNE.
 */
int dec_ref_count(const char* _key);

#endif // LEDGER_H
