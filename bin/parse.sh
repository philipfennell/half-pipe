#!/bin/bash
# XProc Pipeline Parser
java -jar ~/Library/Saxon/saxon9.jar -t -o debug/parsed-pipeline.xpl $1 transforms/xproc-parser.xsl
