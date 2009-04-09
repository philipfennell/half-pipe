#!/bin/bash
# XProc Test Suite: Individual Test Runner
java -jar lib/saxon9.jar -t -o tests/results/test.xml tests/required/$1.xml transforms/xproc-tester.xsl MODE=$2