#!/bin/bash

cp=$LIBRARY/commons-httpclient-3.1/commons-httpclient-3.1.jar:$LIBRARY/commons-logging-1.1.1/commons-logging-1.1.1.jar:$LIBRARY/commons-codec-1.3/commons-codec-1.3.jar:$LIBRARY/Calabash/lib/calabash.jar:$LIBRARY/Saxon/saxon9.jar:$LIBRARY/Saxon/saxon9-s9api.jar
if [ $# -lt 1  ]
  then
    echo usage "$0 params"
    echo Where params are the calabash parameters
  exit 2

fi

java -Xmx1024m -Dcom.xmlcalabash.phonehome=false -cp $cp com.xmlcalabash.drivers.Main $*
