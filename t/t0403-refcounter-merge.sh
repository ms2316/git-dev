#!/bin/sh
#
# Copyright (c) 2018 Mihails Smolins
#

test_description='reference counting gc on merge

Tests reference counting garbage collector when performing merge.'

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
db: 6fcdbdad90e504db3d90303aa3b51cc08b157f6c: key retrieved: data was 1.
db: 6fcdbdad90e504db3d90303aa3b51cc08b157f6c: key stored with value 2.
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
db: 69535ad26b13d9bdc4fdf881ece856216818772f: key stored with value 1.
db: 3683f870be446c7cc05ffaef9fa06415276e1828: key stored with value 1.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key retrieved: data was 1.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key stored with value 2.
db: 61780798228d17af2d34fce4cfbdf35556832472: key stored with value 1.
[master 69535ad] Added b
 Author: A U Thor <author@example.com>
 1 file changed, 1 insertion(+)
 create mode 100644 b
Switched to branch 'feat'
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
db: d8c604cd38369cb7015c8570a75ba999c22e9a8d: key stored with value 1.
db: 3a247983d5372d3d195a08a8905eea1712cb881c: key stored with value 1.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key retrieved: data was 2.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key stored with value 3.
db: f2ad6c76f0115a6ba5b00456a849810e7ec0af20: key stored with value 1.
[feat d8c604c] Added c
 Author: A U Thor <author@example.com>
 1 file changed, 1 insertion(+)
 create mode 100644 c
Switched to branch 'master'
DEBUG: We are in cmd_merge!
Merging:
69535ad Added b
virtual feat
found 1 common ancestor:
6fcdbda single file
Merge made by the 'recursive' strategy.
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
 c | 1 +
 1 file changed, 1 insertion(+)
 create mode 100644 c
db: b832b65ef08ad619f37b3d167d546a3f1a24eeb0: key stored with value 1.
db: 04a59185a0c5f4047e4fd3fa87b0c84e671b00ee: key stored with value 1.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key retrieved: data was 3.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key stored with value 4.
db: 61780798228d17af2d34fce4cfbdf35556832472: key retrieved: data was 1.
db: 61780798228d17af2d34fce4cfbdf35556832472: key stored with value 2.
db: f2ad6c76f0115a6ba5b00456a849810e7ec0af20: key retrieved: data was 1.
db: f2ad6c76f0115a6ba5b00456a849810e7ec0af20: key stored with value 2.
*   b832b65 Merge branch 'feat'
|\  
| * d8c604c Added c
* | 69535ad Added b
|/  
* 6fcdbda single file
EOF
test_expect_success 'merge has to be done' '
	echo a > a &&
	git add a &&
	git commit -m "single file" 2>&1 | tee actual &&
	git branch feat 2>&1 | tee -a actual &&
	echo b > b &&
	git add b &&
	git commit -m "Added b" 2>&1 | tee -a actual  &&
	git checkout feat 2>&1 | tee -a actual &&
	echo c > c &&
	git add c &&
	git commit -m "Added c" 2>&1 | tee -a actual &&
	git checkout master 2>&1 | tee -a actual &&
	git merge feat 2>&1 | tee -a actual &&
	git log --graph --oneline --all 2>&1 | tee -a actual &&
	test_cmp expected actual
'

cat >expected <<'EOF'
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
db: 5538c3833cb860d059b2dd4f7529ecdf156a25f0: key stored with value 1.
db: 1c9a90a034b45886322bbec31d30322998cb33f4: key stored with value 1.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key retrieved: data was 4.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key stored with value 5.
db: 61780798228d17af2d34fce4cfbdf35556832472: key retrieved: data was 2.
db: 61780798228d17af2d34fce4cfbdf35556832472: key stored with value 3.
db: f2ad6c76f0115a6ba5b00456a849810e7ec0af20: key retrieved: data was 2.
db: f2ad6c76f0115a6ba5b00456a849810e7ec0af20: key stored with value 3.
db: d905d9da82c97264ab6f4920e20242e088850ce9: key stored with value 1.
[master 5538c38] Add e
 Author: A U Thor <author@example.com>
 1 file changed, 1 insertion(+)
 create mode 100644 e
