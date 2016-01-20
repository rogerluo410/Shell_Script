#!/bin/sh

args=$*  #all arguments [-r -c -a -m -v]
argc=$#  #total number of arguments
exitcode=0

hint=`echo ${args} | grep -i "h"`

if [ -z "$args" ] || [ -n "$hint" ]; then
  echo "Usage: "
  echo "$(basename $0) -r  --构建rspec测试环境"
  echo "$(basename $0) -a  --全量spec测试"
  echo "$(basename $0) -c  --控制器spec测试"
  echo "$(basename $0) -m  --业务实体spec测试"
  exit 11
fi

#Default that the command of `rails generate rspec:install` is executed
rake_test=`echo ${args} | grep -i "r"`
if [ -n "${rake_test}" ]; then
  RAILS_ENV=test rake db:create 
  RAILS_ENV=test rake db:migrate
fi


for (( i = 1; i <= ${argc}; i++ )); do
  arg=`echo ${args} | awk "{print $"${i}"}"`
  if [ "${arg}" == "-c" ]; then
    bundle exec rspec spec/api/   
  fi
  if [ "${arg}" == "-a" ]; then
    bundle exec rspec spec/  
  fi
  if [ "${arg}" == "-m" ]; then
    bundle exec rspec spec/models
  fi
done

exitcode=1
exit $exitcode
