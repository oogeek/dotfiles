#!/bin/bash
pandoc -o custom-reference.odt --print-default-data-file reference.odt
name=${1%.md}
pandoc -t odt "$1" --reference-doc=custom-reference.odt -o "$name.odt"
