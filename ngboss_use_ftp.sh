#! /usr/bin/ksh

export ORACLE_BASE=/oracle/app/oracle
export ORACLE_HOME=/oracle/app/oracle/product/9.2.0
export ADMIN_HOME=/oracle/app/oracle/admin
userpwd=`/home/boss/bin/aicbs_bin/getDatabase -i /home/boss/config/aicbs_config/getCrontab_boss.cfg` 
#userpwd=aicbs/shyz4567@zwbcv3

if [ -z "$userpwd" ]
then
 echo "�������ݿ�ʧ��..." >>${log_file}
 exit -1
fi

# �ʹ�ǰ��̨ͨ��FTP�ļ��ӿڷ�ʽ��������ͨ�ýű�
# �ýű�������� aicbs.ngboss_ftp_cfg���ʹ�� ,Ҳ���Զ�̬�Ĵ������
# �ýű����û���ʽ���Ϊ: ngboss_use_ftp.sh busi_id(ҵ�����) filename.txt(�ļ���) 
# �ýű������з�ʽ���Ϊ: ngboss_use_ftp.sh 0(ҵ�����) ip��ַ �û��� ���� FTPĿ¼ �ļ��� FTP��ʽ ����Ŀ¼ 

StartTime=`date +%Y%m%d%H%M%S`
StartDate=`date +%Y%m%d`
log_file=/log/aicbs_log/ngboss_use_ftp_${StartDate}.log
echo "busi_id:$1,filename:$2 $StartTime BEGIN" >> ${log_file}


dealFileFromFtp()
{
   # $1: FTP��ַ
   # $2: FTP��¼��
   # $3: FTP����
   # $4: FTP�ϵ�ȫ·��
   # $5: �ļ���
   # $6: 0:get�ļ� 1:put�ļ� 2:delete�ļ�
   # $7: �ļ�·��
   echo "FTP��ַ: $1"
   echo "FTP�ϵ�ȫ·�� : $4"
   echo "�ļ��� : $5"
   echo "(0:get�ļ� 1:put�ļ� 2:delete�ļ�) : $6"
   
   
   F="ftp.tmp" 
   echo "open $1"                                       >  $F 
   echo "user $2 $3"                                    >> $F 
   echo "cd $4"                                         >> $F 
   echo "ascii"                                         >> $F 
   echo "prompt off"                                    >> $F
   if [ "$6" -eq "0" ];then
   echo "mget $5"                                       >> $F
   elif [ "$6" -eq "1" ]; then
   echo "mput $5"                                       >> $F 
   elif [ "$6" -eq "2" ]; then
   echo "mdelete $5 "                                   >> $F
   fi
   echo "bye"                                           >> $F 
   ftp -i -in < $F  
   rm -rf $F
}
 
if [ $# -le 1 ] 
then
	echo "ȱ�ٲ�����aicbs.ngboss_ftp_cfg.busi_id(ҵ�����) �� �ļ���";
	echo "���磺ngboss_use_ftp.sh 1 filename.txt";
	exit -1;	
fi

line=`sqlplus ${userpwd} <<! |grep newline | awk -F  '=' '{print $2}'   
SELECT 'newline='||busi_id||'|'||ip_address||'|'||ftp_name||'|'||ftp_psd||'|'||file_address||'|'||ext1||'|'||ext2
 from aicbs.ngboss_ftp_cfg
 where busi_id =$1 ;
exit;
!`
 
if [ "$1" -eq "0" ]; then
echo "��ִ̬��FTP����>>>>>">>${log_file}
echo "busi_id = $1">>${log_file}
echo "ip��ַ = $2">>${log_file}
echo "�û��� = $3">>${log_file}
echo "���� = $4">>${log_file}
echo "FTPĿ¼ = $5">>${log_file}
echo "�ļ��� = $6">>${log_file}
echo "FTP��ʽ = $7">>${log_file}
echo "����Ŀ¼ = $8">>${log_file}
cd $8   #cd ����Ŀ¼
dealFileFromFtp  $2 $3 $4 $5 $6 $7;
else
echo "���û�ִ��FTP����>>>>>">>${log_file}

 echo $line >>${log_file}
 busi_id=`echo ${line}|awk -F '|' '{print $1}'` 
 ip_address=`echo ${line}|awk -F '|' '{print $2}'`
 ftp_name=`echo ${line}|awk -F '|' '{print $3}'`
 ftp_psd=`echo ${line}|awk -F '|' '{print $4}'`
 file_address=`echo ${line}|awk -F '|' '{print $5}'`
 method=`echo ${line}|awk -F '|' '{print $6}'`
 local_address=`echo ${line}|awk -F '|' '{print $7}'`
 
 echo $busi_id >>${log_file}
 echo $ip_address >>${log_file}
 echo $ftp_name >>${log_file}
 echo $ftp_psd >>${log_file}
 echo $file_address >>${log_file}
 echo $method >>${log_file}
 echo $local_address >>${log_file}

   #if [ test -z "$busi_id" or test -z "$ip_address" or test -z "$ftp_name" or test -z "$ftp_psd" or test -z "$file_address" or test -z "$method" ]
 if [ -z "$busi_id" or -z "$ip_address" or -z "$ftp_name" or -z "$ftp_psd" or -z "$file_address" or -z "$method" or -z "$local_address" ]
 then
  echo "ȱ�ٱ�Ҫ����,����aicbs.ngboss_ftp_cfg.busi_id=$1������" >>${log_file}
	echo "һ�����,busi_id,ip_address,ftp_name,ftp_psd,file_address,ext1,ext2���Ǳ�Ҫ����" >>${log_file}
	exit -1;	
 fi
cd $local_address   #cd ����Ŀ¼
dealFileFromFtp  $ip_address $ftp_name $ftp_psd $file_address $2 $method;
fi

  if [ $? -eq 0 ]; then
  echo "FTP�����ɹ�..." >>${log_file}
  return 0
  else
  echo "FTP����ʧ��..." >>${log_file}
  return -1
  fi
  

vStopTime=`date +%Y%m%d%H%M%S`
export vStopTime
echo "### End   $vStopTime ###" >> ${log_file}

echo "�ű�ִ����ϣ�"
exit 0
