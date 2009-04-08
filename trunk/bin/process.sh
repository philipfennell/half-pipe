#!/bin/bash
# XProc Processor
java -jar ~/Library/Saxon/saxon9.jar -t -o results/output.xml $1 transforms/half-pipe.xsl MODE=$2