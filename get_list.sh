#!/bin/bash

cat ${1} | cut -d"," -f2 | tr "\r\n" ","
