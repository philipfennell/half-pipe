#!/bin/bash
# Basic XST transformer script
java -jar lib/saxon9.jar -t -o $1 $2 $3 $4
