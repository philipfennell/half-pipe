#!/bin/bash

cp=~/Library/Calabash/lib/calabash.jar:~/Library/Saxon/saxon9.jar:~/Library/Saxon/saxon9-s9api.jar
if [ $# -lt 1  ]
  then
    echo usage "$0 params"
    echo Where params are the calabash parameters
  exit 2

fi

java -Dcom.xmlcalabash.phonehome=false -cp $cp com.xmlcalabash.drivers.Main $*

