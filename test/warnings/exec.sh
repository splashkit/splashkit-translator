#!/bin/sh
echo "Generate adapter"
../../translate --verbose --generate clib,cpp -i warnings.h --output ../out
