#!/bin/sh
#
# Copyright (c) 2018 Mihails Smolins
#

test_description='reference counting gc on amend

Tests reference counting garbage collector when performing amend.'

. ./test-lib.sh

test_expect_success 'amended commit must not be deleted' '
	GIT_AUTHOR_DATE="2006-06-26 00:00:00 +0000" &&
	GIT_COMMITTER_DATE="2006-06-26 00:00:00 +0000" &&
	export GIT_AUTHOR_DATE GIT_COMMITTER_DATE &&

	echo a > a &&
	git add a &&
	git commit -m "single file" &&
	git branch feat &&
	echo b > b &&
	git add b &&
	git commit --amend -m "Added b"
	> DB->get: BDB0073 DB_NOTFOUND: No matching key/data pair found
'

test_expect_success 'amended commit must be deleted' '
	git branch -D feat &&
	echo c > c &&
	git add c &&
	git commit --amend -m "ccc"
'

test_done
