#!/bin/sh
#
# Copyright (c) 2018 Mihails Smolins
#

test_description='reference counting gc on amend

Tests reference counting garbage collector when performing amend.'

. ./test-lib.sh

test_expect_success 'pre-test setup to have the same hashes' '
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
db: 6fcdbdad90e504db3d90303aa3b51cc08b157f6c: key retrieved: data was 1.
db: 6fcdbdad90e504db3d90303aa3b51cc08b157f6c: key stored with value 2.
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
db: 6a7ac14bf42028ffb3491e41375e5fa48209b1ce: key stored with value 1.
db: 3683f870be446c7cc05ffaef9fa06415276e1828: key stored with value 1.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key retrieved: data was 1.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key stored with value 2.
db: 61780798228d17af2d34fce4cfbdf35556832472: key stored with value 1.
[master 6a7ac14] Added b
 Author: A U Thor <author@example.com>
 Date: Mon Jun 26 00:00:00 2006 +0000
 2 files changed, 2 insertions(+)
 create mode 100644 a
 create mode 100644 b
db: 6fcdbdad90e504db3d90303aa3b51cc08b157f6c: key retrieved: data was 2.
db: 6fcdbdad90e504db3d90303aa3b51cc08b157f6c: key stored with value 1.
db: 6fcdbdad90e504db3d90303aa3b51cc08b157f6c: key retrieved: data was 1.
* 6fcdbda single file
* 6a7ac14 Added b
EOF
test_expect_success 'amended commit must not be deleted' '
	echo a > a &&
	git add a &&
	git commit -m "single file" 2>&1 | tee actual &&
	git branch feat 2>&1 | tee -a actual &&
	echo b > b &&
	git add b &&
	git commit --amend -m "Added b" 2>&1 | tee -a actual &&
	git log --graph --oneline --all 2>&1 | tee -a actual &&
	test_cmp expected actual
'

cat >expected <<'EOF'
db: 6fcdbdad90e504db3d90303aa3b51cc08b157f6c: key retrieved: data was 1.
db: 6fcdbdad90e504db3d90303aa3b51cc08b157f6c: key stored with value 0.
db: 6fcdbdad90e504db3d90303aa3b51cc08b157f6c: key retrieved: data was 0.
db: aaff74984cccd156a469afa7d9ab10e4777beb24: key retrieved: data was 1.
db: aaff74984cccd156a469afa7d9ab10e4777beb24: key stored with value 0.
db: aaff74984cccd156a469afa7d9ab10e4777beb24: key retrieved: data was 0.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key retrieved: data was 2.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key stored with value 1.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key retrieved: data was 1.
Object .git/objects/aa/ff74984cccd156a469afa7d9ab10e4777beb24 will be deleted
Starting processing parents
Done with parents
Object .git/objects/6f/cdbdad90e504db3d90303aa3b51cc08b157f6c will be deleted
Deleted branch feat (was 6fcdbda).
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
db: 708c0a8e1c9c3b91037947484b2a96286592c01e: key stored with value 1.
db: 04a59185a0c5f4047e4fd3fa87b0c84e671b00ee: key stored with value 1.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key retrieved: data was 1.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key stored with value 2.
db: 61780798228d17af2d34fce4cfbdf35556832472: key retrieved: data was 1.
db: 61780798228d17af2d34fce4cfbdf35556832472: key stored with value 2.
db: f2ad6c76f0115a6ba5b00456a849810e7ec0af20: key stored with value 1.
[master 708c0a8] ccc
 Author: A U Thor <author@example.com>
 Date: Mon Jun 26 00:00:00 2006 +0000
 3 files changed, 3 insertions(+)
 create mode 100644 a
 create mode 100644 b
 create mode 100644 c
db: 6a7ac14bf42028ffb3491e41375e5fa48209b1ce: key retrieved: data was 1.
db: 6a7ac14bf42028ffb3491e41375e5fa48209b1ce: key stored with value 0.
db: 6a7ac14bf42028ffb3491e41375e5fa48209b1ce: key retrieved: data was 0.
db: 3683f870be446c7cc05ffaef9fa06415276e1828: key retrieved: data was 1.
db: 3683f870be446c7cc05ffaef9fa06415276e1828: key stored with value 0.
db: 3683f870be446c7cc05ffaef9fa06415276e1828: key retrieved: data was 0.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key retrieved: data was 2.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key stored with value 1.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key retrieved: data was 1.
db: 61780798228d17af2d34fce4cfbdf35556832472: key retrieved: data was 2.
db: 61780798228d17af2d34fce4cfbdf35556832472: key stored with value 1.
db: 61780798228d17af2d34fce4cfbdf35556832472: key retrieved: data was 1.
Object .git/objects/36/83f870be446c7cc05ffaef9fa06415276e1828 will be deleted
Object .git/objects/6a/7ac14bf42028ffb3491e41375e5fa48209b1ce will be deleted
* 708c0a8 ccc
EOF
test_expect_success 'amended commit must be deleted' '
	git branch -D feat 2>&1 | tee actual &&
	echo c > c &&
	git add c &&
	git commit --amend -m "ccc" 2>&1 | tee -a actual &&
	git log --graph --oneline --all 2>&1 | tee -a actual &&
	test_cmp expected actual
'

test_done
