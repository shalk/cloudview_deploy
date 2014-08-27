# $Id: sync-clock,v 1.6 2003/09/23 21:39:29 jmates Exp $ 
# 
# Use ntpdate to get rough clock sync with department of Genome Sciences 
# time server. 

OS_VER=`cat /etc/*ease|grep -i ^VERSION|awk '{print $3}'`
#=======custom here========
if [ -f /opt/msp/bin/conf.properties ] ; then
    SERVER=`grep serverIp /opt/msp/bin/conf.properties  | awk -F= '{print $2}'`
else
    SERVER='127.0.0.1'
#=======custom here========
 
# if running from cron (no tty available), sleep a bit to space 
# out update requests to avoid slamming a server at a particular time 
if [[ x$1 != xnodelay ]]
then
    if ! test -t 0; then 
      MYRAND=$RANDOM 
      MYRAND=${MYRAND:=$$} 
     
      if [ $MYRAND -gt 9 ]; then 
        sleep `echo $MYRAND | sed 's/.*\(..\)$/\1/' | sed 's/^0//'` 
      fi 
    fi 
fi
 

if (( OS_VER >= 11 ))
then
    cmd='/usr/sbin/sntp -P no -r ' #$SERVER
    #After sles11 command 'sntp' take the place of 'ntpudate'
else
    cmd='/usr/sbin/ntpdate -su ' #$SERVER 
fi
for svr in $SERVER
do
    $cmd $svr && break;
done

# update hardware clock on Linux (RedHat?) systems 
if [ -f /sbin/hwclock ]; then 
  /sbin/hwclock --systohc 
fi
