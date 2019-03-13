#!/bin/bash




sed -i 's|^\( *workgroup = \).*|\1'"$workgroup"'|' $file

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
exec "$@"
