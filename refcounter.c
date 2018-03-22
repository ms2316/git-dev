//REFCOUNTER_C

#include "cache.h"
#include "refcounter.h"

const char* get_hex_hash_by_bname(const char* name) {
	struct object_id oid;
	if (get_oid(name, &oid))
		return NULL;
	return oid_to_hex(&oid);
}