db: 5538c3833cb860d059b2dd4f7529ecdf156a25f0: key retrieved: data was 1.
db: 5538c3833cb860d059b2dd4f7529ecdf156a25f0: key stored with value 2.
Switched to branch 'br'
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
db: 5cd28d6fd72d9d605e9cd632b4c3f9ba83d1d76c: key stored with value 1.
db: 5b42b9894c9dda00e0acd0e0422f87bb0d0c0cfe: key stored with value 1.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key retrieved: data was 5.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key stored with value 6.
db: 61780798228d17af2d34fce4cfbdf35556832472: key retrieved: data was 3.
db: 61780798228d17af2d34fce4cfbdf35556832472: key stored with value 4.
db: f2ad6c76f0115a6ba5b00456a849810e7ec0af20: key retrieved: data was 3.
db: f2ad6c76f0115a6ba5b00456a849810e7ec0af20: key stored with value 4.
db: d905d9da82c97264ab6f4920e20242e088850ce9: key retrieved: data was 1.
db: d905d9da82c97264ab6f4920e20242e088850ce9: key stored with value 2.
db: 6a69f92020f5df77af6e8813ff1232493383b708: key stored with value 1.
[br 5cd28d6] Added f
 Author: A U Thor <author@example.com>
 1 file changed, 1 insertion(+)
 create mode 100644 f
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
db: e14516d75b1dc9720c34673ddbdf22c35fd9af8f: key stored with value 1.
db: 1a44725d9ab7b2c70c0d7ba47e298c2c4c934597: key stored with value 1.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key retrieved: data was 6.
db: 78981922613b2afb6025042ff6bd878ac1994e85: key stored with value 7.
db: 61780798228d17af2d34fce4cfbdf35556832472: key retrieved: data was 4.
db: 61780798228d17af2d34fce4cfbdf35556832472: key stored with value 5.
db: f2ad6c76f0115a6ba5b00456a849810e7ec0af20: key retrieved: data was 4.
db: f2ad6c76f0115a6ba5b00456a849810e7ec0af20: key stored with value 5.
db: d905d9da82c97264ab6f4920e20242e088850ce9: key retrieved: data was 2.
db: d905d9da82c97264ab6f4920e20242e088850ce9: key stored with value 3.
db: 6a69f92020f5df77af6e8813ff1232493383b708: key retrieved: data was 1.
db: 6a69f92020f5df77af6e8813ff1232493383b708: key stored with value 2.
db: 01058d844a98d293a3b03a8615a34700e4ed2be3: key stored with value 1.
[br e14516d] Added g
 Author: A U Thor <author@example.com>
 1 file changed, 1 insertion(+)
 create mode 100644 g
Switched to branch 'master'
DEBUG: We are in cmd_merge!
DEBUG: the most common case of merging one remote
Updating 5538c38..e14516d
Fast-forward
 f | 1 +
 g | 1 +
 2 files changed, 2 insertions(+)
 create mode 100644 f
 create mode 100644 g
db: e14516d75b1dc9720c34673ddbdf22c35fd9af8f: key retrieved: data was 1.
db: e14516d75b1dc9720c34673ddbdf22c35fd9af8f: key stored with value 2.
db: 5538c3833cb860d059b2dd4f7529ecdf156a25f0: key retrieved: data was 2.
db: 5538c3833cb860d059b2dd4f7529ecdf156a25f0: key stored with value 1.
* e14516d Added g
* 5cd28d6 Added f
* 5538c38 Add e
*   b832b65 Merge branch 'feat'
|\  
| * d8c604c Added c
* | 69535ad Added b
|/  
* 6fcdbda single file
EOF
test_expect_success 'most common case of merging one remote' '
	echo e > e &&
	git add e &&
	git commit -m "Add e" 2>&1 | tee actual &&
	git branch br 2>&1 | tee -a actual &&
	git checkout br 2>&1 | tee -a actual &&
	echo f > f &&
	git add f &&
	git commit -m "Added f" 2>&1 | tee -a actual &&
	echo g > g &&
	git add g &&
	git commit -m "Added g" 2>&1 | tee -a actual &&
	git checkout master 2>&1 | tee -a actual &&
	git merge br  2>&1 | tee -a actual &&
	git log --graph --oneline --all 2>&1 | tee -a actual &&
	test_cmp expected actual
'

test_done
