#! /bin/bash
echo "Input-file format must like below(one ticket id in a row):
  ...
  172336
  172713
  172782
  172343
  172345
  172346
  172348
  ...

  If input-file format isn't the same as the above format,this shell programm co
uldn't work correctly.
  And,output-file format list tickets in a row ,eight tickets per line.
  Lastly,the output-file is created at the same path with the shell programm.

   "

if [ $# -ne 1 ];
then
 echo "one argument expected.";
 exit -1;
fi

filename="$1"
filename1=`echo $1.output`
if [ -e "$filename" ]
then
  echo $filename
else
  echo "file $filename not found";
  exit -1;
fi

if [ -e "$filename1" ]
then
  rm $filename1
fi
touch $filename1
filelist="";
count="0" ;
cnt=`wc -l $filename  | awk '{print $1}'`
#cnt=14
cnt1=0
echo "number of row is $cnt"
cat $filename | while read myline
do
 if [ "$count" -eq 0 ]
 then
 filelist=`echo "${myline}"`
 else
 filelist=`echo "${filelist},${myline}"`
 fi
 count=$(($count+1))
 cnt1=$(($cnt1+1))
# echo $count
# echo $filelist
# echo $cnt1
 if [ "$count" -eq 8 ]
 then
 echo $filelist >>${filename1}
 filelist="";
 count="0";
 fi
 if [ "$cnt" -eq "$cnt1" ]
 then
 echo $filelist >>${filename1}
 fi
done
echo "Well done."

exit 0;
