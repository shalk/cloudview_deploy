#!/bin/bash

if [ $# -ne 1 ]
then
echo "please enter the cloudview directory fullpath 
like:
 sh $0 /public/sourcecode/cloudview1.5.1.20130717/ 
"
echo "Then  modify  the file :  hosts "
exit 1
fi

ln -s  $1   cloudview
echo "cloudview is linked in  current directory"
echo "Then  modify  the file :  hosts "



