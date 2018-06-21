#!/bin/bash
echo "$(date) - starting ..."

usernamefile="newusername.txt"
scriptfile1="createUsersAll.sh"
templatefile="template_createUser.cls"
userfilebase="_createSingleUser.cls"
tempfile="tempuser.tmp"
if [ -f  ${scriptfile1} ]
then
    rm  ${scriptfile1}
    echo "deleted ${scriptfile1}"
fi
delfile="*${userfilebase}"
echo deleted ${delfile}
rm ${delfile}

echo deleted ${tempfile}
rm ${tempfile}

if [ "$1" == "" ]; then
    echo "cleaned up temp files, but missing file to work on... usage: \" $0 filename\""
    exit 1
fi

echo "using as data file $1" 
cat newUsernames.txt  | sed -E "s/ /-/g" > ${tempfile}

echo "SFDCUSernames:" ${SFDCUSernames}

# SFDCUSernames=($(awk -F '#' '{print $1}' raw2.txt))
SFDCUSernames=($(awk -F'\\'  '{print $0}' ${tempfile}))

for u in "${SFDCUSernames[@]}"
do
   echo user is: ">$u<"
   cat ${templatefile} | sed -E "s/##Input##/${u}/"   > ${u}${userfilebase}
   echo ${u}${userfilebase}
   echo "echo \"${u}${userfilebase}\" " >> ${scriptfile1}
   echo "force apex ${u}${userfilebase}| grep USER_DEBUG" >> ${scriptfile1}
   #cat ${u}${userfilebase}
   echo "----"
done
echo "echo \" now done with ${scriptfile1} \" "  >> ${scriptfile1}
# exit 1

chmod u+x ${scriptfile1}
s=./${scriptfile1}
echo "$(date) - running now ${s}"
source ${s}
echo "$(date) - finished all ${s}"

