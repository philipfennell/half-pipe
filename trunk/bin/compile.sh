#!/bin/bash
# XProc Pipeline Compiler
java -jar lib/saxon9.jar -t -o debug/compiled-pipeline.xsl $1 transforms/xproc-compiler.xsl MODE=$2