// LEDGER_C

#include "ledger.h"

//Default ledger DB name
const char* DB_name = ".git/ledger";

/*
 * Close DB
 * Returns error(non-zero) if DB close failed
 */
int close_database(DB *dbp) {
	int ret;

	if (dbp && ((ret = dbp->close(dbp, 0)) != 0)) {
		fprintf(stderr, "Database close failed: %s\n", db_strerror(ret));
		return ret;
	}

	return 0;
}

/*
 * Opens the DB and initializes dbp
 * Returns error(non-zero) in case of DB related issues
 */
int open_database(DB **dbpp) {

	DB *dbp;
	u_int32_t open_flags;
	int ret;

	/* Initialize the DB handle */
	if ((ret = db_create(&dbp, NULL, 0)) != 0) {
		fprintf(stderr, "db_create: %s\n", db_strerror(ret));
		return ret;
	}

	/* Point to the memory malloc'd by db_create() */
	*dbpp = dbp;

	/* Set the open flags */
	open_flags = DB_CREATE;

	/* Now open the database */
	ret = dbp->open(dbp,        /* Pointer to the database */
			NULL,       /* Txn pointer */
			DB_name,    /* DB name */
			NULL,       /* Logical db name (unneeded) */
			DB_HASH,    /* Database type (using hashtable) */
			open_flags, /* Open flags */
			0);         /* File mode. Using defaults */

	if (ret) {
		dbp->err(dbp, ret, "Database '%s' open failed", DB_name);
		close_database(dbp);
		return ret;
	}

	return 0;
}

/*
 *  Add (_key, count) pair to DB
 *  Non-zero is returned in case of an error
 */
int add_to_db_overwriting(const char* _key, int count) {
	DB *dbp;
	DBT key, data;
	int ret;

	if ((ret = open_database(&dbp)) != 0) {
		return ret;
	}

	memset(&key, 0, sizeof(key));
	memset(&data, 0, sizeof(data));

	key.data = (char*)_key;
	key.size = sizeof(char)*strlen(_key);
	data.data = &count;
	data.size = sizeof(int);

	if ((ret = dbp->put(dbp, NULL, &key, &data, 0)) == 0)
		printf("db: %s: key stored with value %d.\n", (char *)key.data, count);
	else {
		dbp->err(dbp, ret, "DB->put");
	}

	close_database(dbp);
	return ret;
}

const int get_ref_count(const char* _key) {
	DB *dbp;
	DBT key, data;
	int ret;
	int count = -1;

	if ((ret = open_database(&dbp)) != 0) {
		return -1;
	}

	memset(&key, 0, sizeof(key));
	memset(&data, 0, sizeof(data));

	key.data = (char*)_key;
	key.size = sizeof(char)*strlen(_key);
	data.data = &count;
	data.size = sizeof(int);

	if ((ret = dbp->get(dbp, NULL, &key, &data, 0)) == 0) {
		int *tmp = (int*)data.data;
		count = *tmp;
		printf("db: %s: key retrieved: data was %d.\n",
				(char *)key.data, count );
	} else {
		dbp->err(dbp, ret, "DB->get");
		count = 0;
	}

	close_database(dbp);
	return count;
}

int is_garbage(const char* _key) {
	return !get_ref_count(_key);
}

int inc_ref_count(const char* _key) {

	int count = get_ref_count(_key);
	// check if the key exists at all
	if (count < 0) count = 0;

	return add_to_db_overwriting(_key, count + 1);
}

int dec_ref_count(const char* _key) {

	int count = get_ref_count(_key);

	if (count == 0) {
		printf("Semantic Error: The refcount is already zero and can't\
			be negative\n");
		return -1;
	}
	if (count < 0) {
		printf("Semantic Error: Trying to decrement refcount\
			of a key not in DB\n");
		return -1;
	}

	return add_to_db_overwriting(_key, count - 1);
}
