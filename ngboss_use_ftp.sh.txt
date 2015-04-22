#! /usr/bin/ksh

export ORACLE_BASE=/oracle/app/oracle
export ORACLE_HOME=/oracle/app/oracle/product/9.2.0
export ADMIN_HOME=/oracle/app/oracle/admin
userpwd=`/home/boss/bin/aicbs_bin/getDatabase -i /home/boss/config/aicbs_config/getCrontab_boss.cfg` 
#userpwd=aicbs/shyz4567@zwbcv3

if [ -z "$userpwd" ]
then
 echo "连接数据库失败..." >>${log_file}
 exit -1
fi

# 帐管前后台通过FTP文件接口方式传输数据通用脚本
# 该脚本与帐务库 aicbs.ngboss_ftp_cfg配合使用 ,也可以动态的传入参数
# 该脚本配置化方式入参为: ngboss_use_ftp.sh busi_id(业务代号) filename.txt(文件名) 
# 该脚本命令行方式入参为: ngboss_use_ftp.sh 0(业务代号) ip地址 用户名 密码 FTP目录 文件名 FTP方式 本地目录 

StartTime=`date +%Y%m%d%H%M%S`
StartDate=`date +%Y%m%d`
log_file=/log/aicbs_log/ngboss_use_ftp_${StartDate}.log
echo "busi_id:$1,filename:$2 $StartTime BEGIN" >> ${log_file}


dealFileFromFtp()
{
   # $1: FTP地址
   # $2: FTP登录名
   # $3: FTP密码
   # $4: FTP上的全路径
   # $5: 文件名
   # $6: 0:get文件 1:put文件 2:delete文件
   # $7: 文件路径
   echo "FTP地址: $1"
   echo "FTP上的全路径 : $4"
   echo "文件名 : $5"
   echo "(0:get文件 1:put文件 2:delete文件) : $6"
   
   
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
	echo "缺少参数：aicbs.ngboss_ftp_cfg.busi_id(业务代号) 或 文件名";
	echo "例如：ngboss_use_ftp.sh 1 filename.txt";
	exit -1;	
fi

line=`sqlplus ${userpwd} <<! |grep newline | awk -F  '=' '{print $2}'   
SELECT 'newline='||busi_id||'|'||ip_address||'|'||ftp_name||'|'||ftp_psd||'|'||file_address||'|'||ext1||'|'||ext2
 from aicbs.ngboss_ftp_cfg
 where busi_id =$1 ;
exit;
!`
 
if [ "$1" -eq "0" ]; then
echo "动态执行FTP命令>>>>>">>${log_file}
echo "busi_id = $1">>${log_file}
echo "ip地址 = $2">>${log_file}
echo "用户名 = $3">>${log_file}
echo "密码 = $4">>${log_file}
echo "FTP目录 = $5">>${log_file}
echo "文件名 = $6">>${log_file}
echo "FTP方式 = $7">>${log_file}
echo "本地目录 = $8">>${log_file}
cd $8   #cd 本地目录
dealFileFromFtp  $2 $3 $4 $5 $6 $7;
else
echo "配置化执行FTP命令>>>>>">>${log_file}

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
  echo "缺少必要参数,请检查aicbs.ngboss_ftp_cfg.busi_id=$1的配置" >>${log_file}
	echo "一般情况,busi_id,ip_address,ftp_name,ftp_psd,file_address,ext1,ext2都是必要参数" >>${log_file}
	exit -1;	
 fi
cd $local_address   #cd 本地目录
dealFileFromFtp  $ip_address $ftp_name $ftp_psd $file_address $2 $method;
fi

  if [ $? -eq 0 ]; then
  echo "FTP操作成功..." >>${log_file}
  return 0
  else
  echo "FTP操作失败..." >>${log_file}
  return -1
  fi
  

vStopTime=`date +%Y%m%d%H%M%S`
export vStopTime
echo "### End   $vStopTime ###" >> ${log_file}

echo "脚本执行完毕！"
exit 0
