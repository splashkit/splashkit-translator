#!/bin/sh
echo "Generate adapter"
../../translate --ide --verbose --generate clib,cpp -i warnings.h --output ../out
