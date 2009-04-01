#!/bin/bash

java -jar ~/Library/Saxon/saxon9.jar -t -o tests/results/test.xml tests/required/$1.xml transforms/xproc-tester.xsl MODE=debug
