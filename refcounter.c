//REFCOUNTER_C

#include "cache.h"
#include "commit.h"
#include "refcounter.h"
#include "ledger.h"
#include "tree.h"

const char* get_hex_hash_by_bname(const char* name) {
	struct object_id oid;
	if (get_oid(name, &oid))
		return NULL;
	return oid_to_hex(&oid);
}

int delete_object(struct object_id* oid) {
	const char* hex = oid_to_hex(oid);
	size_t sz = 13 + 2 + 1 + 38 + 1;
	char path[sz];
	memcpy(path, ".git/objects/", 13);
	memcpy(path+13, hex, 2);
	memcpy(path+15, "/", 1);
	memcpy(path+16, hex + 2, 39);
	printf("Commit_path: %s will be deleted\n", path);
	return unlink(path);
}

int refcount_dec_gc(struct commit* cmt) {
	int ret = 0;
	if (!cmt->object.parsed) {
		printf("Commit not parsed\n");
		parse_commit_or_die(cmt);
	}
	const char* cmt_hash = oid_to_hex(&(cmt->object.oid));

	if (dec_ref_count(cmt_hash))
		printf("Error decrementing refcount of commit\
			%s in refcount_gc\n", cmt_hash);
	if (!is_garbage(cmt_hash))
		return 0;

	printf("Getting tree_hash now\n");
	// first work with tree
	if (!cmt->tree->object.parsed) {
		printf("Tree not parsed\n");
		if (parse_tree(cmt->tree)) {
			printf("Error parsing tree\n");
		}
	}
	const char* tree_hash = oid_to_hex(&(cmt->tree->object.oid));

	/*
	if (dec_ref_count(tree_hash))
		printf("Error decrementing refcount of tree
			%s in refcount_gc\n", tree_hash);
	if (!is_garbage(tree_hash))
		return 0;
	*/

	/*
	//first traverse tree
	//parse_pathspec(&pathspec, PATHSPEC_ALL_MAGIC &
	//			  ~(PATHSPEC_FROMTOP | PATHSPEC_LITERAL),
	//	       PATHSPEC_PREFER_CWD,
	//	       NULL, argv + 1);

	// ret = read_tree_recursive(cmt->tree, "", 0, 0, &pathspec,
	//			      tree_gc, NULL);
	if (ret = delete_object(&(cmt->tree->object.oid))) {
		printf("Error when deleting tree in refcount_dec_gc\n");
	}
	*/

	printf("Starting processing parents\n");
	// then traverse parent commits
	for (struct commit_list *l = cmt->parents; l; l = l->next) {
		printf("Going into %s\n", oid_to_hex(&(l->item->object.oid)));
		int retval = refcount_dec_gc(l->item);
		printf("Returning\n");
		if (!ret) ret = retval;
	}
	printf("Done with parents\n");
	//finally delete the given commit
	if ((ret = delete_object(&(cmt->object.oid)))) {
		printf("Error %d when deleting commit in refcount_dec_gc\n", ret);
	}
	return ret;
}
