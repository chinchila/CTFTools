#!/bin/bash

function extract(){
	unzip $1 -d ${1/.zip/} && eval $2 && cd ${1/.zip/}
	for zip in `find . -maxdepth 1 -iname *.zip`; do
		extract $zip 'rm $1'
	done
}

extract $1
