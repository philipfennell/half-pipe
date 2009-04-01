#!/bin/bash

java -jar ~/Library/Saxon/saxon9.jar -t -o debug/compiled-pipeline.xsl $1 transforms/xproc-compiler.xsl MODE=debug
