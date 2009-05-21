#!/bin/sh

# Run from vimfiles directory
cd .. && (
if [ -e dist/mktypes_binary.zip ]
then
	rm dist/mktypes_binary.zip
fi
zip -r dist/mktypes_binary.zip extra_source/mktypes/dist/*)
