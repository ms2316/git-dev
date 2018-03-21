//REFCOUNTER_C

#include <stdlib.h>
#include "cache.h"
#include "refcounter.h"

const char* get_hex_hash_by_bname(const char* name) {
	struct object_id oid;
	char* cmt_hash = (char*) malloc(GIT_MAX_HEXSZ * sizeof(char));
	if (get_oid(name, &oid))
		return NULL;
	for (int i = 0; i < GIT_MAX_RAWSZ; i++)
		sprintf(cmt_hash+2*i, "%02x", oid.hash[i]);
	return cmt_hash;
}
