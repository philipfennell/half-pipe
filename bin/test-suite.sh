#!/bin/bash
# XProc Test Suite Runner
java -jar ~/Library/Saxon/saxon9.jar -t -o tests/results/half-pipe.xml tests/test-suite.xml transforms/xproc-test-suite.xsl MODE=$2