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
db: 4eb81ce8ca7c867d8631dcdafb5b325c800f989f: key stored with value 1.
db: 0153c1977fc91ac6d43b80ba0df3e5618a22df79: key stored with value 1.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key retrieved: data was 2.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key stored with value 3.
db: 61780798228d17af2d34fce4cfbdf35556832472: key stored with value 1.
db: 723e98345297d8490a430e1573ec8a5a8a31e7aa: key retrieved: data was 1.
db: 723e98345297d8490a430e1573ec8a5a8a31e7aa: key stored with value 2.
db: 723e98345297d8490a430e1573ec8a5a8a31e7aa: key retrieved: data was 2.
[master 4eb81ce] Added b
 Author: A U Thor <author@example.com>
 1 file changed, 1 insertion(+)
 create mode 100644 b
* 4eb81ce Added b
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
	echo b > b &&
	git add b &&
	git commit -m "Added b" 2>&1 | tee -a actual &&
	git log --graph --oneline --all 2>&1 | tee -a actual &&
	test_cmp expected actual
'

cat >expected <<'EOF'
Switched to branch 'my_branch'
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
db: cc3aa628e96b9bd527f60c45d691b18e0af056f1: key stored with value 1.
db: 47bf70748a31292989efe096f883f849a1b74c66: key stored with value 1.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key retrieved: data was 3.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key stored with value 4.
db: f2ad6c76f0115a6ba5b00456a849810e7ec0af20: key stored with value 1.
db: 723e98345297d8490a430e1573ec8a5a8a31e7aa: key retrieved: data was 2.
db: 723e98345297d8490a430e1573ec8a5a8a31e7aa: key stored with value 3.
db: 723e98345297d8490a430e1573ec8a5a8a31e7aa: key retrieved: data was 3.
[my_branch cc3aa62] another commit
 Author: A U Thor <author@example.com>
 1 file changed, 1 insertion(+)
 create mode 100644 c
Switched to branch 'master'
db: cc3aa628e96b9bd527f60c45d691b18e0af056f1: key retrieved: data was 1.
db: cc3aa628e96b9bd527f60c45d691b18e0af056f1: key stored with value 0.
db: cc3aa628e96b9bd527f60c45d691b18e0af056f1: key retrieved: data was 0.
db: 47bf70748a31292989efe096f883f849a1b74c66: key retrieved: data was 1.
db: 47bf70748a31292989efe096f883f849a1b74c66: key stored with value 0.
db: 47bf70748a31292989efe096f883f849a1b74c66: key retrieved: data was 0.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key retrieved: data was 4.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key stored with value 3.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key retrieved: data was 3.
db: f2ad6c76f0115a6ba5b00456a849810e7ec0af20: key retrieved: data was 1.
db: f2ad6c76f0115a6ba5b00456a849810e7ec0af20: key stored with value 0.
db: f2ad6c76f0115a6ba5b00456a849810e7ec0af20: key retrieved: data was 0.
Object .git/objects/f2/ad6c76f0115a6ba5b00456a849810e7ec0af20 will be deleted
db: 723e98345297d8490a430e1573ec8a5a8a31e7aa: key retrieved: data was 3.
db: 723e98345297d8490a430e1573ec8a5a8a31e7aa: key stored with value 2.
db: 723e98345297d8490a430e1573ec8a5a8a31e7aa: key retrieved: data was 2.
Object .git/objects/47/bf70748a31292989efe096f883f849a1b74c66 will be deleted
Starting processing parents
Going into bdc293343e14e3139ad54be4103148211c3fffc4
db: bdc293343e14e3139ad54be4103148211c3fffc4: key retrieved: data was 2.
db: bdc293343e14e3139ad54be4103148211c3fffc4: key stored with value 1.
db: bdc293343e14e3139ad54be4103148211c3fffc4: key retrieved: data was 1.
Returning
Done with parents
Object .git/objects/cc/3aa628e96b9bd527f60c45d691b18e0af056f1 will be deleted
Deleted branch my_branch (was cc3aa62).
* 4eb81ce Added b
* bdc2933 Files a and files f/g
* 6fcdbda single file
EOF
test_expect_success 'deleting branch should delete files' '
	git checkout my_branch 2>&1 | tee actual &&
	echo c > c &&
	git add c &&
	git commit -m "another commit" 2>&1 | tee -a actual &&
	git checkout master 2>&1 | tee -a actual &&
	git branch -D my_branch 2>&1 | tee -a actual &&
	git log --graph --oneline --all 2>&1 | tee -a actual &&
	test_cmp expected actual && rm actual expected
'

test_done
