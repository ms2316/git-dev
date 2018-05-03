#!/bin/sh
#
# Copyright (c) 2018 Mihails Smolins
#

test_description='reference counting gc

Tests reference counting garbage collector.'

. ./test-lib.sh

test_expect_success 'pre-test setup to keep hashes the same' '
	GIT_AUTHOR_DATE="2006-06-26 00:00:00 +0000" &&
	GIT_COMMITTER_DATE="2006-06-26 00:00:00 +0000" &&
	export GIT_AUTHOR_DATE GIT_COMMITTER_DATE
'

cat >expected <<'EOF'
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
db: 6fcdbdad90e504db3d90303aa3b51cc08b157f6c: key stored with value 1.
db: aaff74984cccd156a469afa7d9ab10e4777beb24: key stored with value 1.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key stored with value 1.
[master (root-commit) 6fcdbda] single file
 Author: A U Thor <author@example.com>
 1 file changed, 1 insertion(+)
 create mode 100644 a
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
db: bdc293343e14e3139ad54be4103148211c3fffc4: key stored with value 1.
db: dcb942478e894aaace77a6c2da89371bb017be37: key stored with value 1.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key retrieved: data was 1.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key stored with value 2.
db: 723e98345297d8490a430e1573ec8a5a8a31e7aa: key stored with value 1.
db: 723e98345297d8490a430e1573ec8a5a8a31e7aa: key retrieved: data was 1.
db: 0da04c786650ad52524a10682d1e566f72b2bc96: key stored with value 1.
[master bdc2933] Files a and files f/g
 Author: A U Thor <author@example.com>
 1 file changed, 1 insertion(+)
 create mode 100644 f/g
db: bdc293343e14e3139ad54be4103148211c3fffc4: key retrieved: data was 1.
db: bdc293343e14e3139ad54be4103148211c3fffc4: key stored with value 2.
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
db: ce9cb5d6a5e7a3eac0b049ff026990e6ac056cb7: key stored with value 1.
db: 60cc63998fff9e04143609b3258f4999b607b831: key stored with value 1.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key retrieved: data was 2.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key stored with value 3.
db: 575742d9762525faedf57a496a793ab39cbe58a7: key stored with value 1.
db: 723e98345297d8490a430e1573ec8a5a8a31e7aa: key retrieved: data was 1.
db: 723e98345297d8490a430e1573ec8a5a8a31e7aa: key stored with value 2.
db: 723e98345297d8490a430e1573ec8a5a8a31e7aa: key retrieved: data was 2.
[my_branch ce9cb5d] Added b
 Author: A U Thor <author@example.com>
 1 file changed, 1 insertion(+)
 create mode 100644 b
db: ce9cb5d6a5e7a3eac0b049ff026990e6ac056cb7: key retrieved: data was 1.
db: ce9cb5d6a5e7a3eac0b049ff026990e6ac056cb7: key stored with value 0.
db: ce9cb5d6a5e7a3eac0b049ff026990e6ac056cb7: key retrieved: data was 0.
db: 60cc63998fff9e04143609b3258f4999b607b831: key retrieved: data was 1.
db: 60cc63998fff9e04143609b3258f4999b607b831: key stored with value 0.
db: 60cc63998fff9e04143609b3258f4999b607b831: key retrieved: data was 0.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key retrieved: data was 3.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key stored with value 2.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key retrieved: data was 2.
db: 575742d9762525faedf57a496a793ab39cbe58a7: key retrieved: data was 1.
db: 575742d9762525faedf57a496a793ab39cbe58a7: key stored with value 0.
db: 575742d9762525faedf57a496a793ab39cbe58a7: key retrieved: data was 0.
Object .git/objects/57/5742d9762525faedf57a496a793ab39cbe58a7 will be deleted
Error deleting object in tree_gc
db: 723e98345297d8490a430e1573ec8a5a8a31e7aa: key retrieved: data was 2.
db: 723e98345297d8490a430e1573ec8a5a8a31e7aa: key stored with value 1.
db: 723e98345297d8490a430e1573ec8a5a8a31e7aa: key retrieved: data was 1.
Object .git/objects/60/cc63998fff9e04143609b3258f4999b607b831 will be deleted
Error when deleting tree in refcount_dec_gc
Starting processing parents
Going into bdc293343e14e3139ad54be4103148211c3fffc4
db: bdc293343e14e3139ad54be4103148211c3fffc4: key retrieved: data was 2.
db: bdc293343e14e3139ad54be4103148211c3fffc4: key stored with value 1.
db: bdc293343e14e3139ad54be4103148211c3fffc4: key retrieved: data was 1.
Returning
Done with parents
Object .git/objects/ce/9cb5d6a5e7a3eac0b049ff026990e6ac056cb7 will be deleted
Error when deleting commit in refcount_dec_gc
Running repack
Deleted branch my_branch (was ce9cb5d).
2905	.git/objects/
* bdc2933 Files a and files f/g
* 6fcdbda single file
EOF
test_expect_success 'testing commit' '
	echo a > a &&
	git add a &&
	git commit -m "single file" 2>&1 | tee -a actual &&
	mkdir f &&
	echo fg > f/g &&
	git add f/g &&
	git commit -m "Files a and files f/g" 2>&1 | tee -a actual &&
	git branch my_branch 2>&1 | tee -a actual &&
	git checkout my_branch &&
	echo "bjhkjfashdlfkhasdjkfhalkshfklahskfhasdfalkshfkahsfklhalksfhlkashflkahsflkhasklfhaklshfashlfkhsakfhasklhfaklhsfk" > b &&
	git add b &&
	git commit -m "Added b" 2>&1 | tee -a actual &&
	git checkout master &&
	git gc &&
	git branch -D my_branch 2>&1 | tee -a actual &&
	gdu -bs .git/objects/ | tee -a actual &&
	git log --graph --oneline --all 2>&1 | tee -a actual &&
	test_cmp expected actual
'

test_done
