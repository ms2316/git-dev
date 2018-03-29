#!/bin/sh
#
# Copyright (c) 2018 Mihails Smolins
#

test_description='reference counting gc

Tests  reference counting garbage collector.'

. ./test-lib.sh

test_expect_success 'testing commit' '
	echo a > a &&
	git add a &&
	git commit -m "single file" &&
	mkdir f &&
	echo fg > f/g &&
	git add f/g &&
	git commit -m "Files a and files f/g" &&
	git branch my_branch &&
	echo b > b &&
	git add b &&
	git commit -m "Added b"
'

test_expect_success 'deleting branch should delete files' '
	GIT_AUTHOR_DATE="2006-06-26 00:00:00 +0000" &&
	GIT_COMMITTER_DATE="2006-06-26 00:00:00 +0000" &&
	export GIT_AUTHOR_DATE GIT_COMMITTER_DATE &&

	git checkout my_branch &&
	echo c > c &&
	git add c &&
	git commit -m "huj commit" &&
	git checkout master &&
	git branch -D my_branch
'

test_done
