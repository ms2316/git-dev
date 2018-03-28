#!/bin/sh
#
# Copyright (c) 2018 Mihails Smolins
#

test_description='reference counting gc

Tests  reference counting garbage collector.'

. ./test-lib.sh

test_expect_success 'testing' '
	echo e > e &&
	git add e &&
	git commit -m "just a test"
'

test_expect_success 'deleting branch should delete files' '
	GIT_AUTHOR_DATE="2006-06-26 00:00:00 +0000" &&
	GIT_COMMITTER_DATE="2006-06-26 00:00:00 +0000" &&
	export GIT_AUTHOR_DATE GIT_COMMITTER_DATE &&

	echo a > a &&
	git add a &&
	git commit -m "first master" &&
	git branch huj &&
	echo b > b &&
	git add b &&
	git commit -m "second master" &&
	git checkout huj &&
	echo c > c &&
	git add c &&
	git commit -m "huj commit" &&
	echo d > d &&
	git add d &&
	git commit -m "hhh" &&
	git checkout master &&
	git branch -D huj
'

test_done
