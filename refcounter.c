//REFCOUNTER_C

#include "refcounter.h"
#include "cache.h"
#include "commit.h"
#include "ledger.h"
#include "pathspec.h"
#include "run-command.h"
#include "tree.h"
#include "tree-walk.h"

int packed_garbage = 0;

const char* get_hex_hash_by_bname(const char* name) {
	struct object_id oid;
	if (get_oid(name, &oid))
		return NULL;
	return oid_to_hex(&oid);
}

int delete_object(const char *hex) {
	size_t sz = 13 + 2 + 1 + 38 + 1;
	char path[sz];
	memcpy(path, ".git/objects/", 13);
	memcpy(path+13, hex, 2);
	memcpy(path+15, "/", 1);
	memcpy(path+16, hex + 2, 39);
	printf("Object %s will be deleted\n", path);
	return unlink(path);
}

int delete_object_by_id(struct object_id* oid) {
	const char* hex = oid_to_hex(oid);
	return delete_object(hex);
}

int delete_object_by_sha(const unsigned char* sha1) {
	const char* hex = sha1_to_hex(sha1);
	return delete_object(hex);
}

int tree_inc(const unsigned char *sha1, struct strbuf *base,
	     const char *pathname, unsigned mode, int stage, void *context)
{
	const char *hash = sha1_to_hex(sha1);

	if (inc_ref_count(hash)) {
		fprintf(stderr, "Error incrementing refcount of object\
				 with hash %s in tree_gc.\n", hash);
		return -1;
	}

	if (S_ISDIR(mode) && (get_ref_count(hash) == 1))
		return READ_TREE_RECURSIVE;

	return 0;
}

int init_commit_refcount(struct commit *cmt) {
	if (!cmt->object.parsed)
		parse_commit_or_die(cmt);

	inc_ref_count(oid_to_hex(&(cmt->object.oid)));

	if (!cmt->tree->object.parsed) {
		if (parse_tree(cmt->tree))
			fprintf(stderr, "Error parsing tree\n");
	}

	const char* tree_hash = oid_to_hex(&cmt->tree->object.oid);
	if (get_ref_count(tree_hash) > 0)
		return 0;

	if (inc_ref_count(tree_hash))
		fprintf(stderr, "Error incrementing refcount\
				 of toplevel tree %s\n", tree_hash);

	//At this point its clear that the tree is new
	parse_pathspec(&pathspec, PATHSPEC_ALL_MAGIC &
				  ~(PATHSPEC_FROMTOP | PATHSPEC_LITERAL),
		       PATHSPEC_PREFER_CWD,
		       NULL, NULL);
	for (int i = 0; i < pathspec.nr; i++)
		pathspec.items[i].nowildcard_len = pathspec.items[i].len;

	if (read_tree_recursive(cmt->tree, "", 0, 0, &pathspec,
				  tree_inc, NULL)) {
		fprintf(stderr, "Error when reading tree recursively\n");
	}

	return 0;
}

int tree_gc(const unsigned char *sha1, struct strbuf *base,
	    const char *pathname, unsigned mode, int stage, void *context)
{
	const char *hash = sha1_to_hex(sha1);
	if (dec_ref_count(hash)) {
		fprintf(stderr, "Error decrementing refcount of object\
				 with hash %s during refcount GC\n", hash);
	}

	if (!is_garbage(hash))
		return 0;

	// At this point we know that hash is garbage
	if (delete_object_by_sha(sha1)) {
		printf("Error deleting object in tree_gc\n");
		packed_garbage++;
	}

	if (S_ISDIR(mode))
		return READ_TREE_RECURSIVE;

	return 0;
}

int refcount_dec_gc(struct commit* cmt, unsigned int traversal) {
	int ret = 0;

	if (!cmt->object.parsed)
		parse_commit_or_die(cmt);

	const char* cmt_hash = oid_to_hex(&(cmt->object.oid));
	if (dec_ref_count(cmt_hash)) {
		fprintf(stderr, "Error decrementing refcount of commit\
				 %s in refcount_gc\n", cmt_hash);
	}

	if (!is_garbage(cmt_hash))
		return 0;

	// first work with tree
	if (!cmt->tree->object.parsed) {
		if (parse_tree(cmt->tree))
			fprintf(stderr, "Error parsing tree\n");
	}

	const char* tree_hash = oid_to_hex(&(cmt->tree->object.oid));

	if (dec_ref_count(tree_hash))
		fprintf(stderr, "Error decrementing refcount of tree\
				 %s in refcount_gc\n", tree_hash);
	if (is_garbage(tree_hash)) {
		parse_pathspec(&pathspec, PATHSPEC_ALL_MAGIC &
					  ~(PATHSPEC_FROMTOP | PATHSPEC_LITERAL),
			       PATHSPEC_PREFER_CWD,
			       NULL, NULL);
		for (int i = 0; i < pathspec.nr; i++)
			pathspec.items[i].nowildcard_len = pathspec.items[i].len;

		if (read_tree_recursive(cmt->tree, "", 0, 0, &pathspec,
					  tree_gc, NULL)) {
			fprintf(stderr, "Error when reading tree recursively\n");
		}

		if (delete_object_by_id(&(cmt->tree->object.oid))) {
			printf("Error when deleting tree in refcount_dec_gc\n");
			packed_garbage++;
		}
	}

	if (traversal == PROCESS_PARENTS) {
		printf("Starting processing parents\n");
		for (struct commit_list *l = cmt->parents; l; l = l->next) {
			printf("Going into %s\n", oid_to_hex(&(l->item->object.oid)));
			int retval = refcount_dec_gc(l->item, PROCESS_PARENTS);
			printf("Returning\n");
			if (!ret)
				ret = retval;
		}
		printf("Done with parents\n");
	}

	if (delete_object_by_id(&(cmt->object.oid))) {
		printf("Error when deleting commit in refcount_dec_gc\n");
		packed_garbage++;
	}

	return ret;
}

int refcount_gc(struct commit* cmt, unsigned int traversal) {
	int ret = refcount_dec_gc(cmt, traversal);
	if (packed_garbage) {
		printf("Running repack\n");
		const char *args[] = {"repack", "-Ad", NULL};
		if (run_command_v_opt(args, RUN_GIT_CMD))
			printf("Error running repack after refcount_gc\n");

		packed_garbage = 0;
	}
	return ret;
}
