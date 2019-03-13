#!/bin/bash

file=/etc/samba/smb.conf
workgroup="${WORKGROUP:-"workgroup"}" 

sed -i 's|^\( *workgroup = \).*|\1'"$workgroup"'|' $file

if [ -f /shares.conf ]; then
  found=0
  for share in $(egrep -o "^\[(.*)\]" /shares.conf|sed 's/\[//;s/\]//'); do
    grep -iq "\[$share\]" $file
    if [ $? -eq 0 ]; then
      found=1
    fi
  done
  if [ $found -eq 0 ]; then
    cat /shares.conf >> $file
  fi
fi

if [ ! -d /data/logs ]; then
  mkdir -p /data/logs
fi

LOGFILE="/data/logs/samba.log"

if [ ! -d /data ]; then
  mkdir -p /data
fi

if [ ! -f $LOGFILE ]; then
  touch $LOGFILE 
  chmod 666 $LOGFILE
fi

exec tail -f $LOGFILE &
exec smbd -F --no-process-group </dev/null
exec "$@"
