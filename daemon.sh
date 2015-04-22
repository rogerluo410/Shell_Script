#daemon process
#!/bin/bash
cur_day=`date`
log="/home/luo/DaysOff/log/daemon.log"
echo "--------------------------------------"
echo "[${cur_day}]Daemon process start.">>${log}
sleep_time=300
nodejs_address="/home/luo/DaysOff"
ruby_address="/home/luo/DaysOff/ad_proxy"
exec_nodejs="node app.js"
exec_ruby_daemon="ruby active_dir_server.rb"
#kill process first
pgrep -f "${exec_nodejs}" | awk '{print "kill " $1 }' |sh
pgrep -f "${exec_ruby_daemon}" | awk '{print "kill " $1}' |sh

#Check
if test $(pgrep -f "${exec_nodejs}" | wc -l ) -eq 0
then
echo "[`date`]Get ready to start app.js." >>${log}
  cd $nodejs_address
  ${exec_nodejs}&
fi

if test $(pgrep -f "${exec_ruby_daemon}" | wc -l ) -eq 0
then
echo "[`date`]Get ready to start AD proxy server." >>${log}
  cd $ruby_address
  ${exec_ruby_daemon}&
fi

#Check process is running or not
while [ 1 ]
do
if test $(pgrep -f "${exec_nodejs}" | wc -l ) -eq 0
then
  echo "[`date`]node app.js is not run." >>${log}
  cd $nodejs_address
  ${exec_nodejs}&
  echo "[`date`]node app.js is running." >>${log}
else
  echo "[`date`]node app.js has already running." >>${log}
fi
if test $(pgrep -f "${exec_ruby_daemon}" | wc -l ) -eq 0
then
 echo "[`date`]AD proxy server is not run." >>${log}
 cd $ruby_address
 ${exec_ruby_daemon}&
 echo "[`date`]AD proxy server is running." >>${log}
else
 echo "[`date`]AD proxy server has already running." >>${log}
fi
sleep $sleep_time
done
