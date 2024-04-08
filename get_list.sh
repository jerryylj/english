#!/bin/bash

if [ -z "${1}" ]; then
    echo "input file"
    exit 1
fi

cat ${1} | cut -d"," -f2 | tr "\r\n" "," > ./list.txt
