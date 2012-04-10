#!/bin/bash

BBUSER=abudden
BBPROJ=taghighlight
GHUSER=abudden
GHPROJ=TagHighlight

BITBUCKET=ssh://hg@bitbucket.org/${BBUSER}/${BBPROJ}
GITHUB=git+ssh://git@github.com:${GHUSER}/${GHPROJ}.git

hg push $BITBUCKET
# Only fail on error, not on "no changes to push"
if [ $? -gt 1 ]
then
	exit 255
fi

hg push $GITHUB
# Only fail on error, not on "no changes to push"
if [ $? -gt 1 ]
then
	exit 255
fi
